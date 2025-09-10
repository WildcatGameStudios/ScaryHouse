extends Node

## NOTE: the empty string "" is an INVALID state name; it is a sentinel value in
## the state machine logic and should not be used in application code.
## Also NOTE: please use `add_state` instead of directly setting this value.
## This helps us keep track of `enabled` states.
var states = {}
var enabled = {}
var transitions = {}
var current_state: String = "Idle"
var queued_state: String = ""

# specifically for running, to keep consistency with other states
var running: bool = false
var old_cam_basis: Basis
var old_gun_transform: Transform3D

var dt: float
@onready var parent: player = $'../'
@onready var cam: Camera3D = $'../head/Camera3D'
@onready var overhead_cam: Vector3 = cam.position
const ANY_STATE: String = ""

func _ready() -> void:
	add_state("Idle", idle)
	add_state("Walk", walk)
	add_state("Run", run)
	add_state("Jump", jump)
	add_state("Aim", aim)
	#add_state("Fire", fire)
	#add_state("Die", die)
	
	toggle_state("Idle", true)
	toggle_state("Walk", true)
	toggle_state("Run", true)
	toggle_state("Jump", true)
	toggle_state("Aim", true)
	
	# set_transition("Idle", "Jump", func(_dt: float): parent.jump())
	set_transition("Jump", ANY_STATE, func(_dt: float): parent.reset_jump())
	set_transition(ANY_STATE, "Aim", func(_dt: float): 
		old_cam_basis = cam.transform.basis
	)
	set_transition("Aim", ANY_STATE, func(_dt: float):
		cam.position = overhead_cam
		cam.transform.basis = old_cam_basis
	)

# use this for state-agnostic code
func _process(delta: float) -> void:
	update_state()
	running = Input.is_action_pressed("run")
	dt = delta
	states[current_state].call(dt)

# core state machine utilities
#region
func add_state(state: String, update: Callable) -> void:
	states[state] = update
	enabled[state] = false

func update_state() -> void:
	if queued_state == "":
		return
	if states.has(queued_state) == null:
		print("player_sm: Attempt to switch to invalid state '%s'" % queued_state)
	elif !enabled[queued_state]:
		print("player_sm: Attempt to switch to disabled state '%s'" % queued_state)
	else:
		call_transition(current_state, ANY_STATE)
		call_transition(current_state, queued_state)
		call_transition(ANY_STATE, queued_state)
		current_state = queued_state
		# print("player_sm: switched to state '%s'" % current_state)
	queued_state = ""

func set_transition(start: String, end: String, fn: Callable) -> void:
	if start == end:
		print("player_sm: Attempt to set transition from '%s' to itself" % end)
		return
	var key = "%d%s:%d%s" % [start.length(), start, end.length(), end]
	transitions[key] = fn

func call_transition(start: String, end: String) -> void:
	var key = "%d%s:%d%s" % [start.length(), start, end.length(), end]
	var trans = transitions.get(key)
	if trans != null:
		trans.call(dt)

func queue_transition(state: String) -> void:
	if queued_state == "":
		queued_state = state

func will_transition() -> bool:
	return queued_state != ""

func toggle_state(state: String, is_on: bool) -> void:
	enabled[state] = is_on
#endregion

# specific state update function callbacks and helpers
#region

func walk_trigger() -> bool:
	return Input.is_action_pressed("move_forward") || \
		   Input.is_action_pressed("move_back") || \
		   Input.is_action_pressed("move_left") || \
		   Input.is_action_pressed("move_right")

func handle_move(dt: float) -> void:
	if running:
		parent.run(dt)
	else:
		parent.walk(dt)

func idle(dt: float):
	# ironically, we still walk while idle; walk sets velocity
	parent.walk(dt)
	parent.move(dt)
	parent.handle_rotation()
	if Input.is_action_just_pressed("jump"):
		queue_transition("Jump")
		return
	elif !parent.is_on_floor():
		if enabled.find_key("Jump"):
			parent.jump()
		queue_transition("Jump")
	if walk_trigger():
		queue_transition("Walk")

func jump(dt: float):
	handle_move(dt)
	parent.move(dt)
	parent.handle_rotation()
	if parent.is_on_floor():
		queue_transition("Idle")
		return
	if Input.is_action_just_pressed("jump") && parent.double_jump_ready:
		parent.double_jump()

func walk(dt: float):
	handle_move(dt)
	parent.move(dt)
	parent.handle_rotation()
	if !walk_trigger():
		queue_transition("Idle")
		return
	if Input.is_action_just_pressed("jump"):
		parent.jump()
		queue_transition("Jump")
		return
	if !parent.is_on_floor():
		queue_transition("Jump")
		return
	if Input.is_action_pressed("run"):
		queue_transition("Run")
		return

func run(dt: float):
	handle_move(dt)
	parent.move(dt)
	parent.handle_rotation()
	if !walk_trigger():
		queue_transition("Idle")
		return
	elif !Input.is_action_pressed("run"):
		queue_transition("Walk")
		return
	if Input.is_action_just_pressed("jump"):
		parent.jump()
		queue_transition("Jump")
		return
	if !parent.is_on_floor():
		queue_transition("Jump")
		return

func aim(dt: float):
	parent.move(dt)
	var current_mouse_direction: Vector2 = Input.get_last_mouse_velocity()
	var joystick_rotation: Vector2 = Input.get_vector("joystick_look_left", "joystick_look_right", "joystick_look_up", "joystick_look_down")
	if current_mouse_direction:
		# to move up and down we rotate along x-axis 
		parent.look_direction.x -= current_mouse_direction.y * parent.verticle_look_speed
		#restric user camera angles for up/ down 
		parent.look_direction.x = clamp(parent.look_direction.x, deg_to_rad(parent.min_look_degree), deg_to_rad(parent.max_look_degree))
		# get rotation for side by side which is rotating against y axis 
		parent.look_direction.y -= current_mouse_direction.x * parent.horizontal_look_speed
	elif joystick_rotation:
		# to move up and down we rotate along x-axis 
		parent.look_direction.x -= joystick_rotation.y * parent.joystick_v_look_speed
		#restric user camera angles for up/ down 
		parent.look_direction.x = clamp(parent.look_direction.x, deg_to_rad(parent.min_look_degree), deg_to_rad(parent.max_look_degree))
		# get rotation for side by side which is rotating against y axis 
		parent.look_direction.y -= joystick_rotation.x * parent.joystick_h_look_speed
	
	# set parent head rotation
	parent.transform.basis = Basis()
	parent.rotate_y(parent.look_direction.y)
	# do camera pitch rotation
	cam.basis = Basis()
	cam.rotate_x(parent.look_direction.x)

	if Input.is_action_just_pressed("run"):
		queue_transition("Idle")
		return
	if !parent.is_on_floor():
		queue_transition("Jump")
		return

#endregion
