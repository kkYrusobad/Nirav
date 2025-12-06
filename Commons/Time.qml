pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  // Current date, updated every second
  property var now: new Date()

  readonly property int timestamp: {
    return Math.floor(root.now / 1000);
  }

  Timer {
    id: updateTimer
    interval: 1000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: {
      var newTime = new Date();
      root.now = newTime;

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
}
