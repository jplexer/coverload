var rulesKey = "/coverload/rules"
var patchDir = "/usr/share/patchmanager/patches/coverload"
var builtinCoversDir = patchDir + "/covers"
var coversDir = "/usr/share/coverload/covers"
var builtinCovers = ["mpris", "notifications", "privacy"]

function coverDir(id) {
    return (builtinCovers.indexOf(id) >= 0 ? builtinCoversDir : coversDir) + "/" + id
}

function coverUrl(id, file) {
    return "file://" + coverDir(id) + "/" + file
}

function parseRules(json) {
    if (!json)
        return []
    try {
        var rules = JSON.parse(json)
        return Array.isArray(rules) ? rules : []
    } catch (e) {
        console.warn("coverload: invalid rules in dconf", rulesKey, "-", e)
        return []
    }
}

function describe(launcherItem, window) {
    var li = launcherItem
    return {
        fileID: (li && li.fileID) || "",
        filePath: (li && li.filePath) || "",
        exec: (li && li.exec) || "",
        title: (window && window.title) || (li && li.title) || ""
    }
}

function findRule(rules, app) {
    for (var i = 0; i < rules.length; ++i) {
        var rule = rules[i]
        if (!rule || !rule.cover)
            continue
        if ((rule.fileID && rule.fileID === app.fileID)
                || (rule.filePath && rule.filePath === app.filePath)) {
            return rule
        }
    }
    return null
}

// True if name (e.g. an Android package or MPRIS player name) appears in the
// app's desktop file name or Exec line, either dotted or with dots as underscores.
function appMentions(app, name) {
    if (!name)
        return false
    var escaped = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
    var dotted = new RegExp("(^|[^A-Za-z0-9.])" + escaped + "(?![A-Za-z0-9.])")
    var underscored = new RegExp("(^|[^A-Za-z0-9])" + escaped.replace(/\\\./g, "_") + "(?![A-Za-z0-9])")
    var fields = [app.fileID, app.filePath, app.exec]
    for (var i = 0; i < fields.length; ++i) {
        if (fields[i] && (dotted.test(fields[i]) || underscored.test(fields[i])))
            return true
    }
    return false
}

// Calls done(object or null)
function readJson(url, done) {
    var xhr = new XMLHttpRequest()
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== XMLHttpRequest.DONE)
            return
        var result = null
        try {
            result = xhr.responseText ? JSON.parse(xhr.responseText) : null
        } catch (e) {
            console.warn("coverload: invalid JSON in", url, "-", e)
        }
        done(result)
    }
    xhr.open("GET", url)
    xhr.send()
}

function iconSource(iconId) {
    if (!iconId)
        return ""
    if (iconId.charAt(0) === "/")
        return "file://" + iconId
    if (iconId.indexOf(":/") > 0)
        return iconId
    return "image://theme/" + iconId
}
