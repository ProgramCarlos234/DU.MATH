shader_type canvas_item;

uniform int color_index = 0;

vec4 get_color_from_index(int index) {
	if (index == 0) return vec4(1.0, 0.0, 0.0, 1.0); // Rojo
	if (index == 1) return vec4(0.0, 1.0, 0.0, 1.0); // Verde
	if (index == 2) return vec4(0.0, 0.0, 1.0, 1.0); // Azul
	if (index == 3) return vec4(1.0, 1.0, 0.0, 1.0); // Amarillo
	if (index == 4) return vec4(1.0, 0.0, 1.0, 1.0); // Magenta
	return vec4(1.0); // Blanco por defecto
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 tint = get_color_from_index(color_index);
	COLOR = vec4(tint.rgb, tex_color.a);
	if (COLOR.a < 0.1) {
		discard;
	}
}
