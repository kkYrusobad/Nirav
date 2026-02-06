# Installing & Running Niruv Shell

Niruv is a minimal Gruvbox-themed desktop shell for Wayland (optimized for Niri), built on top of the [Quickshell](https://github.com/outfoxxed/quickshell) framework.

> ⚠️ **Wayland Required** — Niruv does not support X11. You must be running a Wayland session.

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

### Supported Distributions

The install script auto-detects your distribution and uses the appropriate package manager:

| Distro Family | Package Manager | Distributions |
|---------------|-----------------|---------------|
| **Arch** | pacman | Arch, EndeavourOS, Manjaro, CachyOS, Garuda, ArcoLinux |
| **Fedora** | dnf | Fedora, RHEL, CentOS, Rocky, Alma |
| **Debian** | apt | Debian, Ubuntu, Pop!_OS, Linux Mint, Zorin, elementary |
| **openSUSE** | zypper | openSUSE Tumbleweed, openSUSE Leap |
| **Void** | xbps | Void Linux |
| **Alpine** | apk | Alpine Linux |
| **NixOS** | nix | Manual configuration required |

---

## 📦 Dependencies

### System Requirements

| Requirement | Description |
|-------------|-------------|
| **Wayland session** | Required — X11 is not supported |
| **Linux kernel** | With thermal zone support for temperature readings |
| **PipeWire / PulseAudio** | Audio backend |

---

### Core (Required)

| Package | Arch Package | Description |
|---------|--------------|-------------|
| **Quickshell** | `quickshell-git` (AUR) | Qt/QML shell framework |
| **Niri** | `niri` (AUR) | Scrollable-tiling Wayland compositor |
| **Qt6** | `qt6-base qt6-declarative qt6-wayland` | Qt framework (dependency of quickshell) |
| **JetBrainsMono Nerd Font** | `ttf-jetbrains-mono-nerd` | Icons and text rendering |

---

### Shell Widgets

| Package | Arch Package | Widget | Description |
|---------|--------------|--------|-------------|
| brightnessctl | `brightnessctl` | Brightness | Screen brightness control |
| wlsunset | `wlsunset` | NightLight | Gamma/blue light filter |
| cava | `cava` | Visualizer | Audio spectrum visualizer |
| libnotify | `libnotify` | Timer | Desktop notifications (`notify-send`) |
| paplay | `libpulse` | Timer | Sound playback for alarms |
| NetworkManager | `networkmanager` | WiFi | WiFi status (`nmcli`) |
| bluez-utils | `bluez-utils` | Bluetooth | Bluetooth status (`bluetoothctl`) |
| rfkill | `util-linux` | WiFi/Bluetooth | Radio device control |
| wpctl | `wireplumber` | Media/Volume | PipeWire volume control |
| power-profiles-daemon | `power-profiles-daemon` | Battery | Power profile switching |

---

### Screenshots & Recording

| Package | Arch Package | Description |
|---------|--------------|-------------|
| grim | `grim` | Screenshot capture |
| slurp | `slurp` | Region selection |
| wl-clipboard | `wl-clipboard` | Clipboard (`wl-copy`) |
| satty | `satty` (AUR) | Screenshot annotation editor |
| gpu-screen-recorder | `gpu-screen-recorder` (AUR) | Screen recording |

---

### Wallpaper

| Package | Arch Package | Description |
|---------|--------------|-------------|
| swaybg | `swaybg` | Wallpaper setter |

---

### Audio Mixer GUI (any one)

| Package | Arch Package | Description |
|---------|--------------|-------------|
| pwvucontrol | `pwvucontrol` (AUR) | PipeWire volume control (preferred) |
| pavucontrol | `pavucontrol` | PulseAudio volume control |
| alsamixer | `alsa-utils` | Terminal audio mixer (fallback) |

---

### TUI Applications (launched by widgets)

| Package | Arch Package | Widget | Description |
|---------|--------------|--------|-------------|
| impala | `impala` (AUR) | WiFi | TUI WiFi manager |
| bluetui | `bluetui` (AUR) | Bluetooth | TUI Bluetooth manager |
| battop | `battop` (AUR) | Battery | TUI battery monitor |

---

### oNIgiRI Dependencies (optional, for menu scripts)

| Package | Arch Package | Description |
|---------|--------------|-------------|
| fuzzel | `fuzzel` | Wayland application launcher |
| gum | `gum` | TUI prompts & confirmations |
| fzf | `fzf` | Fuzzy finder |
| alacritty | `alacritty` | Terminal emulator for TUI apps |
| yay | `yay` (AUR) | AUR helper for package installation |
| swayidle | `swayidle` | Idle management / screensaver |
| curl | `curl` | Web requests |

---

### Build Dependencies (for compiling quickshell)

| Package | Arch Package | Description |
|---------|--------------|-------------|
| cmake | `cmake` | Build system |
| ninja | `ninja` | Build tool |
| git | `git` | Version control |
| base-devel | `base-devel` | Compiler toolchain |

---

## 📋 One-liner Install (Arch Linux)

```bash
# Core + most optional deps
sudo pacman -S --needed \
  qt6-base qt6-declarative qt6-wayland \
  ttf-jetbrains-mono-nerd \
  brightnessctl wlsunset cava libnotify libpulse \
  networkmanager bluez-utils wireplumber power-profiles-daemon \
  grim slurp wl-clipboard swaybg pavucontrol \
  fuzzel gum fzf alacritty swayidle curl git base-devel cmake ninja

# AUR packages (via yay)
yay -S --needed quickshell-git niri satty gpu-screen-recorder \
  pwvucontrol impala bluetui battop
```

---

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

---

## 🛠️ Configuration

Settings are automatically created on first launch at:
`~/.config/niruv/settings.json`

The shell supports live-reloading — changes take effect immediately upon saving.

---

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

---

## 📜 Credits

Niruv is inspired by [Noctalia Shell](https://github.com/nicholasswift/noctalia-shell) and integrates with [oNIgiRI](https://github.com/kkYrusobad/oNIgiRI) for system menus.
