extends Node2D

var Ball = preload("res://ball.tscn")
var Star = preload("res://assets/star.tscn")

var SmokeBlast = preload("res://assets/smoke_blast.tscn")

var all_balls:Array[Ball] = []
var rng = RandomNumberGenerator.new()

var mouse_x_clamped:float
var next_ball:Ball

var size_least = 0.75
var size_most = 1.25

var drop_left = 488
var drop_right = 952

var match_size = 5

var explosion_force = 600
var magnet_force = 50000
var force_radius = 100
var death_timer_grace = 0.25

var num_stars = 0
var star_req = 7
var star_scaling = 1.2
var star_score = 0

func set_next_ball():
	next_ball = Ball.instantiate()
	next_ball.explosion.connect(_on_ball_explosion)
	add_child(next_ball)
	next_ball.position = $NextBallMarker.position
	next_ball.freeze = true
	var new_scale = rng.randf_range(size_least, size_most)
	next_ball.change_size(new_scale)
	var ball_color:Color = next_ball.get_node("Circle").modulate
	$Line2D.material.set_shader_parameter("color1",ball_color)
	$DropIcon.modulate = ball_color
	match rng.randi() % 10:
		0:
			next_ball.set_bomb()
		1:
			next_ball.set_rubber()
		2:
			next_ball.set_magnet()
		3:
			next_ball.set_bonus()
		4:
			next_ball.set_gem()

func _ready():
	set_next_ball()
	$KillBox/ProgressBar.modulate=Color(1,0,0,0)

func _input(event):
	if event is InputEventMouse:
		mouse_x_clamped = clamp(event.position.x,drop_left, drop_right)
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
	
	if len($KillBox.get_overlapping_areas())>0:
		if $DeathTimer.is_stopped():
			$DeathTimer.start()
		else:
			var time_left = 1-($DeathTimer.time_left/$DeathTimer.wait_time)
			if time_left > death_timer_grace:
				$KillBox/ProgressBar.value = time_left
				$KillBox/ProgressBar.modulate = Color(1,0,0,time_left)
	else:
		$DeathTimer.stop()
		$KillBox/ProgressBar.modulate=Color(1,0,0,0)
		$KillBox/ProgressBar.value = 0
	check_for_pop()
	
	if star_score >= star_req:
		num_stars += 1
		star_score -= star_req
		star_req = floor(star_req * star_scaling)
		$StarBar.max_value = star_req
		$StarBar.value = star_score
		var new_star = Star.instantiate()
		add_child(new_star)
		$StarPath/PathFollow2D.progress_ratio = rng.randf()
		new_star.position = $StarPath/PathFollow2D.position
	
			
func _physics_process(delta):
	for ball1 in all_balls:
		if ball1.magnet:
			for ball2 in all_balls:
				if ball1 != ball2:
					var force_dist = (ball1.position - ball2.position).length()
					var force_direction = (ball1.position - ball2.position)/force_dist
					ball2.apply_central_force((force_radius/force_dist) * force_direction * delta * magnet_force)
					ball1.apply_central_force(-(force_radius/force_dist) * force_direction * delta * magnet_force)

func check_for_pop():
	
	#check symbols
	var to_check = all_balls.duplicate()
	var to_pop = []
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
		var size = 0
		for ball in group:
			if ball.bonus:
				size += 2
			else:
				size += 1
		if size >= match_size:
			star_score += size
			$StarBar.max_value = star_req
			for i in group:
				to_pop.append(i)
				#all_balls.erase(i)
				#i.pop()
				
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
		var size = 0
		for ball in group:
			if ball.bonus:
				size += 2
			else:
				size += 1
		if size >= match_size:
			star_score += size
			$StarBar.max_value = star_req
			for i in group:
				to_pop.append(i)
				#all_balls.erase(i)
				#i.pop()
	for i in to_pop:
		var gem_neighbors = i.get_gem_neighbors()
		for j in gem_neighbors:
			if j not in to_pop:
				all_balls.erase(j)
				j.pop()
				star_score += 1
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


func _on_death_timer_timeout():
	game_over()
