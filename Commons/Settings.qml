pragma Singleton

import QtQuick
import Quickshell

/*
 * Niruv Settings - Simplified settings singleton
 * TODO: Add file-based settings persistence
 */
Singleton {
  id: root

  // Debug mode (check environment variable)
  readonly property bool isDebug: {
    return (Quickshell.env("NIRUV_DEBUG") ?? "") === "1";
  }

  // Configuration directories
  readonly property string configDir: {
    var envDir = Quickshell.env("NIRUV_CONFIG_DIR");
    if (envDir && envDir.length > 0) {
      return envDir.endsWith("/") ? envDir : envDir + "/";
    }
    return Quickshell.env("HOME") + "/.config/niruv/";
  }

  readonly property string cacheDir: {
    var envDir = Quickshell.env("NIRUV_CACHE_DIR");
    if (envDir && envDir.length > 0) {
      return envDir.endsWith("/") ? envDir : envDir + "/";
    }
    return Quickshell.env("HOME") + "/.cache/niruv/";
  }

  // Hard-coded default settings for barebones shell
  readonly property var data: ({
    "general": {
      "scaleRatio": 1.0,
      "animationSpeed": 1.0
    },
    "bar": {
      "enabled": true,
      "position": "top"
    }
  })
}
