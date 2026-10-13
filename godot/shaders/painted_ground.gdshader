shader_type spatial;
render_mode specular_disabled;
uniform sampler2D cleanplate : source_color, filter_linear_mipmap, repeat_disable;
uniform vec3 reference_center = vec3(1.0,0.0,1.3);
uniform vec3 reference_right = vec3(.7071,0.0,-.7071);
uniform vec3 reference_up = vec3(-.586,.559,-.586);
uniform vec2 reference_size = vec2(44.0,22.0);
uniform float warm_enabled = 1.0;
varying vec3 world_pos;
void vertex() { world_pos = (MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment() {
	vec3 p = world_pos-reference_center;
	vec2 uv = vec2(.5+dot(p,reference_right)/reference_size.x,.5-dot(p,reference_up)/reference_size.y);
	vec3 c = texture(cleanplate,clamp(uv,vec2(.001),vec2(.999))).rgb;
	c = mix(c,vec3(dot(c,vec3(.2126,.7152,.0722))),.22);
	c *= vec3(1.08,1.03,.76);
	// Regional colored mist keeps the dark forest's plum/teal hue visible.
	float outer = smoothstep(7.5,19.0,length((world_pos.xz-vec2(1.0,1.3))/vec2(1.1,1.0)));
	float pocket = .5+.5*sin(world_pos.x*.22-world_pos.z*.19);
	vec3 forest_tint = mix(vec3(.25,.16,.40),vec3(.11,.32,.36),pocket);
	c = mix(c,c*.70+forest_tint*.26,outer*.65);
	float rim = smoothstep(.34,.70,length((uv-vec2(.5,.49))*vec2(1.0,1.7)));
	c *= mix(vec3(1.0),mix(vec3(.43,.30,.57),vec3(.25,.48,.53),pocket),rim*.85);
	vec2 lamp_delta = (world_pos.xz-vec2(.25,3.55))/vec2(2.8,2.1);
	float warm = exp(-dot(lamp_delta,lamp_delta)*.5)*warm_enabled;
	vec2 pen_delta = (world_pos.xz-vec2(3.8,1.0))/vec2(1.7,2.0);
	warm = max(warm,exp(-dot(pen_delta,pen_delta)*.5)*.72*warm_enabled);
	c = mix(c,vec3(1.0,.53,.23),warm*.83);
	ALBEDO = c*.62;
	EMISSION = c*.44;
	ROUGHNESS=1.0; SPECULAR=0.0;
}
void light() {
	float d = smoothstep(.06,.94,(dot(NORMAL,LIGHT)+.32)/1.32);
	vec3 lc = LIGHT_COLOR/PI;
	DIFFUSE_LIGHT += lc * ATTENUATION * d;
	float warm = max(lc.r-lc.b*1.55,0.0);
	DIFFUSE_LIGHT -= vec3(0.0,0.0,.15)*clamp(warm*ATTENUATION*d,0.0,1.0);
}
