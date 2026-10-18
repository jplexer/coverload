import QtQuick 2.6
import Sailfish.Silica 1.0
import "../coverload.js" as Coverload

Page {
    id: page

    property Page settingsPage
    property CoverCatalog catalog
    property var rules: []
    property var apps: []
    property string filter
    property bool failed

    readonly property int matchCount: {
        var count = 0
        for (var i = 0; i < apps.length; ++i) {
            if (matches(apps[i]))
                ++count
        }
        return count
    }

    function matches(app) {
        return filter === "" || app.title.toLowerCase().indexOf(filter.toLowerCase()) >= 0
    }

    function ruleFor(app) {
        for (var i = 0; i < rules.length; ++i) {
            if (rules[i].fileID === app.fileID)
                return rules[i]
        }
        return null
    }

    function pick(app) {
        var dialog = pageStack.push(Qt.resolvedUrl("RuleDialog.qml"), {
            rule: ruleFor(app) || {
                fileID: app.fileID,
                filePath: app.filePath,
                title: app.title,
                icon: app.icon,
                cover: "mpris",
                options: {}
            },
            catalog: catalog,
            acceptDestination: settingsPage,
            acceptDestinationAction: PageStackAction.Pop
        })
        dialog.accepted.connect(function() { settingsPage.put(dialog.rule) })
    }

    function refresh(model) {
        var list = []
        for (var i = 0; i < model.itemCount; ++i) {
            var item = model.get(i)
            if (!item || !item.isValid || !item.shouldDisplay)
                continue
            list.push({
                fileID: item.fileID,
                filePath: item.filePath,
                title: item.title,
                icon: item.iconId,
                android: /apkd/.test(item.exec) || /apkd/.test(item.fileID)
            })
        }
        list.sort(function(a, b) { return a.title.localeCompare(b.title) })
        apps = list
    }

    Component.onCompleted: {
        try {
            var model = Qt.createQmlObject("import org.nemomobile.lipstick 0.1; LauncherModel {}",
                                           page, "LauncherModel")
            model.itemCountChanged.connect(function() { page.refresh(model) })
            refresh(model)
        } catch (e) {
            console.warn("coverload: cannot list apps:", e)
            failed = true
        }
    }

    SilicaListView {
        id: view

        anchors.fill: parent
        model: page.apps

        header: Column {
            width: view.width

            PageHeader {
                title: qsTr("Choose app")
            }

            SearchField {
                width: parent.width
                placeholderText: qsTr("Search")
                onTextChanged: page.filter = text
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }
        }

        delegate: ListItem {
            readonly property bool isConfigured: page.ruleFor(modelData) !== null
            readonly property bool matching: page.matches(modelData)

            contentHeight: matching ? Theme.itemSizeMedium : 0
            visible: matching
            onClicked: page.pick(modelData)

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
                    text: Theme.highlightText(modelData.title, page.filter, Theme.highlightColor)
                    textFormat: Text.StyledText
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    truncationMode: TruncationMode.Fade
                }

                Label {
                    width: parent.width
                    visible: text !== ""
                    text: isConfigured ? qsTr("Has a custom cover")
                                       : (modelData.android ? qsTr("Android app") : "")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    truncationMode: TruncationMode.Fade
                }
            }
        }

        ViewPlaceholder {
            enabled: page.failed || (page.apps.length > 0 && page.matchCount === 0)
            text: page.failed ? qsTr("Could not list apps") : qsTr("No matching apps")
        }

        VerticalScrollDecorator {}
    }
}
