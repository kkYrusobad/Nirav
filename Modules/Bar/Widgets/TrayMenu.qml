import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons

/*
 * Niruv TrayMenu - Context menu for system tray items
 * Displays menu items from tray item's QsMenuHandle
 * Integrates with PanelState for click-outside-to-close
 */
PopupWindow {
  id: root

  property ShellScreen screen
  property var trayItem: null
  property Item anchorItem: null
  property real anchorX: 0
  property real anchorY: 0
  property bool isSubMenu: false
  property var parentMenu: null

  // Get menu from tray item (for root menu) or directly passed (for submenus)
  property QsMenuHandle menuHandle: null
  readonly property QsMenuHandle menu: menuHandle ? menuHandle : (trayItem ? trayItem.menu : null)
  readonly property int menuWidth: 220

  implicitWidth: menuWidth
  implicitHeight: Math.min(screen?.height * 0.7 || 400, contentColumn.implicitHeight + Style.marginM * 2)
  visible: false
  color: Color.transparent

  anchor.item: anchorItem
  anchor.rect.x: anchorX
  anchor.rect.y: anchorY
  
  anchor.gravity: {
    if (isSubMenu) return Quickshell.Start; // Submenus open to the right (Start)
    
    // For root menu, center horizontally relative to the anchor point
    // Note: Quickshell handles edge constraints automatically if the window would overflow
    return Quickshell.Center;
  }

  anchor.edges: {
    if (isSubMenu) return Quickshell.RightEdge;
    
    switch (Settings.data.bar.position) {
      case "bottom": return Quickshell.TopEdge;
      default:
      case "top": return Quickshell.BottomEdge;
    }
  }

  function showAt(item, x, y) {
    anchorItem = item;
    anchorX = x;
    anchorY = y;
    visible = true;

    // Register with PanelState if root menu
    if (!isSubMenu) {
      PanelState.openPanel(root);
    }

    Qt.callLater(() => {
      root.anchor.updateAnchor();
    });
  }

  // close() method for PanelState compatibility
  function close() {
    hideMenu();
  }

  function hideMenu() {
    // Close all submenus first
    for (var i = 0; i < contentColumn.children.length; i++) {
      var child = contentColumn.children[i];
      if (child && child.subMenu) {
        child.subMenu.hideMenu();
        child.subMenu.destroy();
        child.subMenu = null;
      }
    }
    visible = false;
    
    // Unregister from PanelState
    if (!isSubMenu) {
      PanelState.panelClosed(root);
    }
  }

  // Menu opener
  QsMenuOpener {
    id: opener
    menu: root.menu
  }

  // Background & Shadow
  Rectangle {
    anchors.fill: parent
    color: Color.mSurface
    border.color: Color.mOutline
    border.width: Style.borderS
    radius: Style.radiusM

    // Shadow effect (layered rectangle)
    Rectangle {
      anchors.fill: parent
      anchors.margins: -2
      z: -1
      radius: parent.radius + 2
      color: Qt.alpha(Color.mShadow, 0.3)
      visible: root.visible
    }

    opacity: root.visible ? 1.0 : 0.0
    scale: root.visible ? 1.0 : 0.98
    
    Behavior on opacity {
      NumberAnimation { duration: Style.animationFast; easing.type: Easing.OutCubic }
    }
    Behavior on scale {
      NumberAnimation { duration: Style.animationFast; easing.type: Easing.OutCubic }
    }
  }

  // Keyboard handling
  Item {
    anchors.fill: parent
    focus: root.visible
    Keys.onEscapePressed: hideMenu()
  }

  // Menu content
  Flickable {
    id: flickable
    anchors.fill: parent
    anchors.margins: Style.marginS
    contentHeight: contentColumn.implicitHeight
    clip: true

    ColumnLayout {
      id: contentColumn
      width: flickable.width
      spacing: 2

      Repeater {
        model: opener.children ? [...opener.children.values] : []

        delegate: Rectangle {
          id: menuItem
          required property var modelData
          property var subMenu: null

          Layout.fillWidth: true
          Layout.preferredHeight: modelData?.isSeparator ? 8 : 32
          color: Color.transparent
          radius: Style.radiusS

          // Separator
          Rectangle {
            anchors.centerIn: parent
            width: parent.width - Style.marginM * 2
            height: 1
            color: Color.mOutline
            visible: modelData?.isSeparator ?? false
          }

          // Menu item content
          Rectangle {
            anchors.fill: parent
            anchors.margins: modelData?.isSeparator ? 0 : 2
            color: itemMouse.containsMouse ? Color.mHover : Color.transparent
            radius: Style.radiusS
            visible: !(modelData?.isSeparator ?? false)

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: Style.marginL
              anchors.rightMargin: Style.marginL
              spacing: Style.marginS

              // Menu item text
              Text {
                Layout.fillWidth: true
                text: modelData?.text?.replace(/[\n\r]+/g, ' ') || "..."
                color: (modelData?.enabled ?? true) 
                  ? (itemMouse.containsMouse ? Color.mOnHover : Color.mOnSurface) 
                  : Color.mOnSurfaceVariant
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeS
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
              }

              // Submenu indicator
              Text {
                text: "›"
                color: Color.mOnSurfaceVariant
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeM
                visible: modelData?.hasChildren ?? false
              }
            }

            MouseArea {
              id: itemMouse
              anchors.fill: parent
              hoverEnabled: true
              enabled: (modelData?.enabled ?? true) && !(modelData?.isSeparator ?? false)

              onClicked: {
                if (modelData && !modelData.isSeparator) {
                  if (modelData.hasChildren) {
                    // Toggle submenu
                    if (menuItem.subMenu) {
                      menuItem.subMenu.hideMenu();
                      menuItem.subMenu.destroy();
                      menuItem.subMenu = null;
                    } else {
                      openSubmenu();
                    }
                  } else {
                    // Trigger action and close entire menu tree
                    modelData.triggered();
                    closeMenuTree();
                  }
                }
              }

              // Open submenu on hover
              onContainsMouseChanged: {
                if (containsMouse && modelData?.hasChildren && !menuItem.subMenu) {
                  openSubmenu();
                }
              }

              function openSubmenu() {
                // Close other submenus first
                for (var i = 0; i < contentColumn.children.length; i++) {
                  var sibling = contentColumn.children[i];
                  if (sibling !== menuItem && sibling.subMenu) {
                    sibling.subMenu.hideMenu();
                    sibling.subMenu.destroy();
                    sibling.subMenu = null;
                  }
                }

                // Open new submenu
                var component = Qt.createComponent("TrayMenu.qml");
                if (component.status === Component.Ready) {
                  menuItem.subMenu = component.createObject(root, {
                    "menuHandle": modelData,
                    "isSubMenu": true,
                    "screen": root.screen,
                    "parentMenu": root
                  });
                  if (menuItem.subMenu) {
                    menuItem.subMenu.showAt(menuItem, root.menuWidth - 4, 0);
                  }
                } else {
                  Logger.e("TrayMenu", "Failed to create submenu: " + component.errorString());
                }
              }

              function closeMenuTree() {
                // Find root menu and close it
                var current = root;
                while (current.parentMenu) {
                  current = current.parentMenu;
                }
                current.hideMenu();
              }
            }
          }

          Component.onDestruction: {
            if (subMenu) {
              subMenu.destroy();
              subMenu = null;
            }
          }
        }
      }
    }
  }

  // Watch for visibility changes to cleanup
  onVisibleChanged: {
    if (!visible && !isSubMenu) {
      // Cleanup when hidden
      for (var i = 0; i < contentColumn.children.length; i++) {
        var child = contentColumn.children[i];
        if (child && child.subMenu) {
          child.subMenu.destroy();
          child.subMenu = null;
        }
      }
    }
  }
}
