extends RigidBody3D

class_name EvilBird

enum State {
	Swoop,
	Grab,
	Takeoff,
	Dead,
}

var reset_time: float
var time_till_death: float
var despawn_duration: float = 4.0
var grab_time: float
var grabbed: bool = false
var takeoff_time: float = 5.0

var target_laundry: Node3D = null

var current_state: State = State.Swoop

@onready var foot_attach: Node3D = $feet
@onready var grab_timer: Timer = $grab_timer
@onready var takeoff_timer: Timer = $takeoff_timer
@onready var despawn_timer: Timer = $despawn_timer
@onready var head: CSGSphere3D = $mesh/head

@export var speed: float = 10.0
@export var grab_radius: float = 0.5

var pulsing: bool
var pulse_tween: float = 1.0
var pulse_duration: float = 1.0
var base_color: Color

signal died
signal stolen(Node3D)

# when an evil bird spawns, it will select a piece of clothing at random
# from any of the lines. this will be its target until:
# - it is killed by the drone, or
# - it steals the piece of clothing, flying away and despawning

func _ready() -> void:
	time_till_death = reset_time
	base_color = (head.material as BaseMaterial3D).albedo_color

func _process(dt: float) -> void:
	if grabbed and target_laundry != null:
		target_laundry.global_position = foot_attach.global_position
	match current_state:
		State.Swoop: swoop(dt)
		State.Grab: grab(dt)
		State.Takeoff: takeoff(dt)
		State.Dead: play_dead(dt)
	if current_state != State.Dead:
		if pulsing and pulse_tween <= 0.0:
			pulse_tween = 1.0
	
	pulse_tween -= (1.0 / pulse_duration) * dt
	var true_tween = max(0.0, pulse_tween)
	(head.material as BaseMaterial3D).albedo_color = true_tween * Color.RED + (1-true_tween) * base_color

func tick(dt: float) -> void:
	if current_state == State.Dead:
		return
	pulsing = true
	time_till_death -= dt
	if time_till_death <= 0.0:
		die()

func reset_tick(dt: float) -> void:
	time_till_death = reset_time
	pulsing = false

func swoop(dt: float):
	# travel towards the clothline
	if target_laundry == null:
		print("evil_bird.gd: cannot swoop to null node!")
		return
	var to_target = (target_laundry.global_position - foot_attach.position) - global_position
	if to_target.length() < grab_radius:
		current_state = State.Grab
		grab_timer.start(grab_time)
		return
	to_target = to_target.normalized()
	
	self.position += (to_target * speed) * dt

func grab(dt: float):
	pass

func takeoff(dt: float):
	self.position.y += speed * dt

func play_dead(dt: float):
	if despawn_timer.time_left < 1.0:
		$mesh.transparency = 1 - despawn_timer.time_left

func die() -> void:
	current_state = State.Dead
	freeze = false
	# quick 'n dirty pseudorandomness
	self.angular_velocity.x += cos(Time.get_unix_time_from_system() / 10000)
	self.angular_velocity.y += sin(Time.get_unix_time_from_system() / 10000)
	despawn_timer.start(despawn_duration)
	target_laundry = null
	
func _on_despawn_timer_timeout():
	emit_signal("died")

func _on_grab_timer_timeout():
	if current_state == State.Grab:
		current_state = State.Takeoff
		grabbed = true
		takeoff_timer.start(takeoff_time)

func _on_takeoff_timer_timeout():
	emit_signal("stolen", target_laundry)
	print("leave")
