shader_type canvas_item;

uniform vec2 rotation;
uniform vec2 voronoi_points[15];
uniform vec2 voronoi_vectors[15];

const float opacity = 0.7;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float min_dist = 10.0;
	int min_index = 0;
	for(int i=0; i<voronoi_points.length(); i++)
	{
		float this_dist = distance(UV, voronoi_points[i]);
		if(this_dist < min_dist)
		{
			min_dist = this_dist;
			min_index = i;
		}
	}
	float this_dot = 1.0-abs(dot(voronoi_vectors[min_index],rotation));
	if(distance(UV,vec2(0.5,0.5))<0.5)
	{
		COLOR= vec4(1.0,1.0,1.0, this_dot*opacity);
	} else {
		COLOR = vec4(0.0,0.0,0.0,0.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
