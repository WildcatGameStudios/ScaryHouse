extends CharacterBody3D

class_name player

# For quick and easy control 
@export_category("Player set up")
@export_group("Movement Toggles")
@export var can_walk: bool = true
@export var can_run: bool = true
@export var can_jump: bool = true
@export var can_crouch: bool = true
@export var can_dash: bool = true
@export var can_double_jump: bool = true
	# set(v): can_double_jump = v; psm.toggle_state("Walk", v);

@export_group("Player Stats")
@export var max_health: int = 100

@export_group("Camera Parameters")
@export var horizontal_look_speed: float = 0.00003
@export var verticle_look_speed: float = 0.00002
@export var joystick_h_look_speed: float = 0.06
@export var joystick_v_look_speed: float = 0.06
@export var min_look_degree: float = -40
@export var max_look_degree: float = 45
@export var enable_bobbing: bool = true
@export var bob_time: float = PI / 8.0

@export_category("Movement")

@export_group("Horizontal Movement Variables")
@export var walk_speed: float = 3
@export var run_speed: float = 20
@export var crouch_speed: int = 2

@export_group("Jump Variables")
@export var max_jump_height: int = 2
@export var time_to_peak: float = 0.3
@export var fall_speed_boost: float = 0.75

@export_group("Double Jump Variables")
@export var double_jump_height: int = 4
@export var time_to_dj_peak: float = 0.4

@export_group("Coyote Time")
@export var listen_time: float = 0.2
@export var watch_time: float = 0.2


@export_group("Dash Variables")
@export var dash_cooldown: float = 0.1
@export var dash_duration: float = 0.4
@export var dash_distance: float = 5

@export_category("Ice Physics")
@export var is_ice_skating: bool = false # Toggle this for ice level
@export var ice_friction: float = 0.05   # How slippery the ice is
@export var ice_acceleration: float = 1.0 # How quickly you speed up on ice

# scene refrences 
@onready var head: Node3D = $head
@onready var psm: Node = $PSM
@onready var right_hand: Marker3D = $head/right_hand
@onready var left_hand: Marker3D = $head/left_hand_objecteft_hand
@onready var camera_3d: Camera3D = $head/Camera3D


# timers 
@onready var dash_timer: Timer = $timers/dash_timer
@onready var dash_cooldown_timer: Timer = $timers/dash_cooldown_timer
@onready var coyote_timer: Timer = $timers/coyote_timer

# jump variables 
var gravity: float 
var jump_strength: float
var temp_grav_power: float
var double_jump_ready: bool = false
var look_direction: Vector2

# coyote variables 
var coyote_valid: bool = false
var coyote_input: String = "void"

# walk variables
@onready var head_base_y: float = head.position.y
var bob_speed_mod = 1.0
var bob_magnitude: float = 10.0

# stats 
var current_health: int:
	set(new_value):
		current_health = new_value 
		if current_health <= 0:
			die()

# dash variables
var in_dash: bool = false
var dash_ready: bool = false
var dash_per_second: float
var temp_dash: Vector3 # variable for keeping track of dash so we can take it way on exit of dash 

# combat variables 
var is_hit: bool = false
var is_dead: bool = false

# reset variables 
var camera_init_pos : Vector3
var camera_inti_rot : Vector3

func _ready() -> void: 
	# set jump variables
	gravity = (2 * max_jump_height) / (time_to_peak * time_to_peak) 
	jump_strength = time_to_peak * gravity
	
	#set dash variables 
	dash_per_second  = dash_distance / dash_duration
	
	#set stats
	current_health = max_health
	
	# set enabled / disabled states
	psm.toggle_state("Walk", can_walk)
	psm.toggle_state("Run", can_run)
	psm.toggle_state("Jump", can_jump)
	psm.toggle_state("Crouch", can_crouch)
	psm.toggle_state("Dash", can_dash)
	
	# set timers
	dash_timer.wait_time = dash_duration
	dash_cooldown_timer.wait_time = dash_cooldown
	
	# set health
	current_health = max_health
	look_direction = Vector2(0.0, rotation.y)
	
	# set resets 
	camera_init_pos = camera_3d.position
	camera_inti_rot = camera_3d.rotation
	

# getter / setter functions 
#region
# get hand positions as vec3, left hand = index 0 right hand = index 1
func get_hand_positions () -> Array[Vector3] :
	var hands : Array[Vector3] = [right_hand.global_position, left_hand.global_position]
	return hands

