extends Node3D

@onready var csg_box_3d: CSGBox3D = $CSGBox3D

@export var TIME_TO_DIE: float = 30
var death_timer: float = 30

func _process(delta: float) -> void:
	death_timer -= delta
	if death_timer <= 0:
		pass
	if death_timer > TIME_TO_DIE / 2:
		csg_box_3d.material.albedo_color = Color(2 * (1 - death_timer / TIME_TO_DIE),1,0)
	else:
		csg_box_3d.material.albedo_color = Color(1,2 * death_timer / (TIME_TO_DIE),0)
