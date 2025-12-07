precision highp float;

uniform float uTime;
uniform vec2 uSize;

void main() {
  vec2 uv = gl_FragCoord.xy / uSize.xy;

  // Wave distortion
  float wave = sin(uv.x * 10.0 + uTime * 2.0) * 0.1 +
               cos(uv.y * 12.0 + uTime * 1.5) * 0.1;

  uv += wave;

  // Neon gradient (UIT style: dark blue -> cyan)
  vec3 col1 = vec3(0.0, 0.05, 0.18);
  vec3 col2 = vec3(0.0, 0.6, 1.0);

  float gradient = smoothstep(0.0, 1.0, uv.y + wave);
  vec3 color = mix(col1, col2, gradient);

  gl_FragColor = vec4(color, 1.0);
}
