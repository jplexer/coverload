import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import "qml/coverload.js" as Coverload
import "qml/settings"

Page {
    id: page

    readonly property var rules: Coverload.parseRules(rulesValue.value)

    function save(list) {
        rulesValue.value = JSON.stringify(list)
    }

    function put(rule) {
        var list = rules.filter(function(r) { return r.fileID !== rule.fileID })
        list.push(rule)
        list.sort(function(a, b) { return (a.title || "").localeCompare(b.title || "") })
        save(list)
    }

    function remove(fileID) {
        save(rules.filter(function(r) { return r.fileID !== fileID }))
    }

    function edit(rule) {
        var dialog = pageStack.push(Qt.resolvedUrl("qml/settings/RuleDialog.qml"),
                                    { rule: rule, catalog: catalog })
        dialog.accepted.connect(function() { page.put(dialog.rule) })
    }

    function add() {
        pageStack.push(Qt.resolvedUrl("qml/settings/AppPickerPage.qml"), {
            settingsPage: page,
            catalog: catalog,
            rules: rules
        })
    }

    ConfigurationValue {
        id: rulesValue

        key: Coverload.rulesKey
        defaultValue: "[]"
    }

    CoverCatalog {
        id: catalog
    }

    SilicaListView {
        id: view

        anchors.fill: parent
        model: page.rules

        header: PageHeader {
            title: qsTr("Custom covers")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add app")
                onClicked: page.add()
            }
        }

        delegate: ListItem {
            id: item

            readonly property var info: (catalog.covers, catalog.find(modelData.cover))

            contentHeight: Theme.itemSizeMedium
            onClicked: page.edit(modelData)
            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Remove")
                    onClicked: {
                        var fileID = modelData.fileID
                        item.remorseAction(qsTr("Removing"), function() { page.remove(fileID) })
                    }
                }
            }

            Image {
                id: icon

                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.iconSizeMedium
                height: width
                sourceSize: Qt.size(width, height)
                source: Coverload.iconSource(modelData.icon)
            }

            Column {
                anchors {
                    left: icon.right
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }

                Label {
                    width: parent.width
                    text: modelData.title || modelData.fileID
                    color: item.highlighted ? Theme.highlightColor : Theme.primaryColor
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    width: parent.width
                    text: item.info ? item.info.name : qsTr("Missing cover: %1").arg(modelData.cover)
                    font.pixelSize: Theme.fontSizeSmall
                    color: item.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    truncationMode: TruncationMode.Fade
                }
            }
        }

        ViewPlaceholder {
            enabled: page.rules.length === 0
            text: qsTr("No custom covers")
            hintText: qsTr("Pull down to choose an app")
        }

        VerticalScrollDecorator {}
    }
}
