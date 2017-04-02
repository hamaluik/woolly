#ifdef GL_ES
precision mediump float;
#endif

#define SHADER_NAME Shadow

// attribute inputs
attribute vec3 position;

// camera uniforms
uniform mat4 MVP;

void main() {
    // set the camera-space position of the vertex
	gl_Position = MVP * vec4(position, 1.0);
}