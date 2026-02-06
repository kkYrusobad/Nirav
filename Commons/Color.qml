pragma Singleton

import QtQuick
import Quickshell

/*
 * Niruv Colors - Gruvbox Material Dark color scheme
 * Uses Material Design 3 naming with 'm' prefix to avoid QML signal conflicts
 */
Singleton {
  id: root

  // --- Key Colors: Gruvbox Material Dark Soft ---
  readonly property color mPrimary: "#a9b665"       // Green (Soft)
  readonly property color mOnPrimary: "#32302f"     // Soft BG

  readonly property color mSecondary: "#d8a657"     // Yellow (Soft)
  readonly property color mOnSecondary: "#32302f"   // Soft BG

  readonly property color mTertiary: "#89b482"      // Aqua (Soft)
  readonly property color mOnTertiary: "#32302f"    // Soft BG

  // --- Additional Gruvbox Colors ---
  readonly property color mOrange: "#e78a4e"
  readonly property color mOnOrange: "#32302f"

  readonly property color mBlue: "#7daea3"
  readonly property color mOnBlue: "#32302f"

  readonly property color mPurple: "#d3869b"
  readonly property color mOnPurple: "#32302f"

  // --- Utility Colors ---
  readonly property color mError: "#ea6962"         // Red (Soft)
  readonly property color mOnError: "#32302f"

  // --- Surface Colors ---
  readonly property color mSurface: "#32302f"       // BG Soft
  readonly property color mOnSurface: "#dab997"     // FG (Soft)

  readonly property color mSurfaceVariant: "#3c3836" // BG1
  readonly property color mOnSurfaceVariant: "#bdad9c" // FG3-ish (Soft)

  readonly property color mOutline: "#504945"       // Gray border (Soft)
  readonly property color mShadow: "#1d2021"        // Hard black

  readonly property color mHover: "#3c3836"         // BG1
  readonly property color mOnHover: "#dab997"       // FG (Soft)

  // --- Absolute Colors ---
  readonly property color transparent: "transparent"
  readonly property color black: "#000000"
  readonly property color white: "#ffffff"
}
