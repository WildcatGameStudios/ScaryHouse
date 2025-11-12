extends Control

func load_level(path: String):
	var level = load(path)
	get_tree().change_scene_to_packed(level)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_clean_gutters_pressed() -> void:
	load_level("res://scenes/levels/clean_gutters/level.tscn")
