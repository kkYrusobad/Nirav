# Architecture & Development

This document outlines the internal structure of Niruv and provides guidelines for contributors.

## 🏗️ Project Structure

The project is organized into modular components:

```
Niruv/
├── shell.qml                  # Main Entry Point
├── Commons/                   # Core Singletons (Colors, Style, Settings, PanelState)
├── Modules/                   # UI Components
│   ├── Bar/                   # Top/Bottom Bar with Widgets
│   ├── Cards/                 # Reusable card components
│   ├── Panels/                # Popup panels (ClockPanel, BatteryPanel, etc.)
│   ├── Launcher/              # Application launcher
│   └── ...
├── Services/                  # Background Logic
│   ├── Compositor/            # Niri Integration
│   ├── Hardware/              # Battery, Bluetooth, etc.
│   └── ...
└── Assets/                    # Static Resources
```

## 🧩 Core Concepts

### Singletons (`Commons/`)

Niruv uses global singletons for shared state and utilities:

- **`Color`**: Defines the Gruvbox Material color palette.
- **`Style`**: Contains UI tokens like font sizes, margins, and animation durations.
- **`Settings`**: Manages user configuration.
- **`Logger`**: Provides standardized logging (`Logger.i`, `Logger.d`, `Logger.e`).
- **`Time`**: Clock utilities and timer functionality with alarm sound.
- **`PanelState`**: Tracks open panels for click-outside-to-close functionality.

### Services (`Services/`)

Logic is separated from UI into Services. For example, `BatteryService.qml` handles UPower integration, exposing properties that `Battery.qml` (the widget) simply displays.

Key services include:

- **SystemStatService**: Reads CPU/RAM/Temperature/Load from `/proc/` filesystem
- **BatteryService**: UPower integration for battery status
- **CavaService**: Manages the Cava audio visualizer process
- **BluetoothService**: Bluetooth device battery monitoring
- **ApplicationsService**: Desktop app listing and fuzzy search
- **MenuService**: System menu categories and actions

### Panels (`Modules/Panels/`)

Popup panels provide detailed information when clicking on bar widgets:

- **ClockPanel**: Calendar cards and timer/stopwatch
- **BatteryPanel**: Detailed battery statistics
- **MediaPanel**: Full media player controls with album art
- **SystemMonitorPanel**: Detailed CPU/RAM/Temp/Load with progress bars

### Cards (`Modules/Cards/`)

Reusable card components used within panels:

- **CalendarHeaderCard**: Current day, date, and month display
- **CalendarMonthCard**: Month grid calendar with current day highlighted
- **TimerCard**: Timer/Stopwatch with Pomodoro presets

## 🤝 Contributing

### Creating a New Widget

1. Create your widget file in `Modules/Bar/Widgets/` (e.g., `MyWidget.qml`).
2. Import `qs.Commons` to access `Color` and `Style`.
3. Use the standard `N` prefixed components if available (e.g., `NText`, `NIcon`).
4. Add your widget to the `widgets` list in `settings.json` to test it.

### Coding Standards

- **Naming**: Use `PascalCase` for components and `camelCase` for properties/functions.
- **Colors**: Always use `Color.mXxx` properties. Never hardcode hex values in widgets.
- **Logging**: Use `Logger` instead of `console.log`.

### Debugging

Run the shell with `NIRUV_DEBUG=1` to see debug output from `Logger.d()` calls.

```bash
NIRUV_DEBUG=1 qs -c niruv
```
