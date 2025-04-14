extends Node2D

var Ball = preload("res://ball.tscn")

var all_balls = []
var rng = RandomNumberGenerator.new()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var new_ball = Ball.instantiate()
			new_ball.position = event.position
			add_child(new_ball)
			all_balls.append(new_ball)
			var new_scale = rng.randf_range(0.75, 1.25)
			new_ball.change_size(new_scale)

func _process(delta):
	var settled = true
	for ball in all_balls:
		if ball.moving:
			settled = false
	if settled:
		check_for_pop()
			
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
		if len(group) >= 3:
			for i in group:
				all_balls.erase(i)
				i.queue_free()
				
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
		if len(group) >= 3:
			for i in group:
				all_balls.erase(i)
				i.queue_free()
	
	
