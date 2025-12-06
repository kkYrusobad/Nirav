/*
 * Niruv – A minimal Gruvbox-themed desktop shell for Niri
 * Built on Quickshell (Qt/QML)
 * Licensed under the MIT License.
 */

// Qt & Quickshell Core
import QtQuick
import Quickshell
import Quickshell.Wayland

// Commons
import qs.Commons

// Modules
import qs.Modules.Bar

ShellRoot {
  id: shellRoot

  Component.onCompleted: {
    Logger.i("Shell", "---------------------------");
    Logger.i("Shell", "Niruv Shell Hello!");
    Logger.i("Shell", "---------------------------");
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
}
