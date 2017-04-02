#ifdef GL_ES
precision mediump float;
#endif

#define SHADER_NAME Shadow

void main() {
    gl_FragColor = vec4(gl_FragCoord.z, 1.0, 0.0, 1.0);
}