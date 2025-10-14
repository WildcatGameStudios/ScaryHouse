extends RigidBody3D

var active: bool = false:
	set(b): 
		if b:
			gravity_scale = 0.0
			active = true
		else:
			gravity_scale = 1.0
			active = false
			pulse_active = false

var pulse_active: bool = false

@export_group("Movement Variables")
@export var default_speed: float = 100.0
@export var fall_speed: float = 3.0
@export var active_pulse_slowdown: float = 5.0
@export_group("Pulse Variables")
@export var pulse_radius: float = 10.0
@export var pulse_duration: float = 1.0
var pulse_tween: float = pulse_duration
var base_color: Color

@onready var csg_box_3d: CSGBox3D = $CSGBox3D

var speed: float = default_speed

var birds: Array[EvilBird]

# current set of controls:
# - while active, arrow keys (or wsad?) to move drone
# - mouse to look up/down and left/right
# - (may change soon) space/shift to fly up/down
# - 'e' to toggle pulse to attack birds. speed greatly reduces while doing so

func _ready() -> void:
	freeze = false
	base_color = (csg_box_3d.material as BaseMaterial3D).albedo_color

func _physics_process(dt: float) -> void:
	# handle pulse activation
	if Input.is_action_just_pressed("e"):
		pulse_active = not pulse_active
	
	# set speed based on pulse status
	if pulse_active:
		speed = default_speed / active_pulse_slowdown
		process_pulse(dt)
	else:
		speed = default_speed
	
	# update pulse colors
	pulse_tween -= (1/pulse_duration) * dt
	
	var true_tween = max(0.0, pulse_tween)
	(csg_box_3d.material as BaseMaterial3D).albedo_color = true_tween * Color.RED + (1-true_tween) * base_color
	
	# kill dead birds
	for b in birds_to_kill:
		birds.erase(b)
		if b.target_laundry != null:
			b.target_laundry.queue_free()
		b.queue_free()
	birds_to_kill.clear()
	
	if !active:
		return
	# handle movement logic
	var input_vec = Input.get_vector("move_right", "move_left", "move_back", "move_forward")
	
	var movement_vec = Vector3()
	movement_vec.x = input_vec.x * speed
	movement_vec.z = input_vec.y * speed
	
	var y_dir = 0
	if Input.is_action_pressed("jump"):
		y_dir += 1
	if Input.is_action_pressed("run"):
		y_dir -= 1
	
	movement_vec.y = y_dir * speed
	
	apply_force(movement_vec)

var birds_to_kill: Array[EvilBird]
func process_pulse(dt: float) -> void:
	if pulse_tween < 0.0:
		pulse_tween = 1.0
	
	for b in birds:
		if b.position.distance_to(position) < pulse_radius:
			b.tick(dt)
			b.pulsing = true
		else:
			b.reset_tick(dt)
			b.pulsing = false

func _on_bird_die(b: EvilBird):
	birds_to_kill.append(b)
