# coverload

Custom app switcher covers for Sailfish OS, for any app, including Android apps
running under AppSupport. More covers can be installed as separate RPMs.

Built-in covers:

- **Media controls**: track, artist, album art and playback buttons for apps
  with an MPRIS player.
- **Notifications**: the app's newest notifications and their count, with
  optional message text and a clear button.
- **Privacy**: the app's icon and name on the ambience background or over a
  blurred preview, for banking, 2FA or chat apps.

## Using it

1. Install the `coverload` RPM.
2. Apply **Custom app covers** in Patchmanager.
3. Tap the patch in Patchmanager to open its settings. Pull down, choose
   **Add app**, pick an app and a cover.

## Writing a cover

A cover is a directory in `/usr/share/coverload/covers/<id>/`:

| file          |                                                          |
|---------------|----------------------------------------------------------|
| `cover.json`  | `{ "name", "description", "settings": "Settings.qml" }`  |
| `Cover.qml`   | the cover, an `Item` that fills its parent               |
| `Settings.qml`| optional options UI, a `Column` with `property var options` |

These properties are set on `Cover.qml` if it declares them:

- `host`: the lipstick `SwitcherItem`, with `window`, `launcherItem`,
  `running` and `editMode` (true in close mode, so disable buttons then)
- `app`: `{ fileID, filePath, exec, title }`
- `options`: whatever the cover's `Settings.qml` stored

To show the normal app preview instead of your cover, declare `ready` and set
it to `false`.

Taps outside your own `MouseArea`s open the app as usual. Shared pieces live
in `file:///usr/share/patchmanager/patches/coverload/qml/`: `coverload.js`
helpers, `CoverCanvas` (lays content out at cover size and scales it),
`CoverActionStrip` (native-looking cover buttons) and `RoundedMask`.

`examples/cover-template/` has a minimal cover and a spec to package it. Covers
run inside lipstick, so a cover can do anything lipstick can. Only install
covers you trust.
