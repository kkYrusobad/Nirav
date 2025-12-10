import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.System

/*
 * Niruv Night Light Widget - Blue light filter toggle
 * Features: 3-state cycle (off → on → forced → off)
 */
Item {
  id: root

  property ShellScreen screen: null

  // Dimensions
  implicitWidth: nightLightRow.width
  implicitHeight: Style.barHeight

  // Only show if wlsunset is available
  visible: NightLightService.available

  // State from NightLightService
  readonly property bool enabled: NightLightService.enabled
  readonly property bool forced: NightLightService.forced

  // Background Pill (only on hover)
  Rectangle {
    anchors.verticalCenter: nightLightRow.verticalCenter
    anchors.left: nightLightRow.left
    anchors.right: nightLightRow.right
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
    id: nightLightRow
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: Style.marginXS

    // Night light icon
    Text {
      id: nightLightIcon
      anchors.verticalCenter: parent.verticalCenter
      text: NightLightService.getIcon()
      color: {
        if (mouseArea.containsMouse) return Color.mOnSurface;
        if (forced) return Color.mOnSurface;  // Orange for forced state visibility
        if (enabled) return Color.mOnSurface; // Yellow for enabled/auto state
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
  }

  // Interaction
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: (mouse) => {
      if (mouse.button === Qt.RightButton) {
        // Right-click: toggle between on/forced (or turn on if off)
        if (!NightLightService.enabled) {
          NightLightService.enabled = true;
          NightLightService.forced = true;
        } else {
          NightLightService.forced = !NightLightService.forced;
        }
        NightLightService.apply();
      } else {
        // Left-click: cycle through states
        NightLightService.toggle();
      }
    }
  }
}
