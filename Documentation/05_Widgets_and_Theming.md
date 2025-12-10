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

A simple, elegant clock displaying the current time and date. Clicking it opens the **ClockPanel**.

- **ClockPanel**: Contains calendar cards and timer functionality
- **CalendarHeaderCard**: Displays the current day name, date, and month/year
- **CalendarMonthCard**: Full month grid with current day highlighted
- **TimerCard**: Timer/Stopwatch with Pomodoro presets

### Timer/Stopwatch (TimerCard)

Niruv includes a built-in timer accessible from the ClockPanel.

- **Countdown Mode**: Set custom duration and count down to zero
- **Stopwatch Mode**: Count up from zero (click stopwatch icon)
- **Pomodoro Presets**: Quick-start buttons for common intervals:
  - 25 minutes (Work session)
  - 5 minutes (Short break)
  - 15 minutes (Long break)
- **Customizable Alarm**: Change the sound by editing `Commons/Time.qml`:

  ```qml
  command: ["sh", "-c", "for i in 1 2 3; do paplay /path/to/your/sound.ogg; sleep 0.3; done"]
  ```

- **Bar Indicator**: Timer countdown appears in the center bar when running

### SystemMonitor Widget

Displays real-time system statistics in a compact capsule format.

- **CPU Usage**: Shows percentage with threshold warning (turns red when >80%)
- **RAM Usage**: Shows percentage with threshold warning (turns red when >80%)
- **CPU Temperature**: Displays in degrees, turns red when >80°C
- **Load Average**: Shows 1-minute system load
- **Hover Effect**: Capsule background turns blue on hover
- **Click Action**: Opens **SystemMonitorPanel** with detailed stats and progress bars
- **Service**: Uses `SystemStatService.qml` to poll `/proc/` filesystem every 3 seconds

### Wallpaper Widget

A quick wallpaper changer widget.

- **Click Action**: Sets a random wallpaper from `~/Pictures/Wallpapers` using `swaybg`
- **Supported Formats**: JPG, JPEG, PNG, WebP
- **Hover Effect**: Background pill appears on hover
- **Script**: Uses `oNIgiRI/bin/niri-random-wallpaper` for reliable process handling

### Volume Widget

Audio volume control with PipeWire integration.

- **Icon**: Changes based on volume level (muted, low, medium, high)
- **Hover Expansion**: Percentage text expands on hover after 500ms delay
- **Scroll Control**: Scroll up/down to adjust volume
- **Left-Click**: Opens **VolumePanel** with slider and mute toggle
- **Right-Click**: Opens external mixer (pwvucontrol/pavucontrol)
- **VolumePanel Features**:
  - Volume slider with visual feedback
  - Mute toggle in header
  - Quick button to open audio mixer
- **Service**: Uses `Services/Media/AudioService.qml` with Quickshell.Services.Pipewire

### Brightness Widget

Screen brightness control using brightnessctl.

- **Icon**: Changes based on brightness level (off, low, high)
- **Hover Expansion**: Percentage text expands on hover
- **Scroll Control**: Scroll up/down to adjust brightness (5% steps)
- **Left-Click**: Opens **BrightnessPanel** with slider and Night Light controls
- **Right-Click**: Set to 100%
- **BrightnessPanel Features**:
  - Brightness slider with visual feedback
  - Night Light section with Off/Auto/On mode buttons
- **Auto-Hide**: Widget only appears if brightnessctl is available
- **Service**: Uses `Services/Hardware/BrightnessService.qml`

### WiFi & Bluetooth Widgets

Network connectivity widgets with shared **NetworkPanel**.

- **WiFi Widget**: Shows connection status and SSID on hover
- **Bluetooth Widget**: Shows connection status and device name on hover
- **Left-Click** (either): Opens **NetworkPanel**
- **NetworkPanel Features**:
  - WiFi section: Toggle switch, SSID, "WiFi Settings" button (opens impala TUI)
  - Bluetooth section: Toggle switch, device name, "Bluetooth Settings" button (opens bluetui TUI)

### Night Light Widget

Blue light filter toggle using wlsunset.

- **3-State Cycle**: Click cycles through Off → Auto → Forced → Off
- **Icon Changes**: Different icons for each state
- **Right-Click**: Toggle between Auto and Forced modes
- **Auto-Hide**: Widget only appears if wlsunset is installed
- **Service**: Uses `Services/System/NightLightService.qml`

## 🖱️ Panel Behavior

All popup panels share consistent behavior:

- **Click-Outside-to-Close**: Click anywhere outside the panel to close it
- **ESC Key**: Press Escape to close the panel
- **Auto-Close on New Panel**: Opening a new panel automatically closes any open panel
- **Smooth Animations**: Scale and fade animations on open/close
- **PanelState Singleton**: Centralized tracking via `Commons/PanelState.qml`
