extends Node3D

@onready var player: player = $player

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_Q):
		player.can_walk = false
	else:
		player.can_walk = true
