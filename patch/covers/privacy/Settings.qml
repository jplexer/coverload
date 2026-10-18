import QtQuick 2.6
import Sailfish.Silica 1.0

Column {
    id: root

    property var options: ({})

    function set(key, value) {
        var copy = JSON.parse(JSON.stringify(options || {}))
        copy[key] = value
        options = copy
    }

    Component.onCompleted: modeBox.currentIndex = options && options.mode === "blur" ? 1 : 0

    ComboBox {
        id: modeBox

        label: qsTr("Background")
        menu: ContextMenu {
            MenuItem {
                text: qsTr("Ambience")
                onClicked: root.set("mode", "icon")
            }
            MenuItem {
                text: qsTr("Blurred preview")
                onClicked: root.set("mode", "blur")
            }
        }
    }

    TextSwitch {
        text: qsTr("Show app name")
        automaticCheck: false
        checked: !root.options || root.options.showName !== false
        onClicked: root.set("showName", !checked)
    }
}
