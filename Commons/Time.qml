pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  // Current date, updated every second
  property var now: new Date()

  readonly property int timestamp: {
    return Math.floor(root.now / 1000);
  }

  // ===== Timer State (for countdown/stopwatch) =====
  property bool timerRunning: false
  property bool timerStopwatchMode: false
  property int timerRemainingSeconds: 0
  property int timerTotalSeconds: 0
  property int timerElapsedSeconds: 0
  property bool timerSoundPlaying: false
  property int timerStartTimestamp: 0
  property int timerPausedAt: 0

  Timer {
    id: updateTimer
    interval: 1000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: {
      var newTime = new Date();
      root.now = newTime;

      // Update timer if running
      if (root.timerRunning && root.timerStartTimestamp > 0) {
        const elapsedSinceStart = root.timestamp - root.timerStartTimestamp;

        if (root.timerStopwatchMode) {
          root.timerElapsedSeconds = root.timerPausedAt + elapsedSinceStart;
        } else {
          root.timerRemainingSeconds = root.timerTotalSeconds - elapsedSinceStart;
          if (root.timerRemainingSeconds <= 0) {
            root.timerOnFinished();
          }
        }
      }

      // Adjust next interval to sync with the start of the next second
      var msIntoSecond = newTime.getMilliseconds();
      if (msIntoSecond > 100) {
        updateTimer.interval = 1000 - msIntoSecond + 10;
        updateTimer.restart();
      } else {
        updateTimer.interval = 1000;
      }
    }
  }

  // Formats a Date object into a YYYYMMDD-HHMMSS string
  function getFormattedTimestamp(date) {
    if (!date) {
      date = new Date();
    }
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');

    return `${year}${month}${day}-${hours}${minutes}${seconds}`;
  }

  // Format an easy to read approximate duration ex: "4h 32m"
  // Used for battery time remaining, uptime, etc.
  function formatVagueHumanReadableDuration(totalSeconds) {
    if (typeof totalSeconds !== 'number' || totalSeconds < 0) {
      return '0s';
    }

    totalSeconds = Math.floor(totalSeconds);

    const days = Math.floor(totalSeconds / 86400);
    const hours = Math.floor((totalSeconds % 86400) / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    const parts = [];
    if (days) parts.push(`${days}d`);
    if (hours) parts.push(`${hours}h`);
    if (minutes) parts.push(`${minutes}m`);

    // Only show seconds if no hours and no minutes
    if (!hours && !minutes) {
      parts.push(`${seconds}s`);
    }

    return parts.join(' ') || '0s';
  }

  // Format timer display (MM:SS or HH:MM:SS)
  function formatTimerDisplay(seconds, alwaysShowHours) {
    const hrs = Math.floor(Math.abs(seconds) / 3600);
    const mins = Math.floor((Math.abs(seconds) % 3600) / 60);
    const secs = Math.abs(seconds) % 60;

    if (alwaysShowHours || hrs > 0) {
      return `${hrs.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  // ===== Timer Functions =====
  function timerStart() {
    if (root.timerStopwatchMode) {
      root.timerRunning = true;
      root.timerStartTimestamp = root.timestamp;
      root.timerPausedAt = root.timerElapsedSeconds;
    } else {
      if (root.timerRemainingSeconds <= 0) {
        return;
      }
      root.timerRunning = true;
      root.timerTotalSeconds = root.timerRemainingSeconds;
      root.timerStartTimestamp = root.timestamp;
      root.timerPausedAt = 0;
    }
  }

  function timerPause() {
    if (root.timerRunning) {
      if (root.timerStopwatchMode) {
        root.timerPausedAt = root.timerElapsedSeconds;
      } else {
        root.timerPausedAt = root.timerRemainingSeconds;
      }
    }
    root.timerRunning = false;
    root.timerStartTimestamp = 0;
    root.timerSoundPlaying = false;
    alarmSoundProcess.running = false;
  }

  function timerReset() {
    root.timerRunning = false;
    root.timerStartTimestamp = 0;
    if (root.timerStopwatchMode) {
      root.timerElapsedSeconds = 0;
      root.timerPausedAt = 0;
    } else {
      root.timerRemainingSeconds = 0;
      root.timerTotalSeconds = 0;
      root.timerPausedAt = 0;
    }
    root.timerSoundPlaying = false;
    alarmSoundProcess.running = false;
  }

  function timerOnFinished() {
    root.timerRunning = false;
    root.timerRemainingSeconds = 0;
    root.timerSoundPlaying = true;
    // Play system notification with sound
    notificationProcess.running = true;
    // Play alarm sound (loop 3 times)
    alarmSoundProcess.running = true;
  }

  // Process to show notification
  Process {
    id: notificationProcess
    command: ["notify-send", "-u", "critical", "-i", "alarm-timer", "⏱ Timer Complete", "Your countdown timer has finished!"]
    running: false
  }

  // Process to play alarm sound
  Process {
    id: alarmSoundProcess
    command: ["sh", "-c", "for i in 1 2 3; do paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || paplay /usr/share/sounds/freedesktop/stereo/message-new-instant.oga 2>/dev/null || paplay /usr/share/sounds/gnome/default/alerts/glass.ogg 2>/dev/null; sleep 0.3; done"]
    running: false
  }
}


