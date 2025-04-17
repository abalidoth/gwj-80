extends Node2D

var Ball = preload("res://ball.tscn")

var SmokeBlast = preload("res://assets/smoke_blast.tscn")

var all_balls:Array[Ball] = []
var rng = RandomNumberGenerator.new()

var next_ball:Ball

var size_least = 0.75
var size_most = 1.25

var drop_left = 330
var drop_right = 790

var match_size = 5

var explosion_force = 600
var magnet_force = 5000

func set_next_ball():
	next_ball = Ball.instantiate()
	next_ball.explosion.connect(_on_ball_explosion)
	add_child(next_ball)
	next_ball.position = $NextBallMarker.position
	next_ball.freeze = true
	var new_scale = rng.randf_range(size_least, size_most)
	next_ball.change_size(new_scale)
	$Line2D.material.set_shader_parameter("color1",next_ball.modulate)
	$DropIcon.modulate = next_ball.modulate
	match rng.randi() % 10:
		0:
			next_ball.set_bomb()
		1:
			next_ball.set_rubber()
		2:
			next_ball.set_magnet()

func _ready():
	set_next_ball()

func _input(event):
	var mouse_x_clamped = clamp(event.position.x,drop_left, drop_right)
	if event is InputEventMouseButton and $ClickTimer.is_stopped():
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var new_ball = next_ball
			new_ball.position = Vector2(mouse_x_clamped,50)
			all_balls.append(new_ball)
			new_ball.freeze = false
			set_next_ball()
			$ClickTimer.start()
	elif event is InputEventMouseMotion:
		$DropIcon.position = Vector2(mouse_x_clamped,25)
		$Line2D.points[-1] = Vector2(mouse_x_clamped,25)

func _process(delta):
	var settled = true
	for ball in all_balls:
		if ball.moving:
			settled = false
	if settled:
		if len($KillBox.get_overlapping_areas())>0 and $ClickTimer.is_stopped():
			game_over()
	check_for_pop()
			
func _physics_process(delta):
	for ball1 in all_balls:
		if ball1.magnet:
			for ball2 in all_balls:
				if ball1 != ball2:
					var force_dist = (ball1.position - ball2.position).abs()
					var force_direction = (ball1.position - ball2.position)/force_dist
					ball2.apply_central_force(force_direction * delta * magnet_force)
	

func check_for_pop():
	
	#check symbols
	var to_check = all_balls.duplicate()
	var out_groups_symbol = []
	while to_check:
		var current_group = []
		var already_checked = []
		current_group.append(to_check[0])
		var current_symbol = current_group[0].ball_symbol
		while current_group:
			var checking = current_group.pop_back()
			if checking in to_check:
				already_checked.append(checking)
				to_check.erase(checking)
				for i in checking.get_symbol_neighbors():
					current_group.append(i)
		out_groups_symbol.append(already_checked)
	for group in out_groups_symbol:
		if len(group) >= match_size:
			for i in group:
				all_balls.erase(i)
				i.pop()
				
	#check colors
	to_check = all_balls.duplicate()
	var out_groups_color = []
	while to_check:
		var current_group = []
		var already_checked = []
		current_group.append(to_check[0])
		var current_color = current_group[0].ball_color
		while current_group:
			var checking = current_group.pop_back()
			if checking in to_check:
				already_checked.append(checking)
				to_check.erase(checking)
				for i in checking.get_color_neighbors():
					current_group.append(i)
		out_groups_color.append(already_checked)
	for group in out_groups_color:
		if len(group) >= match_size:
			for i in group:
				all_balls.erase(i)
				i.pop()
	
	#this is to prevent balls from hanging
	for ball in all_balls:
		ball.apply_impulse(Vector2(0,0))


func game_over():
	get_tree().change_scene_to_file("res://main_scene.tscn")

func _on_ball_explosion(explosion_position:Vector2):
	var smoke_blast = SmokeBlast.instantiate()
	add_child(smoke_blast)
	smoke_blast.position = explosion_position
	smoke_blast.emitting=true
	for ball in all_balls:
		var direction = (ball.position - explosion_position)
		var distance = direction.length()
		if distance >0.1:
			ball.apply_impulse(direction * explosion_force / distance)
			
	var smoke_tween = smoke_blast.create_tween()
	smoke_tween.tween_interval(2)
	smoke_tween.tween_callback(smoke_blast.queue_free)
