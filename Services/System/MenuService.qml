pragma Singleton

import QtQuick
import Quickshell

import qs.Commons

/*
 * MenuService - Provides menu structure and action handlers
 * Based on niri-menu functionality
 */
Singleton {
  id: root

  // Current menu navigation state
  property string currentCategory: ""  // Empty = show categories, else show items
  property var menuCategories: [
    {
      id: "learn",
      name: "Learn",
      icon: "󰠮",
      items: [
        { name: "Keybindings", icon: "󰌌", action: "keybindings" },
        { name: "Niri Wiki", icon: "󰨡", action: "url:https://github.com/YaLTeR/niri/wiki" },
        { name: "Arch Wiki", icon: "󰣇", action: "url:https://wiki.archlinux.org" },
        { name: "Neovim Docs", icon: "", action: "url:https://www.lazyvim.org/keymaps" },
        { name: "Bash Reference", icon: "", action: "url:https://devhints.io/bash" }
      ]
    },
    {
      id: "trigger",
      name: "Trigger",
      icon: "󰹑",
      items: [
        { name: "Screenshot Region", icon: "󰹑", action: "cmd:niri-cmd-screenshot region" },
        { name: "Screenshot Full", icon: "󰍹", action: "cmd:niri-cmd-screenshot fullscreen" },
        { name: "Screenshot Clipboard", icon: "󰆏", action: "cmd:niri-cmd-screenshot clipboard" },
        { name: "Screen Record", icon: "", action: "cmd:/home/kky/garbage/noctaliaChange/Niruv/Scripts/niri-record" },
        { name: "Toggle Screensaver", icon: "󱄅", action: "cmd:niri-toggle-screensaver" },
        { name: "Toggle Nightlight", icon: "󰔎", action: "cmd:niri-toggle-nightlight" }
      ]
    },
    {
      id: "style",
      name: "Style",
      icon: "󰃣",
      items: [
        { name: "Edit Niri Config", icon: "󰒓", action: "edit:~/.config/niri/config.kdl" },
        { name: "Theme Selection", icon: "󰏘", action: "notify:Theme selection coming soon" }
      ]
    },
    {
      id: "setup",
      name: "Setup",
      icon: "󰒓",
      items: [
        { name: "WiFi", icon: "󰖩", action: "cmd:rfkill unblock wifi; niri-launch-or-focus-tui --floating --center --name WiFi impala" },
        { name: "Bluetooth", icon: "󰂯", action: "cmd:rfkill unblock bluetooth; niri-launch-or-focus-tui --floating --center --name Bluetooth bluetui" },
        { name: "Audio", icon: "󰕾", action: "cmd:pavucontrol" },
        { name: "Power Profile", icon: "󱐋", submenu: "power_profile" }
      ]
    },
    {
      id: "install",
      name: "Install",
      icon: "󰏔",
      items: [
        { name: "Package", icon: "󰏗", action: "cmd:niri-launch-or-focus-tui --floating --center --name PkgInstall niri-pkg-install" },
        { name: "AUR Package", icon: "󰣇", action: "cmd:niri-launch-or-focus-tui --floating --center --name AURInstall niri-pkg-aur-install" },
        { name: "Web App", icon: "󰖟", action: "cmd:niri-launch-or-focus-tui --floating --center --name WebAppInstall niri-webapp-install" },
        { name: "TUI App", icon: "󰆍", action: "cmd:niri-launch-or-focus-tui --floating --center --name TUIInstall niri-tui-install" }
      ]
    },

    {
      id: "remove",
      name: "Remove",
      icon: "󱧖",
      items: [
        { name: "Package", icon: "󱧖", action: "cmd:niri-launch-or-focus-tui --floating --center --name PkgRemove niri-pkg-remove" },
        { name: "My App", icon: "󱍕", action: "cmd:niri-launch-or-focus-tui --floating --center --name AppRemove niri-custom-apps-remove" }
      ]
    },
    {
      id: "about",
      name: "About",
      icon: "󰋽",
      items: [
        { name: "About Niruv", icon: "󰋽", action: "cmd:niri-launch-about" }
      ]
    },
    {
      id: "system",
      name: "System",
      icon: "󱩊",
      items: [
        { name: "Lock Screen", icon: "󰌾", action: "cmd:swaylock" },
        { name: "Screensaver", icon: "󱄅", action: "cmd:niri-launch-screensaver force" },
        { name: "Suspend", icon: "󰒲", action: "cmd:systemctl suspend" },
        { name: "Restart", icon: "󰜉", action: "confirm:systemctl reboot" },
        { name: "Shutdown", icon: "󰐥", action: "confirm:systemctl poweroff" }
      ]
    }
  ]

  // Power profile submenu
  property var powerProfileItems: [
    { name: "Performance", icon: "󱐋", action: "cmd:powerprofilesctl set performance" },
    { name: "Balanced", icon: "󰾅", action: "cmd:powerprofilesctl set balanced" },
    { name: "Power Saver", icon: "󰾆", action: "cmd:powerprofilesctl set power-saver" }
  ]

  // Search state
  property string menuSearchText: ""
  property bool isSearching: menuSearchText.length > 0

  // Get all items flattened (for search)
  function getAllItems() {
    let allItems = [];
    for (let cat of menuCategories) {
      // Add category items with parent info
      for (let item of cat.items) {
        allItems.push({
          name: item.name,
          icon: item.icon,
          action: item.action,
          submenu: item.submenu,
          category: cat.name,
          categoryId: cat.id
        });
      }
    }
    // Add power profile items
    for (let item of powerProfileItems) {
      allItems.push({
        name: item.name,
        icon: item.icon,
        action: item.action,
        category: "Power Profile",
        categoryId: "power_profile"
      });
    }
    return allItems;
  }


  // Get filtered items for search
  function getFilteredItems() {
    if (!isSearching) return [];
    
    const query = menuSearchText.toLowerCase();
    const allItems = getAllItems();
    
    return allItems.filter(item => {
      return item.name.toLowerCase().includes(query) ||
             (item.category && item.category.toLowerCase().includes(query));
    });
  }

  // Get current items to display
  function getCurrentItems() {
    // If searching, return filtered items
    if (isSearching) {
      return getFilteredItems();
    }
    
    if (currentCategory === "") {
      return menuCategories;
    } else if (currentCategory === "power_profile") {
      return powerProfileItems;
    } else {
      for (let cat of menuCategories) {
        if (cat.id === currentCategory) {
          return cat.items;
        }
      }
    }
    return [];
  }


  // Navigate to category
  function openCategory(categoryId) {
    Logger.d("MenuService", "Opening category: " + categoryId);
    currentCategory = categoryId;
  }

  // Go back to categories
  function goBack() {
    if (currentCategory === "power_profile") {
      currentCategory = "setup";
    } else {
      currentCategory = "";
    }
  }

  // Reset navigation
  function reset() {
    currentCategory = "";
    menuSearchText = "";
  }


  // Execute an action
  function executeAction(action, closeLauncher) {
    if (!action) return false;

    Logger.d("MenuService", "Executing action: " + action);

    if (action.startsWith("url:")) {
      const url = action.substring(4);
      Quickshell.execDetached(["xdg-open", url]);
      if (closeLauncher) closeLauncher();
      return true;
    }

    if (action.startsWith("cmd:")) {
      const cmd = action.substring(4);
      // Add oNIgiRI bin directory to PATH for niri-* commands
      const binPath = "/home/kky/garbage/noctaliaChange/oNIgiRI/bin";
      const fullCmd = "export PATH=\"" + binPath + ":$PATH\"; " + cmd;
      Quickshell.execDetached(["sh", "-c", fullCmd]);
      if (closeLauncher) closeLauncher();
      return true;
    }


    if (action.startsWith("edit:")) {
      const file = action.substring(5).replace("~", "/home/" + Qt.platform.os);
      // Use environment EDITOR or fallback to neovim
      Quickshell.execDetached(["sh", "-c", "${EDITOR:-nvim} " + file]);
      if (closeLauncher) closeLauncher();
      return true;
    }

    if (action.startsWith("notify:")) {
      const msg = action.substring(7);
      Quickshell.execDetached(["notify-send", "Niruv", msg]);
      return true;
    }

    if (action.startsWith("confirm:")) {
      const cmd = action.substring(8);
      // For dangerous actions, run in terminal with confirmation
      Quickshell.execDetached(["alacritty", "-e", "sh", "-c", 
        "echo 'Press Enter to confirm or Ctrl+C to cancel:'; read; " + cmd]);
      if (closeLauncher) closeLauncher();
      return true;
    }

    if (action === "keybindings") {
      Quickshell.execDetached(["sh", "-c", "niri-menu-keybindings 2>/dev/null || notify-send 'Keybindings' 'Not available'"]);
      if (closeLauncher) closeLauncher();
      return true;
    }

    return false;
  }
}
