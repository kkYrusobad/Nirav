# Configuration

Niruv is highly customizable through its settings system. This guide explains how to configure the shell to your liking.

## ⚙️ Settings Files

Niruv stores its configuration in the standard XDG config directory:

- **Settings**: `~/.config/noctalia/settings.json`
- **Colors**: `~/.config/noctalia/colors.json`

*Note: The folder name `noctalia` is inherited from the upstream project.*

### Default Settings Structure

The `settings.json` file follows this structure:

```json
{
  "general": {
    "scaleRatio": 1.0,
    "animationSpeed": 1.0
  },
  "bar": {
    "enabled": true,
    "position": "top",
    "widgets": {
      "left": ["workspaces"],
      "center": ["activeWindow"],
      "right": ["systemMonitor", "volume", "battery", "clock"]
    }
  },
  "dock": {
    "enabled": true,
    "position": "bottom",
    "autohide": false
  },
  "notifications": {
    "enabled": true,
    "position": "top-right",
    "maxVisible": 5
  },
  "colorSchemes": {
    "darkMode": true,
    "current": "gruvbox-dark"
  }
}
```

## 🖥️ Bar Configuration

You can customize the position and content of the bar.

### Position

Supported values: `"top"`, `"bottom"`, `"left"`, `"right"`.

### Widgets

You can arrange widgets in the `left`, `center`, and `right` sections of the bar. Available widgets include:

- `workspaces`: Niri workspace indicators
- `clock`: Date and time
- `battery`: Battery status
- `volume`: Audio volume control
- `brightness`: Screen brightness
- `systemMonitor`: CPU/RAM usage
- `activeWindow`: Title of the focused window
- `tray`: System tray

## 🔧 Environment Variables

You can override certain paths and behaviors using environment variables:

- `NOCTALIA_DEBUG=1`: Enable debug logging.
- `NOCTALIA_CONFIG_DIR`: Override the configuration directory.
- `NOCTALIA_CACHE_DIR`: Override the cache directory.
- `NOCTALIA_SETTINGS_FILE`: Override the specific settings file path.
