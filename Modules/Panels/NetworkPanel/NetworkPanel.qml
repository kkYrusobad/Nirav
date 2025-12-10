import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons

/*
 * NetworkPanel - Combined WiFi and Bluetooth popup panel
 * Shows: WiFi status + toggle, Bluetooth status + toggle, TUI launcher buttons
 */
PopupWindow {
  id: root

  property Item anchorItem: null
  property ShellScreen screen: null

  visible: false
  color: "transparent"

  // Position below the anchor item
  anchor.item: anchorItem
  anchor.rect.x: anchorItem ? (anchorItem.width - panelWidth) / 2 : 0
  anchor.rect.y: anchorItem ? anchorItem.height + Style.marginS : 0

  property real panelWidth: 280

  implicitWidth: panelContent.width
  implicitHeight: panelContent.height

  function toggle() {
    if (visible) {
      close();
    } else {
      open();
    }
  }

  function open() {
    PanelState.openPanel(root);
    visible = true;
    // Refresh status when opening
    wifiStatusProcess.running = true;
    btStatusProcess.running = true;
  }

  function close() {
    visible = false;
    PanelState.panelClosed(root);
  }

  // === WiFi State ===
  property string wifiState: "disconnected"  // "connected", "disconnected", "off"
  property string wifiSsid: ""
  readonly property bool wifiConnected: wifiState === "connected" && wifiSsid !== ""
  readonly property bool wifiOff: wifiState === "off"

  // === Bluetooth State ===
  property string btState: "on"  // "connected", "on", "off"
  property string btDevice: ""
  readonly property bool btConnected: btState === "connected" && btDevice !== ""
  readonly property bool btOff: btState === "off"

  // === WiFi Status Polling ===
  Process {
    id: wifiStatusProcess
    command: ["sh", "-c", "nmcli -t -f SSID,ACTIVE device wifi list 2>/dev/null | grep ':yes$' | head -1; nmcli radio wifi"]
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n");
        const radioState = lines[lines.length - 1];
        if (radioState === "disabled") {
          root.wifiState = "off";
          root.wifiSsid = "";
        } else {
          let connected = false;
          for (let i = 0; i < lines.length - 1; i++) {
            const line = lines[i];
            if (line && line.endsWith(":yes")) {
              root.wifiSsid = line.slice(0, -4);
              root.wifiState = "connected";
              connected = true;
              break;
            }
          }
          if (!connected) {
            root.wifiState = "disconnected";
            root.wifiSsid = "";
          }
        }
      }
    }
  }

  // === Bluetooth Status Polling ===
  Process {
    id: btStatusProcess
    command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo 'on' || echo 'off'; bluetoothctl devices Connected 2>/dev/null | head -1"]
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n");
        const powerState = lines[0];
        if (powerState === "off") {
          root.btState = "off";
          root.btDevice = "";
        } else {
          if (lines.length > 1 && lines[1] && lines[1].startsWith("Device ")) {
            const parts = lines[1].split(" ");
            if (parts.length >= 3) {
              root.btDevice = parts.slice(2).join(" ");
              root.btState = "connected";
            } else {
              root.btState = "on";
              root.btDevice = "";
            }
          } else {
            root.btState = "on";
            root.btDevice = "";
          }
        }
      }
    }
  }

  // === Toggle Processes ===
  Process {
    id: wifiToggleProcess
    property bool targetState: true
    command: ["nmcli", "radio", "wifi", targetState ? "on" : "off"]
    onExited: wifiStatusProcess.running = true
  }

  Process {
    id: btToggleProcess
    property bool targetState: true
    command: ["bluetoothctl", "power", targetState ? "on" : "off"]
    onExited: btStatusProcess.running = true
  }

  // === TUI Launch Processes ===
  Process {
    id: wifiTuiProcess
    command: ["sh", "-c", "rfkill unblock wifi; /home/kky/garbage/noctaliaChange/oNIgiRI/bin/niri-launch-or-focus-tui --floating --center --name WiFi impala"]
  }

  Process {
    id: btTuiProcess
    command: ["sh", "-c", "rfkill unblock bluetooth; /home/kky/garbage/noctaliaChange/oNIgiRI/bin/niri-launch-or-focus-tui --floating --center --name Bluetooth bluetui"]
  }

  // Panel background
  Rectangle {
    id: panelContent
    width: root.panelWidth
    height: contentColumn.implicitHeight + Style.marginL * 2
    radius: Style.radiusL
    color: Color.mSurface
    border.color: Color.mOutline
    border.width: Style.borderS

    // Shadow effect
    Rectangle {
      anchors.fill: parent
      anchors.margins: -2
      z: -1
      radius: parent.radius + 2
      color: Qt.alpha(Color.mShadow, 0.3)
    }

    ColumnLayout {
      id: contentColumn
      anchors.fill: parent
      anchors.margins: Style.marginL
      spacing: Style.marginM

      // === WiFi Section ===
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: wifiColumn.implicitHeight + Style.marginM * 2
        radius: Style.radiusM
        color: Color.mSurfaceVariant
        border.color: Color.mOutline
        border.width: Style.borderS

        ColumnLayout {
          id: wifiColumn
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginS

          // WiFi header row
          RowLayout {
            Layout.fillWidth: true

            Text {
              text: root.wifiOff ? "󰤭" : (root.wifiConnected ? "󰤨" : "󰤭")
              color: root.wifiOff ? Color.mOnSurfaceVariant : Color.mBlue
              font.family: Style.fontFamily
              font.pixelSize: 18
            }

            Column {
              Layout.fillWidth: true
              spacing: -2

              Text {
                text: "WiFi"
                color: Color.mOnSurface
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeM
                font.weight: Style.fontWeightSemiBold
              }

              Text {
                text: {
                  if (root.wifiOff) return "Off";
                  if (root.wifiConnected) return root.wifiSsid;
                  return "Not connected";
                }
                color: Color.mOnSurfaceVariant
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeS
              }
            }

            // Toggle button
            Rectangle {
              Layout.preferredWidth: 44
              Layout.preferredHeight: 24
              radius: 12
              color: root.wifiOff ? Color.mOutline : Color.mBlue

              Rectangle {
                x: root.wifiOff ? 2 : parent.width - width - 2
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 20
                radius: 10
                color: Color.mSurface

                Behavior on x {
                  NumberAnimation { duration: Style.animationFast }
                }
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  wifiToggleProcess.targetState = root.wifiOff;
                  wifiToggleProcess.running = true;
                }
              }
            }
          }

          // Open WiFi settings button
          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            radius: Style.radiusS
            color: wifiSettingsMouseArea.containsMouse ? Qt.alpha(Color.mBlue, 0.2) : "transparent"
            border.color: Color.mOutline
            border.width: Style.borderS

            RowLayout {
              anchors.centerIn: parent
              spacing: Style.marginS

              Text {
                text: "󰛳"
                color: Color.mBlue
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeM
              }

              Text {
                text: "WiFi Settings"
                color: Color.mOnSurface
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeS
                font.weight: Style.fontWeightMedium
              }
            }

            MouseArea {
              id: wifiSettingsMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.close();
                wifiTuiProcess.running = true;
              }
            }
          }
        }
      }

      // === Bluetooth Section ===
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: btColumn.implicitHeight + Style.marginM * 2
        radius: Style.radiusM
        color: Color.mSurfaceVariant
        border.color: Color.mOutline
        border.width: Style.borderS

        ColumnLayout {
          id: btColumn
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginS

          // Bluetooth header row
          RowLayout {
            Layout.fillWidth: true

            Text {
              text: root.btOff ? "" : (root.btConnected ? "󰂳" : "")
              color: root.btOff ? Color.mOnSurfaceVariant : Color.mBlue
              font.family: Style.fontFamily
              font.pixelSize: 18
            }

            Column {
              Layout.fillWidth: true
              spacing: -2

              Text {
                text: "Bluetooth"
                color: Color.mOnSurface
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeM
                font.weight: Style.fontWeightSemiBold
              }

              Text {
                text: {
                  if (root.btOff) return "Off";
                  if (root.btConnected) return root.btDevice;
                  return "Not connected";
                }
                color: Color.mOnSurfaceVariant
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeS
              }
            }

            // Toggle button
            Rectangle {
              Layout.preferredWidth: 44
              Layout.preferredHeight: 24
              radius: 12
              color: root.btOff ? Color.mOutline : Color.mBlue

              Rectangle {
                x: root.btOff ? 2 : parent.width - width - 2
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 20
                radius: 10
                color: Color.mSurface

                Behavior on x {
                  NumberAnimation { duration: Style.animationFast }
                }
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  btToggleProcess.targetState = root.btOff;
                  btToggleProcess.running = true;
                }
              }
            }
          }

          // Open Bluetooth settings button
          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            radius: Style.radiusS
            color: btSettingsMouseArea.containsMouse ? Qt.alpha(Color.mBlue, 0.2) : "transparent"
            border.color: Color.mOutline
            border.width: Style.borderS

            RowLayout {
              anchors.centerIn: parent
              spacing: Style.marginS

              Text {
                text: "󰀂"
                color: Color.mBlue
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeM
              }

              Text {
                text: "Bluetooth Settings"
                color: Color.mOnSurface
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeS
                font.weight: Style.fontWeightMedium
              }
            }

            MouseArea {
              id: btSettingsMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.close();
                btTuiProcess.running = true;
              }
            }
          }
        }
      }
    }

    // Animation
    scale: root.visible ? 1.0 : 0.95
    opacity: root.visible ? 1.0 : 0.0
    transformOrigin: Item.Top

    Behavior on scale {
      NumberAnimation {
        duration: Style.animationFast
        easing.type: Easing.OutCubic
      }
    }

    Behavior on opacity {
      NumberAnimation {
        duration: Style.animationFast
        easing.type: Easing.OutCubic
      }
    }
  }

  // Close on Escape key
  Shortcut {
    sequence: "Escape"
    enabled: root.visible
    onActivated: root.close()
  }
}
