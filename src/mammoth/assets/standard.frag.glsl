#ifdef GL_ES
precision mediump float;
#endif

#define SHADER_NAME Standard

// lights
#ifdef UNIFORM_DIRECTIONAL_LIGHTS
struct SDirectionalLight {
    vec3 direction;
    vec3 colour;
};
uniform SDirectionalLight directionalLights[NUMBER_DIRECTIONAL_LIGHTS];
#endif
#ifdef UNIFORM_POINT_LIGHTS
struct SPointLight {
    vec3 position;
    vec3 colour;
    float distance;
};
uniform SPointLight pointLights[NUMBER_POINT_LIGHTS];
#endif

// material uniforms
uniform vec3 albedoColour;
uniform vec3 ambientColour;

// inputs
varying vec3 v_position;
varying vec3 v_normal;
varying vec3 v_colour;
#ifdef ATTRIBUTE_UV
varying vec2 v_uv;
#endif

#ifdef UNIFORM_TEXTURE
uniform sampler2D texture;
#endif

void main() {
    // base colour from vertex shader
    vec3 colour = v_colour;

    #ifdef UNIFORM_DIRECTIONAL_LIGHTS
	// sun diffuse term
	float dLight0 = clamp(dot(v_normal, directionalLights[0].direction), 0.0, 1.0);
    colour += directionalLights[0].colour * dLight0 * albedoColour;
    #endif

    #ifdef UNIFORM_POINT_LIGHTS
    vec3 pLightDir0 = pointLights[0].position - v_position;
    float pDist0 = length(pLightDir0);
	float pLight0 = clamp(dot(v_normal, pLightDir0), 0.0, 1.0) * pointLights[0].distance / (pDist0 * pDist0);
    colour += pointLights[0].colour * pLight0 * albedoColour;
    #endif

    vec4 outColour = vec4(colour, 1.0);
    #ifdef UNIFORM_TEXTURE
    outColour *= texture2D(texture, v_uv);
    #endif

    // gamma
    gl_FragColor = vec4(pow(outColour.rgb, vec3(1.0/2.2)), outColour.a);
    //gl_FragColor = outColour;
}