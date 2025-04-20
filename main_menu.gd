extends Node2D

var Ball = preload("res://ball.tscn")
var rng = RandomNumberGenerator.new()
var all_balls: Array[Ball] =[]

func _on_timer_timeout():
	print("boop")
	var new_ball:Ball = Ball.instantiate()
	add_child(new_ball)
	$Path2D/PathFollow2D.progress_ratio = rng.randf()
	new_ball.position = $Path2D/PathFollow2D.position
	new_ball.linear_velocity.x = rng.randfn(0.0,40.0)
	all_balls.append(new_ball)

func _process(delta):
	for ball in all_balls:
		if ball.position.y > 1000:
			ball.pop()
			all_balls.erase(ball)


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://main_scene.tscn")


func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://credits.tscn") # Replace with function body.


func _on_help_button_pressed():
	get_tree().change_scene_to_file("res://page_1.tscn") # Replace with function body.
