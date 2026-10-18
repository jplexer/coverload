import QtQuick 2.6
import Sailfish.Silica 1.0
import Amber.Mpris 1.0
import "../../qml"
import "../../qml/coverload.js" as Coverload

Item {
    id: cover

    property Item host
    property var app: ({})
    property var options: ({})

    readonly property string service: {
        var services = controller.availableServices
        if (options.service)
            return services.indexOf(options.service) >= 0 ? options.service : ""
        for (var i = 0; i < services.length; ++i) {
            var name = services[i].replace(/^org\.mpris\.MediaPlayer2\./, "")
                                  .replace(/^AppSupport\./, "")
            if (Coverload.appMentions(app, name))
                return services[i]
        }
        return ""
    }
    readonly property bool ready: service !== ""
                                  && controller.currentService === service
                                  && !(options.hideWhenStopped && controller.playbackStatus === Mpris.Stopped)

    readonly property bool playing: controller.playbackStatus === Mpris.Playing
    readonly property string title: controller.metaData.title || ""
    readonly property string artist: {
        var a = controller.metaData.contributingArtist
        return !a ? "" : (typeof a === "string" ? a : Array.prototype.join.call(a, ", "))
    }
    readonly property var actions: (options.actions || ["playPause", "next"]).slice(0, 2)

    MprisController {
        id: controller
    }

    // Follow the app's own player instead of whichever one played last
    Binding {
        target: controller
        property: "currentService"
        value: cover.service
        when: cover.service !== ""
    }

    CoverCanvas {
        id: canvas

        Item {
            id: artSlot

            readonly property real size: Math.min(canvas.width - 2 * Theme.paddingLarge,
                                                  labels.y - 2 * Theme.paddingLarge)

            x: (canvas.width - size) / 2
            y: Theme.paddingLarge
            width: size
            height: size

            Rectangle {
                anchors.fill: parent
                visible: !art.visible
                radius: Theme.paddingSmall
                color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)

                HighlightImage {
                    anchors.centerIn: parent
                    source: "image://theme/icon-l-music"
                    color: Theme.secondaryHighlightColor
                }
            }

            Image {
                id: art

                anchors.fill: parent
                visible: status === Image.Ready
                source: controller.metaData.artUrl || ""
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true

                layer.enabled: true
                layer.effect: RoundedMask { radius: Theme.paddingSmall }
            }
        }

        Column {
            id: labels

            y: canvas.height - actionStrip.height / canvas.scale - height - Theme.paddingSmall
            x: Theme.paddingLarge
            width: canvas.width - 2 * Theme.paddingLarge

            Label {
                width: parent.width
                text: cover.title
                visible: text !== ""
                color: cover.playing ? Theme.primaryColor : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.Wrap
                maximumLineCount: 2
                truncationMode: TruncationMode.Fade
            }

            Label {
                width: parent.width
                text: cover.artist
                visible: text !== ""
                color: cover.playing ? Theme.secondaryColor : Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
            }
        }
    }

    CoverActionStrip {
        id: actionStrip

        anchors.bottom: parent.bottom
        width: parent.width
        host: cover.host
        actions: cover.actions.map(function(name) {
            switch (name) {
            case "previous":
                return { icon: "image://theme/icon-cover-previous-song", enabled: controller.canGoPrevious }
            case "next":
                return { icon: "image://theme/icon-cover-next-song", enabled: controller.canGoNext }
            case "playPause":
                return cover.playing ? { icon: "image://theme/icon-cover-pause", enabled: controller.canPause }
                                     : { icon: "image://theme/icon-cover-play", enabled: controller.canPlay }
            }
            return { icon: "", enabled: false }
        })

        onTriggered: {
            var name = cover.actions[index]
            if (name === "previous")
                controller.previous()
            else if (name === "next")
                controller.next()
            else if (name === "playPause")
                controller.playPause()
        }
    }
}
