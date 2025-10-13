extends Node3D

var player_in_scythe_area : bool = false
var scythe_picked_up : bool = false

@export var grass_count : int = 10000
@export var rand_seed : int = 2004
## The ratio of dashes between x and y axis of box for grass. 
## 05 means balanced, 1 is full x and 0 is full y 
@export var seperation_ratio : float = 0.5
@export var swing_radius : float = 0.7




# scene refrences 
@onready var player: player = $player
@onready var tall_grass: MultiMeshInstance3D = $multimeshes/tall_grass
@onready var top_left: Marker3D = $boundry/top_left
@onready var top_right: Marker3D = $boundry/top_right
@onready var bottom_left: Marker3D = $boundry/bottom_left
@onready var bottom_right: Marker3D = $boundry/bottom_right
@onready var scythe: Node3D = $Scythe

# global variables
var grass_positions
var grass_basis = []
var random




func _ready() -> void:
	
	# create random object 
	random = RandomNumberGenerator.new()
	random.seed = rand_seed
	
	# set counts 
	tall_grass.multimesh.instance_count = 0
	tall_grass.multimesh.use_custom_data = true
	tall_grass.multimesh.instance_count = grass_count
	
	
	
	# set first multimesh positions 
	grass_positions = calc_grass_positions()
	for current_blade in range(grass_count) : 
		var rot_y  = random.randi_range(0,360)
		var rot_amount = deg_to_rad(rot_y)
		var new_basis = Basis()
		new_basis = new_basis.rotated(Vector3.UP, rot_amount)
		grass_basis.append(new_basis)
		
		tall_grass.multimesh.set_instance_custom_data(current_blade, Color(random.randf(),0,0,0))
		tall_grass.multimesh.set_instance_transform(current_blade, Transform3D(new_basis, grass_positions[current_blade]))
		

func _input(event: InputEvent) -> void:
	# if e 
	if Input.is_action_just_pressed("e") and not scythe_picked_up : 
		if player_in_scythe_area : 
			scythe.position = Vector3(0.236,-0.4,0)
			scythe.rotate(Vector3(0,1,0), deg_to_rad(-90))
			scythe.rotate(Vector3(0,0,1), deg_to_rad(20.5))
			scythe.get_parent().remove_child(scythe)
			
			player.add_hand_object(scythe, 1)
	
	if Input.is_action_just_pressed("select") : 
		swing()


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

# to be called whenever update is neccesary (NOT EVERYFRAME)
func update_grass_positions () : 
	tall_grass.multimesh.instance_count =  grass_positions.size()

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
		
		if in_zone : 
			grass_positions.remove_at(blade)
			blade -= 1
		
	update_grass_positions()


# signal hookups 
func _on_scythe_pickup_body_entered(body: Node3D) -> void:
	if body.has_method("player") : 
		player_in_scythe_area = true


func _on_scythe_pickup_body_exited(body: Node3D) -> void:
	if body.has_method("player") : 
		player_in_scythe_area = false
