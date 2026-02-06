# Configuration

Niruv is highly customizable through its JSON-based settings system. This guide explains how to configure the shell.

## ⚙️ Settings Files

Niruv stores its configuration in the standard XDG config directory:

- **Settings**: `~/.config/niruv/settings.json`

The shell will automatically create this file with default values on the first run.

### Settings Structure

The `settings.json` file follows this structure:

```json
{
    "bar": {
        "capsuleOpacity": 0.5,
        "density": "default",
        "enabled": true,
        "position": "top",
        "showCapsule": true
    },
    "general": {
        "animationDisabled": false,
        "animationSpeed": 1,
        "radiusRatio": 1,
        "scaleRatio": 1,
        "screenRadiusRatio": 1,
        "shadowOffsetX": 2,
        "shadowOffsetY": 2
    }
}
```

## 🖥️ Bar Configuration

You can customize the position and density of the bar.

### Position

Supported values: `"top"`, `"bottom"`, `"left"`, `"right"`.

### Density

Supported values:

- `"mini"`: Smallest size
- `"compact"`: Balanced size
- `"default"` (Recommended)
- `"comfortable"`: Larger elements and spacing

## 🌙 Night Light

Night light toggle uses `wlsunset`. Configuration for location/temp should be handled via user's `wlsunset` setup if applicable, though the shell provides a simple toggle.

## 🔧 Environment Variables

You can override certain paths and behaviors using environment variables:

- `NIRUV_DEBUG=1`: Enable debug logging and reload popups.
- `NIRUV_CONFIG_DIR`: Override the configuration directory (default: `~/.config/niruv/`).
- `NIRUV_CACHE_DIR`: Override the cache directory (default: `~/.cache/niruv/`).
