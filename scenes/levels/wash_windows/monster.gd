extends CharacterBody3D

@export var attack_delay: float = 2.0  #Time monster pauses before lunging
@export var lunge_speed: float = 10.0
@export var lunge_distance: float = 5.0 #How far the monster will lunge

var is_lunging: bool = false
var time_to_attack: float = 0.0
var distance_traveled: float = 0.0 #Tracks how far the monster has moved

signal attack_player

func _ready():
	time_to_attack = attack_delay

func _process(delta):
	if is_lunging:
		#Movement
		var direction = Vector3(0, 0, -1)
		velocity = direction * lunge_speed
		
		#Do movement
		move_and_slide()
		
		#Track the distance the monster traveled
		var distance_this_frame = lunge_speed * delta
		distance_traveled += distance_this_frame
		
		#Check if the lunge is complete
		if distance_traveled >= lunge_distance:
			#Attack is finished; stop and remove monster
			velocity = Vector3.ZERO
			is_lunging = false
			#Remove the monster instance from the game
			queue_free()
			return

	elif time_to_attack > 0:
		#Monster is winding up
		time_to_attack -= delta
		if time_to_attack <= 0:
			lunge()

func lunge():
	#Start the attack
	is_lunging = true
	distance_traveled = 0.0 #Reset tracker
	
	#Notify the main level script that an attack has happened (for damage/penalty)
	emit_signal("attack_player")
