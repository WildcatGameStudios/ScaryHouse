extends Node3D

#assign catapult for the level so we can use this reference
@export var catapult: Node3D
@export var base_trash_launch_strength: Vector2 = Vector2(30,5)
#trash bin movement speed increase on binned trash
@export var bin_speed_increase: float = 0.2
@export var total_trash: int

#holds the trash that is in the catapult
var current_trash: Node3D
#number of bags thrown
var thrown_counter: int = 0
#number of bags binned
var binned_counter: float = 0

func launch_trash(throw_strength: float):
	#exit if no trash to launch
	if current_trash == null:
		return
	
	#add velocity rotated to catapult arm rotation
	current_trash.velocity = throw_strength * Vector3(base_trash_launch_strength.x,base_trash_launch_strength.y,0).rotated(Vector3(0,1,0),catapult.catapult_arm.rotation.y-PI/2)
	#empty current trash because it's not longer in the catapult
	current_trash = null
	thrown_counter += 1
	if thrown_counter < total_trash:
		$TrashCooldown.start()

func load_trash():
	#exit if there is trash loaded
	if current_trash != null:
		return
	
	#choose random number for trash type
	var trash_type = randi() % 2
	var trash: Node3D
	if trash_type == 0:
		#trash scene
		trash = load("uid://dyrpy368isbe3").instantiate()
	if trash_type == 1:
		#recycle scene
		trash = load("uid://0eekxcndxw8o").instantiate()
	
	add_child(trash)
	current_trash = trash
	trash.collided.connect(trash_collided)

#do stuff when trash collides (hit a bin or a wall)
func trash_collided(hit_bin: bool):
	if hit_bin:
		print("hit")
		binned_counter += 1
		#bins start moving when 3 trash is binned
		if binned_counter >= 3:
			$AnimationPlayer.play("slide_bins")
			$AnimationPlayer.speed_scale += bin_speed_increase
	else:
		print("no hit")

func evalutate_score() -> float:
	var score = 100 * (binned_counter / total_trash)
	return score

func _ready() -> void:
	catapult.throw_trash.connect(launch_trash)

func _physics_process(delta: float) -> void:
	#position current trash in catapult bowl
	if current_trash != null:
		current_trash.global_position = catapult.catapult_bowl.global_position + Vector3(0,3,0)
		#remove velocity from gravity
		current_trash.velocity = Vector3.ZERO
	print(evalutate_score())

#replace trash after launch and short cooldown
func _on_trash_cooldown_timeout() -> void:
	load_trash()
