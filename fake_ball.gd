extends Node2D

class_name FakeBall


@export var ball_color : BALL_COLOR
@export var ball_symbol : BALL_SYMBOL

@export var bomb = false
@export var rubber = false
@export var magnet = false
@export var bonus = false
@export var gem = false

var rng = RandomNumberGenerator.new()

enum BALL_COLOR {RED, BLUE, GREEN, YELLOW, PURPLE}
enum BALL_SYMBOL {SQUARE, CIRCLE, TRIANGLE, CROSS, STAR}


var neighbors = {}
var neighbor_lines = {}

signal explosion(ball_position:Vector2)

var voronoi_points: Array[Vector2]
var voronoi_vectors: Array[Vector2]

func _ready():
	
	match ball_color:
		BALL_COLOR.RED:
			$Circle.modulate = Color.RED
		BALL_COLOR.BLUE:
			$Circle.modulate = Color.DODGER_BLUE
		BALL_COLOR.GREEN:
			$Circle.modulate = Color.LIME_GREEN
		BALL_COLOR.YELLOW:
			$Circle.modulate = Color.YELLOW
		BALL_COLOR.PURPLE:
			$Circle.modulate = Color.VIOLET
			
	match ball_symbol:
		BALL_SYMBOL.STAR:
			%Icons/StarIcon.visible=true
		BALL_SYMBOL.CIRCLE:
			%Icons/CircleIcon.visible = true
		BALL_SYMBOL.TRIANGLE:
			%Icons/TriangleIcon.visible= true
		BALL_SYMBOL.SQUARE:
			%Icons/SquareIcon.visible=true
		BALL_SYMBOL.CROSS:
			%Icons/CrossIcon.visible=true
			
	if bomb:
		set_bomb()
	if rubber:
		set_rubber()
	if magnet:
		set_magnet()
	if bonus:
		set_bonus()
	if gem:
		set_gem()



func change_size(new_scale):
	$Circle.scale *= new_scale
	$PhysicsShape.shape.radius *= new_scale
	$CollisionArea/CollisionShape.shape.radius *= new_scale
	%Icons.scale *= new_scale
	$Shine.scale *= new_scale
	%SmokeParticles.scale *= new_scale
	%RubberMask.scale *= new_scale
	%MagnetMask.scale *= new_scale
	%BonusParticles.scale *= new_scale
	%GemMask.scale *= new_scale
	
func _process(delta):
		
	var rotation_vector = Vector2(cos(rotation), sin(rotation))
	$GemMask.material.set_shader_parameter("rotation", rotation_vector)
		




func _on_collision_area_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	pass

func get_symbol_neighbors():
	var out = []
	for i in $CollisionArea.get_overlapping_areas():
		if i.get_parent().ball_symbol == ball_symbol:
			out.append(i.get_parent())
	return out
	
func get_color_neighbors():
	var out = []
	for i in $CollisionArea.get_overlapping_areas():
		if i.get_parent().ball_color == ball_color:
			out.append(i.get_parent())
	return out

func get_gem_neighbors():
	var out = []
	for i in $CollisionArea.get_overlapping_areas():
		if i.get_parent().gem:
			out.append(i.get_parent())
	return out

func pop():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($Circle,"scale",Vector2.ZERO, 0.1)
	tween.tween_callback(queue_free)
	if bomb:
		explosion.emit(position)

func set_bomb():
	bomb = true
	%SmokeParticles.emitting=true
	
func set_rubber():
	rubber = true
	%RubberMask.visible = true
	
func set_magnet():
	magnet = true
	%MagnetMask.visible = true

func set_bonus():
	bonus = true
	%BonusParticles.emitting = true

func set_gem():
	gem = true
	var rotation_vector = Vector2(cos(rotation), sin(rotation))
	for i in range(15):
		voronoi_points.append(Vector2(rng.randf(),rng.randf()))
		var voronoi_angle = rng.randf() * TAU
		voronoi_vectors.append(Vector2(cos(voronoi_angle), sin(voronoi_angle)))
		$GemMask.material.set_shader_parameter("rotation", rotation_vector)
		$GemMask.material.set_shader_parameter("voronoi_points", voronoi_points)
		$GemMask.material.set_shader_parameter("voronoi_vectors", voronoi_vectors)
	$GemMask.visible = true
		
	
