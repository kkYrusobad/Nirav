pragma Singleton

import QtQuick
import Quickshell

/*
 * Niruv Colors - Gruvbox Material Dark color scheme
 * Uses Material Design 3 naming with 'm' prefix to avoid QML signal conflicts
 */
Singleton {
  id: root

  // --- Key Colors: Gruvbox Material Dark ---
  readonly property color mPrimary: "#b8bb26"       // Green
  readonly property color mOnPrimary: "#1d2021"     // Dark BG

  readonly property color mSecondary: "#fabd2f"     // Yellow
  readonly property color mOnSecondary: "#1d2021"   // Dark BG

  readonly property color mTertiary: "#8ec07c"      // Aqua
  readonly property color mOnTertiary: "#1d2021"    // Dark BG

  // --- Utility Colors ---
  readonly property color mError: "#fb4934"         // Red
  readonly property color mOnError: "#1d2021"

  // --- Surface Colors ---
  readonly property color mSurface: "#282828"       // BG0
  readonly property color mOnSurface: "#fbf1c7"     // FG0 (Light)

  readonly property color mSurfaceVariant: "#3c3836" // BG1
  readonly property color mOnSurfaceVariant: "#d5c4a1" // FG2

  readonly property color mOutline: "#57514e"       // Gray border
  readonly property color mShadow: "#1d2021"        // Hard black

  readonly property color mHover: "#504945"         // BG2
  readonly property color mOnHover: "#ebdbb2"       // FG1

  // --- Absolute Colors ---
  readonly property color transparent: "transparent"
  readonly property color black: "#000000"
  readonly property color white: "#ffffff"
}