func reset_camera () -> void : 
	camera_3d.position = camera_init_pos
	camera_3d.rotation = camera_inti_rot

func toggle_camera (toggle : bool) -> void : 
	camera_3d.current = toggle

# Add object to hand / remove object 
# Parameters
# object = object to be added / removed, hand 0 means left hand, 1 means right hand
func add_hand_object(object : Node3D, hand : int = 1, obj_scale : Vector3 = Vector3(1.0,1.0,1.0)) :
	# add object as child of hand 
	var obj
	if hand == 0 : # left hand
		left_hand.add_child(object) 
		obj = left_hand.get_child(0)
		
	elif hand == 1 : # right hand
		right_hand.add_child(object) 
		obj = right_hand.get_child(0)
	obj.scale = obj_scale # set scale
	

func remove_hand_object(hand : int = 1) -> Node3D :
	var obj : Node3D 
	if hand == 1 : 
		obj = right_hand.get_child(0)
		right_hand.remove_child(obj)
		
	elif hand == 0: 
		obj = left_hand.get_child(0)
		left_hand.remove_child(obj)
		
	# return what was in the hand 
	return obj

func get_hand_object(hand : int = 1) : 
	if hand == 0 : 
		return left_hand.get_child(0)
	elif hand == 1 : 
		return right_hand.get_child(0)
	
#endregion


# Movement functions 
#region

# overall move function, must be called for any movement to take place
func move(delta): 
	
	# check if not on ground, if so apply gravity
	if !is_on_floor(): 
		apply_gravity(delta)
	
	move_and_slide()
	

# apply gravity 
func apply_gravity(delta) -> void: 
	velocity.y -= (gravity + temp_grav_power) * delta

func bob(delta: float) -> void:
	if enable_bobbing:
		# only reset bobbing if we are moving
		var horiz_vel = velocity
		horiz_vel.y = 0
		if bob_time > PI / (8.0 * bob_speed_mod) and horiz_vel.length_squared() > 0.0:
			bob_time = 0.0
	
	# whether or not we should bob, we should finish a previously-started bob animation
	var camera_y_mod = (abs(cos(min(PI / 8.0, bob_time) * 8.0 * bob_speed_mod)) - 1.0) / bob_magnitude
	head.position.y = head_base_y + camera_y_mod
	bob_time += delta

func unbob(delta: float) -> void:
	head.position.y = head_base_y
	bob_time = PI / 8.0

# function to handle the walk logic 
func walk(delta) -> void:
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_direction: Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	if is_ice_skating:
		# Ice physics: accelerate/decelerate slowly
		if move_direction:
			var target_velocity = move_direction * walk_speed
			# Use ice_acceleration to slowly reach target speed
			var acceleration_step = walk_speed * ice_acceleration * delta
			velocity.x = move_toward(velocity.x, target_velocity.x, acceleration_step)
			velocity.z = move_toward(velocity.z, target_velocity.z, acceleration_step)
		else:
			# Use ice_friction to slowly slide to a stop
			var deceleration_step = walk_speed * ice_friction * delta
			velocity.x = move_toward(velocity.x, 0, deceleration_step)
			velocity.z = move_toward(velocity.z, 0, deceleration_step)
	else:
		# Normal physics: snappy movement
		if move_direction:
			velocity.x = move_direction.x * walk_speed
			velocity.z = move_direction.z * walk_speed
		else:
			velocity.x = move_toward(velocity.x, 0, walk_speed)
			velocity.z = move_toward(velocity.z, 0, walk_speed)


func stop_walking(delta) -> void:
	if !is_ice_skating:
		# Instant stop on normal ground
		velocity.x = 0
		velocity.z = 0
	# On ice, do nothing to allow sliding to a stop

# function for player run 
func run(delta):
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_direction: Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	if is_ice_skating:
		# Ice physics, accelerate/decelerate slowly
		if move_direction:
			var target_velocity = move_direction * run_speed
			var acceleration_step = run_speed * ice_acceleration * delta
			velocity.x = move_toward(velocity.x, target_velocity.x, acceleration_step)
			velocity.z = move_toward(velocity.z, target_velocity.z, acceleration_step)
		else:
			var deceleration_step = run_speed * ice_friction * delta
			velocity.x = move_toward(velocity.x, 0, deceleration_step)
			velocity.z = move_toward(velocity.z, 0, deceleration_step)
	else:
		# Normal physics
		if move_direction:
			velocity.x = move_direction.x * run_speed
			velocity.z = move_direction.z * run_speed
		else:
			velocity.x = move_toward(velocity.x, 0, run_speed)
			velocity.z = move_toward(velocity.z, 0, run_speed)

	bob_speed_mod = 1.5
	bob(delta)

