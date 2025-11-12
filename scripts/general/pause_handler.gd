extends Node

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_dt: float) -> void:
	if get_tree().get_nodes_in_group("world") == []:
		return
	var world: Node3D = get_tree().get_nodes_in_group("world")[0]
	if Input.is_action_just_pressed("pause"):
		if world.process_mode == Node.PROCESS_MODE_DISABLED:
			world.process_mode = Node.PROCESS_MODE_INHERIT
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			world.process_mode = Node.PROCESS_MODE_DISABLED
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
