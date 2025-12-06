pragma Singleton

import QtQuick
import Quickshell

/*
 * Niruv Style - UI tokens for consistent styling
 */
Singleton {
  id: root

  // Font size
  readonly property real fontSizeXS: 9
  readonly property real fontSizeS: 10
  readonly property real fontSizeM: 11
  readonly property real fontSizeL: 13
  readonly property real fontSizeXL: 16
  readonly property real fontSizeXXL: 18

  // Font family
  readonly property string fontFamily: "JetBrainsMono Nerd Font"

  // Font weight
  readonly property int fontWeightRegular: 400
  readonly property int fontWeightMedium: 500
  readonly property int fontWeightSemiBold: 600
  readonly property int fontWeightBold: 700

  // Radii
  readonly property int radiusXS: 4
  readonly property int radiusS: 8
  readonly property int radiusM: 12
  readonly property int radiusL: 16

  // Border
  readonly property int borderS: 1
  readonly property int borderM: 2

  // Margins (for margins and spacing)
  readonly property int marginXS: 4
  readonly property int marginS: 6
  readonly property int marginM: 9
  readonly property int marginL: 13
  readonly property int marginXL: 18

  // Animation duration (ms)
  readonly property int animationFast: 150
  readonly property int animationNormal: 300
  readonly property int animationSlow: 450

  // Bar Dimensions
  readonly property real barHeight: 28

  // Opacity
  readonly property real opacityLight: 0.25
  readonly property real opacityMedium: 0.5
  readonly property real opacityHeavy: 0.75
  readonly property real opacityFull: 1.0
}
