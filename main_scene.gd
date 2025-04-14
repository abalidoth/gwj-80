extends Node2D

var Ball = preload("res://ball.tscn")

var all_balls:Array[Ball] = []
var rng = RandomNumberGenerator.new()

var next_ball:Ball

var size_least = 0.75
var size_most = 1.25

var drop_left = 330
var drop_right = 790

var match_size = 5

func set_next_ball():
	next_ball = Ball.instantiate()
	add_child(next_ball)
	next_ball.position = $NextBallMarker.position
	next_ball.freeze = true
	var new_scale = rng.randf_range(size_least, size_most)
	next_ball.change_size(new_scale)

func _ready():
	set_next_ball()

func _input(event):
	if event is InputEventMouseButton and $ClickTimer.is_stopped():
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var new_ball = next_ball
			new_ball.position = Vector2(clamp(event.position.x,drop_left, drop_right),50)
			all_balls.append(new_ball)
			new_ball.freeze = false
			set_next_ball()
			$ClickTimer.start()
	elif event is InputEventMouseMotion:
		$DropIcon.position = Vector2(clamp(event.position.x,drop_left,drop_right),25)

func _process(delta):
	var settled = true
	for ball in all_balls:
		if ball.moving:
			settled = false
	if settled:
		check_for_pop()
			
			

func check_for_pop():
	if len($KillBox.get_overlapping_areas())>0 and $ClickTimer.is_stopped():
		game_over()
	
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
