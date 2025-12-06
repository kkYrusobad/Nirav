import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets

/*
 * Niruv Bar - Main bar component with workspaces and clock
 */
Item {
  id: root

  property ShellScreen screen: null

  anchors.fill: parent

  // Bar background
  Rectangle {
    id: barBackground
    anchors.fill: parent
    color: Color.mSurface
  }

  // Center Branding (Absolute positioning to avoid shifting)
  Text {
    anchors.centerIn: parent
    text: "kkY - Niruv"
    color: Color.mPrimary
    font.family: Style.fontFamily
    font.pixelSize: Style.fontSizeM
    font.weight: Style.fontWeightSemiBold
    z: 1 // Ensure it's above background
  }

  // Bar content layout
  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: 4
    anchors.rightMargin: 4
    spacing: Style.marginM

    // Left section - Workspaces
    Item {
      Layout.fillHeight: true
      Layout.preferredWidth: workspaceWidget.implicitWidth

      Workspace {
        id: workspaceWidget
        anchors.verticalCenter: parent.verticalCenter
        screen: root.screen
      }
    }

    // Spacer to push right section to the end
    Item {
      Layout.fillWidth: true
    }

    // Right section - Battery and Clock
    Item {
      Layout.fillHeight: true
      Layout.preferredWidth: rightRow.width + Style.marginM

      Row {
        id: rightRow
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.marginM

        // Battery widget
        Battery {
          id: batteryWidget
          anchors.verticalCenter: parent.verticalCenter
          screen: root.screen
        }

        // Clock
        Text {
          id: clockText
          anchors.verticalCenter: parent.verticalCenter
          color: Color.mOnSurface
          font.family: Style.fontFamily
          font.pixelSize: Style.fontSizeM
          font.weight: Style.fontWeightMedium

          text: {
            var now = Time.now;
            var hours = String(now.getHours()).padStart(2, '0');
            var minutes = String(now.getMinutes()).padStart(2, '0');
            return hours + ":" + minutes;
          }
        }
      }
    }
  }
}
