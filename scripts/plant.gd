extends Node3D

@onready var csg_box_3d: CSGBox3D = $CSGBox3D

@export var time_to_activate: float = 0 # the plant will not start dying for this amount of time
@export var time_to_die: float = 30 # amount of time until the plant dies after being activated
var death_timer: float = 30

func _process(delta: float) -> void:
	if time_to_activate > 0:
		time_to_activate -= delta
	else:
		death_timer -= delta
		if death_timer <= 0:
			pass
		if death_timer > time_to_die / 2:
			csg_box_3d.material.albedo_color = Color(2 * (1 - death_timer / time_to_die),1,0)
		else:
			csg_box_3d.material.albedo_color = Color(1,2 * death_timer / (time_to_die),0)
