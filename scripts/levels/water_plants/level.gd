extends Node3D

@onready var player: player = $player
@onready var items: Node = $items
@onready var plants: Node = $plants
@onready var ray_cast_3d: RayCast3D = $player/head/Camera3D/RayCast3D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("e"):
		var collider = ray_cast_3d.get_collider()
		if collider in items.get_children():
			collider.use_collision = false
			items.remove_child(collider)
			player.add_hand_object(collider)
			collider.position = Vector3(0,.2,0)
		elif collider.get_parent() in plants.get_children():
			print(player.get_hand_object())
