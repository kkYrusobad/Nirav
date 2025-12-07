import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.System

/*
 * Niruv SystemMonitor Widget - Compact system stats display
 * Shows: CPU%, RAM%, Temperature, Load Average
 */
Item {
  id: root

  property ShellScreen screen: null

  // Track hover state for expansion
  property bool isHovered: false

  // Dimensions
  implicitWidth: contentRow.width + Style.marginS * 2
  implicitHeight: Style.barHeight

  // Capsule background (Noctalia-style like Media widget)
  Rectangle {
    id: capsule
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
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
  }

  // Content row with all stats
  Row {
    id: contentRow
    anchors.centerIn: parent
    spacing: Style.marginS

    // CPU Usage
    Row {
      spacing: 2
      anchors.verticalCenter: parent.verticalCenter

      Text {
        text: "󰘚"
        color: mouseArea.containsMouse ? Color.mOnPrimary : (SystemStatService.cpuUsage > 80 ? Color.mError : Color.mBlue)
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeL
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
          ColorAnimation { duration: Style.animationFast }
        }
      }

      Text {
        text: Math.round(SystemStatService.cpuUsage) + "%"
        color: mouseArea.containsMouse ? Color.mOnPrimary : Color.mOnSurface
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeS
        font.weight: Style.fontWeightMedium
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
          ColorAnimation { duration: Style.animationFast }
        }
      }
    }

    // RAM Usage
    Row {
      spacing: 2
      anchors.verticalCenter: parent.verticalCenter

      Text {
        text: ""
        color: mouseArea.containsMouse ? Color.mOnPrimary : (SystemStatService.memPercent > 80 ? Color.mError : Color.mBlue)
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeL
        anchors.verticalCenter: parent.verticalCenter
      }

      Text {
        text: Math.round(SystemStatService.memPercent) + "%"
        color: mouseArea.containsMouse ? Color.mOnPrimary : Color.mOnSurface
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeS
        font.weight: Style.fontWeightMedium
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
          ColorAnimation { duration: Style.animationFast }
        }
      }
    }

    // CPU Temperature
    Row {
      spacing: 2
      anchors.verticalCenter: parent.verticalCenter
      visible: SystemStatService.cpuTemp > 0

      Text {
        text: ""
        color: mouseArea.containsMouse ? Color.mBlue : (SystemStatService.cpuTemp > 80 ? Color.mError : Color.mBlue)
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeL
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
          ColorAnimation {
            duration: Style.animationFast
          }
        }
      }

      Text {
        text: Math.round(SystemStatService.cpuTemp) + "°"
        color: mouseArea.containsMouse ? Color.mOnPrimary : Color.mOnSurface
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeS
        font.weight: Style.fontWeightMedium
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
          ColorAnimation { duration: Style.animationFast }
        }
      }
    }

    // Load Average
    Row {
      spacing: 2
      anchors.verticalCenter: parent.verticalCenter

      Text {
        text: ""
        color: mouseArea.containsMouse ? Color.mOnPrimary : Color.mBlue
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeL
        anchors.verticalCenter: parent.verticalCenter
      }

      Text {
        text: SystemStatService.loadAvg.toFixed(2)
        color: mouseArea.containsMouse ? Color.mOnPrimary : Color.mOnSurface
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeS
        font.weight: Style.fontWeightMedium
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
          ColorAnimation { duration: Style.animationFast }
        }
      }
    }
  }

  // Mouse interaction
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true

    onEntered: isHovered = true
    onExited: isHovered = false
  }
}
