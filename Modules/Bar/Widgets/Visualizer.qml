import QtQuick
import Quickshell
import qs.Commons
import qs.Services.Media

/*
 * Niruv Visualizer Widget - Audio spectrum bars for the bar
 * With capsule backdrop like Media widget
 */
Item {
  id: root

  property ShellScreen screen: null
  property color fillColor: Color.mPrimary
  property bool showMinimumSignal: true
  property real minimumSignalValue: 0.03

  implicitWidth: capsule.width
  implicitHeight: Style.barHeight

  // Get values from CavaService
  readonly property var values: CavaService.values
  readonly property int valuesCount: (values && Array.isArray(values)) ? values.length : 0
  readonly property int totalBars: valuesCount * 2
  readonly property real barSlotSize: totalBars > 0 ? spectrumContainer.width / totalBars : 0

  // Capsule backdrop
  Rectangle {
    id: capsule
    anchors.verticalCenter: parent.verticalCenter
    width: spectrumContainer.width + Style.marginS * 2
    height: 20
    radius: height / 2
    color: Color.mSurfaceVariant
  }

  // Spectrum bars container
  Item {
    id: spectrumContainer
    anchors.centerIn: capsule
    width: 180
    height: 14

    Repeater {
      model: root.totalBars

      Rectangle {
        // First half mirrored, second half normal
        property int valueIndex: index < root.valuesCount 
                                 ? root.valuesCount - 1 - index 
                                 : index - root.valuesCount

        property real rawAmp: (root.values && root.values[valueIndex] !== undefined) 
                              ? root.values[valueIndex] : 0
        property real amp: (root.showMinimumSignal && rawAmp === 0) 
                           ? root.minimumSignalValue : rawAmp

        color: root.fillColor
        radius: 1
        antialiasing: true

        width: root.barSlotSize * 0.5
        height: spectrumContainer.height * amp
        x: index * root.barSlotSize + (root.barSlotSize * 0.25)
        y: spectrumContainer.height - height

        visible: root.visible
      }
    }
  }
}
