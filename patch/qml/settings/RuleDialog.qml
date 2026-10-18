import QtQuick 2.6
import Sailfish.Silica 1.0
import "../coverload.js" as Coverload

Dialog {
    id: dialog

    property var rule
    property CoverCatalog catalog

    property string coverId: rule.cover || ""
    property var coverInfo: null
    // Snapshot of catalog.covers for the menu
    property var covers: []
    property bool _completed

    canAccept: coverInfo !== null

    onAccepted: {
        var result = JSON.parse(JSON.stringify(rule))
        result.cover = coverId
        result.options = settingsLoader.item ? settingsLoader.item.options
                                             : (coverId === rule.cover ? (rule.options || {}) : {})
        rule = result
    }

    function findCover(id) {
        for (var i = 0; i < covers.length; ++i) {
            if (covers[i].id === id)
                return i
        }
        return -1
    }

    function syncCovers() {
        if (!_completed || coverMenu.active || !catalog)
            return
        if (JSON.stringify(catalog.covers) === JSON.stringify(covers))
            return
        covers = catalog.covers
        coverBox.currentIndex = Math.max(0, findCover(coverId))
        updateCover()
    }

    function selectCover(id) {
        if (id === coverId)
            return
        coverId = id
        // Wait for the menu to close before replacing the settings panel
        coverChangeTimer.restart()
    }

    function updateCover() {
        var index = findCover(coverId)
        var info = index >= 0 ? covers[index] : null
        if (info === coverInfo || (info && coverInfo && info.id === coverInfo.id))
            return
        coverInfo = info
        loadSettings()
    }

    function loadSettings() {
        if (!coverInfo || !coverInfo.settings) {
            settingsLoader.source = ""
            return
        }
        settingsLoader.setSource(Coverload.coverUrl(coverInfo.id, coverInfo.settings), {
            options: coverInfo.id === rule.cover ? JSON.parse(JSON.stringify(rule.options || {})) : {}
        })
    }

    Component.onCompleted: {
        _completed = true
        syncCovers()
    }

    Connections {
        target: dialog.catalog
        onCoversChanged: dialog.syncCovers()
    }

    Timer {
        id: coverChangeTimer

        interval: 0
        onTriggered: dialog.updateCover()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column

            width: parent.width

            DialogHeader {
                acceptText: qsTr("Save")
            }

            Item {
                width: parent.width
                height: Theme.itemSizeMedium

                Image {
                    id: icon

                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.iconSizeMedium
                    height: width
                    sourceSize: Qt.size(width, height)
                    source: Coverload.iconSource(dialog.rule.icon)
                }

                Label {
                    anchors {
                        left: icon.right
                        leftMargin: Theme.paddingLarge
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    text: dialog.rule.title || dialog.rule.fileID
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    truncationMode: TruncationMode.Fade
                }
            }

            ComboBox {
                id: coverBox

                label: qsTr("Cover")
                description: dialog.coverInfo ? dialog.coverInfo.description : ""
                menu: ContextMenu {
                    id: coverMenu

                    onActiveChanged: if (!active) dialog.syncCovers()

                    Repeater {
                        model: dialog.covers
                        MenuItem {
                            text: modelData.name
                            onClicked: dialog.selectCover(modelData.id)
                        }
                    }
                }
            }

            SectionHeader {
                text: qsTr("Options")
                visible: settingsLoader.status === Loader.Ready
            }

            Loader {
                id: settingsLoader

                width: parent.width
            }
        }

        VerticalScrollDecorator {}
    }
}
