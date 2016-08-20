import QtQuick 2.3

ShaderEffect {
        fragmentShader: "
            uniform lowp sampler2D source;
            uniform lowp float qt_Opacity;
            varying highp vec2 qt_TexCoord0;

            void main() {
                lowp vec4 p = texture2D(source, qt_TexCoord0);
                p.r = 1.0 - p.r;
                p.g = 1.0 - p.g;
                p.b = 1.0 - p.b;
                gl_FragColor = vec4(vec3(dot(p.rgb, vec3(0.299, 0.587, 0.114))), p.a) * qt_Opacity;
            }
        "
    }
