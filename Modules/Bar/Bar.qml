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

    // Center section - Branding
    Item {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter

      Text {
        anchors.centerIn: parent
        text: "kkY - Niruv"
        color: Color.mPrimary
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeM
        font.weight: Style.fontWeightSemiBold
      }
    }

    // Right section - Clock
    Item {
      Layout.fillHeight: true
      Layout.preferredWidth: clockText.implicitWidth + Style.marginM

      Text {
        id: clockText
        anchors.right: parent.right
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
