#ifdef GL_ES
precision mediump float;
#endif

void main() {
    gl_FragColor = vec4(gl_FragCoord.zzz, 1.0);
}