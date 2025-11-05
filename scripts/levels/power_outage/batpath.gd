extends PathFollow3D

@export var move_speed: float = 5.0
@export var player: Node3D
var attacking: bool = false

func attack() -> void:
	if attacking:
		return
	progress = 0.0
	attacking = true

func _physics_process(delta):
	if attacking:
		progress += move_speed * delta
		
		# when the bat reaches the end of the path
		if progress_ratio >= 1.0:
			_reset_attack()

func _reset_attack() -> void:
	print("attack finished")
	attacking = false
	progress = 0.0
