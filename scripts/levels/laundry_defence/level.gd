extends Node3D

@onready var player: player = $player
@onready var drone: RigidBody3D = $Drone
@onready var bird_spawn_timer: Timer = $bird_spawn_timer
@onready var bird_eye_view: Camera3D = $bird_eye_view

var bird_scene = preload("res://scenes/levels/laundry_defence/evil_bird.tscn")

@export_group("Spawn Variables")
## Spawn Rate is how many birds spawn per minute.
@export_range(1,20) var spawn_rate: int = 20
## Number of birds that spawn in this minigame.
@export var num_spawn: int = 30

@export_group("Bird Variables")
@export_range(1,10) var bird_speed: float = 10.0
@export var time_to_bird_death: float = 2.0
@export var despawn_duration: float = 10.0
@export var grab_time: float = 5.0

var prev_can_walk: bool
var prev_can_run: bool

# this array holds the following data:
# - up to four arrays containing the line ID and up to 15 cloth IDs
var available_lines = [1,2,3,4]
var available_clothes = [[],[],[],[]]
var stolen_clothes: Array[Node3D] = []

func _ready() -> void:
	# initialize to current player state
	prev_can_walk = player.can_walk
	prev_can_run = player.can_run
	
	bird_spawn_timer.start(60 / spawn_rate)
	
	for i in range(0,4):
		available_clothes[i].append(i)
		for j in range(0,15):
			available_clothes[i].append(j+1)

func _process(dt: float) -> void:
	if Input.is_action_just_pressed("q") and drone.active:
		exit_drone()
	elif Input.is_action_just_pressed("e") and not drone.active:
		enter_drone()

func exit_drone() -> void:
	player.can_walk = prev_can_walk
	player.can_run = prev_can_run
	drone.active = false
	
	bird_eye_view.current = false
	player.toggle_camera(true)

func enter_drone() -> void:
	prev_can_walk = player.can_walk
	prev_can_run = player.can_run
	player.can_walk = false
	player.can_run = false
	
	player.toggle_camera(false)
	bird_eye_view.current = true
	
	drone.active = true

func spawn_bird() -> void:
	var new_bird = bird_scene.instantiate()
	drone.birds.append(new_bird)
	add_child(new_bird)
	
	# find target laundry
	var line_id = randi() % available_lines.size()
	var clothes_id = randi() % (available_clothes[line_id].size() - 1) + 1
	
	var node_id = "clothes/line_%d/Cloth%d" % [available_lines[line_id], available_clothes[line_id][clothes_id]]
	available_clothes[line_id].remove_at(clothes_id)
	if available_clothes[line_id].size() == 0:
		available_lines.erase(line_id)
	
	var cloth = get_node(node_id)
	
	new_bird.target_laundry = get_node(node_id)
	new_bird.speed = bird_speed
	new_bird.reset_time = time_to_bird_death
	new_bird.time_till_death = time_to_bird_death
	new_bird.despawn_duration = despawn_duration
	new_bird.grab_time = grab_time
	
	new_bird.died.connect(drone._on_bird_die.bind(new_bird))
	new_bird.stolen.connect(func _anon(c): _on_stolen(new_bird, c))
	
	new_bird.position = $bird_spawner.position + get_spawn_pos_shift()

# this function will add randomness to the position that a bird will spawn. currently, it is
# disabled by only returning the zero vector (thus not shifting the bird's position at all)
func get_spawn_pos_shift() -> Vector3:
	return Vector3.ZERO

func _on_bird_spawn_timer_timeout() -> void:
	bird_spawn_timer.start(60 / spawn_rate)
	spawn_bird()

func _on_stolen(b: EvilBird, cloth: Node3D) -> void:
	stolen_clothes.append(cloth)
	drone.birds_to_kill.append(b)
	print("handle")
