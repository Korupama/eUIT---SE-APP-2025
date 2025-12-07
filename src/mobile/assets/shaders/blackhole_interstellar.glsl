precision highp float;

uniform float uTime;
uniform vec2 uSize;

// Cheap hash noise
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(23.43, 93.17))) * 12345.678);
}

// Soft noise, interpolated (VERY cheap)
float softNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * uSize.xy) / uSize.y;

    float t = uTime * 0.55;

    float r = length(uv);
    float angle = atan(uv.y, uv.x);

    // Chaotic swirl (changes slowly over time)
    float chaos = softNoise(uv * 3.0 + t * 0.3) * 1.2;

    float swirl = (0.11 / (r + 0.18)) * (1.0 + chaos * 0.6);

    float angleWarp = angle + swirl * sin(t * 2.0 + r * 6.0 + chaos);

    vec2 warped = vec2(cos(angleWarp), sin(angleWarp)) * r;

    // Accretion disk glow
    float disk = smoothstep(0.23, 0.17, r) * 2.0;

    // Outer nebula breathing
    float nebula = softNoise(warped * 2.0 - t * 0.25) * (1.0 - r);

    // Star streaks getting sucked
    float stars = hash(warped * 90.0 + t) * smoothstep(0.95, 0.15, r);

    // Color palette
    vec3 baseColor = vec3(0.0, 0.07, 0.18);
    vec3 accretion = vec3(0.0, 0.65, 1.5) * disk;
    vec3 warpColor = vec3(0.0, 0.55, 1.2) * swirl * 1.4;
    vec3 nebulaColor = vec3(0.0, 0.2, 0.5) * nebula;
    vec3 starColor = vec3(1.0) * stars * 0.9;

    vec3 finalColor = baseColor + accretion + warpColor + nebulaColor + starColor;

    // Cosmic vignette
    finalColor *= smoothstep(1.25, 0.25, r);

    gl_FragColor = vec4(finalColor, 1.0);
}
