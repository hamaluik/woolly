#ifdef GL_ES
precision mediump float;
#endif

// attribute inputs
attribute vec3 position;
attribute vec3 normal;

// camera uniforms
uniform mat4 MVP;

void main() {
    // set the camera-space position of the vertex
	gl_Position = MVP * vec4(position, 1.0);
}