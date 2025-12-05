extends PathFollow3D

@export var move_speed: float = 15.0
@export var player: Node3D
var attacking: bool = false
var parried: bool = false

func attack() -> void:
	if attacking:
		return
	progress = 0.0
	attacking = true

func scatter() -> void:
	if attacking:
		parried = true

func _physics_process(delta):
	if attacking == true and parried == false:
		progress += move_speed * delta
		
		# When the bat reaches the end of the path
		if progress_ratio >= 1.0:
			_reset_attack()
	elif attacking == true and parried == true:
		progress += -(move_speed + 10.0) * delta
		
		if progress_ratio <= 0:
			_reset_attack()

func _reset_attack() -> void:
	print("attack finished")
	attacking = false
	parried = false
	progress = 0.0
