shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(0.35, 0.25, 0.1, 1.0);
uniform float fade : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 base_color = texture(TEXTURE, UV);

	float distance_from_center = length(UV - vec2(0.5));
	float alpha_multiplier = smoothstep(0.0, 0.7, distance_from_center);

	// Ensure we're working in the correct color space
	base_color.rgb = mix(base_color.rgb, tint_color.rgb, tint_color.a);
	base_color.a *= alpha_multiplier * fade;

	COLOR = base_color;
}