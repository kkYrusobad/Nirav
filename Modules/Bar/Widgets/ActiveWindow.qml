import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.Commons

/*
 * Niruv ActiveWindow Widget - Shows focused window title and icon
 * Uses Niri IPC to get focused window information
 */
Item {
  id: root

  property ShellScreen screen: null
  
  // Window info properties
  property string windowTitle: ""
  property string windowAppId: ""
  property string windowIcon: ""
  property bool hasWindow: windowTitle !== ""

  // Dimensions - add extra left margin for spacing from SystemMonitor
  implicitWidth: hasWindow ? contentRow.width + Style.marginS * 2 + Style.marginM : 0
  implicitHeight: Style.barHeight
  visible: hasWindow

  // Poll for focused window info
  Timer {
    id: pollTimer
    interval: 500
    running: true
    repeat: true
    onTriggered: focusedWindowProcess.running = true
  }

  // Get focused window info via niri msg
  Process {
    id: focusedWindowProcess
    command: ["niri", "msg", "-j", "focused-window"]
    
    stdout: SplitParser {
      onRead: data => {
        try {
          const windowData = JSON.parse(data.trim());
          if (windowData) {
            root.windowTitle = windowData.title || "";
            root.windowAppId = windowData.app_id || "";
            // Use app_id as icon name fallback
            root.windowIcon = windowData.app_id || "application-x-executable";
          } else {
            root.windowTitle = "";
            root.windowAppId = "";
            root.windowIcon = "";
          }
        } catch (e) {
          // No window focused or parse error
          root.windowTitle = "";
          root.windowAppId = "";
          root.windowIcon = "";
        }
      }
    }
  }

  // Initial fetch
  Component.onCompleted: {
    focusedWindowProcess.running = true;
  }

  // Capsule background
  Rectangle {
    id: capsule
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    width: contentRow.width + Style.marginS * 4
    height: 20
    radius: height / 2
    color: mouseArea.containsMouse ? Color.mPrimary : Color.mSurfaceVariant
    visible: hasWindow

    Behavior on color {
      ColorAnimation {
        duration: Style.animationFast
        easing.type: Easing.InOutQuad
      }
    }

    Behavior on width {
      NumberAnimation {
        duration: Style.animationFast
        easing.type: Easing.OutCubic
      }
    }
  }

  // Content row
  Row {
    id: contentRow
    anchors.centerIn: parent
    spacing: Style.marginXS
    visible: hasWindow

    // Window icon
    IconImage {
      id: windowIconImage
      anchors.verticalCenter: parent.verticalCenter
      width: 14
      height: 14
      source: hasWindow ? Quickshell.iconPath(root.windowIcon, "application-x-executable") : ""
      asynchronous: true
    }

    // Window title (truncated)
    Text {
      id: titleText
      anchors.verticalCenter: parent.verticalCenter
      text: {
        const maxLen = 30;
        if (root.windowTitle.length > maxLen) {
          return root.windowTitle.substring(0, maxLen) + "…";
        }
        return root.windowTitle;
      }
      color: mouseArea.containsMouse ? Color.mOnPrimary : Color.mOnSurface
      font.family: Style.fontFamily
      font.pixelSize: Style.fontSizeS
      font.weight: Style.fontWeightMedium

      Behavior on color {
        ColorAnimation { duration: Style.animationFast }
      }
    }
  }

  // Mouse interaction (future: click to focus, right-click for options)
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    visible: hasWindow
  }
}
