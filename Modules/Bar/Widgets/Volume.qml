import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Commons
import qs.Services.Media
import qs.Modules.Panels.VolumePanel

/*
 * Niruv Volume Widget - Audio volume control in the bar
 * Features: Icon, percentage on hover, scroll wheel control, click to open panel
 */
Item {
  id: root

  property ShellScreen screen: null

  // Volume panel
  VolumePanel {
    id: volumePanel
    anchorItem: root
    screen: root.screen
  }

  // Dimensions
  implicitWidth: volumeRow.width
  implicitHeight: Style.barHeight

  // Volume state from AudioService
  readonly property real volume: AudioService.volume
  readonly property bool muted: AudioService.muted
  readonly property string volumePercent: Math.round(volume * 100) + "%"

  // Expansion state
  property bool isExpanded: false

  // Background Pill (appears on hover)
  Rectangle {
    anchors.verticalCenter: volumeRow.verticalCenter
    anchors.left: volumeRow.left
    anchors.right: volumeRow.right
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
    id: volumeRow
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: Style.marginXS
    layoutDirection: Qt.RightToLeft  // Icon stays right, text expands left

    // Volume icon
    Text {
      id: volumeIcon
      anchors.verticalCenter: parent.verticalCenter
      text: AudioService.getIcon()
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
        text: volumePercent
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
        // Right-click: open external mixer
        mixerProcess.running = true;
      } else {
        // Left-click: open volume panel
        volumePanel.toggle();
      }
    }

    onWheel: (wheel) => {
      wheelAccumulator += wheel.angleDelta.y;
      if (wheelAccumulator >= 120) {
        wheelAccumulator = 0;
        AudioService.increaseVolume();
      } else if (wheelAccumulator <= -120) {
        wheelAccumulator = 0;
        AudioService.decreaseVolume();
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

  // Process to open external mixer
  Process {
    id: mixerProcess
    command: ["sh", "-c", "pwvucontrol || pavucontrol || alsamixer"]
    running: false
  }
}
