#version 300 es
precision highp float;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

vec3 adjustContrast(vec3 color, float contrast) {
    return clamp((color - 0.5) * contrast + 0.5, 0.0, 1.0);
}

vec3 adjustSaturation(vec3 color, float sat) {
    float luma = dot(color, vec3(0.299, 0.587, 0.114));
    return clamp(mix(vec3(luma), color, sat), 0.0, 1.0);
}

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    vec3 color = pixColor.rgb;

    color = adjustContrast(color, 1.25);
    color = adjustSaturation(color, 1.35);

    // sheen boost di highlight (kesan glossy)
    float luma = dot(color, vec3(0.299, 0.587, 0.114));
    float highlight = smoothstep(0.6, 1.0, luma);
    color += vec3(0.03, 0.02, 0.05) * highlight; // tint dingin di area terang
    color += 0.08 * highlight * highlight;

    fragColor = vec4(clamp(color, 0.0, 1.0), pixColor.a);
}
