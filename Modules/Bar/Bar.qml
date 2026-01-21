import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Bar.Widgets
import qs.Modules.Panels.ClockPanel
import qs.Modules.Panels.NetworkPanel

/*
 * Niruv Bar - Main bar component with workspaces and clock
 */
Item {
  id: root

  property ShellScreen screen: null

  anchors.fill: parent

  // Bar background (Gruvbox Material Dark)
  Rectangle {
    id: barBackground
    anchors.fill: parent
    // color: Color.mSurface
    color: "transparent"
  }

  // Left logo icon with backdrop
  Item {
    id: leftLogoContainer
    anchors.left: parent.left
    anchors.leftMargin: Style.marginM - 6
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

  // Clock Panel (popup with calendar and timer)
  ClockPanel {
    id: clockPanel
    anchorItem: clockArea
    screen: root.screen
  }

  // Shared Network Panel (for WiFi and Bluetooth widgets)
  NetworkPanel {
    id: networkPanel
    anchorItem: wifiWidget
    screen: root.screen
  }

  // Clock (absolutely centered, click to open ClockPanel)
  MouseArea {
    id: clockArea
    anchors.centerIn: parent
    width: clockContent.width + Style.marginM * 2
    height: parent.height
    cursorShape: Qt.PointingHandCursor
    z: 10

    onClicked: {
      clockPanel.toggle();
    }

    Row {
      id: clockContent
      anchors.centerIn: parent
      spacing: Style.marginS

      // Timer indicator (pulsing dot when timer is running)
      Rectangle {
        visible: Time.timerRunning
        width: 6
        height: 6
        radius: 3
        color: Color.mPrimary
        anchors.verticalCenter: parent.verticalCenter

        SequentialAnimation on opacity {
          running: Time.timerRunning
          loops: Animation.Infinite
          NumberAnimation { to: 0.3; duration: 500 }
          NumberAnimation { to: 1.0; duration: 500 }
        }
      }

      Text {
        id: clockTextCenter
        anchors.verticalCenter: parent.verticalCenter
        color: Time.timerRunning ? Color.mPrimary : Color.mOnSurface
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeM
        font.weight: Style.fontWeightSemiBold

        text: {
          // Show timer countdown when running
          if (Time.timerRunning) {
            if (Time.timerStopwatchMode) {
              return "󱎫 " + Time.formatTimerDisplay(Time.timerElapsedSeconds, false);
            } else {
              return "󱎫 " + Time.formatTimerDisplay(Time.timerRemainingSeconds, false);
            }
          }
          // Normal clock display
          var now = Time.now;
          var date = now.toLocaleDateString(Qt.locale(), "ddd, MMM d");
          var time = now.toLocaleTimeString(Qt.locale(), "hh:mm");
          return date + "  " + time;
        }
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
    anchors.leftMargin: 42
    anchors.rightMargin: 48
    spacing: Style.marginM

    // Left section - Workspaces, SystemMonitor, and ActiveWindow
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

        ActiveWindow {
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

        // System Tray (first - system apps)
        Tray {
          anchors.verticalCenter: parent.verticalCenter 
          screen: root.screen
        }

        // Wallpaper widget
        Wallpaper {
          anchors.verticalCenter: parent.verticalCenter
          screen: root.screen
        }

        // WiFi widget
        WiFi {
          id: wifiWidget
          anchors.verticalCenter: parent.verticalCenter
          screen: root.screen
          networkPanel: networkPanel
        }

        // Bluetooth widget
        Bluetooth {
          anchors.verticalCenter: parent.verticalCenter
          screen: root.screen
          networkPanel: networkPanel
        }

        // Screen Recorder
        ScreenRecorder {
          anchors.verticalCenter: parent.verticalCenter
        }

        // Volume widget
        Volume {
          anchors.verticalCenter: parent.verticalCenter
          screen: root.screen
        }

        // Brightness widget
        Brightness {
          anchors.verticalCenter: parent.verticalCenter
          screen: root.screen
        }

        // Night Light widget
        NightLight {
          anchors.verticalCenter: parent.verticalCenter
          screen: root.screen
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
