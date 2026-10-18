// Minimal coverload cover. Installed to /usr/share/coverload/covers/<id>/Cover.qml.
//
// Set by coverload if declared:
//   host     the lipstick SwitcherItem (host.window, host.launcherItem, host.running, host.editMode)
//   app      { fileID, filePath, exec, title }
//   options  this cover's options from the settings page (see cover.json "settings")
// Declare "ready" and set it to false to show the normal app preview instead.

import QtQuick 2.6
import Sailfish.Silica 1.0

Item {
    property Item host
    property var app: ({})
    property var options: ({})
    readonly property bool ready: true


    // Covers are designed at the large cover size and scaled to the switcher cell
    Item {
        width: Theme.coverSizeLarge.width
        height: parent.height / scale
        scale: parent.width / width
        transformOrigin: Item.TopLeft

        Label {
            anchors.centerIn: parent
            width: parent.width - 2 * Theme.paddingLarge
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: app.title
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
        }
    }
}
