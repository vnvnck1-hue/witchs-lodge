shader_type canvas_item;
// 카드 표면: (1) 원근 기울기 — 드래그 방향·마우스 위치에 따라 카드가 3D로 기운 듯 사다리꼴로 보인다.
// (2) 소모 연출 — 흰 섬광 → 아래에서 위로 불꽃 띠가 타 올라가며 사라진다 (VFX 연구 card_burn 이식).
// 노이즈·연소선은 card_burn_noise.gdshaderinc 공용(에디티브 글로우 층 card_burn_glow 와 같은 선을 쓴다).
//
// 연소선 기준 층 구조 (탄 쪽 → 남은 카드 쪽): [탄 부분 = 투명] | [외곽선] | [불꽃] | [카드]
// 불꽃이 카드 밖으로 삐져나갈 수 있도록 CardView 가 소모 중에는 그림 사각형을 pad 만큼 넓힌다.
// 카드 외곽이 S자 곡선이라 불꽃 마스크는 텍스처 알파를 넓혀서(dilate) 쓴다.

uniform vec2 card_size = vec2(100.0, 120.0);
uniform vec2 pad = vec2(0.0, 0.0);    // 그림 사각형을 카드 밖으로 넓힌 양(px, 한쪽)
uniform vec2 tilt = vec2(0.0, 0.0);   // x: 좌우로 기울기(Y축 회전), y: 앞뒤로 기울기(X축 회전). -0.35..0.35
uniform float shine = 0.0;            // 기울기 쪽 가장자리 하이라이트
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float flash : hint_range(0.0, 1.0) = 0.0;
#include "res://shaders/card_burn_noise.gdshaderinc"

group_uniforms Burn;
uniform bool burn_from_top = false;
uniform vec4 flame_color : source_color = vec4(0.464, 0.252, 0.883, 1.0);
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float flame_brightness : hint_range(1.0, 8.0, 0.1) = 1.0;
/** 불타는 띠 전체 두께 (카드 높이 대비) */
uniform float fire_thickness : hint_range(0.0, 0.4, 0.001) = 0.14;
uniform float flame_percent : hint_range(0.0, 100.0, 0.1) = 80.0;
uniform float outline_percent : hint_range(0.0, 100.0, 0.1) = 20.0;
uniform float speed : hint_range(0.0, 20.0, 0.01) = 11.4;
uniform float noise_scale : hint_range(0.5, 40.0, 0.01) = 21.24;
uniform float burn_noise_scale : hint_range(0.5, 40.0, 0.01) = 15.12;
uniform float edge_wobble : hint_range(0.0, 1.0, 0.001) = 0.865;
uniform float edge_jaggedness : hint_range(0.0, 1.0, 0.001) = 0.164;
uniform float roughness : hint_range(0.0, 1.0, 0.01) = 0.15;
uniform float edge_softness : hint_range(0.5, 8.0, 0.1) = 1.5;

varying vec4 v_modulate;
varying vec2 v_n;

void vertex() {
	v_modulate = COLOR;
	vec2 c = pad + card_size * 0.5;
	vec2 n = (VERTEX - c) / card_size;   // 카드 기준 -0.5..0.5
	v_n = n;
	// 멀어지는 쪽 가장자리는 짧아지고 가까운 쪽은 길어진다
	float sy = 1.0 + tilt.x * n.x * 2.0;
	float sx = 1.0 + tilt.y * n.y * 2.0;
	VERTEX = c + vec2((VERTEX.x - c.x) * sx, (VERTEX.y - c.y) * sy);
	// 원근 시 살짝 좁아지는 폭
	VERTEX.x = c.x + (VERTEX.x - c.x) * (1.0 - abs(tilt.x) * 0.25);
	VERTEX.y = c.y + (VERTEX.y - c.y) * (1.0 - abs(tilt.y) * 0.25);
}

float aa_step(float edge, float x) {
	float w = max(fwidth(x) * edge_softness, 1e-5);
	return smoothstep(edge - w, edge + w, x);
}

float card_alpha(sampler2D tex, vec2 c) {
	float inside = step(0.0, c.x) * step(c.x, 1.0) * step(0.0, c.y) * step(c.y, 1.0);
	return texture(tex, clamp(c, 0.0, 1.0)).a * inside;
}

void fragment() {
	// 그림 사각형 UV → 카드 UV (pad 만큼 넓힌 경우 가운데 기준으로 축소)
	vec2 quad = card_size + pad * 2.0;
	vec2 c = (UV - 0.5) * quad / card_size + 0.5;
	vec4 card = texture(TEXTURE, clamp(c, 0.0, 1.0));
	card.a = card_alpha(TEXTURE, c);

	float lit = clamp(dot(v_n, -normalize(tilt + vec2(0.0001))) + 0.2, 0.0, 1.0);
	card.rgb += vec3(1.0, 0.96, 0.88) * shine * lit * lit * 0.35 * length(tilt) * 3.0;
	card.rgb = mix(card.rgb, vec3(1.0, 0.97, 0.9), flash);

	vec4 col = card;
	if (progress > 0.0) {
		float aspect = card_size.x / card_size.y;
		float t = TIME * speed * 0.1;
		float h = burn_from_top ? c.y : 1.0 - c.y;
		float x = c.x * aspect;

		float gain = mix(0.05, 0.6, roughness);
		float e = burn_edge(x, h, t, progress, fire_thickness, edge_wobble, edge_jaggedness, burn_noise_scale, roughness);   // e < 0 : 탄 부분

		float outline_end = fire_thickness * outline_percent * 0.01;
		float flame_w = fire_thickness * flame_percent * 0.01;
		float tongue = fbm(vec2(x * noise_scale, h * noise_scale * 0.6 - t * 1.5), gain);
		float flame_end = outline_end + flame_w * (0.45 + 1.1 * tongue);

		// 불꽃 마스크: 카드 알파를 pad 범위까지 넓힌 영역 (혀 모양 노이즈로 들쭉날쭉하게)
		vec2 spill = pad / card_size * (0.35 + 0.65 * tongue);
		float dil = card.a;
		for (int i = 0; i < 8; i++) {
			float ang = float(i) * 0.7853982;
			dil = max(dil, card_alpha(TEXTURE, c + vec2(cos(ang), sin(ang)) * spill));
		}
		float band_mask = smoothstep(0.1, 0.6, dil);

		float not_burnt = aa_step(0.0, e);
		float past_outline = aa_step(outline_end, e);
		float past_flame = aa_step(flame_end, e);

		vec4 flame = vec4(flame_color.rgb * flame_brightness, flame_color.a);
		vec4 band = mix(outline_color, flame, past_outline);
		band.a *= band_mask;

		col = mix(band, card, past_flame);
		col = mix(vec4(card.rgb, 0.0), col, not_burnt);
	}
	COLOR = col * v_modulate;
}
