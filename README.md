<p align="center">
  <h1 align="center">निरव · Niruv</h1>
  <p align="center">
    <em>A minimal, Gruvbox-themed desktop shell for Niri</em>
  </p>
</p>

<div align="center">

<https://github.com/user-attachments/assets/da7172b0-9a61-4387-8d6a-9b5da72b2cd6>

</div>

---

**Niruv** is a lightweight desktop shell built on [Quickshell](https://quickshell.outfoxxed.me/) (Qt/QML) for the [Niri](https://github.com/YaLTeR/niri) Wayland compositor.

The name combines **Niri** + **Gruv**box, and references the Sanskrit word **निरव** (*nirav*) — meaning "quiet" or "silent" — reflecting the shell's minimal, unobtrusive design philosophy.

## ✨ Features

- 🎨 **Gruvbox Material Dark** color scheme
- 🖥️ **Workspace indicators** with Nerd Font icons and smooth animations
- 📊 **System Monitor** showing CPU%, RAM%, temperature, and load average with threshold alerts
- 🖼️ **Wallpaper widget** click to set random wallpaper via swaybg
- 🔋 **Battery widget** with hover effects, themed expansion, and detailed BatteryPanel popup
- 🎥 **Screen Recorder** with recording status, hover expansion, and direct launch
- 📶 **WiFi widget** with SSID display on hover, click opens NetworkPanel
- 🔵 **Bluetooth widget** with connected device display, click opens NetworkPanel
- 🎵 **Media widget** showing current track (Artist - Title), with MediaPanel popup for full controls
- 🎼 **Cava Visualizer** integrated audio spectrum display
- 🔊 **Volume widget** with VolumePanel popup, scroll to adjust, right-click mixer
- ☀️ **Brightness widget** with BrightnessPanel popup including Night Light controls
- 🌙 **Night Light widget** with wlsunset toggle (off → auto → forced states)
- 🕐 **Clock widget** with ClockPanel popup containing calendar and timer
- ⏱️ **Timer/Stopwatch** with Pomodoro presets, customizable alarm sound
- 📅 **Calendar Cards** displaying current date and month grid
- ⌨️ **JetBrainsMono Nerd Font** throughout
- 🚀 **Minimalist Launcher** with app search + system menu (Tab to switch modes)
- 🖱️ **Click-outside-to-close** panels - click anywhere outside or press ESC

## 📚 Documentation

For detailed guides on installation, configuration, and development, please refer to the full documentation:

- [**Introduction**](Documentation/01_Introduction.md)
- [**Installation Guide**](Documentation/02_Installation.md)
- [**Configuration**](Documentation/03_Configuration.md)
- [**Architecture & Development**](Documentation/04_Architecture_and_Development.md)
- [**Widgets & Theming**](Documentation/05_Widgets_and_Theming.md)

## 📦 Requirements

| Dependency | Description |
|------------|-------------|
| [quickshell](https://quickshell.outfoxxed.me/) | Qt/QML shell framework |
| [niri](https://github.com/YaLTeR/niri) | Scrollable-tiling Wayland compositor |
| JetBrainsMono Nerd Font | Icon and text rendering |

## 🚀 Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/niruv.git

# Create symlink for Quickshell
mkdir -p ~/.config/quickshell
ln -sf /path/to/niruv ~/.config/quickshell/niruv

# Run
qs -c niruv
```

### Debug Mode

```bash
NIRUV_DEBUG=1 qs -c niruv
```

## 🎛️ Customization

### Workspace Icons

Edit `Modules/Bar/Widgets/Workspace.qml` line 77:

```qml
property var workspaceIcons: ["", "", "", "", "5", "6", "7", "8", "9", "10"]
```

Browse icons at [nerdfonts.com/cheat-sheet](https://www.nerdfonts.com/cheat-sheet)

## 📁 Project Structure

```
niruv/
├── shell.qml                  # Entry point
├── Commons/                   # Core singletons
│   ├── Color.qml              # Gruvbox color palette
│   ├── Style.qml              # UI design tokens
│   ├── Logger.qml             # Debug logging
│   ├── Time.qml               # Clock + Timer utilities
│   ├── Settings.qml           # Configuration
│   └── PanelState.qml         # Panel visibility tracking (click-outside-to-close)
├── Modules/
│   ├── Bar/                   # Top bar module
│   │   ├── Bar.qml            # Main bar component
│   │   └── Widgets/
│   │       ├── Workspace.qml  # Workspace indicators
│   │       ├── SystemMonitor.qml # CPU/RAM/Temp/Load display
│   │       ├── Wallpaper.qml  # Random wallpaper setter
│   │       ├── Battery.qml    # Battery status widget
│   │       ├── ScreenRecorder.qml # Screen recording widget
│   │       ├── WiFi.qml       # WiFi status widget
│   │       ├── Bluetooth.qml  # Bluetooth status widget
│   │       ├── Media.qml      # Media player widget
│   │       ├── Visualizer.qml # Cava audio visualizer
│   │       ├── Volume.qml     # Volume control widget
│   │       ├── Brightness.qml # Brightness control widget
│   │       └── NightLight.qml # Night light toggle widget
│   ├── Cards/                 # Reusable card components
│   │   ├── CalendarHeaderCard.qml  # Current date display
│   │   ├── CalendarMonthCard.qml   # Month grid calendar
│   │   └── TimerCard.qml      # Timer/Stopwatch with Pomodoro presets
│   ├── Panels/                # Popup panels
│   │   ├── ClockPanel/        # Calendar + Timer panel
│   │   ├── BatteryPanel/      # Detailed battery info
│   │   ├── MediaPanel/        # Full media controls
│   │   ├── VolumePanel/       # Volume slider + mute toggle
│   │   ├── BrightnessPanel/   # Brightness slider + Night Light
│   │   ├── NetworkPanel/      # WiFi + Bluetooth controls
│   │   └── SystemMonitorPanel/ # Detailed system stats
│   └── Launcher/              # App Launcher + System Menu
│       └── Launcher.qml       # Minimalist launcher UI
└── Services/
    ├── Compositor/
    │   └── NiriService.qml    # Niri IPC integration
    ├── Hardware/
    │   ├── BatteryService.qml    # Battery icon logic
    │   └── BrightnessService.qml # Brightness control via brightnessctl
    ├── Media/
    │   ├── CavaService.qml       # Cava audio visualizer service
    │   └── AudioService.qml      # PipeWire audio volume/mute control
    ├── Networking/
    │   └── BluetoothService.qml # Bluetooth battery support
    ├── System/
    │   ├── ApplicationsService.qml  # App listing + search
    │   ├── MenuService.qml          # System menu categories + actions
    │   ├── SystemStatService.qml    # CPU/RAM/Temp/Load stats
    │   └── NightLightService.qml    # wlsunset night light control
    └── UI/
        └── ToastService.qml   # Desktop notifications
```

## 🙏 Acknowledgments

- [Noctalia Shell](https://github.com/nicholasswift/noctalia-shell) — Inspiration for animation patterns
- [Gruvbox](https://github.com/morhetz/gruvbox) — Color scheme

## 📄 License

MIT
