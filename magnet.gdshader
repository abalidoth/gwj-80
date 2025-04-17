shader_type canvas_item;

uniform float frequency = 10.0;
uniform float speed = 5.0;


void vertex() {
}

void fragment() {

	float dist = distance(UV,vec2(0.5,0.5));
	float amp = (sin(dist * frequency + TIME * speed) + 1.0)*0.5;
	COLOR *= amp;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
