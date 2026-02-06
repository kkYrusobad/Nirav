pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

/*
 * Niruv ToastService - Sends desktop notifications
 * Uses notify-send for system notifications
 */
Singleton {
  id: root

  // Show a warning notification
  function showWarning(title, message) {
    NotificationService.post(title, message, "battery-caution", 2);
    Logger.i("ToastService", `Warning: ${title} - ${message}`);
  }

  // Show a normal notification
  function showNotice(title, message, icon) {
    NotificationService.post(title, message, icon || "dialog-information", 1);
    Logger.i("ToastService", `Notice: ${title} - ${message}`);
  }

  Process {
    id: notifyProcess
    running: false
  }

  Component.onCompleted: {
    Logger.i("ToastService", "Service started");
  }
}
