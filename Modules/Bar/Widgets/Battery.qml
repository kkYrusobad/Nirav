import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.Commons
import qs.Services.Hardware
import qs.Services.Networking
import qs.Services.UI

/*
 * Niruv Battery Widget v2 - Enhanced battery status display
 * Features: Multi-device, Bluetooth, Tooltip, Low battery alerts, Click action
 */
Item {
  id: root

  property ShellScreen screen: null

  // Optional: specify a specific device by native path
  property string deviceNativePath: ""

  // Warning threshold for low battery notification
  property real warningThreshold: 20

  // --- Device Selection ---
  function findBatteryDevice(nativePath) {
    if (!nativePath || !UPower.devices) {
      return UPower.displayDevice;
    }
    var devices = UPower.devices.values || [];
    for (var i = 0; i < devices.length; i++) {
      var device = devices[i];
      if (device && device.nativePath === nativePath &&
          device.type !== UPowerDeviceType.LinePower &&
          device.percentage !== undefined) {
        return device;
      }
    }
    return UPower.displayDevice;
  }

  readonly property var battery: findBatteryDevice(deviceNativePath)

  // --- Initialization ---
  property bool initComplete: false
  Timer {
    interval: 500
    running: true
    onTriggered: root.initComplete = true
  }

  // --- Battery State ---
  readonly property bool isReady: initComplete && battery && battery.ready && battery.percentage !== undefined
  readonly property real percent: isReady ? Math.round(battery.percentage * 100) : 0
  readonly property bool charging: isReady ? battery.state === UPowerDeviceState.Charging : false
  readonly property bool isLowBattery: isReady && !charging && percent <= warningThreshold

  // --- Low Battery Notification ---
  property bool hasNotifiedLowBattery: false

  function maybeNotify(currentPercent, isCharging) {
    if (!isCharging && !hasNotifiedLowBattery && currentPercent <= warningThreshold) {
      hasNotifiedLowBattery = true;
      ToastService.showWarning("Low Battery", `Battery at ${Math.round(currentPercent)}%. Plug in your charger.`);
    } else if (hasNotifiedLowBattery && (isCharging || currentPercent > warningThreshold + 5)) {
      hasNotifiedLowBattery = false;
    }
  }

  Connections {
    target: battery
    function onPercentageChanged() {
      if (battery) {
        maybeNotify(battery.percentage * 100, battery.state === UPowerDeviceState.Charging);
      }
    }
    function onStateChanged() {
      if (battery) {
        if (battery.state === UPowerDeviceState.Charging) {
          hasNotifiedLowBattery = false;
        }
        maybeNotify(battery.percentage * 100, battery.state === UPowerDeviceState.Charging);
      }
    }
  }

  // --- Tooltip Text ---
  readonly property string tooltipText: {
    let lines = [];

    if (!isReady) {
      return "No battery detected";
    }

    // Main battery info
    lines.push(`Battery: ${percent}%`);

    // Time remaining/to full
    if (battery.timeToEmpty > 0) {
      lines.push(`Time left: ${Time.formatVagueHumanReadableDuration(battery.timeToEmpty)}`);
    }
    if (battery.timeToFull > 0) {
      lines.push(`Full in: ${Time.formatVagueHumanReadableDuration(battery.timeToFull)}`);
    }

    // Charge rate
    if (battery.changeRate !== undefined && battery.changeRate !== 0) {
      const rate = Math.abs(battery.changeRate);
      lines.push(`Rate: ${rate.toFixed(1)}W`);
    }

    // Health
    if (battery.healthPercentage !== undefined && battery.healthPercentage > 0) {
      lines.push(`Health: ${Math.round(battery.healthPercentage)}%`);
    }

    // Bluetooth devices with battery
    var btDevices = BluetoothService.allDevicesWithBattery;
    if (btDevices && btDevices.length > 0) {
      lines.push(""); // separator
      lines.push("Bluetooth:");
      for (var i = 0; i < btDevices.length; i++) {
        lines.push(`  ${BluetoothService.getBattery(btDevices[i])}`);
      }
    }

    return lines.join("\n");
  }

  // --- Dimensions ---
  implicitWidth: batteryRow.width
  implicitHeight: Style.barHeight

  // --- UI ---
  
  // Background Pill
  Rectangle {
    anchors.verticalCenter: batteryRow.verticalCenter
    anchors.left: batteryRow.left
    anchors.right: batteryRow.right
    anchors.margins: -Style.marginS
    height: 18 // Matching Workspace active indicator height
    color: mouseArea.containsMouse ? Color.mBlue: Color.transparent
    radius: height / 2

    Behavior on color {
      ColorAnimation {
        duration: Style.animationFast
        easing.type: Easing.InOutQuad
      }
    }
  }

  Row {
    id: batteryRow
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: Style.marginXS

    // Battery icon
    Text {
      id: batteryIcon
      anchors.verticalCenter: parent.verticalCenter
      text: BatteryService.getIcon(percent, charging, isReady)
      color: {
        if (!initComplete) return Color.transparent;
        if (mouseArea.containsMouse) return Color.mOnPrimary;
        if (charging) return Color.mPrimary;
        if (isLowBattery) return Color.mError;
        return Color.mOnSurface;
      }
      font.family: Style.fontFamily
      font.pixelSize: Style.fontSizeL
      font.weight: Font.Normal

      Behavior on color {
        ColorAnimation {
          duration: Style.animationFast
          easing.type: Easing.InOutCubic
        }
      }
    }

    // Percentage text container (expands on hover with delay)
    Item {
      id: percentContainer
      height: parent.height
      // Show if expanded OR if tooltip is open
      width: (isExpanded || tooltipPopup.visible) ? percentText.implicitWidth + Style.marginXS : 0
      clip: true

      Behavior on width {
        NumberAnimation {
          duration: Style.animationNormal
          easing.type: Easing.OutCubic
        }
      }

      Text {
        id: percentText
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        text: isReady ? percent + "%" : "—"
        color: {
          if (!initComplete) return Color.transparent;
          if (mouseArea.containsMouse) return Color.mOnPrimary;
          if (charging) return Color.mPrimary;
          if (isLowBattery) return Color.mError;
          return Color.mOnSurface;
        }
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeM
        font.weight: Style.fontWeightMedium

        Behavior on color {
          ColorAnimation {
            duration: Style.animationFast
            easing.type: Easing.InOutCubic
          }
        }
      }
    }
  }

  // --- Process Execution ---
  Process {
    id: battopProcess
    command: ["/home/kky/garbage/noctaliaChange/oNIgiRI/bin/niri-launch-or-focus-tui", "--floating", "--center", "--name", "Battop", "battop"]
  }

  // --- Interaction ---
  property bool isExpanded: false

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    //anchors.leftMargin: -Style.marginL
    //anchors.rightMargin: -Style.marginL
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onEntered: expandTimer.start()
    onExited: {
      expandTimer.stop()
      isExpanded = false
    }

    onClicked: (mouse) => {
      if (mouse.button === Qt.RightButton) {
        battopProcess.running = true;
      } else {
        // Toggle tooltip on click
        tooltipPopup.visible = !tooltipPopup.visible;
        if (tooltipPopup.visible) {
          tooltipTimeout.restart();
        }
      }
    }
  }

  // Delay before expanding percentage
  Timer {
    id: expandTimer
    interval: 500 // 500ms delay (user preference)
    repeat: false
    onTriggered: isExpanded = true
  }

  // Tooltip timeout
  Timer {
    id: tooltipTimeout
    interval: 2000
    repeat: false
    onTriggered: tooltipPopup.visible = false
  }

  // Tooltip popup window
  PopupWindow {
    id: tooltipPopup
    visible: false
    
    onVisibleChanged: {
      if (!visible) tooltipTimeout.stop();
    }

    anchor.item: root
    anchor.rect.x: (root.width - implicitWidth) / 2
    anchor.rect.y: root.height + Style.marginS

    implicitWidth: tooltipContent.width
    implicitHeight: tooltipContent.height

    color: "transparent"

    Rectangle {
      id: tooltipContent
      width: tooltipLabel.implicitWidth + Style.marginM * 2
      height: tooltipLabel.implicitHeight + Style.marginM

      color: Color.mSurface
      border.color: Color.mOutline
      border.width: 1
      radius: Style.radiusXS

      // Animation properties
      //scale: tooltipPopup.visible ? 1.0 : 0.85
      //opacity: tooltipPopup.visible ? 1.0 : 0.0
      //transformOrigin: Item.Top
//
      //Behavior on scale {
      //  NumberAnimation {
      //    duration: Style.animationFast
      //    easing.type: Easing.OutBack
      //    easing.overshoot: 1.2
      //  }
      //}
//
      //Behavior on opacity {
      //  NumberAnimation {
      //    duration: Style.animationFast
      //    easing.type: Easing.OutCubic
      //  }
      //}

      Text {
        id: tooltipLabel
        anchors.centerIn: parent
        text: root.tooltipText
        color: Color.mOnSurface
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeS
      }
    }
  }
}
