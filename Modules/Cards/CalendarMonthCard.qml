import QtQuick
import QtQuick.Layouts
import qs.Commons

/*
 * CalendarMonthCard - Month grid calendar with navigation
 * Features: Month navigation, today highlight, week day headers
 */
Rectangle {
  id: root

  Layout.fillWidth: true
  implicitHeight: calendarContent.implicitHeight + Style.marginM * 2
  radius: Style.radiusM
  color: Color.mSurfaceVariant
  border.color: Color.mOutline
  border.width: Style.borderS

  readonly property var now: Time.now
  property int calendarMonth: now.getMonth()
  property int calendarYear: now.getFullYear()

  // First day of week (0 = Sunday, 1 = Monday)
  readonly property int firstDayOfWeek: 1 // Monday

  ColumnLayout {
    id: calendarContent
    anchors.fill: parent
    anchors.margins: Style.marginM
    spacing: Style.marginS

    // Navigation row
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      // Previous month button
      Rectangle {
        width: 28
        height: 28
        radius: Style.radiusS
        color: prevMouseArea.containsMouse ? Color.mSurface : Color.transparent

        Text {
          anchors.centerIn: parent
          text: "󰅁"
          color: Color.mOnSurface
          font.family: Style.fontFamily
          font.pixelSize: Style.fontSizeL
        }

        MouseArea {
          id: prevMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            let newDate = new Date(root.calendarYear, root.calendarMonth - 1, 1);
            root.calendarYear = newDate.getFullYear();
            root.calendarMonth = newDate.getMonth();
          }
        }
      }

      // Month/Year display
      Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: root.now.toLocaleDateString(Qt.locale(), "MMMM yyyy")
               .replace(root.now.toLocaleDateString(Qt.locale(), "MMMM"),
                        new Date(root.calendarYear, root.calendarMonth, 1)
                        .toLocaleDateString(Qt.locale(), "MMMM"))
               .replace(root.now.getFullYear().toString(), root.calendarYear.toString())
        color: Color.mOnSurface
        font.family: Style.fontFamily
        font.pixelSize: Style.fontSizeM
        font.weight: Style.fontWeightSemiBold

        Component.onCompleted: {
          // Simplified: just show month year
          text = Qt.binding(function() {
            var d = new Date(root.calendarYear, root.calendarMonth, 1);
            return d.toLocaleDateString(Qt.locale(), "MMMM yyyy");
          });
        }
      }

      // Today button
      Rectangle {
        width: 28
        height: 28
        radius: Style.radiusS
        color: todayMouseArea.containsMouse ? Color.mSurface : Color.transparent

        Text {
          anchors.centerIn: parent
          text: "󰃭"
          color: Color.mOnSurface
          font.family: Style.fontFamily
          font.pixelSize: Style.fontSizeL
        }

        MouseArea {
          id: todayMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.calendarMonth = root.now.getMonth();
            root.calendarYear = root.now.getFullYear();
          }
        }
      }

      // Next month button
      Rectangle {
        width: 28
        height: 28
        radius: Style.radiusS
        color: nextMouseArea.containsMouse ? Color.mSurface : Color.transparent

        Text {
          anchors.centerIn: parent
          text: "󰅂"
          color: Color.mOnSurface
          font.family: Style.fontFamily
          font.pixelSize: Style.fontSizeL
        }

        MouseArea {
          id: nextMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            let newDate = new Date(root.calendarYear, root.calendarMonth + 1, 1);
            root.calendarYear = newDate.getFullYear();
            root.calendarMonth = newDate.getMonth();
          }
        }
      }
    }

    // Day name headers
    GridLayout {
      Layout.fillWidth: true
      columns: 7
      columnSpacing: 0
      rowSpacing: 0

      Repeater {
        model: ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
        Item {
          Layout.fillWidth: true
          Layout.preferredHeight: 24

          Text {
            anchors.centerIn: parent
            text: modelData
            color: Color.mPrimary
            font.family: Style.fontFamily
            font.pixelSize: Style.fontSizeS
            font.weight: Style.fontWeightBold
          }
        }
      }
    }

    // Calendar grid
    GridLayout {
      id: grid
      Layout.fillWidth: true
      columns: 7
      columnSpacing: 2
      rowSpacing: 2

      property var daysModel: {
        const firstOfMonth = new Date(root.calendarYear, root.calendarMonth, 1);
        const lastOfMonth = new Date(root.calendarYear, root.calendarMonth + 1, 0);
        const daysInMonth = lastOfMonth.getDate();
        const firstDayOfWeek = root.firstDayOfWeek;
        const firstOfMonthDayOfWeek = firstOfMonth.getDay();

        // Calculate days before first of month (adjust for Monday start)
        let daysBefore = (firstOfMonthDayOfWeek - firstDayOfWeek + 7) % 7;

        const days = [];
        const today = new Date();

        // Previous month days
        const prevMonth = new Date(root.calendarYear, root.calendarMonth, 0);
        const prevMonthDays = prevMonth.getDate();
        for (var i = daysBefore - 1; i >= 0; i--) {
          const day = prevMonthDays - i;
          days.push({
            "day": day,
            "month": root.calendarMonth - 1,
            "year": root.calendarMonth === 0 ? root.calendarYear - 1 : root.calendarYear,
            "today": false,
            "currentMonth": false
          });
        }

        // Current month days
        for (var day = 1; day <= daysInMonth; day++) {
          const date = new Date(root.calendarYear, root.calendarMonth, day);
          const isToday = date.getFullYear() === today.getFullYear() &&
                          date.getMonth() === today.getMonth() &&
                          date.getDate() === today.getDate();
          days.push({
            "day": day,
            "month": root.calendarMonth,
            "year": root.calendarYear,
            "today": isToday,
            "currentMonth": true
          });
        }

        // Next month days (fill to 42 cells = 6 weeks)
        const remaining = 42 - days.length;
        for (var i = 1; i <= remaining; i++) {
          days.push({
            "day": i,
            "month": root.calendarMonth + 1,
            "year": root.calendarMonth === 11 ? root.calendarYear + 1 : root.calendarYear,
            "today": false,
            "currentMonth": false
          });
        }

        return days;
      }

      Repeater {
        model: grid.daysModel

        Item {
          Layout.fillWidth: true
          Layout.preferredHeight: 28

          Rectangle {
            width: 26
            height: 26
            anchors.centerIn: parent
            radius: Style.radiusS
            color: modelData.today ? Color.mSecondary : Color.transparent

            Text {
              anchors.centerIn: parent
              text: modelData.day
              color: {
                if (modelData.today) return Color.mOnSecondary;
                if (modelData.currentMonth) return Color.mOnSurface;
                return Color.mOnSurfaceVariant;
              }
              opacity: modelData.currentMonth ? 1.0 : 0.4
              font.family: Style.fontFamily
              font.pixelSize: Style.fontSizeS
              font.weight: modelData.today ? Style.fontWeightBold : Style.fontWeightMedium
            }
          }
        }
      }
    }
  }
}
