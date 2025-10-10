extends Node3D

@onready var player: player = $player
@onready var items: Node = $items
@onready var plants: Node = $plants
@onready var ray_cast_3d: RayCast3D = $player/head/Camera3D/RayCast3D
@onready var flies_2: CSGCylinder3D = $items/flies2

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("e"):
		var collider = ray_cast_3d.get_collider()
		if !player.get_hand_object() and collider in items.get_children():
			collider.use_collision = false
			items.remove_child(collider)
			collider.position = Vector3(0,0,0)
			player.add_hand_object(collider)
		elif collider and collider.get_parent() in plants.get_children():
			if player.get_hand_object().get_meta("item_type") == collider.get_parent().needs.back():
				collider.get_parent().remove_need()
				var obj = player.remove_hand_object()
				items.add_child(obj)
				obj.position = Vector3(.4 * obj.get_meta("item_type") - .6,.55,.25 * int(obj.name) + .5)
