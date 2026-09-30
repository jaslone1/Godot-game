extends Control

# Changes the scene to your active game world
func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://src/worlds/world.tscn")

# Closes the game application
func _on_quit_pressed() -> void:
	get_tree().quit()
