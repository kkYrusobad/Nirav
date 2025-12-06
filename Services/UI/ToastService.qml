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
    notifyProcess.command = ["notify-send", "-u", "critical", "-i", "battery-caution", title, message];
    notifyProcess.running = true;
    Logger.i("ToastService", `Warning: ${title} - ${message}`);
  }

  // Show a normal notification
  function showNotice(title, message, icon) {
    var iconName = icon || "dialog-information";
    notifyProcess.command = ["notify-send", "-i", iconName, title, message];
    notifyProcess.running = true;
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
