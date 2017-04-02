precision mediump float;

#define SHADER_NAME Tusk UI

varying vec2 v_uv;
varying vec4 v_colour;

uniform sampler2D texture;

void main() {
    gl_FragColor = texture2D(texture, v_uv) * v_colour;
}