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

    Component.onCompleted: {
        emptyBox.currentIndex = options && options.whenEmpty === "placeholder" ? 1 : 0
        appNameField.text = (options && options.appName) || ""
    }

    TextSwitch {
        text: qsTr("Show message text")
        description: qsTr("Otherwise only senders and titles are shown")
        automaticCheck: false
        checked: !root.options || root.options.showBody !== false
        onClicked: root.set("showBody", !checked)
    }

    TextSwitch {
        text: qsTr("Clear button")
        description: qsTr("Adds a cover button that dismisses this app's notifications")
        automaticCheck: false
        checked: root.options && root.options.clearButton === true
        onClicked: root.set("clearButton", !checked)
    }

    ComboBox {
        id: emptyBox

        label: qsTr("Without notifications")
        menu: ContextMenu {
            MenuItem {
                text: qsTr("Show app preview")
                onClicked: root.set("whenEmpty", "preview")
            }
            MenuItem {
                text: qsTr("Show placeholder")
                onClicked: root.set("whenEmpty", "placeholder")
            }
        }
    }

    TextField {
        id: appNameField

        width: parent.width
        label: qsTr("App name in notifications")
        placeholderText: qsTr("App name in notifications (optional)")
        description: qsTr("Leave empty to match automatically. Set it if the cover stays empty.")
        EnterKey.iconSource: "image://theme/icon-m-enter-close"
        EnterKey.onClicked: focus = false
        onTextChanged: root.set("appName", text.trim())
    }
}
