// 화면 후처리: 가장자리의 짙은 인디고 비네트 + 어두운 영역을 보라로 들어 올리는 색보정.
shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform vec4 vignette_color : source_color = vec4(0.17, 0.2, 0.36, 1.0);
uniform float vignette_strength = 0.10;
uniform float vignette_start = 0.45;
uniform float vignette_end = 1.15;
uniform vec4 lift_color : source_color = vec4(0.12, 0.07, 0.26, 1.0);
uniform float lift_amount = 0.0;
uniform float saturation = 1.0;

void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	vec2 uv = SCREEN_UV - 0.5;
	uv.x *= (SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x) * 0.62;
	float v = smoothstep(vignette_start, vignette_end, length(uv) * 1.6);
	c = mix(c, c * vignette_color.rgb * 2.2, v * vignette_strength);
	float lum = dot(c, vec3(0.299, 0.587, 0.114));
	c += lift_color.rgb * (1.0 - smoothstep(0.0, 0.55, lum)) * lift_amount;
	c = mix(vec3(dot(c, vec3(0.299, 0.587, 0.114))), c, saturation);
	COLOR = vec4(c, 1.0);
}
