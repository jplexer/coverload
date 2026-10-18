import QtQuick 2.6
import Sailfish.Silica 1.0
import org.nemomobile.lipstick 0.1
import "../../qml"
import "../../qml/coverload.js" as Coverload

Item {
    id: cover

    property Item host
    property var app: ({})
    property var options: ({})

    // Newest first. Plain snapshots, so nothing holds on to notification objects.
    property var notifications: []
    property int count
    property bool removable

    readonly property bool ready: notifications.length > 0 || options.whenEmpty === "placeholder"
    readonly property bool showBody: options.showBody !== false
    readonly property string appTitle: (host && host.launcherItem && host.launcherItem.title) || app.title || ""

    function belongs(n) {
        if (options.appName)
            return n.appName.toLowerCase() === options.appName.toLowerCase()

        var origin = (n.hints && n.hints["x-nemo-origin-package"]) || ""
        if (origin !== "" && Coverload.appMentions(app, origin))
            return true
        if (n.owner !== "" && Coverload.appMentions(app, n.owner))
            return true
        return appTitle !== "" && (n.appName === appTitle || n.disambiguatedAppName === appTitle)
    }

    function refresh() {
        var list = []
        var total = 0
        var anyRemovable = false
        for (var i = 0; i < model.itemCount; ++i) {
            var n = model.get(i)
            if (!n || !belongs(n))
                continue
            total += Math.max(1, n.itemCount)
            anyRemovable = anyRemovable || n.userRemovable
            list.push({
                summary: n.summary,
                body: n.body,
                hasProgress: n.hasProgress,
                progress: n.progress
            })
        }
        notifications = list
        count = total
        removable = anyRemovable
    }

    function clear() {
        for (var i = model.itemCount - 1; i >= 0; --i) {
            var n = model.get(i)
            if (n && n.userRemovable && belongs(n))
                n.removeRequested()
        }
    }

    onOptionsChanged: refresh()
    onAppChanged: refresh()

    NotificationListModel {
        id: model

        onPopulatedChanged: cover.refresh()
        onItemCountChanged: cover.refresh()
    }

    // Content changes of existing notifications arrive as dataChanged
    Connections {
        target: model
        ignoreUnknownSignals: true
        onDataChanged: cover.refresh()
        onRowsMoved: cover.refresh()
        onModelReset: cover.refresh()
    }

    CoverCanvas {
        id: canvas

        Row {
            id: header

            x: Theme.paddingLarge
            y: Theme.paddingMedium
            spacing: Theme.paddingMedium
            visible: cover.notifications.length > 0

            Label {
                id: countLabel

                text: cover.count
                font.pixelSize: Theme.fontSizeHuge
                color: Theme.primaryColor
            }

            Label {
                anchors.verticalCenter: countLabel.verticalCenter
                width: canvas.width - 2 * Theme.paddingLarge - countLabel.width - parent.spacing
                text: cover.count === 1 ? qsTr("New\nnotification") : qsTr("New\nnotifications")
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                truncationMode: TruncationMode.Fade
            }
        }

        Item {
            id: listArea

            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
                topMargin: Theme.paddingSmall
            }
            height: canvas.height - y - (actionStrip.visible ? actionStrip.height / canvas.scale
                                                             : Theme.paddingLarge)
            clip: true
            visible: cover.notifications.length > 0

            Column {
                id: list

                width: parent.width
                spacing: Theme.paddingMedium

                Repeater {
                    model: cover.notifications.slice(0, 4)

                    Column {
                        width: list.width

                        Label {
                            width: parent.width
                            text: modelData.summary
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.primaryColor
                            truncationMode: TruncationMode.Fade
                        }

                        Label {
                            width: parent.width
                            visible: cover.showBody && text !== ""
                            text: modelData.body
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.secondaryColor
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            truncationMode: TruncationMode.Fade
                        }

                        Item {
                            width: parent.width
                            height: Theme.paddingSmall * 2
                            visible: modelData.hasProgress

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: Math.max(2, Theme.paddingSmall / 2)
                                radius: height / 2
                                color: Theme.rgba(Theme.highlightColor, Theme.opacityLow)

                                Rectangle {
                                    width: parent.width * Math.max(0, Math.min(1, modelData.progress))
                                    height: parent.height
                                    radius: parent.radius
                                    color: Theme.highlightColor
                                }
                            }
                        }
                    }
                }
            }

            OpacityRampEffect {
                sourceItem: list
                direction: OpacityRamp.TopToBottom
                offset: Math.max(0, (listArea.height - Theme.itemSizeSmall) / Math.max(1, list.height))
                slope: Math.max(1, list.height / Theme.itemSizeSmall)
            }
        }

        // Shown when there is nothing to list and whenEmpty is "placeholder"
        Column {
            anchors.centerIn: parent
            width: parent.width - 2 * Theme.paddingLarge
            spacing: Theme.paddingMedium
            visible: cover.notifications.length === 0

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.iconSizeLarge
                height: width
                sourceSize: Qt.size(width, height)
                source: Coverload.iconSource(cover.host && cover.host.launcherItem
                                             ? cover.host.launcherItem.iconId : "")
            }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                text: qsTr("No notifications")
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.secondaryColor
            }
        }
    }

    CoverActionStrip {
        id: actionStrip

        anchors.bottom: parent.bottom
        width: parent.width
        host: cover.host
        visible: cover.options.clearButton === true && cover.notifications.length > 0
        actions: [{ icon: "image://theme/icon-cover-cancel", enabled: cover.removable }]
        onTriggered: cover.clear()
    }
}
