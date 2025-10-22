extends Node3D

var player_in_scythe_area : bool = false
var scythe_picked_up : bool = false

@export var grass_count : int = 10000
@export var rand_seed : int = 2004
## The ratio of dashes between x and y axis of box for grass. 
## 0.5 means balanced, 1 is full x and 0 is full y 
@export var seperation_ratio : float = 0.5
@export var swing_radius : float = 0.7
@export var swing_cooldown : float = 0.5
@export var time_to_death : float = 3
# used to calculate fall off linearly from player position to center
@export var gaze_fall_off = 0
@export var recovery_time : float = 1
@export var win_percent : float = 0.9

# scene refrences 
@onready var player: player = $player
@onready var tall_grass: MultiMeshInstance3D = $multimeshes/tall_grass
@onready var top_left: Marker3D = $boundry/top_left
@onready var top_right: Marker3D = $boundry/top_right
@onready var bottom_left: Marker3D = $boundry/bottom_left
@onready var bottom_right: Marker3D = $boundry/bottom_right
@onready var scythe: Node3D = $Scythe
@onready var swing_cooldown_timer: Timer = $timers/swing_cooldown
@onready var scarecrow_container: Node3D = $Scarecrows
@onready var fade_screen: ColorRect = $fade_screen




# global variables
var grass_positions
var random
var base_grass_y
var swing_ready = true
var is_blade_cut = []
var total_cut = 0
var percent_cut
var scarecrows 
var player_near_scarecrow : 
	set(new_val) : 
		if player_near_scarecrow and !new_val : 
			in_recover = true
		player_near_scarecrow = new_val
var in_recover : bool = false
var active_scarecrow = -1 

var max_score = 100
var score

func _ready() -> void:
	# set scarecrows 
	scarecrows = scarecrow_container.get_children()
	scarecrows[0].activate()
	scarecrows[1].activate()
	scarecrows[2].activate()
	scarecrows[3].activate()
	scarecrows[4].activate()
	scarecrows[5].activate()
	# set spot
	base_grass_y = top_left.position.y
	
	# set timer
	swing_cooldown_timer.wait_time = swing_cooldown
	
	# create random object 
	random = RandomNumberGenerator.new()
	random.seed = rand_seed
	
	# set counts 
	tall_grass.multimesh.instance_count = 0
	tall_grass.multimesh.use_custom_data = true
	tall_grass.multimesh.instance_count = grass_count
	
	
	# set first multimesh positions 
	grass_positions = calc_grass_positions()
	print(grass_positions.size())
	print(grass_count)
	for current_blade in range(grass_count) : 
		var rot_y  = random.randi_range(0,360)
		var rot_amount = deg_to_rad(rot_y)
		var new_basis = Basis()
		new_basis = new_basis.rotated(Vector3.UP, rot_amount)
		
		
		tall_grass.multimesh.set_instance_custom_data(current_blade, Color(base_grass_y + 2,0,0,0))
		tall_grass.multimesh.set_instance_transform(current_blade, Transform3D(new_basis, grass_positions[current_blade]))
		is_blade_cut.append(false)


func _physics_process(delta: float) -> void:
	if player_near_scarecrow : 
		fade_player_screen(delta)
	if in_recover : 
		recover(delta)


func _input(event: InputEvent) -> void:
	# if e 
	if Input.is_action_just_pressed("e") and not scythe_picked_up : 
		if player_in_scythe_area : 
			scythe.position = Vector3(0.236,-0.4,0)
			scythe.rotate(Vector3(0,1,0), deg_to_rad(-90))
			scythe.rotate(Vector3(0,0,1), deg_to_rad(20.5))
			scythe.get_parent().remove_child(scythe)
			
			player.add_hand_object(scythe, 1)
			scythe_picked_up = true
	
	if Input.is_action_just_pressed("select") : 
		if swing_ready and scythe_picked_up:
			swing()

func recover (delta) : 
	if fade_screen.color.a <= 0 : 
		in_recover = false
	else : 
		fade_screen.color.a -= (1.0 / recovery_time) * delta

func fade_player_screen (delta) :
	# calculate amount to add to screen 
	# max amount 
	var max_per_sec = 1.0 / time_to_death
	# calculate fall off 
	var add_death = (max_per_sec * delta) 
	# get player dist 
	var dist = (player.position - scarecrows[active_scarecrow].position).length()
	
	# 2 is the cut off distance for full force 
	dist -= 2
	
	if dist < 0 : 
		dist = 0
	var fall_off_percent = float(dist / 8 )
	if gaze_fall_off != 0 : 
		add_death = add_death * (gaze_fall_off * fall_off_percent)
	fade_screen.color.a += add_death
	if fade_screen.color.a == 1.0 : 
		print("Player dead!")

