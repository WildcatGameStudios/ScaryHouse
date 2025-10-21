extends Node3D

@onready var plant: CSGBox3D = $Plant
@onready var needs_list: CSGBox3D = $NeedsList
@export var time_to_activate: float = 0 # the plant will not start dying for this amount of time
var activate_timer: float = time_to_activate
@export var time_between_dying_rolls: float = 5 # while active, time between rolls to start dying
var dying_rolls_timer: float = time_between_dying_rolls
@export var start_dying_chance: float = .1 # chance to start dying every time_between_chance_rolls
@export var time_to_die: float = 30 # amount of time until the plant dies after being activated
var death_timer: float = time_to_die

@export var stop_adding_needs_chance: float = .6 # chance to stop adding needs after every time a need is added
@export var max_needs: int = 4 # max number of needs
var needs: Array[int] = []

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
	position.y = -.25 # move up so player can see
	needs.append(randi_range(0,3)) # at least 1 need
	while randf() < stop_adding_needs_chance and needs.size() < max_needs: # generate needs
		needs.append(randi_range(0,3))
	needs_list.size.y = needs.size() * .2 + .1 # needs list box to fit needs list
	needs_list.position.y = needs_list.size.y / 2 + 1 # bottom of box will stay constant
	
	for i in range(needs.size()): # make box for each need
		var new_need = CSGBox3D.new()
		new_need.size = Vector3(.4,.2,.1)
		new_need.position = Vector3(1,.2 * i + 1.15,0)
		new_need.material = StandardMaterial3D.new()
		match needs[i]:
			0:
				new_need.material.albedo_color = Color(0,0,1) # blue water
			1:
				new_need.material.albedo_color = Color(0,0,0) # black flies
			2:
				new_need.material.albedo_color = Color(.5,0,.5) # purple light
			3:
				new_need.material.albedo_color = Color(10.0 / 17,5.0 / 17,0) # brown fertilizer
		add_child(new_need)

func dying(delta: float) -> void:
	death_timer -= delta
	if death_timer > time_to_die / 2: # if in first half of dying, increase red
		plant.material.albedo_color = Color(2 * (1 - death_timer / time_to_die),1,0)
	else: # if in second half, decease green
		plant.material.albedo_color = Color(1,2 * death_timer / (time_to_die),0)

func exit_dying() -> void:
	death_timer = time_to_die
	position.y = -3 # move down

func remove_need() -> void:
	get_child(needs.size() + 2).queue_free()
	needs.pop_back()
	needs_list.size.y -= .2
	needs_list.position.y -= .1
