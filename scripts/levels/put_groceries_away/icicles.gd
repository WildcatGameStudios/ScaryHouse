extends Area3D

@export var icicle_damage: int = 35
@export var icicle_speed: float = 2.50

@onready var ray_cast: RayCast3D = $RayCastIcicle
var icicle_root: Node3D
var original_position: Vector3

func _ready():
	icicle_root = get_parent()
	original_position = icicle_root.global_position
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move the icicle downwards
	var velocity: Vector3 = Vector3(0, -icicle_speed, 0)
	icicle_root.global_position += velocity * delta
	
	# Check if the raycast hits the ground (or anything else) to respawn
	if ray_cast.is_colliding():
		icicle_root.global_position = original_position

# This function now runs when the icicle's Area3D is entered
func _on_body_entered(body: Node3D):
	# Check if the body that entered has the "current_health" variable
	if "current_health" in body:
		# Directly subtract from the player's health
		body.current_health -= icicle_damage
		print("Player was hit by icicle: ", icicle_damage, " damage")
		
		icicle_root.global_position = original_position