# calculate grass positions give grass num variables and boundry markers 
# return array of vector 3 positions and array of basis
func calc_grass_positions () -> Array[Vector3]: 
	var positions : Array[Vector3] = [] # return positions
	var basis_array : Array[Basis] = []
	var y_level = top_left.position.y
	
	# get dimenions of bounding area 
	var width = abs(top_left.position.x - top_right.position.x)
	var height = abs(top_left.position.z - bottom_left.position.z)
	
	# figure out how many dashes on each axis
	var total_lines : int = sqrt(grass_count) * 2
	var x_lines = int(total_lines * seperation_ratio)
	var y_lines = int(total_lines - x_lines)
	var x_space = width / x_lines
	var y_space = height / y_lines
	
	for i in range(x_lines) : 
		for j in range(y_lines) : 
			# generate position
			var noise_x = random.randf_range(-0.5, 0.5)
			var noise_z = random.randf_range(-0.5, 0.5)
			
			var new_position = Vector3((i * x_space) + noise_x + min(top_left.position.x, top_right.position.x) , y_level, (j * y_space) + noise_z + bottom_left.position.z)
			
			# make sure its in bounds 
			new_position.x = clamp(new_position.x, min(top_left.position.x, top_right.position.x), max(top_left.position.x, top_right.position.x))
			new_position.z = clamp(new_position.z, min(top_left.position.z, bottom_left.position.z), max(top_left.position.z, bottom_left.position.z))
			
			
			positions.append(new_position)
	
	var xs = positions.map(func(p): return p.x)
	var min_x = xs.min()
	var max_x = xs.max()

	return positions


func point_in_swing (point : Vector3) -> bool : 
	# get position
	var center = Vector2(player.position.x, player.position.z)
	var point_2D = Vector2(point.x, point.z)
	
	var look_direction = -player.transform.basis.z.normalized()
	var forward_direction = Vector2(look_direction.x, look_direction.z).normalized()
	
	var vec_to_point = point_2D - center
	var dist = vec_to_point.length()
	if dist > swing_radius : 
		return false
	
	vec_to_point = vec_to_point.normalized()
	
	var dot = forward_direction.dot(vec_to_point)
	
	return dot > 0
	

func swing() : 
	for blade in range(grass_positions.size()) : 
		# check if it is in zone 
		var in_zone = point_in_swing(grass_positions[blade])
		
		if in_zone and !is_blade_cut[blade]: 
			is_blade_cut[blade] = true
			total_cut += 1
			tall_grass.multimesh.set_instance_custom_data(blade, Color(base_grass_y + 0.8, 0.0,0.0,0.0))
	
	swing_ready = false
	swing_cooldown_timer.start()
	
	percent_cut  = float(total_cut) / float(grass_count)
	percent_cut *= 100
	print(total_cut)
	print(grass_count)
	print("Percentage of grass cut  : " , percent_cut)

func eval_score() : 
	return max_score * percent_cut

# signal hookups 
func _on_scythe_pickup_body_entered(body: Node3D) -> void:
	if body.has_method("player") : 
		player_in_scythe_area = true


func _on_scythe_pickup_body_exited(body: Node3D) -> void:
	if body.has_method("player") : 
		player_in_scythe_area = false


func _on_swing_cooldown_timeout() -> void:
	swing_ready = true


# scarecrow signals 
#region
func _on_scarecrow_player_enter() -> void:
	player_near_scarecrow = true
	active_scarecrow = 0


func _on_scarecrow_player_left() -> void:
	player_near_scarecrow = false
	active_scarecrow = -1


func _on_scarecrow_2_player_enter() -> void:
	player_near_scarecrow = true
	active_scarecrow = 1


func _on_scarecrow_2_player_left() -> void:
	player_near_scarecrow = false
	active_scarecrow = -1


func _on_scarecrow_3_player_enter() -> void:
	player_near_scarecrow = true
	active_scarecrow = 2


func _on_scarecrow_3_player_left() -> void:
	player_near_scarecrow = false
	active_scarecrow = -1


func _on_scarecrow_4_player_enter() -> void:
	player_near_scarecrow = true
	active_scarecrow = 3


func _on_scarecrow_4_player_left() -> void:
	player_near_scarecrow = false
	active_scarecrow = -1


func _on_scarecrow_5_player_enter() -> void:
	player_near_scarecrow = true
	active_scarecrow = 4


func _on_scarecrow_5_player_left() -> void:
	player_near_scarecrow = false
	active_scarecrow = -1


func _on_scarecrow_6_player_enter() -> void:
	player_near_scarecrow = true
	active_scarecrow = 5


func _on_scarecrow_6_player_left() -> void:
	player_near_scarecrow = false
	active_scarecrow = -1

#endregion
