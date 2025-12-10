pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

/*
 * NightLightService - Blue light filtering using wlsunset
 * Manages night light state with enabled/forced modes
 */
Singleton {
  id: root

  // Night light state
  property bool enabled: false
  property bool forced: false

  // Whether wlsunset is available
  property bool available: false

  // Temperature settings (Kelvin)
  property int nightTemp: 4000
  property int dayTemp: 6500

  // Check wlsunset availability on startup
  Component.onCompleted: {
    checkProcess.running = true;
  }

  // Check if wlsunset is installed
  Process {
    id: checkProcess
    command: ["which", "wlsunset"]
    onExited: (exitCode, exitStatus) => {
      root.available = (exitCode === 0);
      if (!root.available) {
        Logger.w("NightLightService", "wlsunset not available");
      } else {
        Logger.i("NightLightService", "wlsunset available");
      }
    }
  }

  // Build wlsunset command based on current settings
  function buildCommand(): list<string> {
    var cmd = ["wlsunset"];
    
    if (forced) {
      // Force immediate night temperature
      cmd.push("-t", nightTemp.toString(), "-T", dayTemp.toString());
      // Set schedule so we're always in "night" mode
      cmd.push("-S", "23:59");  // sunrise very late
      cmd.push("-s", "00:00");  // sunset at midnight
      cmd.push("-d", "1");       // instant transition
    } else {
      // Normal enabled mode - use default location-based schedule
      cmd.push("-t", nightTemp.toString(), "-T", dayTemp.toString());
    }
    
    return cmd;
  }

  // Apply current settings (start/stop wlsunset)
  function apply() {
    if (!available) return;

    // Kill any existing wlsunset process first (including system ones)
    killProcess.running = true;
  }

  // Kill existing wlsunset instances
  Process {
    id: killProcess
    command: ["pkill", "-x", "wlsunset"]
    onExited: (exitCode, exitStatus) => {
      // After killing, start new instance if enabled
      if (root.enabled) {
        var cmd = root.buildCommand();
        Logger.i("NightLightService", "Starting wlsunset:", cmd.join(" "));
        Quickshell.execDetached(cmd);
      } else {
        Logger.i("NightLightService", "wlsunset stopped");
      }
    }
  }

  // Toggle through states: off → enabled → forced → off
  function toggle() {
    if (!available) {
      Logger.w("NightLightService", "wlsunset not installed");
      return;
    }

    if (!enabled) {
      // Off → Enabled
      enabled = true;
      forced = false;
    } else if (enabled && !forced) {
      // Enabled → Forced
      forced = true;
    } else {
      // Forced → Off
      enabled = false;
      forced = false;
    }
    
    apply();
  }

  // Get appropriate icon based on state
  function getIcon(): string {
    if (!enabled) return "󰹏";     // moon outline (off)
    if (forced) return "󱩌";       // sun with moon (forced)
    return "󱧡";                   // sun (enabled/auto)
  }

  // Get state label
  function getStateLabel(): string {
    if (!enabled) return "Off";
    if (forced) return "Forced";
    return "Auto";
  }
}
