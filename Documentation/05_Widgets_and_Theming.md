# Widgets & Theming

Niruv is built with a robust theming system and a set of interactive widgets.

## 🎨 Theming System

Niruv uses the **Gruvbox Material Dark** color scheme by default. The color system is designed to be consistent and easy to use.

### Color Palette (`Commons/Color.qml`)

Colors are accessed via the `Color` singleton. We use Material Design 3 naming conventions (prefixed with `m`) to avoid conflicts with QML properties.

| Property | Description | Hex |
|----------|-------------|-----|
| `Color.mPrimary` | Primary accent (Green) | `#b8bb26` |
| `Color.mSecondary` | Secondary accent (Yellow) | `#fabd2f` |
| `Color.mTertiary` | Tertiary accent (Aqua) | `#8ec07c` |
| `Color.mOrange` | Orange accent | `#fe8019` |
| `Color.mBlue` | Blue accent | `#83a598` |
| `Color.mPurple` | Purple accent | `#d3869b` |
| `Color.mError` | Error state (Red) | `#fb4934` |
| `Color.mSurface` | Background color | `#282828` |
| `Color.mOnSurface` | Text color | `#fbf1c7` |

### Styling (`Commons/Style.qml`)

The `Style` singleton defines standard dimensions and animations:

- **Margins**: `Style.marginXS` (4px), `Style.marginS` (6px), `Style.marginM` (9px), `Style.marginL` (13px).
- **Radii**: `Style.radiusXS` (8px), `Style.radiusS` (12px), `Style.radiusM` (16px).
- **Animations**: `Style.animationFast` (150ms), `Style.animationNormal` (300ms).

## 🧩 Widgets

### Battery Widget

The battery widget is more than just a percentage indicator.

- **Hover Effect**: Expands to show a colored background (customizable theme color) and percentage text.
- **Floating Window**: Right-click the icon to launch `battop` in a centered, floating terminal window.
- **Bluetooth**: Automatically detects and displays battery levels for connected Bluetooth devices.

### Workspace Widget

Displays Niri workspaces with smooth animations.

- **Active Indicator**: A pill-shaped indicator follows the active workspace.
- **Icons**: Supports Nerd Font icons for each workspace index.

### Clock Widget

A simple, elegant clock displaying the current time and date. Clicking it can be configured to open a calendar or other utility.
