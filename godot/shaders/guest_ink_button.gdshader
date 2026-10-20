shader_type canvas_item;
// 대화창 '마녀의 대답'·'다음' 버튼용 잉크 패널. 뒤 대화 패널(guest_ink_panel.tres)과 같은 천 일렁임·안료 흐름 공식을
// 패널 좌표로 계산해, 버튼 윤곽과 결이 패널과 같은 위상으로 함께 움직인다. 색·테두리는 버튼 상태(ReplyRow)가 정한다.

uniform float motion_time = 0.0;      // 패널과 같은 시계(presenter.clock)
uniform vec2 rect_size = vec2(430.0, 150.0);   // 이 ColorRect 의 픽셀 크기(버튼 + pad 양쪽)
uniform float pad_px = 18.0;          // 버튼 윤곽 바깥 여유(일렁임이 잘리지 않게)
uniform vec2 panel_origin = vec2(0.0); // 이 ColorRect 왼쪽 위의 패널 좌표(px, 패널 왼쪽 위 = 0)
uniform vec2 panel_size = vec2(1550.0, 500.0);
uniform float wobble = 0.9;           // 패널 일렁임 대비 윤곽 흔들림 비율
uniform vec4 fill_color : source_color = vec4(0.141, 0.086, 0.243, 0.82);
uniform vec4 border_color : source_color = vec4(0.655, 0.588, 0.804, 0.22);
uniform float border_px = 1.0;

uniform float radius_px = 14.0;       // 네모 모서리 둥글기
uniform float bump_px = 4.5;          // 둘레를 따라 도는 울퉁불퉁한 출렁임 크기

// 둥근 네모까지의 거리(px)
float rounded_box(vec2 p, vec2 half_size, float r) {
	vec2 q = abs(p) - half_size + vec2(r);
	return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
	vec2 px = UV * rect_size;
	vec2 puv = (panel_origin + px) / panel_size;
	float clock = motion_time;
	// guest_ink_panel 'Slow cloth / 2 waves' 와 같은 식(패널 uv 기준) → 픽셀 변위
	vec2 shift;
	shift.y = (0.018 * sin(puv.x * 12.0 + clock * 0.48) + 0.009 * sin(puv.x * 23.0 - clock * 0.31)) * panel_size.y;
	shift.x = 0.007 * sin(puv.y * 9.0 + clock * 0.37) * panel_size.x;
	vec2 warped = px + shift * wobble;
	vec2 half_size = rect_size * 0.5 - vec2(pad_px);
	vec2 c = warped - rect_size * 0.5;
	float d = rounded_box(c, half_size, radius_px);
	// 서로 다른 방향·속도로 흐르는 파동 세 겹 → 네 변이 고르지 않게 울퉁불퉁 일렁인다(모서리에서도 끊기지 않는다)
	float seed = panel_origin.x * 0.013 + panel_origin.y * 0.029;  // 버튼마다 모양이 다르게
	float bump = 0.50 * sin(c.x * 0.075 + c.y * 0.061 + clock * 0.9 + seed)
		+ 0.32 * sin(c.x * 0.13 - c.y * 0.117 - clock * 1.35 + seed * 1.7)
		+ 0.18 * sin(c.x * 0.047 + c.y * 0.23 + clock * 0.65 - seed);
	d -= bump * bump_px;
	float aa = max(fwidth(d), 0.75);
	float inside = 1.0 - smoothstep(-aa, aa, d);
	// 테두리: 윤곽 안쪽 border_px 띠
	float band = smoothstep(-border_px - aa, -border_px + aa, d);
	// guest_ink_panel 'pigment' 처럼 느린 안료 흐름으로 바탕에 옅은 얼룩결
	vec2 wuv = (panel_origin + warped) / panel_size;
	float flow = 0.5 + 0.5 * sin(wuv.x * 5.0 + wuv.y * 3.0 + clock * 0.22);
	vec3 fill = mix(fill_color.rgb, fill_color.rgb * 0.84, flow * 0.6);
	// 바탕 위에 테두리를 겹친다(source-over)
	float edge_a = band * border_color.a;
	float a = fill_color.a + (1.0 - fill_color.a) * edge_a;
	vec3 rgb = (fill * fill_color.a * (1.0 - edge_a) + border_color.rgb * edge_a) / max(a, 0.001);
	COLOR = vec4(rgb, a * inside);
}
