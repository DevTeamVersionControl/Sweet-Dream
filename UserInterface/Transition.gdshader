shader_type canvas_item;

uniform vec2 fragment_number = vec2(32, 18);
uniform float dissolve_state : hint_range(0, 2) = 2;
uniform vec4 color : source_color;

void fragment() {
	vec2 pixelFract = fract(UV * fragment_number);
	float pixelDist = distance(pixelFract, vec2(0.5, 0.5));
	COLOR = color;
	COLOR.a *= step(pixelDist, dissolve_state - UV.x);
}
