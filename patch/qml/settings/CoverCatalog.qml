import QtQuick 2.6
import Nemo.FileManager 1.0
import "../coverload.js" as Coverload

Item {
    id: catalog

    // [{ id, name, description, settings }]
    property var covers: []
    property int _generation

    function find(id) {
        for (var i = 0; i < covers.length; ++i) {
            if (covers[i].id === id)
                return covers[i]
        }
        return null
    }

    function reload() {
        var ids = Coverload.builtinCovers.slice()
        for (var i = 0; i < dirModel.count; ++i) {
            var name = dirModel.fileNameAt(i)
            if (ids.indexOf(name) < 0)
                ids.push(name)
        }

        var generation = ++_generation
        var found = []
        var pending = ids.length
        ids.forEach(function(id, order) {
            Coverload.readJson(Coverload.coverUrl(id, "cover.json"), function(meta) {
                if (generation !== _generation)
                    return
                if (meta) {
                    found.push({ id: id, order: order, name: meta.name || id,
                                 description: meta.description || "",
                                 settings: meta.settings || "" })
                } else {
                    console.warn("coverload: skipping cover without cover.json:", id)
                }
                if (--pending === 0) {
                    found.sort(function(a, b) { return a.order - b.order })
                    covers = found
                }
            })
        })
    }

    Component.onCompleted: reload()

    FileModel {
        id: dirModel

        path: Coverload.coversDir
        active: true
        includeFiles: false
        includeDirectories: true
        onCountChanged: catalog.reload()
    }
}
