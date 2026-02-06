#!/bin/bash

# Niruv Shell - Installation Script
# Installs Niruv shell with optional oNIgiRI scripts

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}"
echo "  ╔═══════════════════════════════════════════════════════╗"
echo "  ║      निरव · Niruv Shell Installer                     ║"
echo "  ║      A minimal, Gruvbox-themed shell for Niri         ║"
echo "  ╚═══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Get script directory (works even if script is sourced)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIRUV_DIR="$SCRIPT_DIR"

# ========================================
# 1. Check Core Dependencies
# ========================================
echo -e "${BLUE}[1/5]${NC} Checking core dependencies..."

core_deps=("quickshell" "niri")
missing_core=()

for dep in "${core_deps[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        missing_core+=("$dep")
    fi
done

if [ ${#missing_core[@]} -ne 0 ]; then
    echo -e "${RED}Error: Missing required dependencies: ${missing_core[*]}${NC}"
    echo -e "${YELLOW}Please install them first:${NC}"
    echo -e "  sudo pacman -S ${missing_core[*]}"
    exit 1
fi
echo -e "${GREEN}✓ Core dependencies found${NC}"

# ========================================
# 2. Install Optional Dependencies
# ========================================
echo -e "\n${BLUE}[2/5]${NC} Checking optional dependencies..."

optional_deps=(
    "brightnessctl"
    "wlsunset"
    "wl-copy"
    "pavucontrol"
    "power-profiles-daemon"
    "cava"
    "notify-send"
    "grim"
    "slurp"
)
missing_optional=()

for dep in "${optional_deps[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        missing_optional+=("$dep")
    fi
done

if [ ${#missing_optional[@]} -ne 0 ]; then
    echo -e "${YELLOW}Optional dependencies missing: ${missing_optional[*]}${NC}"
    read -p "Install optional dependencies? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Installing optional dependencies...${NC}"
        # Map command names to package names where they differ
        pkgs=()
        for dep in "${missing_optional[@]}"; do
            case "$dep" in
                "notify-send") pkgs+=("libnotify") ;;
                "wl-copy") pkgs+=("wl-clipboard") ;;
                *) pkgs+=("$dep") ;;
            esac
        done
        sudo pacman -S --needed --noconfirm "${pkgs[@]}" || echo -e "${YELLOW}Some packages may not be available${NC}"
    fi
else
    echo -e "${GREEN}✓ All optional dependencies found${NC}"
fi

# ========================================
# 3. Setup Configuration Directories
# ========================================
echo -e "\n${BLUE}[3/5]${NC} Setting up configuration directories..."

mkdir -p "$HOME/.config/niruv"
mkdir -p "$HOME/.cache/niruv"
echo -e "${GREEN}✓ Created ~/.config/niruv and ~/.cache/niruv${NC}"

# ========================================
# 4. Create Quickshell Symlink
# ========================================
echo -e "\n${BLUE}[4/5]${NC} Creating Quickshell configuration..."

QS_CONFIG_DIR="$HOME/.config/quickshell"
mkdir -p "$QS_CONFIG_DIR"

if [ -L "$QS_CONFIG_DIR/niruv" ]; then
    rm "$QS_CONFIG_DIR/niruv"
fi

ln -sf "$NIRUV_DIR" "$QS_CONFIG_DIR/niruv"
echo -e "${GREEN}✓ Linked $NIRUV_DIR → $QS_CONFIG_DIR/niruv${NC}"

# ========================================
# 5. Optional: Install oNIgiRI Scripts
# ========================================
echo -e "\n${BLUE}[5/5]${NC} oNIgiRI Scripts (Optional)"
echo -e "${YELLOW}oNIgiRI provides system menu scripts, launchers, and TUI utilities for Niri.${NC}"
echo -e "${YELLOW}Repository: https://github.com/kkYrusobad/oNIgiRI${NC}"
echo

read -p "Install oNIgiRI scripts? [y/N] " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    ONIGIRI_DIR="$HOME/.local/share/oNIgiRI"
    
    # Check oNIgiRI dependencies
    onigiri_deps=("fuzzel" "gum" "fzf" "alacritty")
    missing_onigiri=()
    
    for dep in "${onigiri_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_onigiri+=("$dep")
        fi
    done
    
    if [ ${#missing_onigiri[@]} -ne 0 ]; then
        echo -e "${YELLOW}oNIgiRI dependencies missing: ${missing_onigiri[*]}${NC}"
        read -p "Install oNIgiRI dependencies? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo pacman -S --needed --noconfirm "${missing_onigiri[@]}" || true
        fi
    fi
    
    # Clone or update oNIgiRI
    if [ -d "$ONIGIRI_DIR/.git" ]; then
        echo -e "${BLUE}Updating existing oNIgiRI installation...${NC}"
        cd "$ONIGIRI_DIR" && git pull
    else
        echo -e "${BLUE}Cloning oNIgiRI...${NC}"
        rm -rf "$ONIGIRI_DIR"
        git clone https://github.com/kkYrusobad/oNIgiRI.git "$ONIGIRI_DIR"
    fi
    
    # Add oNIgiRI bin to PATH
    ONIGIRI_BIN="$ONIGIRI_DIR/bin"
    
    # Check if already in PATH
    if [[ ":$PATH:" != *":$ONIGIRI_BIN:"* ]]; then
        echo -e "${YELLOW}Adding oNIgiRI to your PATH...${NC}"
        
        # Detect shell and add to appropriate rc file
        if [ -f "$HOME/.bashrc" ]; then
            echo "export PATH=\"\$PATH:$ONIGIRI_BIN\"" >> "$HOME/.bashrc"
            echo -e "${GREEN}✓ Added to ~/.bashrc${NC}"
        fi
        if [ -f "$HOME/.zshrc" ]; then
            echo "export PATH=\"\$PATH:$ONIGIRI_BIN\"" >> "$HOME/.zshrc"
            echo -e "${GREEN}✓ Added to ~/.zshrc${NC}"
        fi
        if [ -d "$HOME/.config/fish" ]; then
            mkdir -p "$HOME/.config/fish/conf.d"
            echo "set -gx PATH \$PATH $ONIGIRI_BIN" > "$HOME/.config/fish/conf.d/onigiri.fish"
            echo -e "${GREEN}✓ Added to fish config${NC}"
        fi
        
        echo -e "${YELLOW}Note: Restart your shell or run 'source ~/.bashrc' to update PATH${NC}"
    fi
    
    echo -e "${GREEN}✓ oNIgiRI installed to $ONIGIRI_DIR${NC}"
fi

# ========================================
# Done!
# ========================================
echo
echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  Installation Complete! 󰄛${NC}"
echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════${NC}"
echo
echo -e "To start Niruv, run:"
echo -e "  ${YELLOW}qs -c niruv${NC}"
echo
echo -e "To auto-start with Niri, add this to ~/.config/niri/config.kdl:"
echo -e "  ${YELLOW}spawn-at-startup \"qs\" \"-c\" \"niruv\"${NC}"
echo
echo -e "For debug mode:"
echo -e "  ${YELLOW}NIRUV_DEBUG=1 qs -c niruv${NC}"
echo
echo -e "Enjoy your quiet shell! 󰊠"
