precision mediump float;

#define SHADER_NAME Screen Texture

varying vec2 v_uv;

uniform sampler2D texture;

void main() {
    gl_FragColor = texture2D(texture, v_uv);
}