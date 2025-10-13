shader_type spatial;
uniform vec4 grass_color : source_color;

//instance uniform vec4 INSTANCE_CUSTOM;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// At runtime, INSTANCE_CUSTOM.x is valid
    float cut_height = INSTANCE_CUSTOM.x;

    ALBEDO = grass_color.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
