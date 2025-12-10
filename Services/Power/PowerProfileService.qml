pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.Commons

/*
 * PowerProfileService - Power profile management singleton
 * Uses power-profiles-daemon via Quickshell's UPower integration
 */
Singleton {
  id: root

  // Access to PowerProfiles from UPower service
  readonly property var powerProfiles: PowerProfiles

  // Whether power profile control is available
  readonly property bool available: powerProfiles && powerProfiles.hasPerformanceProfile

  // Current profile (PowerProfile.Performance, Balanced, or PowerSaver)
  property int profile: powerProfiles ? powerProfiles.profile : PowerProfile.Balanced

  // Get human-readable name for a profile
  function getName(p) {
    if (!available) return "Unknown";

    const prof = (p !== undefined) ? p : profile;

    switch (prof) {
    case PowerProfile.Performance:
      return "Performance";
    case PowerProfile.Balanced:
      return "Balanced";
    case PowerProfile.PowerSaver:
      return "Power Saver";
    default:
      return "Unknown";
    }
  }

  // Get icon for a profile
  function getIcon(p) {
    if (!available) return "󰛲";

    const prof = (p !== undefined) ? p : profile;

    switch (prof) {
    case PowerProfile.Performance:
      return "󱐋";  // Lightning bolt
    case PowerProfile.Balanced:
      return "󰛲";  // Balance
    case PowerProfile.PowerSaver:
      return "󰌪";  // Leaf / eco
    default:
      return "󰛲";
    }
  }

  // Set a specific profile
  function setProfile(p) {
    if (!available) {
      Logger.w("PowerProfileService", "Power profiles not available");
      return;
    }
    try {
      powerProfiles.profile = p;
      Logger.d("PowerProfileService", "Set profile to: " + getName(p));
    } catch (e) {
      Logger.e("PowerProfileService", "Failed to set profile: " + e);
    }
  }

  // Cycle through profiles: PowerSaver -> Balanced -> Performance -> PowerSaver
  function cycleProfile() {
    if (!available) return;
    
    const current = powerProfiles.profile;
    if (current === PowerProfile.Performance) {
      setProfile(PowerProfile.PowerSaver);
    } else if (current === PowerProfile.Balanced) {
      setProfile(PowerProfile.Performance);
    } else if (current === PowerProfile.PowerSaver) {
      setProfile(PowerProfile.Balanced);
    }
  }

  // Check if current profile is the default (Balanced)
  function isDefault() {
    if (!available) return true;
    return (profile === PowerProfile.Balanced);
  }

  // Sync profile property when it changes externally
  Connections {
    target: powerProfiles
    function onProfileChanged() {
      root.profile = powerProfiles.profile;
      Logger.d("PowerProfileService", "Profile changed to: " + root.getName());
    }
  }

  Component.onCompleted: {
    if (available) {
      Logger.d("PowerProfileService", "Service started, current profile: " + getName());
    } else {
      Logger.w("PowerProfileService", "Power profiles not available (power-profiles-daemon not running?)");
    }
  }
}
