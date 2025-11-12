extends Control

func load_level(path: String):
	var level = load(path)
	get_tree().change_scene_to_packed(level)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_clean_gutters_pressed() -> void:
	load_level("res://scenes/levels/clean_gutters/level.tscn")
func _on_cut_grass_pressed() -> void:
	load_level("res://scenes/levels/cut_grass/level.tscn")
func _on_feed_cats_pressed() -> void:
	load_level("res://scenes/levels/feed_cats/level.tscn")
func _on_laundry_defence_pressed() -> void:
	load_level("res://scenes/levels/laundry_defence/level.tscn")
func _on_mix_the_drinks_pressed() -> void:
	load_level("res://scenes/levels/mix_the_drinks/level.tscn")
func _on_power_outtage_pressed() -> void:
	load_level("res://scenes/levels/power_outtage/level.tscn")
func _on_put_groceries_away_pressed() -> void:
	load_level("res://scenes/levels/put_groceries_away/level.tscn")
func _on_raccoon_it_pressed() -> void:
	load_level("res://scenes/levels/raccoon_it/level.tscn")
func _on_refill_salt_pressed() -> void:
	load_level("res://scenes/levels/refill_salt/level.tscn")
func _on_shine_shoes_pressed() -> void:
	load_level("res://scenes/levels/shine_shoes/level.tscn")
func _on_take_out_trash_pressed() -> void:
	load_level("res://scenes/levels/take_out_trash/level.tscn")
func _on_wash_the_dishes_pressed() -> void:
	load_level("res://scenes/levels/wash_the_dishes/level.tscn")
func _on_wash_windows_pressed() -> void:
	load_level("res://scenes/levels/wash_windows/level.tscn")
func _on_water_plants_pressed() -> void:
	load_level("res://scenes/levels/water_plants/level.tscn")
