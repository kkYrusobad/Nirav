/*
 * Niruv – A minimal Gruvbox-themed desktop shell for Niri
 * Built on Quickshell (Qt/QML)
 * Licensed under the MIT License.
 */

// Qt & Quickshell Core
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io


// Commons
import qs.Commons

// Services
import qs.Services.System

// Modules
import qs.Modules.Bar
import qs.Modules.Launcher

ShellRoot {
  id: shellRoot

  // Global launcher reference for accessibility
  property alias launcher: launcher

  Component.onCompleted: {
    Logger.i("Shell", "---------------------------");
    Logger.i("Shell", "Niruv Shell Hello!");
    Logger.i("Shell", "---------------------------");

    // Create launcher trigger file if it doesn't exist
    initTrigger.running = true;
  }


  // Reload handling
  Connections {
    target: Quickshell
    function onReloadCompleted() {
      Quickshell.inhibitReloadPopup();
    }
    function onReloadFailed() {
      if (Settings?.isDebug) {
        // Only show popup in debug mode
      } else {
        Quickshell.inhibitReloadPopup();
      }
    }
  }

  // Create a bar on each screen
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: barWindow
      required property ShellScreen modelData

      screen: modelData

      // Layer shell anchors for top bar
      anchors {
        top: true
        left: true
        right: true
      }

      // Bar dimensions
      implicitHeight: Style.barHeight

      // Layer shell properties
      WlrLayershell.namespace: "niruv-bar"
      WlrLayershell.layer: WlrLayer.Top
      exclusiveZone: implicitHeight

      // Transparent background (we draw our own)
      color: "transparent"

      // Bar content
      Bar {
        anchors.fill: parent
        screen: barWindow.modelData
      }
    }
  }

  // Panel backdrop overlay (transparent, click-outside-to-close)
  // Appears on each screen when a popup panel is open
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panelBackdrop
      required property ShellScreen modelData

      screen: modelData

      // Cover the entire screen (except bar)
      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      // Layer shell properties - sits between bar and popups
      WlrLayershell.namespace: "niruv-panel-backdrop"
      WlrLayershell.layer: WlrLayer.Top
      // No exclusive zone - doesn't reserve space

      // Fully transparent - just catches clicks
      color: "transparent"
      
      // Only visible when a panel is open
      visible: PanelState.hasOpenPanel

      // Catch clicks anywhere on this overlay to close panels
      MouseArea {
        anchors.fill: parent
        onClicked: {
          PanelState.closeOpenPanel();
        }
      }
    }
  }

  // Launcher overlay (on primary screen)
  PanelWindow {
    id: launcherWindow

    screen: Quickshell.screens[0] || null

    // Cover the entire screen
    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    // Layer shell properties
    WlrLayershell.namespace: "niruv-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: launcher.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Semi-transparent backdrop
    color: launcher.isOpen ? "#80000000" : "transparent"
    visible: launcher.isOpen

    Behavior on color {
      ColorAnimation { duration: Style.animationFast }
    }

    // Launcher component
    Launcher {
      id: launcher
      anchors.fill: parent
    }
  }

  // TODO: Add IpcHandler when Quickshell version supports it
  // Usage: qs -c niruv ipc call launcher toggle
  // For now, use keyboard shortcut in Niri config to run:
  //   qs -c niruv ipc call launcher toggle
  // Or spawn the shell and use a global keybind to trigger launcher

  // =========================================
  // File-based trigger for global keybindings
  // =========================================
  // Niri keybinding should run: date +%s%N > /tmp/niruv-launcher-toggle
  // The shell polls this file and toggles the launcher when mtime changes

  property string lastTriggerMtime: ""

  Timer {
    id: launcherTriggerPoll
    interval: 200  // Poll every 200ms
    repeat: true
    running: true

    onTriggered: {
      mtimeChecker.running = true;
    }
  }

  Process {
    id: mtimeChecker
    command: ["stat", "-c", "%Y", "/tmp/niruv-launcher-toggle"]
    running: false

    stdout: SplitParser {
      onRead: data => {
        const newMtime = data.trim();
        if (shellRoot.lastTriggerMtime === "") {
          // First read - just store the value
          shellRoot.lastTriggerMtime = newMtime;
        } else if (newMtime !== shellRoot.lastTriggerMtime) {
          // File was modified
          shellRoot.lastTriggerMtime = newMtime;
          Logger.d("Shell", "Launcher trigger detected: " + newMtime);
          launcher.toggle();
        }
      }
    }
  }




  Process {
    id: initTrigger
    command: ["sh", "-c", "touch /tmp/niruv-launcher-toggle 2>/dev/null || true"]
    running: false
  }
}


