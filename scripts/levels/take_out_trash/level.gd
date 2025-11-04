extends Node3D

#assign catapult for the level so we can use this reference
@export var catapult: Node3D
@export var base_trash_launch_strength: Vector2 = Vector2(30,5)
#trash bin movement speed increase on binned trash
@export var bin_speed_increase: float = 0.2
@export var total_trash: int = 15
@export var move_bins_threshold: int = 3

#holds the trash that is in the catapult
var current_trash: Node3D
#number of bags thrown
var thrown_counter: int = 0
#number of bags binned
var binned_counter: float = 0
#order of trash/recycling, shuffled in ready and referenced when loading trash
var trash_list: Array[bool]

func launch_trash(throw_strength: float):
	#exit if no trash to launch
	if current_trash == null:
		return
	
	#add velocity rotated to catapult arm rotation
	current_trash.velocity = throw_strength * Vector3(base_trash_launch_strength.x,base_trash_launch_strength.y,0).rotated(Vector3(0,1,0),catapult.catapult_arm.rotation.y-PI/2)
	current_trash.launched = true
	#empty current trash because it's not longer in the catapult
	current_trash = null
	thrown_counter += 1
	if thrown_counter < total_trash:
		$TrashCooldown.start()

func load_trash():
	#exit if there is trash loaded
	if current_trash != null:
		return
	
	var trash: Node3D
	if trash_list[thrown_counter] == true:
		#trash scene
		trash = load("uid://dyrpy368isbe3").instantiate()
	if trash_list[thrown_counter] == false:
		#recycle scene
		trash = load("uid://0eekxcndxw8o").instantiate()
	
	add_child(trash)
	current_trash = trash
	trash.collided.connect(trash_collided)
	
	$TrashReserve.get_child(0).queue_free()

func randomize_trash_order():
	#alternates between true/false and shuffles for even, random distribution
	var is_trash_bag: bool = true
	for i in range(total_trash):
		trash_list.append(is_trash_bag)
		is_trash_bag = !is_trash_bag
	
	trash_list.shuffle()

#do stuff when trash collides (hit a bin or a wall)
func trash_collided(hit_bin: bool):
	if hit_bin:
		print("hit")
		binned_counter += 1
		$AnimationPlayer.speed_scale += bin_speed_increase
	else:
		print("no hit")
	#bins start moving when some trash is binned
	if thrown_counter >= move_bins_threshold:
		$AnimationPlayer.play("slide_bins")

func create_trash_reserve():
	for i in range(total_trash):
		var trash: Node3D
		if trash_list[i] == true:
			#dummy trash scene
			trash = load("uid://cmqb1kmubkmqg").instantiate()
		if trash_list[i] == false:
			#dummy recycle scene
			trash = load("uid://dccwqtq7kfg26").instantiate()
		$TrashReserve.add_child(trash)
		trash.global_position = $TrashReserve.position
		await get_tree().create_timer(0.2).timeout

func evalutate_score() -> float:
	var score = 100 * (binned_counter / total_trash)
	return score

func _ready() -> void:
	catapult.throw_trash.connect(launch_trash)
	randomize_trash_order()
	create_trash_reserve()

func _physics_process(delta: float) -> void:
	#position current trash in catapult bowl
	if current_trash != null:
		current_trash.global_position = catapult.catapult_bowl.global_position + Vector3(0,3,0)
		#remove velocity from gravity
		current_trash.velocity = Vector3.ZERO

#replace trash after launch and short cooldown
func _on_trash_cooldown_timeout() -> void:
	load_trash()
