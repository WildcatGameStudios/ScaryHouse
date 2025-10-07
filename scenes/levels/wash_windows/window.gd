class_name Game_Window
extends Node3D
@export var clean_target: float = 100.0
@export var clean_decay_rate: float = 5.0  # Cleanliness lost per second
@export var shutter_speed: float = 5.0    # Speed of the shutter animation
@export var closed_x_left: float = 0.0
@export var closed_x_right: float = -2.598
@export var open_x_left: float = -1.5
@export var open_x_right: float = 1.5


@onready var collider: Area3D = $Collider
@onready var meter_bar: MeshInstance3D = $Meter_Root/Meter_Bar
@onready var dirt_particles: MeshInstance3D = $Dirt_Particles
@onready var shutter_left: MeshInstance3D = $Shutter_Left
@onready var shutter_right: MeshInstance3D = $Shutter_Right
@onready var monster_spawn: Node3D = $Monster_Spawn_Point

#Variables
var current_cleanliness: float = 0.0
var is_active: bool = false
var is_clean: bool = false
var is_monster_spawning: bool = false
var monster_instance: CharacterBody3D = null

#State Machine
enum State {CLOSED, OPEN_CLEAN, OPEN_MONSTER}
var current_state = State.CLOSED

#Signals
signal window_cleaned(window)
signal monster_spotted(window)
signal window_hit(window)

#Initialization
func _ready() -> void:
	# Set initial meter visual (full red)
	update_meter()
	close_shutters(true)

#Main Loop
func _process(delta: float) -> void:
	if is_clean:
		return

	#Window Cleanliness Loss
	if is_active and current_state == State.OPEN_CLEAN:
		# Only decay if window is not being cleaned
		current_cleanliness -= clean_decay_rate * delta
		current_cleanliness = clampf(current_cleanliness, 0, clean_target)

	#Shutter Animation
	var target_left_x = closed_x_left
	var target_right_x = closed_x_right
	
	if current_state != State.CLOSED:
		# Shutters open outward, using the exported values
		target_left_x = open_x_left 
		target_right_x = open_x_right

	var current_pos_l = shutter_left.position.x
	var new_pos_l = lerpf(current_pos_l, target_left_x, shutter_speed * delta)
	shutter_left.position.x = new_pos_l

	var current_pos_r = shutter_right.position.x
	var new_pos_r = lerpf(current_pos_r, target_right_x, shutter_speed * delta)
	shutter_right.position.x = new_pos_r
	
	update_meter()




## Starts the cleaning cycle for this window
func activate_window():
	if is_clean: return
	is_active = true
	# Randomly choose between a clean window or a monster window
	if randi() % 5 == 0: # 1 in 5 chance to spawn a monster
		open_monster()
	else:
		open_clean()

## Closes the shutters
func close_shutters(immediate: bool = false):
	current_state = State.CLOSED
	if immediate:
		shutter_left.position.x = closed_x_left
		shutter_right.position.x = closed_x_right
	
	if monster_instance:
		# Safely remove monster if it's still alive
		monster_instance.queue_free()
		monster_instance = null
		is_monster_spawning = false

## Sets the window to the cleaning state
func open_clean():
	if is_clean: return
	current_state = State.OPEN_CLEAN

## Sets the window to the monster state
func open_monster():
	if is_clean: return
	current_state = State.OPEN_MONSTER
	is_monster_spawning = true
	emit_signal("monster_spotted", self)

## Called when hit by water
func receive_water_hit(amount: float):
	if is_clean: return
	
	if current_state == State.OPEN_MONSTER:
		#Hitting monster with water causes immediate attack
		emit_signal("monster_spotted", self) # Trigger immediate attack
		return
		
	current_cleanliness += amount
	current_cleanliness = clampf(current_cleanliness, 0, clean_target)
	
	# Update visuals (dirtiness fading)
	var ratio = 1.0 - (current_cleanliness / clean_target)
	dirt_particles.scale = Vector3.ONE * ratio
	
	if current_cleanliness >= clean_target:
		is_clean = true
		current_state = State.CLOSED
		emit_signal("window_cleaned", self)
 
## Called when hit by tranquilizer
func receive_tranquilizer_hit():
	if is_clean: return
	
	if current_state == State.OPEN_MONSTER:
		#Hit the monster?
		close_shutters()
		return
	else:
		#Hit clean window with tranquilizer? (breaks window)
		emit_signal("window_hit", self) 


## Updates the cleanliness meter
func update_meter():
	var ratio = current_cleanliness / clean_target
	meter_bar.scale.y = ratio * 1.0 #Meter bar's scale (might need to change)
	
	#Color of the meter bar (Red to Green)
	var red_color = Color.RED
	var green_color = Color.GREEN
	var new_color = red_color.lerp(green_color, ratio)
	
	# Changing color of MeshInstance3D
	var material = StandardMaterial3D.new()
	material.albedo_color = new_color
	meter_bar.material_override = material
