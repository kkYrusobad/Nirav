import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.Media

/*
 * VolumePanel - Popup panel with volume controls
 * Shows: Volume slider, mute toggle, open mixer button
 */
PopupWindow {
  id: root

  property Item anchorItem: null
  property ShellScreen screen: null

  visible: false
  color: "transparent"

  // Position below the anchor item
  anchor.item: anchorItem
  anchor.rect.x: anchorItem ? (anchorItem.width - panelWidth) / 2 : 0
  anchor.rect.y: anchorItem ? anchorItem.height + Style.marginS : 0

  property real panelWidth: 260

  implicitWidth: panelContent.width
  implicitHeight: panelContent.height

  function toggle() {
    if (visible) {
      close();
    } else {
      open();
    }
  }

  function open() {
    PanelState.openPanel(root);
    visible = true;
  }

  function close() {
    visible = false;
    PanelState.panelClosed(root);
  }

  // Volume state from AudioService
  readonly property real volume: AudioService.volume
  readonly property bool muted: AudioService.muted
  readonly property int volumePercent: Math.round(volume * 100)

  // Panel background
  Rectangle {
    id: panelContent
    width: root.panelWidth
    height: contentColumn.implicitHeight + Style.marginL * 2
    radius: Style.radiusL
    color: Color.mSurface
    border.color: Color.mOutline
    border.width: Style.borderS

    // Shadow effect
    Rectangle {
      anchors.fill: parent
      anchors.margins: -2
      z: -1
      radius: parent.radius + 2
      color: Qt.alpha(Color.mShadow, 0.3)
    }

    ColumnLayout {
      id: contentColumn
      anchors.fill: parent
      anchors.margins: Style.marginL
      spacing: Style.marginM

      // Header with volume icon and percentage
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        radius: Style.radiusM
        color: root.muted ? Color.mSurfaceVariant : Color.mPrimary

        Behavior on color {
          ColorAnimation { duration: Style.animationFast }
        }

        RowLayout {
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginM

          // Volume icon (clickable mute toggle)
          Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: width / 2
            color: muteIconMouseArea.containsMouse ? Qt.alpha(Color.mOnPrimary, 0.2) : "transparent"

            Text {
              anchors.centerIn: parent
              text: AudioService.getIcon()
              color: root.muted ? Color.mOnSurfaceVariant : Color.mOnPrimary
              font.family: Style.fontFamily
              font.pixelSize: 22
            }

            MouseArea {
              id: muteIconMouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: AudioService.toggleMute()
            }
          }

          Column {
            Layout.fillWidth: true
            spacing: -2

            Text {
              text: root.muted ? "Muted" : root.volumePercent + "%"
              color: root.muted ? Color.mOnSurfaceVariant : Color.mOnPrimary
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeXL
              font.weight: Style.fontWeightBold
            }

            Text {
              text: "Volume"
              color: Qt.alpha(root.muted ? Color.mOnSurfaceVariant : Color.mOnPrimary, 0.7)
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeS
            }
          }
        }
      }

      // Volume slider card
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 60
        radius: Style.radiusM
        color: Color.mSurfaceVariant
        border.color: Color.mOutline
        border.width: Style.borderS

        RowLayout {
          anchors.fill: parent
          anchors.margins: Style.marginM
          spacing: Style.marginS

          // Low volume icon
          Text {
            text: "󰕿"
            color: Color.mOnSurfaceVariant
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeL
          }

          // Slider track
          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 24

            // Track background
            Rectangle {
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              height: 6
              radius: 3
              color: Color.mOutline
            }

            // Track fill
            Rectangle {
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width * root.volume
              height: 6
              radius: 3
              color: root.muted ? Color.mOnSurfaceVariant : Color.mPrimary

              Behavior on width {
                NumberAnimation { duration: 50 }
              }
            }

            // Handle
            Rectangle {
              x: parent.width * root.volume - width / 2
              anchors.verticalCenter: parent.verticalCenter
              width: 16
              height: 16
              radius: width / 2
              color: root.muted ? Color.mOnSurfaceVariant : Color.mPrimary
              border.color: Color.mSurface
              border.width: 2

              Behavior on x {
                NumberAnimation { duration: 50 }
              }
            }

            // Mouse interaction
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor

              onPressed: (mouse) => {
                updateVolume(mouse.x);
              }

              onPositionChanged: (mouse) => {
                if (pressed) {
                  updateVolume(mouse.x);
                }
              }

              function updateVolume(mouseX) {
                var newVolume = Math.max(0, Math.min(1, mouseX / width));
                AudioService.setVolume(newVolume);
              }
            }
          }

          // High volume icon
          Text {
            text: "󰕾"
            color: Color.mOnSurfaceVariant
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeL
          }
        }
      }

      // Open mixer button
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36
        radius: Style.radiusS
        color: mixerMouseArea.containsMouse ? Qt.alpha(Color.mPrimary, 0.2) : Color.mSurfaceVariant
        border.color: Color.mOutline
        border.width: Style.borderS

        Behavior on color {
          ColorAnimation { duration: Style.animationFast }
        }

        RowLayout {
          anchors.centerIn: parent
          spacing: Style.marginS

          Text {
            text: "󰕾"
            color: Color.mPrimary
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeL
          }

          Text {
            text: "Open Audio Mixer"
            color: Color.mOnSurface
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeS
            font.weight: Style.fontWeightMedium
          }
        }

        MouseArea {
          id: mixerMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.close();
            mixerProcess.running = true;
          }
        }
      }
    }

    // Animation
    scale: root.visible ? 1.0 : 0.95
    opacity: root.visible ? 1.0 : 0.0
    transformOrigin: Item.Top

    Behavior on scale {
      NumberAnimation {
        duration: Style.animationFast
        easing.type: Easing.OutCubic
      }
    }

    Behavior on opacity {
      NumberAnimation {
        duration: Style.animationFast
        easing.type: Easing.OutCubic
      }
    }
  }

  // Process to open mixer
  Process {
    id: mixerProcess
    command: ["sh", "-c", "pwvucontrol || pavucontrol || alsamixer"]
  }

  // Close on Escape key
  Shortcut {
    sequence: "Escape"
    enabled: root.visible
    onActivated: root.close()
  }
}
