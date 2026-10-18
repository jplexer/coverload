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

    readonly property bool blur: options.mode === "blur"
    readonly property var launcherItem: host ? host.launcherItem : null

    Item {
        anchors.fill: parent
        visible: cover.blur

        WindowPixmapItem {
            id: pixmap

            anchors.fill: parent
            windowId: cover.host && cover.blur ? cover.host.windowId : 0
            xScale: Math.min(1.0, (windowSize.height / windowSize.width) / (height / width))
            yScale: Math.min(1.0, (windowSize.width / windowSize.height) / (width / height))
        }

        // Downscaling is most of the blur; the shader smooths out the blocks
        ShaderEffectSource {
            id: small

            anchors.fill: parent
            sourceItem: pixmap
            hideSource: true
            visible: false
            smooth: true
            textureSize: Qt.size(Math.max(1, Math.round(width / 12)), Math.max(1, Math.round(height / 12)))
        }

        ShaderEffect {
            anchors.fill: parent

            property variant source: small
            property size size: Qt.size(width, height)
            property size texel: Qt.size(1 / small.textureSize.width, 1 / small.textureSize.height)
            property real radius: Theme.paddingMedium

            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform sampler2D source;
                uniform lowp float qt_Opacity;
                uniform highp vec2 size;
                uniform highp vec2 texel;
                uniform highp float radius;
                void main() {
                    highp vec2 t = qt_TexCoord0;
                    lowp vec4 c = texture2D(source, t) * 4.0
                        + (texture2D(source, t + vec2(texel.x, 0.0)) + texture2D(source, t - vec2(texel.x, 0.0))
                         + texture2D(source, t + vec2(0.0, texel.y)) + texture2D(source, t - vec2(0.0, texel.y))) * 2.0
                        + texture2D(source, t + texel) + texture2D(source, t - texel)
                        + texture2D(source, t + vec2(texel.x, -texel.y)) + texture2D(source, t + vec2(-texel.x, texel.y));
                    highp vec2 p = t * size;
                    highp vec2 k = clamp(p, vec2(radius), size - vec2(radius));
                    lowp float a = 1.0 - smoothstep(radius - 1.0, radius, distance(p, k));
                    gl_FragColor = (c / 16.0) * a * qt_Opacity;
                }"
        }

        Rectangle {
            anchors.fill: parent
            radius: Theme.paddingMedium
            color: Theme.rgba(Theme.overlayBackgroundColor, Theme.opacityHigh)
        }
    }

    CoverCanvas {
        Column {
            anchors.centerIn: parent
            width: parent.width - 2 * Theme.paddingLarge
            spacing: Theme.paddingMedium

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.iconSizeLarge
                height: width
                sourceSize: Qt.size(width, height)
                source: Coverload.iconSource(cover.launcherItem ? cover.launcherItem.iconId : "")
            }

            Label {
                width: parent.width
                visible: cover.options.showName !== false && text !== ""
                horizontalAlignment: Text.AlignHCenter
                text: cover.launcherItem ? cover.launcherItem.title : cover.app.title
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.primaryColor
                wrapMode: Text.Wrap
                maximumLineCount: 2
                truncationMode: TruncationMode.Fade
            }
        }
    }
}
