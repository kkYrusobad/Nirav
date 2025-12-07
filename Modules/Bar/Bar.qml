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

  // Left logo icon with backdrop
  Item {
    id: leftLogoContainer
    anchors.left: parent.left
    anchors.leftMargin: Style.marginM
    anchors.verticalCenter: parent.verticalCenter
    //width: leftLogoCapsule.width
    width: 30
    height: Style.barHeight
    z: 10

    Rectangle {
      id: leftLogoCapsule
      anchors.verticalCenter: parent.verticalCenter
      width: leftLogoText.width + Style.marginS * 4
      height: 20
      radius: height / 2
      color: Color.mSurfaceVariant
    }

    Text {
      id: leftLogoText
      anchors.centerIn: leftLogoCapsule
      text: ""
      color: Color.mOnSurface
      font.family: Style.fontFamily
      font.pixelSize: Style.fontSizeL
    }
  }

  // Right logo icon with backdrop
  Item {
    id: rightLogoContainer
    anchors.right: parent.right
    anchors.rightMargin: Style.marginM
    anchors.verticalCenter: parent.verticalCenter
    //width: rightLogoCapsule.width
    width: 30
    height: Style.barHeight
    z: 10

    Rectangle {
      id: rightLogoCapsule
      anchors.verticalCenter: parent.verticalCenter
      width: rightLogoText.width + Style.marginS * 4
      height: 20
      radius: height / 2
      color: Color.mSurfaceVariant
    }

    Text {
      id: rightLogoText
      anchors.centerIn: rightLogoCapsule
      text: ""
      color: Color.mOnSurface
      font.family: Style.fontFamily
      font.pixelSize: Style.fontSizeL
    }
  }

  // Clock (absolutely centered, click to open launcher)
  MouseArea {
    id: clockArea
    anchors.centerIn: parent
    width: clockTextCenter.width + Style.marginM * 2
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

  // Media widget (anchored to the left of the clock)
  Media {
    id: mediaWidget
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: clockArea.left
    anchors.rightMargin: Style.marginS
    screen: root.screen
    z: 10
  }

  // Visualizer widget (anchored to the right of the clock)
  Visualizer {
    id: visualizerWidget
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: clockArea.right
    anchors.leftMargin: Style.marginS
    screen: root.screen
    z: 10
  }


  // Bar content layout
  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: 50
    anchors.rightMargin: 48
    spacing: Style.marginM

    // Left section - Workspaces and SystemMonitor
    Item {
      Layout.fillHeight: true
      Layout.preferredWidth: leftRow.width

      Row {
        id: leftRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.marginM

        Workspace {
          id: workspaceWidget
          anchors.verticalCenter: parent.verticalCenter
          screen: root.screen
        }

        SystemMonitor {
          anchors.verticalCenter: parent.verticalCenter
          screen: root.screen
        }
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
