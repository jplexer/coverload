import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Silica.Background 1.0

Grid {
    id: strip

    property var actions: []
    property Item host

    signal triggered(int index)

    readonly property bool housekeeping: host ? host.editMode : false

    height: Math.min(Theme.itemSizeSmall, Math.round(width / 2))
    columns: Math.max(1, actions.length)

    Repeater {
        model: strip.actions.length

        delegate: MouseArea {
            id: button

            readonly property var action: strip.actions[index] || {}
            readonly property bool available: action.enabled !== false

            width: strip.width / strip.columns
            height: strip.height
            enabled: !strip.housekeeping && available

            onClicked: strip.triggered(index)

            ColorBackground {
                anchors.fill: parent
                visible: button.pressed && button.containsMouse && button.enabled
                radius: Theme.paddingMedium
                roundedCorners: strip.columns === 1 ? (Corners.BottomLeft | Corners.BottomRight)
                                                    : (index === 0 ? Corners.BottomLeft : Corners.BottomRight)
            }

            Image {
                anchors.centerIn: parent
                width: Theme.iconSizeSmall
                height: width
                sourceSize: Qt.size(width, height)
                source: !button.action.icon ? ""
                      : (button.pressed && button.containsMouse ? button.action.icon + "?" + Theme.highlightColor
                                                                : button.action.icon)
                opacity: strip.housekeeping ? 0.0 : (button.available ? 1.0 : Theme.opacityLow)

                Behavior on opacity { FadeAnimation {} }
            }
        }
    }
}
