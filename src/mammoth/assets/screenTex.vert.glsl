#ifdef GL_ES
precision mediump float;
#endif

#define SHADER_NAME Screen Texture

attribute vec2 position;
attribute vec2 uv;

varying vec2 v_uv;

void main() {
	v_uv = uv;
	gl_Position = vec4(position, 0, 1.0);
}