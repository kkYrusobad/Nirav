import QtQuick
import QtQuick.Layouts
import qs.Commons

/*
 * CalendarHeaderCard - Date header with large day number and clock
 * Shows: Day number, Month/Year, Digital time
 */
Rectangle {
  id: root

  Layout.fillWidth: true
  implicitHeight: 70
  radius: Style.radiusL
  color: Color.mPrimary

  readonly property var now: Time.now

  RowLayout {
    anchors.fill: parent
    anchors.margins: Style.marginL
    spacing: Style.marginM

    // Large day number
    Text {
      text: root.now.getDate()
      color: Color.mOnPrimary
      font.family: Style.fontFamily
      font.pixelSize: 42
      font.weight: Style.fontWeightBold
      Layout.alignment: Qt.AlignVCenter
    }

    // Month and Year column
    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: -2

      Text {
        text: root.now.toLocaleDateString(Qt.locale(), "MMMM").toUpperCase()
        color: Color.mOnPrimary
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeXL
        font.weight: Style.fontWeightBold
      }

      Text {
        text: root.now.getFullYear()
        color: Qt.alpha(Color.mOnPrimary, 0.7)
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeM
        font.weight: Style.fontWeightMedium
      }
    }

    // Digital clock
    Text {
      text: root.now.toLocaleTimeString(Qt.locale(), "HH:mm")
      color: Color.mOnPrimary
      font.family: Style.fontFamily
      font.pixelSize: Style.fontSizeXXL
      font.weight: Style.fontWeightBold
      Layout.alignment: Qt.AlignVCenter
    }
  }
}
