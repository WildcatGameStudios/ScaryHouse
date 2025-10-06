extends CharacterBody3D

@export var attack_delay: float = 2.0
@export var lunge_speed: float = 10.0
@export var lunge_distance: float = 5.0

var is_lunging: bool = false
var time_to_attack: float = 0.0

signal attack_player

func _ready():
	time_to_attack = attack_delay
	# Start the "prepare to strike" animation/timer

func _process(delta):
	if is_lunging:
		# Simple lunge forward on the Z axis (assuming monster faces forward)
		var direction = Vector3(0, 0, -1)
		velocity = direction * lunge_speed
		move_and_slide()
		
		# Stop the lunge after a certain distance (optional, but good practice)
		# You'd typically use an AnimationPlayer here for a smoother effect

	elif time_to_attack > 0:
		time_to_attack -= delta
		if time_to_attack <= 0:
			lunge()

func lunge():
	is_lunging = true
	emit_signal("attack_player")
	# The main Level script will handle damage and removing the monster
