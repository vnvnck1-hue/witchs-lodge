shader_type spatial;
// Forward+ depth/normal outlines, drawn before the CanvasLayer HUD.
render_mode unshaded, fog_disabled, depth_test_disabled, depth_draw_never, cull_disabled, shadows_disabled;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D normal_texture : hint_normal_roughness_texture, repeat_disable, filter_nearest;
uniform vec4 ink_color : source_color = vec4(.065,.025,.105,1.0);
uniform float width_pixels = 3.0;
uniform float depth_threshold = .32;
uniform float normal_threshold = .75;

void vertex() {
	POSITION = vec4(VERTEX.xy,1.0,1.0); // Godot 4.3+ reverse Z near plane.
}

vec3 view_position(vec2 uv, mat4 inv_projection) {
	float depth = textureLod(depth_texture,uv,0.0).r;
	vec4 pos = inv_projection*vec4(uv*2.0-1.0,depth,1.0);
	return pos.xyz/pos.w;
}

vec3 view_normal(vec2 uv) {
	return normalize(textureLod(normal_texture,uv,0.0).rgb*2.0-1.0);
}

void fragment() {
	vec2 pixel = 1.0/VIEWPORT_SIZE;
	vec3 center = view_position(SCREEN_UV,INV_PROJECTION_MATRIX);
	vec3 normal = view_normal(SCREEN_UV);
	// Remove the expected depth change across a flat sloping surface.
	// This keeps the snow field and broad roof faces clear of false contour lines.
	float edge = 0.0;
	for (int i=0;i<8;i++) {
		float a = float(i)*.785398163;
		vec2 offset = vec2(cos(a),sin(a))*width_pixels;
		vec2 uv = clamp(SCREEN_UV+offset*pixel,pixel*.5,vec2(1.0)-pixel*.5);
		vec3 neighbor = view_position(uv,INV_PROJECTION_MATRIX);
		float delta = abs(dot(normal,neighbor-center));
		float depth_edge = smoothstep(depth_threshold,depth_threshold*1.6,delta);
		float normal_delta = 1.0-dot(normal,view_normal(uv));
		float crease = smoothstep(normal_threshold,normal_threshold+.22,normal_delta);
		edge = max(edge,max(depth_edge,crease*.85));
	}
	ALBEDO = ink_color.rgb;
	ALPHA = edge*ink_color.a;
}
