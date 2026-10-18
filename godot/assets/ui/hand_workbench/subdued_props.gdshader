shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec4 painted = texture(TEXTURE, UV);
	float value = dot(painted.rgb, vec3(0.2126, 0.7152, 0.0722));
	// 카드의 크림·금빛보다 낮은 밝기와 채도, 차가운 후면 장식 톤.
	painted.rgb = mix(vec3(value), painted.rgb, 0.55) * vec3(0.66, 0.69, 0.82);
	COLOR = painted;
}
