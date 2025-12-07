import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI

Item {
  id: root

  implicitWidth: contentRow.width
  implicitHeight: Style.barHeight

  Behavior on implicitWidth {
    NumberAnimation { duration: Style.animationFast; easing.type: Easing.OutCubic }
  }

  property bool isRecording: false
  property bool isExpanded: false

  // Delay before expanding
  Timer {
    id: expandTimer
    interval: 500
    repeat: false
    onTriggered: root.isExpanded = true
  }

  // Check if recording is active
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: {
      // Check for PID file
      var pidFile = "/tmp/niri-record.pid";
      // Simple check if file exists (Quickshell doesn't have direct file exists check easily without IO, 
      // but we can try to read it or use a process)
      // Using a process to check existence is safer
      checkProcess.running = true;
    }
  }

  Process {
    id: checkProcess
    command: ["sh", "-c", "kill -0 $(cat /tmp/niri-record.pid) 2>/dev/null"]
    onExited: (code) => {
      root.isRecording = (code === 0);
    }
  }

  Process {
    id: recordProcess
    command: ["/home/kky/garbage/noctaliaChange/Niruv/Scripts/niri-record"]
    onExited: (code, status) => Logger.i("ScreenRecorder", "Process exited with code: " + code)
  }

  // Background Pill
  Rectangle {
    anchors.centerIn: parent
    width: contentRow.width + Style.marginS * 2
    height: 18
    radius: height / 2
    color: {
      if (root.isRecording) return Color.mError;
      if (mouseArea.containsMouse) return Color.mBlue;
      return Color.transparent;
    }

    Behavior on color {
      ColorAnimation { duration: Style.animationFast }
    }

    Behavior on width {
      NumberAnimation { duration: Style.animationFast; easing.type: Easing.OutCubic }
    }

    // Pulse animation for background when recording
    SequentialAnimation on opacity {
      running: root.isRecording
      loops: Animation.Infinite
      NumberAnimation { to: 0.8; duration: 800; easing.type: Easing.InOutQuad }
      NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
    }
  }

  Row {
    id: contentRow
    anchors.centerIn: parent
    spacing: Style.marginXS

    // Recording Icon
    Text {
      id: iconText
      anchors.verticalCenter: parent.verticalCenter
      text: "" // mdi-record-circle-outline
      font.family: Style.fontFamily
      font.pixelSize: Style.fontSizeL
      color: {
        if (root.isRecording) return Color.mOnPrimary;
        if (mouseArea.containsMouse) return Color.mOnPrimary;
        return Color.mOnSurface;
      }

      Behavior on color {
        ColorAnimation { duration: Style.animationFast }
      }
    }

    // Recording Text
    Text {
      id: recordingText
      anchors.verticalCenter: parent.verticalCenter
      text: root.isRecording ? "Recording..." : "Record?"
      font.family: Style.fontFamily
      font.pixelSize: Style.fontSizeM
      font.weight: Style.fontWeightMedium
      color: Color.mOnPrimary
      visible: root.isRecording || root.isExpanded
    }
  }

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
}
