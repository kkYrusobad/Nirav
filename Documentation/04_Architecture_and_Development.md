# Architecture & Development

This document outlines the internal structure of Niruv and provides guidelines for contributors.

## 🏗️ Project Structure

The project is organized into modular components:

```
Niruv/
├── shell.qml                  # Main Entry Point
├── Commons/                   # Core Singletons (Colors, Style, Settings)
├── Modules/                   # UI Components
│   ├── Bar/                   # Top/Bottom Bar
│   ├── Dock/                  # Application Dock
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

### Services (`Services/`)

Logic is separated from UI into Services. For example, `BatteryService.qml` handles UPower integration, exposing properties that `Battery.qml` (the widget) simply displays.

Key services include:

- **SystemStatService**: Reads CPU/RAM/Temperature/Load from `/proc/` filesystem
- **BatteryService**: UPower integration for battery status
- **CavaService**: Manages the Cava audio visualizer process
- **BluetoothService**: Bluetooth device battery monitoring
- **ApplicationsService**: Desktop app listing and fuzzy search
- **MenuService**: System menu categories and actions

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

Run the shell with `NOCTALIA_DEBUG=1` to see debug output from `Logger.d()` calls.
