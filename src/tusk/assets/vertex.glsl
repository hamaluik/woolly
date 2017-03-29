precision mediump float;

attribute vec2 position;
attribute vec2 uv;
attribute vec4 colour;

uniform mat4 VP;

varying vec2 v_uv;
varying vec4 v_colour;

void main() {
    v_colour = colour;
	v_uv = uv;
	gl_Position = VP * vec4(position, 0, 1.0);
}