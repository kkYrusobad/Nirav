pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.Commons

/*
 * Niruv BatteryService - Provides battery icon selection based on charge state
 * Uses UPower for battery data
 */
Singleton {
  id: root

  // Returns appropriate Nerd Font battery icon based on charge level and state
  function getIcon(percent, charging, isReady) {
    if (!isReady) {
      return "󱉝";  // battery-unknown
    }

    if (charging) {
      return "󰂄";  // battery-charging
    }

    // Discharge icons based on percentage
    if (percent >= 95)
      return "";  // battery-full
    if (percent >= 85)
      return "󰂂";  // battery-90
    if (percent >= 75)
      return "󰂁";  // battery-80
    if (percent >= 65)
      return "󰂀";  // battery-70
    if (percent >= 55)
      return "󰁿";  // battery-60
    if (percent >= 45)
      return "󰁾";  // battery-50
    if (percent >= 35)
      return "󰁽";  // battery-40
    if (percent >= 25)
      return "󰁼";  // battery-30
    if (percent >= 15)
      return "󰁻";  // battery-20
    if (percent >= 5)
      return "󰁺";  // battery-10
    return "󰂎";    // battery-empty/alert
  }
}
