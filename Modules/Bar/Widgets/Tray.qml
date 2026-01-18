import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Commons

/*
 * Niruv Tray Widget - System tray icons
 * Shows icons from apps like Discord, Slack, etc.
 */
Item {
  id: root

  property ShellScreen screen: null

  // Dimensions
  readonly property real iconSize: 14
  readonly property bool hasTrayItems: SystemTray.items && SystemTray.items.values && SystemTray.items.values.length > 0

  // Widget width slightly less than capsule - reduces gap on the right
  implicitWidth: hasTrayItems ? capsule.width : 0
  implicitHeight: Style.barHeight
  visible: hasTrayItems

  // Capsule background
  Rectangle {
    id: capsule
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    width: contentRow.width + Style.marginS * 4
    height: 20
    radius: height / 2
    color: Color.mSurfaceVariant
    visible: hasTrayItems
  }

  // Content row with tray icons
  Row {
    id: contentRow
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: Style.marginS * 2
    spacing: Style.marginS
    visible: hasTrayItems

    Repeater {
      model: SystemTray.items ? SystemTray.items.values : []

      delegate: Item {
        id: trayItemDelegate
        width: root.iconSize
        height: root.iconSize
        visible: modelData !== null

        property string tooltipText: modelData?.tooltipTitle || modelData?.name || modelData?.id || "Tray Item"

        IconImage {
          id: trayIcon
          anchors.fill: parent
          asynchronous: true

          source: {
            let icon = modelData?.icon || "";
            if (!icon) return "";

            // Process icon path (handle Quickshell icon format)
            if (icon.includes("?path=")) {
              const chunks = icon.split("?path=");
              const name = chunks[0];
              const path = chunks[1];
              const fileName = name.substring(name.lastIndexOf("/") + 1);
              return `file://${path}/${fileName}`;
            }
            return icon;
          }

          MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: mouse => {
              if (!modelData) return;

              if (mouse.button === Qt.LeftButton) {
                // Left-click: activate or show menu if onlyMenu
                if (!modelData.onlyMenu) {
                  modelData.activate();
                } else if (modelData.hasMenu) {
                  root.showContextMenu(modelData, trayIcon);
                }
              } else if (mouse.button === Qt.MiddleButton) {
                // Middle-click: secondary activate
                if (modelData.secondaryActivate) {
                  modelData.secondaryActivate();
                }
              } else if (mouse.button === Qt.RightButton) {
                // Right-click: show context menu
                root.showContextMenu(modelData, trayIcon);
              }
            }

            onWheel: wheel => {
              if (wheel.angleDelta.y > 0) {
                modelData?.scrollUp();
              } else if (wheel.angleDelta.y < 0) {
                modelData?.scrollDown();
              }
            }
          }
        }

        // Custom tooltip
        Rectangle {
          id: tooltip
          visible: mouseArea.containsMouse
          x: (parent.width - width) / 2
          y: parent.height + 4
          width: tooltipLabel.width + Style.marginS * 2
          height: tooltipLabel.height + Style.marginXS * 2
          color: Color.mSurface
          border.color: Color.mOutline
          border.width: 1
          radius: 4
          z: 100

          Text {
            id: tooltipLabel
            anchors.centerIn: parent
            text: trayItemDelegate.tooltipText
            color: Color.mOnSurface
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeS
          }
        }
      }
    }
  }

  // Context menu component
  property var activeMenu: null

  function showContextMenu(item, anchor) {
    if (!item.hasMenu || !item.menu) {
      Logger.d("Tray", "No menu available for " + (item.name || item.id));
      return;
    }

    // Close existing menu
    if (activeMenu) {
      activeMenu.destroy();
      activeMenu = null;
    }

    // Create new menu
    var component = Qt.createComponent("TrayMenu.qml");
    if (component.status === Component.Ready) {
      activeMenu = component.createObject(root, {
        "trayItem": item,
        "screen": root.screen
      });
      if (activeMenu) {
        activeMenu.showAt(anchor, 0, Style.barHeight);
      }
    } else {
      Logger.e("Tray", "Failed to create menu: " + component.errorString());
    }
  }
}