# function for crouch walking
func crouch_walk(delta) -> void: 
	# first get walk direction 
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# multiply the direction we got by the basis ( normal axis of player ) 
	# to get the direction the player should move  
	var move_direction: Vector3 = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	# if move direction is not 0 
	if move_direction: 
		velocity.x = move_direction.x * crouch_speed
		velocity.z = move_direction.z * crouch_speed
		
	else: 
		velocity.x = move_toward(velocity.x, 0, crouch_speed)
		velocity.z = move_toward(velocity.z, 0, crouch_speed)

# function for dashing, should only be caled once per dash
func dash():
	in_dash = true
	print("Dash called")
	# want to get the direction for the dash 
	# first get walk direction 
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# multiply the direction we got by the basis ( normal axis of player )
	# to get the direction the player should move
	var move_direction: Vector3 
	
	if input_direction: 
		move_direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	else:
		# move forward 
		move_direction = Vector3(0,0,-1)
	
	velocity += move_direction * dash_per_second
	temp_dash = move_direction * dash_per_second
	
	dash_timer.start()

# function to execute on dash exit 
func reset_dash():
	#if velocity:
	velocity -= temp_dash
	dash_ready = false
	dash_cooldown_timer.start()

# function for player jump, should only be called once per jump
func jump():
	# add jump strength
	velocity.y = jump_strength
	unbob(0.0)

# function for double jumping
func double_jump():
	# calculate the needed jump power to reach double jump height based on current state 
	var double_jump_strength: float = ((double_jump_height + (0.5 * gravity * (time_to_dj_peak * time_to_dj_peak))) / time_to_dj_peak) - velocity.y
	velocity.y += double_jump_strength # add strength
	double_jump_ready = false # ensure you can only double jump once

# function to handle falling logic 
func fall() -> void:
	temp_grav_power = gravity * fall_speed_boost

# to reset temp variables that are used to mainpulate falling / jumping
func reset_jump() -> void:
	temp_grav_power = 0
	if can_double_jump:
		double_jump_ready = true


func hit() -> void:
	pass

# function for handling camera rotation
func handle_rotation():
	var current_mouse_direction: Vector2 = Input.get_last_mouse_velocity()
	var joystick_rotation: Vector2 = Input.get_vector("joystick_look_left", "joystick_look_right", "joystick_look_up", "joystick_look_down")
	if current_mouse_direction:
		# to move up and down we rotate along x-axis 
		look_direction.x -= current_mouse_direction.y * verticle_look_speed
		#restric user camera angles for up/ down 
		look_direction.x = clamp(look_direction.x, deg_to_rad(min_look_degree), deg_to_rad(max_look_degree))
		# get rotation for side by side which is rotating against y axis 
		look_direction.y -= current_mouse_direction.x * horizontal_look_speed
	elif joystick_rotation:
		# to move up and down we rotate along x-axis 
		look_direction.x -= joystick_rotation.y * joystick_v_look_speed
		#restric user camera angles for up/ down 
		look_direction.x = clamp(look_direction.x, deg_to_rad(min_look_degree), deg_to_rad(max_look_degree))
		# get rotation for side by side which is rotating against y axis 
		look_direction.y -= joystick_rotation.x * joystick_h_look_speed
	
	#reset transfrom 
	transform.basis = Basis()
	rotate_y(look_direction.y)
	head.transform.basis = Basis()
	head.rotate_x(look_direction.x)


# to handle the current coyote time variables / state 
# set the action ( coyote time only holds one action at a time ) 
# set valid to true, and start timer
# if to much time has passed ( timeout ) then coyote input no longer valid 
func set_coyote_state(grace_time: float, action: String = "void") -> void:
	coyote_input = action
	coyote_timer.wait_time = grace_time
	coyote_timer.start()
	coyote_valid = true

#endregion


func die() -> void:
	pass


func _on_dash_timer_timeout() -> void:
	in_dash = false

func _on_dash_cooldown_timer_timeout() -> void:
	dash_ready = true


# on timeout, set coyote input back to base state 
func _on_coyote_timer_timeout() -> void:
	coyote_input = "void"
	coyote_valid = false

func player():
	pass
