extends Node2D


func _on_back_button_pressed():
	get_tree().change_scene_to_file("main_menu.tscn")


func _on_forward_button_pressed():
	
	get_tree().change_scene_to_file("res://page2.tscn")
