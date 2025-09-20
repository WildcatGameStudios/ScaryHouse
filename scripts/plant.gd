extends Node3D

@onready var csg_box_3d: CSGBox3D = $CSGBox3D

@export var time_to_activate: float = 0 # the plant will not start dying for this amount of time
@export var time_between_dying_rolls: float = 5 # while active, time between rolls to start dying
var dying_rolls_timer: float = time_between_dying_rolls
@export var start_dying_chance: float = .5 # chance to start dying every time_between_chance_rolls
@export var time_to_die: float = 30 # amount of time until the plant dies after being activated
var death_timer: float = time_to_die

func _process(delta: float) -> void:
	if time_to_activate > 0: # if not active
		time_to_activate -= delta
	elif dying_rolls_timer > 0:
		dying_rolls_timer -= delta
	elif death_timer == time_to_die:
		if randf() < start_dying_chance:
			
	else:
		death_timer -= delta
		if death_timer <= 0:
			pass
		if death_timer > time_to_die / 2:
			csg_box_3d.material.albedo_color = Color(2 * (1 - death_timer / time_to_die),1,0)
		else:
			csg_box_3d.material.albedo_color = Color(1,2 * death_timer / (time_to_die),0)
