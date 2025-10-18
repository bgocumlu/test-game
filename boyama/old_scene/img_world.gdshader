shader_type canvas_item;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (c.r > 0.9 && c.g > 0.9 && c.b > 0.9)
		discard; // make white pixels transparent
	COLOR = vec4(0.0, 0.0, 0.0, 1.0); // draw black outlines only
}
