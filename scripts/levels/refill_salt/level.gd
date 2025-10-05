extends Node3D

@onready var obstacles: Node = $obstacles
@onready var player: player = $player
@onready var area_3d: Area3D = $Area3D

var player_orig_min_look: float

func _ready() -> void:
	player.walk_speed = player.run_speed
	seed(randi_range(0,3)) # use onlt a few versions so it's easy to test for impossibility
	for i in obstacles.get_children():
		i.position.x = randf_range(-15,15) # set the x to a number between -15 and 15
		var z_range = sqrt(225 - i.position.x * i.position.x) # set z to a number so that it is within a circle depending on x
		i.position.z = randf_range(-z_range,z_range) + 50 # set z to a number from the negative half of the circle to the positive and add 50 to align it with the dropper
		i.rotation.y = randf_range(0,180) # rotate in any direction
	player_orig_min_look = player.min_look_degree
	player.min_look_degree = -90 # let the player look straight down

func _on_area_3d_body_entered(body: Node3D) -> void:
	# acceleration motion for player
	pass

func _on_area_3d_body_exited(body: Node3D) -> void:
	# acceleration motion for player
	pass

func _on_tree_exited() -> void:
	player.min_look_degree = player_orig_min_look # reset
