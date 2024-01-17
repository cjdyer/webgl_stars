#version 300 es

precision highp float;

in vec4 vertexPosition;
out vec4 fragmentColor;

uniform vec2 resolution;
uniform vec2 angle;
uniform float time;

vec4 mod289(vec4 x) {
    return x - floor(x * (1.0f / 289.0f)) * 289.0f;
}

vec4 permute(vec4 x) {
    return mod289(((x * 34.0f) + 1.0f) * x);
}

// Perlin noise function
float noise(vec3 position) {
    vec3 floorPos = floor(position);
    vec3 smoothPos = position - floorPos;
    smoothPos = smoothPos * smoothPos * (3.0f - 2.0f * smoothPos);

    vec4 b = floorPos.xxyy + vec4(0.0f, 1.0f, 0.0f, 1.0f);
    vec4 k1 = permute(b.xyxy);
    vec4 k2 = permute(k1.xyxy + b.zzww);

    vec4 c = k2 + floorPos.zzzz;
    vec4 k3 = permute(c);
    vec4 k4 = permute(c + 1.0f);

    vec4 o1 = fract(k3 * (1.0f / 41.0f));
    vec4 o2 = fract(k4 * (1.0f / 41.0f));

    vec4 o3 = o2 * smoothPos.z + o1 * (1.0f - smoothPos.z);
    vec2 o4 = o3.yw * smoothPos.x + o3.xz * (1.0f - smoothPos.x);

    return o4.y * smoothPos.y + o4.x * (1.0f - smoothPos.y);
}

// Hash function for star generation
vec3 hash(vec3 position) {
    uvec3 p = uvec3(ivec3(position));
    p = p * uvec3(392664765U, 347388432U, 814857934U) + p.zxy + p.yzx;
    p = p.yzx * (p.zxy ^ (p >> 3U));

    return vec3(p ^ (p >> 16U)) * (1.0f / vec3(0xffffffffU));
}

// Generate star field
vec3 generateStars(vec3 direction) {
    vec3 starColor = vec3(0.0f);
    float resolutionScale = 500.0f;

    for(float i = 0.0f; i < 5.0f; i++) {
        vec3 position = fract(direction * (0.15f * resolutionScale) + time * 0.25f) - 0.5f;
        vec3 id = floor(direction * (0.15f * resolutionScale) + time * 0.25f);
        vec2 randomNumbers = hash(id).xy;
        float intensity = 1.0f - smoothstep(0.0f, 0.6f, length(position));

        intensity *= step(randomNumbers.x, 0.0005f + i * 0.002f);
        starColor += intensity * (mix(vec3(1.0f, 0.49f, 0.1f), vec3(0.75f, 0.9f, 1.0f), randomNumbers.y) * 0.25f + 0.75f);
        direction *= 1.4f;
    }

    return starColor * starColor;
}

vec3 flare(vec2 p, vec2 pos, vec3 baseColor, float sz) {
    vec2 q = p - pos;
    q *= sz;
    float a = atan(q.x, q.y);
    float r = length(q);

    float rz = 0.f;
    rz += .07f / (length((q) * vec2(7.f, 200.f)));
    rz += 0.3f * (pow(abs(fract(a * .97f + .52f) - 0.5f), 3.f) * (sin(a * 30.f) * 0.15f + 0.85f) * exp2((-r * 5.f)));

    vec3 col = vec3(rz) * baseColor;
    col += exp2((1.f - length(q)) * 50.f - 50.f) * baseColor * vec3(3.f);
    col += exp2((1.f - length(q)) * 20.f - 20.f) * baseColor * vec3(1, 0.95f, 0.8f) * 0.5f;

    return clamp(col, 0.f, 1.f);
}

void main() {
    // Screen position normalization
    vec2 screenPosition = vertexPosition.xy;
    screenPosition.x *= resolution.x / resolution.y;

    float fieldOfView = 0.55f;

    // Calculate view direction
    vec3 viewDirection = normalize(vec3(screenPosition * fieldOfView, fieldOfView));

    // Calculate rotation based on camera angle
    float cosX = cos(angle.x);
    float sinX = sin(angle.x);
    float cosNegY = cos(-angle.y);
    float sinNegY = sin(-angle.y);

    viewDirection = vec3(viewDirection.x * cosX + (viewDirection.y * sinNegY + viewDirection.z * cosNegY) * sinX, viewDirection.y * cosNegY - viewDirection.z * sinNegY, -viewDirection.x * sinX + (viewDirection.y * sinNegY + viewDirection.z * cosNegY) * cosX);

    vec3 baseCol = vec3(0.7f, 0.7f, 0.7f);
    vec3 star = clamp(flare(screenPosition, -viewDirection.xy / viewDirection.z * fieldOfView, baseCol, 2.f) * viewDirection.z,0.,1.);

    // Dust color calculation
    vec3 dustColor = vec3(0.1f, 0.0f, 0.2f);
    dustColor = mix(dustColor, viewDirection.z < 0.0f ? vec3(0.2f, 0.0f, 0.0f) : vec3(0.0f, 0.2f, 0.2f), abs(viewDirection.z));

    // Combine star field and dust color
    vec3 skyColor = generateStars(viewDirection) + star + dustColor * noise(viewDirection * 1.5f);
    fragmentColor = vec4(skyColor, 1.0f);
}
