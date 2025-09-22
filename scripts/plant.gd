extends Node3D

@onready var csg_box_3d: CSGBox3D = $CSGBox3D

@export var time_to_activate: float = 0 # the plant will not start dying for this amount of time
var activate_timer: float = time_to_activate
@export var time_between_dying_rolls: float = 5 # while active, time between rolls to start dying
var dying_rolls_timer: float = time_between_dying_rolls
@export var start_dying_chance: float = .1 # chance to start dying every time_between_chance_rolls
@export var time_to_die: float = 30 # amount of time until the plant dies after being activated
var death_timer: float = time_to_die

func inactive(delta: float) -> void:
	activate_timer -= delta

func exit_inactive() -> void:
	pass

func enter_active() -> void:
	pass

func active(delta: float) -> void:
	dying_rolls_timer -= delta

func exit_active() -> void:
	dying_rolls_timer = time_between_dying_rolls

func enter_dying() -> void:
	pass

func dying(delta: float) -> void:
	death_timer -= delta
	if death_timer > time_to_die / 2:
		csg_box_3d.material.albedo_color = Color(2 * (1 - death_timer / time_to_die),1,0)
	else:
		csg_box_3d.material.albedo_color = Color(1,2 * death_timer / (time_to_die),0)

func exit_dying() -> void:
	death_timer = time_to_die
