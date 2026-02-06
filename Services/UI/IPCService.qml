import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  IpcHandler {
    target: "launcher"
    function toggle() {
      shellRoot.launcher.toggle();
    }
    
    function open() {
      shellRoot.launcher.open();
    }
    
    function close() {
      shellRoot.launcher.close();
    }
  }

  // Add more handlers as needed
  IpcHandler {
    target: "shell"
    function reload() {
      Quickshell.reload();
    }
  }
}
