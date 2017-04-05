#ifdef GL_ES
precision mediump float;
#endif

#define SHADER_NAME Standard

// attribute inputs
attribute vec3 position;
attribute vec3 normal;

#ifdef ATTRIBUTE_UV
attribute vec2 uv;
#endif
#ifdef ATTRIBUTE_COLOUR
attribute vec3 colour;
#endif

// camera uniforms
uniform mat4 MVP;
uniform mat4 M;

// material uniforms
uniform vec3 albedoColour;
uniform vec3 ambientColour;

// outputs
varying vec3 v_position;
varying vec3 v_normal;
varying vec3 v_colour;
#ifdef ATTRIBUTE_UV
varying vec2 v_uv;
#endif

void main() {
    // transform position to world space
    vec3 worldPosition = (M * vec4(position, 1.0)).xyz;
    v_position = worldPosition;

	// transform normals into world space
	vec3 worldNormal = (M * vec4(normal, 0.0)).xyz;
    v_normal = worldNormal;
	
    vec3 col = albedoColour * ambientColour;
    // TODO: colour attributes

    v_colour = col;
    #ifdef ATTRIBUTE_UV
	v_uv = uv;
    #endif

    // set the camera-space position of the vertex
	gl_Position = MVP * vec4(position, 1.0);
}