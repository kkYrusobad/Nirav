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

### Screen Recorder Widget

A minimalist screen recording tool integrated directly into the bar.

- **Status Indication**: Icon changes and background pulses red when recording.
- **Hover Expansion**: Expands to show "Record?" (idle) or "Recording..." (active) text on hover.
- **Direct Launch**: Clicking the icon instantly starts recording the screen (or prompts for region selection depending on configuration).
- **Smooth Animation**: Features smooth text expansion and color transitions.

### Workspace Widget

Displays Niri workspaces with smooth animations.

- **Active Indicator**: A pill-shaped indicator follows the active workspace.
- **Icons**: Supports Nerd Font icons for each workspace index.

### Clock Widget

A simple, elegant clock displaying the current time and date. Clicking it can be configured to open a calendar or other utility.

### SystemMonitor Widget

Displays real-time system statistics in a compact capsule format.

- **CPU Usage**: Shows percentage with threshold warning (turns red when >80%)
- **RAM Usage**: Shows percentage with threshold warning (turns red when >80%)
- **CPU Temperature**: Displays in degrees, turns red when >80°C
- **Load Average**: Shows 1-minute system load
- **Hover Effect**: Capsule background turns blue on hover
- **Service**: Uses `SystemStatService.qml` to poll `/proc/` filesystem every 3 seconds

### Wallpaper Widget

A quick wallpaper changer widget.

- **Click Action**: Sets a random wallpaper from `~/Pictures/Wallpapers` using `swaybg`
- **Supported Formats**: JPG, JPEG, PNG, WebP
- **Hover Effect**: Background pill appears on hover
- **Script**: Uses `oNIgiRI/bin/niri-random-wallpaper` for reliable process handling
