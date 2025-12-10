import QtQuick
import qs.Commons

/*
 * NBox - Rounded group container for cards and panels
 * Used in ClockPanel to group timer and calendar components
 */
Rectangle {
  id: root

  color: Color.mSurfaceVariant
  radius: Style.radiusM
  border.color: Color.mOutline
  border.width: Style.borderS
}
