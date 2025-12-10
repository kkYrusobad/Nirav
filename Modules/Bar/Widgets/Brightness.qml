import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.Hardware
import qs.Modules.Panels.BrightnessPanel

/*
 * Niruv Brightness Widget - Screen brightness control in the bar
 * Features: Icon, percentage on hover, scroll wheel control, click to open panel
 */
Item {
  id: root

  property ShellScreen screen: null

  // Brightness panel
  BrightnessPanel {
    id: brightnessPanel
    anchorItem: root
    screen: root.screen
  }

  // Dimensions
  implicitWidth: brightnessRow.width
  implicitHeight: Style.barHeight

  // Only show if brightness control is available
  visible: BrightnessService.available

  // Brightness state from BrightnessService
  readonly property real brightness: BrightnessService.brightness
  readonly property string brightnessPercent: Math.round(brightness * 100) + "%"

  // Expansion state
  property bool isExpanded: false

  // Background Pill (appears on hover)
  Rectangle {
    anchors.verticalCenter: brightnessRow.verticalCenter
    anchors.left: brightnessRow.left
    anchors.right: brightnessRow.right
    anchors.margins: -Style.marginS
    height: 18
    color: mouseArea.containsMouse ? Color.mBlue : Color.transparent
    radius: height / 2

    Behavior on color {
      ColorAnimation {
        duration: Style.animationFast
        easing.type: Easing.InOutQuad
      }
    }
  }

  Row {
    id: brightnessRow
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: Style.marginXS
    layoutDirection: Qt.RightToLeft  // Icon stays right, text expands left

    // Brightness icon
    Text {
      id: brightnessIcon
      anchors.verticalCenter: parent.verticalCenter
      text: BrightnessService.getIcon()
      color: mouseArea.containsMouse ? Color.mOnPrimary : Color.mOnSurface
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

    // Percentage text container (expands to the left on hover)
    Item {
      id: percentContainer
      height: parent.height
      width: isExpanded ? percentText.implicitWidth + Style.marginXS : 0
      clip: true

      Behavior on width {
        NumberAnimation {
          duration: Style.animationFast
          easing.type: Easing.OutCubic
        }
      }

      Text {
        id: percentText
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        text: brightnessPercent
        color: mouseArea.containsMouse ? Color.mOnPrimary : Color.mOnSurface
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

  // Wheel accumulator for smooth scrolling
  property int wheelAccumulator: 0

  // Interaction
  MouseArea {
    id: mouseArea
    anchors.fill: parent
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
        // Right-click: set to 100%
        BrightnessService.setBrightness(1.0);
      } else {
        // Left-click: open brightness panel
        brightnessPanel.toggle();
      }
    }

    onWheel: (wheel) => {
      wheelAccumulator += wheel.angleDelta.y;
      if (wheelAccumulator >= 120) {
        wheelAccumulator = 0;
        BrightnessService.increaseBrightness();
      } else if (wheelAccumulator <= -120) {
        wheelAccumulator = 0;
        BrightnessService.decreaseBrightness();
      }
    }
  }

  // Delay before expanding percentage
  Timer {
    id: expandTimer
    interval: 500
    repeat: false
    onTriggered: isExpanded = true
  }
}
