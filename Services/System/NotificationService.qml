pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.Commons

Singleton {
  id: root

  // Active notifications model
  property ListModel activeList: ListModel {}

  // Expire durations (ms)
  readonly property int durationLow: 3000
  readonly property int durationNormal: 5000
  readonly property int durationCritical: 10000

  NotificationServer {
    id: server
    onNotification: notification => handleNotification(notification)
  }

  function handleNotification(n) {
    const id = Qt.md5(n.summary + n.body + n.appName + Date.now().toString());
    
    const data = {
      "id": id,
      "summary": n.summary || "",
      "body": n.body || "",
      "appName": n.appName || "System",
      "urgency": n.urgency,
      "icon": n.appIcon || "bell"
    };

    activeList.insert(0, data);

    // Auto-expire
    const timeout = calculateTimeout(n.urgency, n.expireTimeout);
    if (timeout > 0) {
      const timer = expireTimerComponent.createObject(root, {
        "notificationId": id,
        "interval": timeout
      });
      timer.start();
    }
  }

  function calculateTimeout(urgency, expireTimeout) {
    if (expireTimeout > 0) return expireTimeout;
    if (expireTimeout === 0) return -1; // Never expire if requested
    
    if (urgency === 0) return durationLow;
    if (urgency === 2) return durationCritical;
    return durationNormal;
  }

  function removeNotification(id) {
    for (var i = 0; i < activeList.count; i++) {
      if (activeList.get(i).id === id) {
        activeList.remove(i);
        break;
      }
    }
  }

  Component {
    id: expireTimerComponent
    Timer {
      property string notificationId: ""
      repeat: false
      onTriggered: {
        removeNotification(notificationId);
        destroy();
      }
    }
  }

  // API for internal toasts
  function post(summary, body, icon, urgency) {
    handleNotification({
      summary: summary,
      body: body,
      appName: "Niruv",
      appIcon: icon,
      urgency: urgency || 1,
      expireTimeout: -1
    });
  }
}
