extends Node3D

@onready var plant: CSGBox3D = $Plant
var timeToChange: float = 1.5 # time it takes to rise or fall in seconds
var acceleration: float = 3 # acceleration to rise or fall
var startingVelocity: float = 3 / timeToChange + acceleration * timeToChange / 2 # starting velocity to rise
var velocity: float
@onready var needs_list: CSGBox3D = $needsList
@onready var health_bar: CSGBox3D = $healthBar
@export var time_to_activate: float = 0 # the plant will not start dying for this amount of time
var activate_timer: float = time_to_activate
@export var time_between_dying_rolls: float = 5 # while active, time between rolls to start dying
var dying_rolls_timer: float = time_between_dying_rolls
@export var start_dying_chance: float = .1 # chance to start dying every time_between_chance_rolls
@export var time_to_die: float = 60 # amount of time until the plant dies after being activated
var death_timer: float = time_to_die
@onready var items: Node = $items

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
	if position.y > -3.25:
		position.y += velocity * delta
		velocity -= acceleration * delta

func exit_active() -> void:
	position.y = -3.25
	velocity = startingVelocity
	dying_rolls_timer = time_between_dying_rolls

func enter_dying() -> void:
	start_dying_chance = .1
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
	if velocity > 0 and position.y < -.25:
		position.y += velocity * delta
		velocity -= acceleration * delta
	else:
		position.y = -.25
	
	death_timer -= delta
	if death_timer > time_to_die / 2: # if in first half of dying, increase red
		health_bar.material.albedo_color = Color(2 * (1 - death_timer / time_to_die),1,0)
	else: # if in second half, decease green
		health_bar.material.albedo_color = Color(1,2 * death_timer / time_to_die,0)
	health_bar.size.x = 3 * death_timer / time_to_die
	
	if death_timer <= 0:
		get_tree().reload_current_scene()
	
	if items.get_children().size() > 0 and items.get_child(0).get_child(1).time_left <= 0:
		var item = items.get_child(0)
		items.remove_child(item)
		get_parent().get_parent().items.add_child(item)
		match item.get_meta("item_type"): # position to return to
			0: # water
				item.position = Vector3(-.9,.8,int(item.name) * .5)
			1: # flies
				item.position = Vector3(-.3,.65,int(item.name) * .5)
			2: # light
				item.position = Vector3(.3,.79,int(item.name) * .5)
				item.get_child(2).visible = false
			3: # fertilizer
				item.position = Vector3(.9,.7,int(item.name) * .5)
		item.use_collision = true
		item.rotation.x = 0

func exit_dying() -> void:
	death_timer = time_to_die
	velocity = 0

func remove_need() -> void:
	get_child(needs.size() + 5).queue_free()
	needs.pop_back()
	needs_list.size.y -= .2
	needs_list.position.y -= .1
