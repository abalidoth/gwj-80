extends RigidBody2D

class_name Ball

var rng = RandomNumberGenerator.new()

enum BALL_COLOR {RED, BLUE, GREEN, YELLOW, PURPLE}
enum BALL_SYMBOL {SQUARE, CIRCLE, TRIANGLE, CROSS, STAR}

var ball_color : BALL_COLOR
var ball_symbol : BALL_SYMBOL

var moving = true
var move_time = 0.3

var neighbors = {}
var neighbor_lines = {}

signal other_ball_touched(this_ball: Ball, other_ball:Ball)
signal explosion(ball_position:Vector2)

var bomb = false
var rubber = false

func _ready():
	
	$Timer.start(move_time)
	
	ball_color = rng.randi() % BALL_COLOR.size()
	ball_symbol = rng.randi() % BALL_SYMBOL.size()
	
	match ball_color:
		BALL_COLOR.RED:
			modulate = Color.RED
		BALL_COLOR.BLUE:
			modulate = Color.DODGER_BLUE
		BALL_COLOR.GREEN:
			modulate = Color.LIME_GREEN
		BALL_COLOR.YELLOW:
			modulate = Color.YELLOW
		BALL_COLOR.PURPLE:
			modulate = Color.VIOLET
			
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

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Replace with function body.

func change_size(new_scale):
	$Circle.scale *= new_scale
	$PhysicsShape.shape.radius *= new_scale
	$CollisionArea/CollisionShape.shape.radius *= new_scale
	%Icons.scale *= new_scale
	$Shine.scale *= new_scale
	%SmokeParticles.scale *= new_scale
	%RubberMask.scale *= new_scale
	
func _process(delta):
	if linear_velocity.length()>5:
		moving = true
		#modulate = Color.CRIMSON
		$Timer.start(move_time)
		

func _on_timer_timeout():
	moving = false
	#modulate = Color.WHITE


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
	physics_material_override.bounce = 0.8
	
