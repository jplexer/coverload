import QtQuick 2.6

ShaderEffect {
    property real radius
    property size size: Qt.size(width, height)

    fragmentShader: "
        varying highp vec2 qt_TexCoord0;
        uniform sampler2D source;
        uniform lowp float qt_Opacity;
        uniform highp vec2 size;
        uniform highp float radius;
        void main() {
            highp vec2 p = qt_TexCoord0 * size;
            highp vec2 c = clamp(p, vec2(radius), size - vec2(radius));
            lowp float a = 1.0 - smoothstep(radius - 1.0, radius, distance(p, c));
            gl_FragColor = texture2D(source, qt_TexCoord0) * a * qt_Opacity;
        }"
}
