pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.Commons

/*
 * Niruv BluetoothService - Provides Bluetooth device information
 * Primarily used for getting battery levels of connected devices
 */
Singleton {
  id: root

  // Bluetooth adapter
  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property bool available: adapter !== null
  readonly property bool enabled: adapter?.enabled ?? false
  readonly property var devices: adapter ? adapter.devices : null

  // Get all connected devices with battery info
  readonly property var allDevicesWithBattery: {
    if (!adapter || !adapter.devices) {
      return [];
    }
    return adapter.devices.values.filter(dev => {
      return dev && dev.batteryAvailable && dev.battery > 0;
    });
  }

  // Get formatted battery string for a device
  function getBattery(device) {
    if (!device || !device.batteryAvailable) {
      return "";
    }
    return `${device.name}: ${Math.round(device.battery * 100)}%`;
  }

  // Get device icon based on type
  function getDeviceIcon(device) {
    if (!device) return "󰂯";  // generic bluetooth

    var name = (device.name || "").toLowerCase();
    var icon = (device.icon || "").toLowerCase();

    if (icon.includes("headset") || icon.includes("audio") ||
        name.includes("headphone") || name.includes("airpod") ||
        name.includes("headset")) {
      return "󰋋";  // headphones
    }
    if (icon.includes("mouse") || name.includes("mouse")) {
      return "󰍽";  // mouse
    }
    if (icon.includes("keyboard") || name.includes("keyboard")) {
      return "󰌌";  // keyboard
    }
    if (icon.includes("phone") || name.includes("phone")) {
      return "󰏲";  // phone
    }
    return "󰂯";  // generic bluetooth
  }

  Component.onCompleted: {
    Logger.i("BluetoothService", "Service started");
  }
}
