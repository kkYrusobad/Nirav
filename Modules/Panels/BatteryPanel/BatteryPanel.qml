import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.Commons
import qs.Services.Hardware
import qs.Services.Networking

/*
 * BatteryPanel - Popup panel with detailed battery information
 * Shows: Battery percentage, time remaining, health, power rate, Bluetooth devices
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
  }

  function close() {
    visible = false;
    PanelState.panelClosed(root);
  }

  // Battery data
  readonly property var battery: UPower.displayDevice
  readonly property bool isReady: battery && battery.ready && battery.percentage !== undefined
  readonly property real percent: isReady ? Math.round(battery.percentage * 100) : 0
  readonly property bool charging: isReady ? battery.state === UPowerDeviceState.Charging : false

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

      // Header with battery icon and percentage
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 60
        radius: Style.radiusM
        color: Color.mPrimary

        RowLayout {
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginM

          Text {
            text: BatteryService.getIcon(root.percent, root.charging, root.isReady)
            color: Color.mOnPrimary
            font.family: Style.fontFamily
            font.pixelSize: 32
          }

          Column {
            Layout.fillWidth: true
            spacing: -2

            Text {
              text: root.isReady ? root.percent + "%" : "—"
              color: Color.mOnPrimary
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeXXL
              font.weight: Style.fontWeightBold
            }

            Text {
              text: root.charging ? "Charging" : "Discharging"
              color: Qt.alpha(Color.mOnPrimary, 0.8)
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeS
            }
          }
        }
      }

      // Battery details card
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: detailsColumn.implicitHeight + Style.marginM * 2
        radius: Style.radiusM
        color: Color.mSurfaceVariant
        border.color: Color.mOutline
        border.width: Style.borderS

        ColumnLayout {
          id: detailsColumn
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginS

          // Time remaining/to full
          RowLayout {
            Layout.fillWidth: true
            visible: root.isReady && (root.battery.timeToEmpty > 0 || root.battery.timeToFull > 0)

            Text {
              text: "󰥔"
              color: Color.mPrimary
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeL
            }

            Text {
              text: root.charging ? "Time to full" : "Time remaining"
              color: Color.mOnSurfaceVariant
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeS
              Layout.fillWidth: true
            }

            Text {
              text: {
                if (root.charging && root.battery.timeToFull > 0) {
                  return Time.formatVagueHumanReadableDuration(root.battery.timeToFull);
                }
                if (!root.charging && root.battery.timeToEmpty > 0) {
                  return Time.formatVagueHumanReadableDuration(root.battery.timeToEmpty);
                }
                return "—";
              }
              color: Color.mOnSurface
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeS
              font.weight: Style.fontWeightSemiBold
            }
          }

          // Power rate
          RowLayout {
            Layout.fillWidth: true
            visible: root.isReady && root.battery.changeRate !== undefined && root.battery.changeRate !== 0

            Text {
              text: "󱐋"
              color: Color.mPrimary
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeL
            }

            Text {
              text: "Power"
              color: Color.mOnSurfaceVariant
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeS
              Layout.fillWidth: true
            }

            Text {
              text: root.battery.changeRate ? Math.abs(root.battery.changeRate).toFixed(1) + " W" : "—"
              color: Color.mOnSurface
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeS
              font.weight: Style.fontWeightSemiBold
            }
          }

          // Health
          RowLayout {
            Layout.fillWidth: true
            visible: root.isReady && root.battery.healthPercentage !== undefined && root.battery.healthPercentage > 0

            Text {
              text: "󰛨"
              color: Color.mPrimary
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeL
            }

            Text {
              text: "Health"
              color: Color.mOnSurfaceVariant
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeS
              Layout.fillWidth: true
            }

            Text {
              text: root.battery.healthPercentage ? Math.round(root.battery.healthPercentage) + "%" : "—"
              color: Color.mOnSurface
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeS
              font.weight: Style.fontWeightSemiBold
            }
          }
        }
      }

      // Bluetooth devices card
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: btColumn.implicitHeight + Style.marginM * 2
        radius: Style.radiusM
        color: Color.mSurfaceVariant
        border.color: Color.mOutline
        border.width: Style.borderS
        visible: BluetoothService.allDevicesWithBattery && BluetoothService.allDevicesWithBattery.length > 0

        ColumnLayout {
          id: btColumn
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginS

          // Header
          RowLayout {
            Layout.fillWidth: true

            Text {
              text: "󰂯"
              color: Color.mPrimary
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeL
            }

            Text {
              text: "Bluetooth Devices"
              color: Color.mOnSurface
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeS
              font.weight: Style.fontWeightSemiBold
              Layout.fillWidth: true
            }
          }

          // Device list
          Repeater {
            model: BluetoothService.allDevicesWithBattery || []

            RowLayout {
              Layout.fillWidth: true

              Text {
                text: BluetoothService.getBattery(modelData)
                color: Color.mOnSurfaceVariant
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeS
                Layout.fillWidth: true
              }
            }
          }
        }
      }

      // Open battop button
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36
        radius: Style.radiusS
        color: battopMouseArea.containsMouse ? Qt.alpha(Color.mPrimary, 0.2) : Color.mSurfaceVariant
        border.color: Color.mOutline
        border.width: Style.borderS

        RowLayout {
          anchors.centerIn: parent
          spacing: Style.marginS

          Text {
            text: "󰄛"
            color: Color.mPrimary
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeL
          }

          Text {
            text: "Open Battery Monitor"
            color: Color.mOnSurface
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeS
            font.weight: Style.fontWeightMedium
          }
        }

        MouseArea {
          id: battopMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.close();
            battopProcess.running = true;
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

  // Process to open battop
  Process {
    id: battopProcess
    command: ["/home/kky/garbage/noctaliaChange/oNIgiRI/bin/niri-launch-or-focus-tui", "--floating", "--center", "--name", "Battop", "battop"]
  }

  // Close on Escape key
  Shortcut {
    sequence: "Escape"
    enabled: root.visible
    onActivated: root.close()
  }
}
