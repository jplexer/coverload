import QtQuick 2.6
import Sailfish.Silica 1.0
import Amber.Mpris 1.0

Column {
    id: root

    // Read and replaced by the settings page
    property var options: ({})

    readonly property var actionSets: [
        { label: qsTr("Play/pause and next"), actions: ["playPause", "next"] },
        { label: qsTr("Previous and next"), actions: ["previous", "next"] },
        { label: qsTr("Previous and play/pause"), actions: ["previous", "playPause"] },
        { label: qsTr("Play/pause only"), actions: ["playPause"] }
    ]

    // Player names offered in the menu; only refreshed while the menu is closed
    property var services: []

    function set(key, value) {
        var copy = JSON.parse(JSON.stringify(options || {}))
        copy[key] = value
        options = copy
    }

    function refreshServices() {
        if (playerMenu.active)
            return
        var list = controller.availableServices.slice()
        var configured = (options && options.service) || ""
        if (configured && list.indexOf(configured) < 0)
            list.push(configured)
        if (JSON.stringify(list) !== JSON.stringify(services))
            services = list
    }

    function actionSetIndex() {
        var current = JSON.stringify((options && options.actions) || ["playPause", "next"])
        for (var i = 0; i < actionSets.length; ++i) {
            if (JSON.stringify(actionSets[i].actions) === current)
                return i
        }
        return 0
    }

    Component.onCompleted: {
        refreshServices()
        var service = (options && options.service) || ""
        playerBox.currentIndex = service ? services.indexOf(service) + 1 : 0
        buttonsBox.currentIndex = actionSetIndex()
    }

    MprisController {
        id: controller

        onAvailableServicesChanged: root.refreshServices()
    }

    ComboBox {
        id: playerBox

        label: qsTr("Player")
        description: qsTr("Automatic picks the player that belongs to the app. Start playback in the app to list it here.")
        menu: ContextMenu {
            id: playerMenu

            onActiveChanged: if (!active) root.refreshServices()

            MenuItem {
                text: qsTr("Automatic")
                onClicked: root.set("service", "")
            }
            Repeater {
                model: root.services
                MenuItem {
                    text: modelData.replace(/^org\.mpris\.MediaPlayer2\./, "")
                    onClicked: root.set("service", modelData)
                }
            }
        }
    }

    ComboBox {
        id: buttonsBox

        label: qsTr("Buttons")
        menu: ContextMenu {
            Repeater {
                model: root.actionSets
                MenuItem {
                    text: modelData.label
                    onClicked: root.set("actions", modelData.actions)
                }
            }
        }
    }

    TextSwitch {
        text: qsTr("Only while playing")
        description: qsTr("Show the normal app preview when playback is stopped")
        automaticCheck: false
        checked: root.options && root.options.hideWhenStopped === true
        onClicked: root.set("hideWhenStopped", !checked)
    }
}
