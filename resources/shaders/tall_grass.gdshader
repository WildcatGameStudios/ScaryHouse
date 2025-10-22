shader_type spatial;

uniform vec4 grass_color : source_color;

varying vec4 custom_data;
varying vec3 world_position;
//instance uniform vec4 INSTANCE_CUSTOM;

void vertex() {
	// Called for every vertex the material is visible on.
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    custom_data = INSTANCE_CUSTOM;
}

void fragment() {
	// At runtime, INSTANCE_CUSTOM.x is valid
	float cut_height = custom_data.r;

	if (world_position.y > cut_height) {
		discard;
	}

    if (world_position.y > cut_height ) {
        ALBEDO = vec3(1.0, 0.0, 0.0); // Red - should be cut
    } else if (world_position.y > cut_height - 0.05) {
        ALBEDO = vec3(1.0, 1.0, 0.0); // Yellow - border
    } else {
        ALBEDO = grass_color.rgb; // Normal - visible
    }
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
