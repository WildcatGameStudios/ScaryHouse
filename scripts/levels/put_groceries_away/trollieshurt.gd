extends Area3D

@export var trolley_speed: float = 5
@export var damage_amount: int = 35

var direction: int = 1 # 1 for forward, -1 for backward
var ray_cast: RayCast3D
var trolley_root: Node3D # Reference to the moving parent node


func _ready():
	ray_cast = $RayCast3D
	trolley_root = get_parent()
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var velocity: Vector3 = Vector3(trolley_speed * direction, 0, 0)
	trolley_root.global_position += velocity * delta
	
	if ray_cast.is_colliding(): #reverse direction
		direction *= -1
		trolley_root.rotate_y(deg_to_rad(180))


# This function runs when a physics body enters the Area3D
func _on_body_entered(body):
	# Check if the body that entered has a "current_health" variable
	if "current_health" in body:
		# Directly subtract from the player's health variable
		body.current_health -= damage_amount
		print("Player took damage")
