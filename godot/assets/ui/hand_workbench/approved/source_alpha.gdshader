shader_type canvas_item;
render_mode unshaded;
uniform sampler2D alpha_sheet : filter_linear, repeat_disable;
uniform vec4 source_rect;
uniform vec4 alpha_rect;
void fragment() {
	vec2 source_pixel = UV * vec2(1448.0,1086.0);
	vec2 relative = (source_pixel-source_rect.xy)/source_rect.zw;
	vec2 mask_uv = (alpha_rect.xy+relative*alpha_rect.zw)/vec2(2048.0,1024.0);
	// 원본 RGB를 직접 샘플링하고, 정밀 분리 PNG의 알파만 적용한다.
	vec4 original = texture(TEXTURE, UV);
	COLOR = vec4(original.rgb, texture(alpha_sheet,mask_uv).a);
}
