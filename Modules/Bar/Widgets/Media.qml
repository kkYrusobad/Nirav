import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.Commons

/*
 * Niruv Media Widget - Shows current playing media (Noctalia-style)
 * Capsule design: [Icon | Artist - Title]
 * Click to play/pause, right-click for next track
 */
Item {
  id: root

  property ShellScreen screen: null

  // --- Media State ---
  // Find the active/playing MPRIS player
  readonly property var currentPlayer: {
    if (!Mpris.players || !Mpris.players.values) return null;
    let players = Mpris.players.values;
    
    // First, find a playing player
    for (let i = 0; i < players.length; i++) {
      if (players[i] && players[i].playbackState === MprisPlaybackState.Playing) {
        return players[i];
      }
    }
    // Fallback to first controllable player
    for (let i = 0; i < players.length; i++) {
      if (players[i] && players[i].canControl) {
        return players[i];
      }
    }
    return null;
  }

  readonly property bool hasPlayer: currentPlayer !== null
  readonly property bool isPlaying: hasPlayer && currentPlayer.playbackState === MprisPlaybackState.Playing
  readonly property string trackTitle: hasPlayer ? (currentPlayer.trackTitle || "") : ""
  readonly property string trackArtist: hasPlayer ? (currentPlayer.trackArtist || "") : ""

  // Display text: "Artist - Title" or just "Title"
  readonly property string displayText: {
    if (!hasPlayer) return "Nothing playing...";
    if (trackArtist && trackTitle) return trackArtist + " - " + trackTitle;
    if (trackTitle) return trackTitle;
    return "Nothing playing...";
  }

  // Icon based on state
  readonly property string mediaIconText: {
    if (!hasPlayer) return "";           // music-off / no media
    if (isPlaying) return "";            // pause (click to pause)
    return "";                            // play (click to play)
  }

  // --- Dimensions ---
  implicitWidth: capsule.width
  implicitHeight: Style.barHeight

  // Always visible
  visible: true
  opacity: 1.0

  Behavior on implicitWidth {
    NumberAnimation { duration: Style.animationFast; easing.type: Easing.OutCubic }
  }

  // --- UI ---

  // Capsule background (Noctalia-style)
  Rectangle {
    id: capsule
    anchors.verticalCenter: parent.verticalCenter
    width: contentRow.width + Style.marginS * 4
    height: 20
    radius: height / 2
    color: mouseArea.containsMouse ? Color.mBlue : Color.mSurfaceVariant

    Behavior on color {
      ColorAnimation {
        duration: Style.animationFast
        easing.type: Easing.InOutQuad
      }
    }

    Behavior on width {
      NumberAnimation {
        duration: Style.animationFast
        easing.type: Easing.OutCubic
      }
    }

    Row {
      id: contentRow
      anchors.centerIn: parent
      spacing: Style.marginS

      // Media icon (left side, like Noctalia)
      Text {
        id: mediaIcon
        anchors.verticalCenter: parent.verticalCenter
        text: root.mediaIconText
        color: mouseArea.containsMouse ? Color.mOnPrimary : Color.mOnSurface
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeM
        font.weight: Font.Normal

        Behavior on color {
          ColorAnimation {
            duration: Style.animationFast
            easing.type: Easing.InOutCubic
          }
        }
      }

      // Track info text (right of icon)
      Text {
        id: infoText
        anchors.verticalCenter: parent.verticalCenter
        text: root.displayText
        color: mouseArea.containsMouse ? Color.mOnPrimary : Color.mOnSurface
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeS
        font.weight: Style.fontWeightMedium
        // Limit max width and elide
        width: Math.min(implicitWidth, 180)
        elide: Text.ElideRight
        visible: root.displayText !== ""

        Behavior on color {
          ColorAnimation {
            duration: Style.animationFast
            easing.type: Easing.InOutCubic
          }
        }
      }
    }

    // --- Interaction ---
    MouseArea {
      id: mouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onClicked: (mouse) => {
        if (!root.hasPlayer || !root.currentPlayer) return;
        
        if (mouse.button === Qt.LeftButton) {
          // Play/pause
          if (root.isPlaying) {
            root.currentPlayer.pause();
          } else {
            root.currentPlayer.play();
          }
        } else if (mouse.button === Qt.RightButton) {
          // Next track
          if (root.currentPlayer.canGoNext) {
            root.currentPlayer.next();
          }
        }
      }
    }
  }
}
