import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI

/*
 * Niruv ScreenRecorder Widget - Shows recording status, click to toggle recording
 * Text expands to the LEFT of the icon on hover
 */
Item {
  id: root

  property bool isRecording: false
  property bool isExpanded: false

  // --- Dimensions ---
  implicitWidth: contentRow.width
  implicitHeight: Style.barHeight

  // --- Recording Status Check ---
  Timer {
    id: statusTimer
    interval: 1000
    running: true
    repeat: true
    onTriggered: checkProcess.running = true
  }

  Process {
    id: checkProcess
    command: ["sh", "-c", "kill -0 $(cat /tmp/niri-record.pid 2>/dev/null) 2>/dev/null"]
    onExited: (code) => {
      root.isRecording = (code === 0);
    }
  }

  Process {
    id: recordProcess
    command: [Settings.scriptsDir + "niri-record"]
    onExited: (code, status) => Logger.i("ScreenRecorder", "Process exited with code: " + code)
  }

  // --- UI ---

  // Background Pill
  Rectangle {
    id: backgroundPill
    anchors.verticalCenter: contentRow.verticalCenter
    anchors.left: contentRow.left
    anchors.right: contentRow.right
    anchors.margins: -Style.marginS
    height: 18
    radius: height / 2
    color: {
      if (root.isRecording) return Color.mError;
      if (mouseArea.containsMouse) return Color.mBlue;
      return Color.transparent;
    }

    Behavior on color {
      ColorAnimation { duration: Style.animationFast; easing.type: Easing.InOutQuad }
    }

    // Pulse animation when recording
    SequentialAnimation on opacity {
      running: root.isRecording
      loops: Animation.Infinite
      NumberAnimation { to: 0.7; duration: 800; easing.type: Easing.InOutQuad }
      NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
    }
  }

  Row {
    id: contentRow
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: Style.marginXS
    layoutDirection: Qt.RightToLeft  // Icon stays right, text expands left

    // Recording Icon (first due to RightToLeft layout)
    Text {
      id: iconText
      anchors.verticalCenter: parent.verticalCenter
      text: "󰻂"
      font.family: Style.fontFamily
      font.pixelSize: Style.fontSizeL
      color: {
        if (root.isRecording) return Color.mOnPrimary;
        if (mouseArea.containsMouse) return Color.mOnPrimary;
        return Color.mOnSurface;
      }

      Behavior on color {
        ColorAnimation { duration: Style.animationFast; easing.type: Easing.InOutCubic }
      }
    }

    // Text container (expands to the left)
    Item {
      id: textContainer
      height: parent.height
      width: (root.isRecording || root.isExpanded) ? recordingText.implicitWidth + Style.marginXS : 0
      clip: true

      Behavior on width {
        NumberAnimation {
          duration: Style.animationFast
          easing.type: Easing.OutCubic
        }
      }

      Text {
        id: recordingText
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        text: root.isRecording ? "Recording..." : "Record?"
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeM
        font.weight: Style.fontWeightMedium
        color: {
          if (root.isRecording) return Color.mOnPrimary;
          if (mouseArea.containsMouse) return Color.mOnPrimary;
          return Color.mOnSurface;
        }

        Behavior on color {
          ColorAnimation { duration: Style.animationFast; easing.type: Easing.InOutCubic }
        }
      }
    }
  }

  // --- Interaction ---
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onEntered: expandTimer.start()
    onExited: {
      expandTimer.stop()
      root.isExpanded = false
    }

    onClicked: {
      Logger.i("ScreenRecorder", "Icon clicked");
      recordProcess.running = true;
    }
  }

  // Delay before expanding
  Timer {
    id: expandTimer
    interval: 500
    repeat: false
    onTriggered: root.isExpanded = true
  }
}
