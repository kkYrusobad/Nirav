# Installation Guide

This guide covers the requirements and steps to install and run Niruv on your system.

## 📦 Requirements

Before installing Niruv, ensure you have the following dependencies installed:

| Dependency | Description |
|------------|-------------|
| **[quickshell](https://quickshell.outfoxxed.me/)** | The Qt/QML shell framework that powers Niruv. |
| **[niri](https://github.com/YaLTeR/niri)** | The scrollable-tiling Wayland compositor. |
| **JetBrainsMono Nerd Font** | Required for icons and text rendering. |
| **git** | For cloning the repository. |

### Optional Dependencies

- **battop**: For the battery widget's floating status window.
- **libnotify**: For system notifications.
- **brightnessctl**: For screen brightness control.
- **wl-clipboard**: For clipboard operations.

## 📥 Installation Steps

1. **Clone the Repository**

    ```bash
    git clone https://github.com/yourusername/niruv.git
    cd niruv
    ```

2. **Run the Setup Script**

    We provide a `setup.sh` script to automate dependency checks and symlink creation:

    ```bash
    chmod +x setup.sh
    ./setup.sh
    ```

    Alternatively, you can manually create the link:

    ```bash
    mkdir -p ~/.config/quickshell
    ln -sf "$(pwd)/Niruv" ~/.config/quickshell/niruv
    ```

3. **Modern Portability & Troubleshooting**

    Niruv automatically detects its project root. If utilities like Screenshots or the Screensaver don't work, manually specify the project location:

    ```bash
    export NIRUV_PROJECT_DIR="/path/to/your/niruv-folder"
    qs -c niruv
    ```

4. **Run Niruv**

    You can now launch the shell using the `qs` command:

    ```bash
    qs -c niruv
    ```

    To start it automatically with Niri, add the following to your `~/.config/niri/config.kdl`:

    ```kdl
    spawn-at-startup "qs" "-c" "niruv"
    ```

## 🐞 Debug Mode

If you encounter issues or want to see detailed logs, you can run Niruv in debug mode:

```bash
NIRUV_DEBUG=1 qs -c niruv
```

This will enable debug output in the terminal, which is useful for troubleshooting widget behavior or service connections.
