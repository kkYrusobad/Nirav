import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services.System

Variants {
  model: Quickshell.screens

  delegate: PanelWindow {
    id: notifWindow
    screen: modelData

    WlrLayershell.namespace: "niruv-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    color: "transparent"

    anchors {
      top: true
      right: true
    }

    margins {
      top: Style.marginL + Style.barHeight
      right: Style.marginL
    }

    implicitWidth: 350
    implicitHeight: notificationStack.implicitHeight + Style.marginL

    ColumnLayout {
      id: notificationStack
      width: 350
      spacing: Style.marginS

      Repeater {
        model: NotificationService.activeList

        delegate: Rectangle {
          Layout.preferredWidth: 350
          Layout.preferredHeight: contentLayout.implicitHeight + Style.marginL * 2
          
          radius: Style.radiusM
          color: Color.mSurface
          border.color: Color.mOutline
          border.width: Style.borderS

          RowLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: Style.marginM
            spacing: Style.marginM

            Rectangle {
              Layout.preferredWidth: 32
              Layout.preferredHeight: 32
              radius: Style.radiusS
              color: Color.mSurfaceVariant
              
              Text {
                anchors.centerIn: parent
                text: "󰂚" // Notification icon
                font.family: Style.fontFamily
                font.pointSize: 14
                color: model.urgency === 2 ? Color.mError : Color.mPrimary
              }
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 2

              Text {
                Layout.fillWidth: true
                text: model.summary
                font.family: Style.fontFamily
                font.pointSize: Style.fontSizeM
                font.weight: Font.Bold
                color: Color.mOnSurface
                elide: Text.ElideRight
                maximumLineCount: 1
              }

              Text {
                Layout.fillWidth: true
                text: model.body
                font.family: Style.fontFamily
                font.pointSize: Style.fontSizeS
                color: Color.mOnSurfaceVariant
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
              }
            }
          }

          MouseArea {
            anchors.fill: parent
            onClicked: NotificationService.removeNotification(model.id)
          }
        }
      }
    }
  }
}
