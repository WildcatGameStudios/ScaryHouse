extends Node3D

@onready var obstacles: Node = $obstacles

func _ready() -> void:
	for i in obstacles.get_children():
		i.position.x = randf_range(-20,20)
		i.position.z = randf_range(-sqrt(400 - i.position.x * i.position.x),sqrt(400 - i.position.x * i.position.x)) + 50
		i.rotation.y = randf_range(0,180)
