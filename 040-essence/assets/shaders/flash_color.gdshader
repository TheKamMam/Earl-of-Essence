shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1, 1, 1, 1);
uniform float flash_mult : hint_range(0.0, 1.0, 0.1);

void fragment() {
	vec4 prev_color = texture(TEXTURE, UV);
	vec4 new_tint = flash_color;
	new_tint.a = prev_color.a;
	
	COLOR = mix(prev_color, new_tint, flash_mult);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
