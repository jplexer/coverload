// Loaded into each app switcher cover by the coverload patch.
// Looks up the app in the rules and loads the configured cover over it.

import QtQuick 2.6
import Nemo.Configuration 1.0
import "coverload.js" as Coverload

Item {
    id: root

    // The SwitcherItem (set by the patch)
    property Item host

    property var rule: null
    property var app: ({})

    // Covers may declare "property bool ready" to fall back to the normal
    // window thumbnail while they have nothing to show.
    readonly property bool active: rule !== null
                                   && coverLoader.status === Loader.Ready
                                   && coverLoader.item.ready !== false

    readonly property var _launcherItem: host ? host.launcherItem : null
    readonly property var _window: host ? host.window : null

    anchors.fill: parent

    on_LauncherItemChanged: evaluate()
    on_WindowChanged: evaluate()

    ConfigurationValue {
        id: rulesValue

        key: Coverload.rulesKey
        defaultValue: "[]"
        onValueChanged: root.evaluate()
    }

    function evaluate() {
        if (!_launcherItem && !_window) {
            apply(null)
            return
        }
        app = Coverload.describe(_launcherItem, _window)
        apply(Coverload.findRule(Coverload.parseRules(rulesValue.value), app))
    }

    function apply(found) {
        if (JSON.stringify(found) === JSON.stringify(rule))
            return

        rule = found
        if (!found) {
            coverLoader.source = ""
            return
        }

        coverLoader.setSource(Coverload.coverUrl(found.cover, "Cover.qml"), {
            host: root.host,
            app: root.app,
            options: found.options || {}
        })
    }

    Loader {
        id: coverLoader

        anchors.fill: parent

        onStatusChanged: {
            if (status === Loader.Error)
                console.warn("coverload: failed to load cover", source)
        }
    }
}
