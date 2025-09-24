extends Node3D

#assign catapult for the level so we can use this reference
@export var catapult: Node3D

#holds the trash that is in the catapult
var current_trash: Node3D

func launch_trash(throw_strength: float):
	#exit if no trash to launch
	if current_trash == null:
		return
	#add velocity rotated to catapult arm rotation
	current_trash.velocity = throw_strength * Vector3(10,5,0).rotated(Vector3(0,1,0),catapult.catapult_arm.rotation.y-PI/2)
	#empty current trash because it's not longer in the catapult
	current_trash = null
	$TrashCooldown.start()

func load_trash():
	#exit if there is trash loaded
	if current_trash != null:
		return
	
	#choose random number for trash type
	var trash_type = randi() % 2
	var trash: Node3D
	if trash_type == 0:
		#trash
		trash = load("uid://dyrpy368isbe3").instantiate()
	if trash_type == 1:
		#recycle
		trash = load("uid://0eekxcndxw8o").instantiate()
	
	add_child(trash)
	current_trash = trash
	trash.despawn.connect(trash_despawn)

func trash_despawn(hit_bin: bool):
	if hit_bin:
		print("hit")
	else:
		print("no hit")

func _ready() -> void:
	catapult.throw_trash.connect(launch_trash)

func _physics_process(delta: float) -> void:
	#position current trash in catapult bowl
	if current_trash != null:
		current_trash.global_position = catapult.catapult_bowl.global_position + Vector3(0,3,0)
		#remove velocity from gravity
		current_trash.velocity = Vector3.ZERO

#replace trash after launch and short cooldown
func _on_trash_cooldown_timeout() -> void:
	load_trash()
