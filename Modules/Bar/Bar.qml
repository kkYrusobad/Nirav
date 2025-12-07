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

  // Center Branding (Click to open launcher)
  MouseArea {
    anchors.centerIn: parent
    width: brandingText.width + Style.marginM * 2
    height: parent.height
    cursorShape: Qt.PointingHandCursor
    z: 10

    onClicked: {
      // Access launcher through shellRoot
      if (typeof shellRoot !== 'undefined' && shellRoot.launcher) {
        shellRoot.launcher.toggle();
      }
    }

    Text {
      id: clockTextCenter
      anchors.centerIn: parent
      color: Color.mOnSurface
      font.family: Style.fontFamily
      font.pixelSize: Style.fontSizeM
      font.weight: Style.fontWeightSemiBold

      text: {
        var now = Time.now;
        var date = now.toLocaleDateString(Qt.locale(), "ddd, MMM d");
        var time = now.toLocaleTimeString(Qt.locale(), "hh:mm");
        return date + "  " + time;
      }
    }
  }


  // Bar content layout
  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: 6
    anchors.rightMargin: 6
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

        // WiFi widget
        WiFi {
          anchors.verticalCenter: parent.verticalCenter
          screen: root.screen
        }

        // Bluetooth widget
        Bluetooth {
          anchors.verticalCenter: parent.verticalCenter
          screen: root.screen
        }

        // Screen Recorder
        ScreenRecorder {
          anchors.verticalCenter: parent.verticalCenter
        }

        // Battery widget
        Battery {
          id: batteryWidget
          anchors.verticalCenter: parent.verticalCenter
          screen: root.screen
        }


      }
    }
  }
}
