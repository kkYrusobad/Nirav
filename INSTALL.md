# Installing & Running Niruv Shell

Niruv is a minimal Gruvbox-themed desktop shell for Wayland (optimized for Niri), built on top of the [Quickshell](https://github.com/outfoxxed/quickshell) framework.

## 🚀 Quick Install

```bash
git clone https://github.com/kkYrusobad/niruv.git
cd niruv
./install.sh
```

The install script handles:

- Dependency checking and installation
- Config directory creation
- Quickshell symlink setup
- Optional [oNIgiRI](https://github.com/kkYrusobad/oNIgiRI) menu scripts installation

## 📦 Dependencies

### Core (Required)

| Package | Description |
|---------|-------------|
| **quickshell** | Qt/QML shell framework |
| **niri** | Scrollable-tiling Wayland compositor |
| **JetBrainsMono Nerd Font** | Icons and text rendering |

### Optional (for full functionality)

| Package | Description |
|---------|-------------|
| brightnessctl | Brightness control |
| wlsunset | Night light / Gamma control |
| wl-clipboard | Clipboard management |
| pavucontrol | Audio controls |
| power-profiles-daemon | Power profile switching |
| NetworkManager | WiFi management (nmcli) |
| bluez-utils | Bluetooth (bluetoothctl) |
| cava | Audio visualizer |
| grim, slurp | Screenshots |

### oNIgiRI Dependencies (if installing menu scripts)

| Package | Description |
|---------|-------------|
| fuzzel | Application launcher & menu backend |
| gum | TUI prompts & confirmations |
| fzf | Fuzzy searching |
| alacritty | Terminal for TUI apps |

## 🖥️ Running the Shell

```bash
qs -c niruv
```

### Auto-start with Niri

Add to `~/.config/niri/config.kdl`:

```kdl
spawn-at-startup "qs" "-c" "niruv"
```

### Debug Mode

```bash
NIRUV_DEBUG=1 qs -c niruv
```

## 🛠️ Configuration

Settings are automatically created on first launch at:
`~/.config/niruv/settings.json`

The shell supports live-reloading — changes take effect immediately upon saving.

## ⌨️ IPC Controls

Control the shell from the terminal:

```bash
qs -c niruv ipc call launcher toggle   # Toggle launcher
qs -c niruv ipc call osd toggle        # Toggle OSD
```

### Niri Keybindings

```kdl
binds {
    Mod+D { spawn "qs" "-c" "niruv" "ipc" "call" "launcher" "toggle"; }
}
```

## 📜 Credits

Niruv is inspired by [Noctalia Shell](https://github.com/nicholasswift/noctalia-shell) and integrates with [oNIgiRI](https://github.com/kkYrusobad/oNIgiRI) for system menus.
