import QtQuick
import QtQuick.Layouts
import qs.Commons

/*
 * TimerCard - Pomodoro/Stopwatch timer with countdown display
 * Features: Countdown/Stopwatch modes, circular progress ring, editable time input
 */
Rectangle {
  id: root

  Layout.fillWidth: true
  implicitHeight: content.implicitHeight + Style.marginM * 2
  radius: Style.radiusM
  color: Color.mSurfaceVariant
  border.color: Color.mOutline
  border.width: Style.borderS
  clip: true

  // Bind to Time singleton for timer state
  readonly property bool isRunning: Time.timerRunning
  property bool isStopwatchMode: Time.timerStopwatchMode
  readonly property int remainingSeconds: Time.timerRemainingSeconds
  readonly property int totalSeconds: Time.timerTotalSeconds
  readonly property int elapsedSeconds: Time.timerElapsedSeconds
  readonly property bool soundPlaying: Time.timerSoundPlaying

  ColumnLayout {
    id: content
    anchors.fill: parent
    anchors.margins: Style.marginM
    spacing: Style.marginM

    // Header
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      Text {
        text: isStopwatchMode ? "󱎫" : "󰔛"
        color: Color.mPrimary
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeL
      }

      Text {
        text: "Timer"
        color: Color.mOnSurface
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        Layout.fillWidth: true
      }
    }

    // Timer display
    Item {
      id: timerDisplayItem
      Layout.fillWidth: true
      Layout.preferredHeight: isRunning ? 140 : 80
      Layout.alignment: Qt.AlignHCenter

      // Circular progress ring (countdown mode only)
      Canvas {
        id: progressRing
        anchors.fill: parent
        anchors.margins: 10
        visible: !isStopwatchMode && isRunning && totalSeconds > 0
        z: -1

        property real progressRatio: {
          if (totalSeconds <= 0) return 0;
          const ratio = remainingSeconds / totalSeconds;
          return Math.max(0, Math.min(1, ratio));
        }

        onProgressRatioChanged: requestPaint()

        onPaint: {
          var ctx = getContext("2d");
          if (width <= 0 || height <= 0) return;

          var centerX = width / 2;
          var centerY = height / 2;
          var radius = Math.max(0, Math.min(width, height) / 2 - 6);

          ctx.reset();

          // Background circle
          ctx.beginPath();
          ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
          ctx.lineWidth = 4;
          ctx.strokeStyle = Qt.alpha(Color.mOnSurface, 0.2);
          ctx.stroke();

          // Progress arc
          if (progressRatio > 0) {
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + progressRatio * 2 * Math.PI);
            ctx.lineWidth = 4;
            ctx.strokeStyle = Color.mPrimary;
            ctx.lineCap = "round";
            ctx.stroke();
          }
        }
      }

      // Time display
      Column {
        anchors.centerIn: parent
        spacing: Style.marginS

        Text {
          id: timerDisplay
          anchors.horizontalCenter: parent.horizontalCenter
          text: {
            if (isStopwatchMode) {
              return Time.formatTimerDisplay(elapsedSeconds, elapsedSeconds >= 3600);
            }
            return Time.formatTimerDisplay(remainingSeconds, remainingSeconds >= 3600);
          }
          color: isRunning ? Color.mPrimary : Color.mOnSurface
          font.family: Style.fontFamily
          font.pixelSize: isRunning ? Style.fontSizeXXL * 1.5 : Style.fontSizeXXL
          font.weight: Style.fontWeightBold
        }

        // Pomodoro presets (only in countdown mode when not running and no time set)
        Row {
          visible: !isStopwatchMode && !isRunning && remainingSeconds === 0
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Style.marginXS

          Repeater {
            model: [
              { label: "󰔟 25m", seconds: 1500, color: Color.mPrimary },
              { label: "󰾩 5m", seconds: 300, color: Color.mSecondary },
              { label: "󰒲 15m", seconds: 900, color: Color.mTertiary }
            ]

            Rectangle {
              width: 65
              height: 32
              radius: Style.radiusS
              color: pomoMouseArea.containsMouse ? modelData.color : Color.mSurface
              border.color: modelData.color
              border.width: 2

              Text {
                anchors.centerIn: parent
                text: modelData.label
                color: pomoMouseArea.containsMouse ? Color.mOnPrimary : modelData.color
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeS
                font.weight: Style.fontWeightBold
              }

              MouseArea {
                id: pomoMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  Time.timerRemainingSeconds = modelData.seconds;
                }
              }
            }
          }
        }

        // Increment time buttons (only in countdown mode when not running)
        Row {
          visible: !isStopwatchMode && !isRunning
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Style.marginXS

          Repeater {
            model: [
              { label: "+1m", seconds: 60 },
              { label: "+5m", seconds: 300 },
              { label: "+10m", seconds: 600 },
              { label: "+30m", seconds: 1800 }
            ]

            Rectangle {
              width: 48
              height: 28
              radius: Style.radiusS
              color: presetMouseArea.containsMouse ? Color.mPrimary : Color.mSurface
              border.color: Color.mOutline
              border.width: 1

              Text {
                anchors.centerIn: parent
                text: modelData.label
                color: presetMouseArea.containsMouse ? Color.mOnPrimary : Color.mOnSurface
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeS
                font.weight: Style.fontWeightMedium
              }

              MouseArea {
                id: presetMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  Time.timerRemainingSeconds = Time.timerRemainingSeconds + modelData.seconds;
                }
              }
            }
          }
        }

        // Clear button (when time is set but not running)
        Rectangle {
          visible: !isStopwatchMode && !isRunning && remainingSeconds > 0
          anchors.horizontalCenter: parent.horizontalCenter
          width: 60
          height: 24
          radius: Style.radiusXS
          color: clearMouseArea.containsMouse ? Qt.alpha(Color.mError, 0.2) : Color.transparent

          Text {
            anchors.centerIn: parent
            text: "Clear"
            color: Color.mError
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeXS
            font.weight: Style.fontWeightMedium
          }

          MouseArea {
            id: clearMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              Time.timerRemainingSeconds = 0;
            }
          }
        }
      }
    }

    // Control buttons
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      // Start/Pause button
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36
        radius: Style.radiusS
        color: startMouseArea.containsMouse ? Qt.alpha(Color.mPrimary, 0.2) : Color.mSurface
        opacity: (isStopwatchMode || remainingSeconds > 0) ? 1.0 : 0.5

        RowLayout {
          anchors.centerIn: parent
          spacing: Style.marginXS

          Text {
            text: isRunning ? "󰏤" : "󰐊"
            color: Color.mPrimary
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeL
          }

          Text {
            text: isRunning ? "Pause" : "Start"
            color: Color.mOnSurface
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeM
            font.weight: Style.fontWeightMedium
          }
        }

        MouseArea {
          id: startMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          enabled: isStopwatchMode || remainingSeconds > 0
          onClicked: {
            if (isRunning) {
              Time.timerPause();
            } else {
              Time.timerStart();
            }
          }
        }
      }

      // Reset button
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36
        radius: Style.radiusS
        color: resetMouseArea.containsMouse ? Qt.alpha(Color.mPrimary, 0.2) : Color.mSurface
        opacity: ((isStopwatchMode && (elapsedSeconds > 0 || isRunning)) ||
                  (!isStopwatchMode && (remainingSeconds > 0 || isRunning || soundPlaying))) ? 1.0 : 0.5

        RowLayout {
          anchors.centerIn: parent
          spacing: Style.marginXS

          Text {
            text: "󰑓"
            color: Color.mPrimary
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeL
          }

          Text {
            text: "Reset"
            color: Color.mOnSurface
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeM
            font.weight: Style.fontWeightMedium
          }
        }

        MouseArea {
          id: resetMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: Time.timerReset()
        }
      }
    }

    // Mode tabs
    RowLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignHCenter
      visible: !isRunning
      spacing: Style.marginXS

      // Countdown tab
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 32
        radius: Style.radiusS
        color: !isStopwatchMode ? Color.mPrimary : (countdownMouseArea.containsMouse ? Color.mSurface : Color.transparent)

        Text {
          anchors.centerIn: parent
          text: "Countdown"
          color: !isStopwatchMode ? Color.mOnPrimary : Color.mOnSurface
          font.family: Style.fontFamily
          font.pixelSize: Style.fontSizeS
          font.weight: Style.fontWeightMedium
        }

        MouseArea {
          id: countdownMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (isStopwatchMode) {
              Time.timerStopwatchMode = false;
              Time.timerReset();
            }
          }
        }
      }

      // Stopwatch tab
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 32
        radius: Style.radiusS
        color: isStopwatchMode ? Color.mPrimary : (stopwatchMouseArea.containsMouse ? Color.mSurface : Color.transparent)

        Text {
          anchors.centerIn: parent
          text: "Stopwatch"
          color: isStopwatchMode ? Color.mOnPrimary : Color.mOnSurface
          font.family: Style.fontFamily
          font.pixelSize: Style.fontSizeS
          font.weight: Style.fontWeightMedium
        }

        MouseArea {
          id: stopwatchMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (!isStopwatchMode) {
              Time.timerStopwatchMode = true;
              Time.timerReset();
            }
          }
        }
      }
    }
  }
}

