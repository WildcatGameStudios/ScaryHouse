extends Node3D

#player instance should be the player node in the level
#export is a good way to pass reference nodes
#the interaction camera is the node of the same name
#this is a node3d that will determine the player position and rotation
#while in interaction mode
@export var player_instance: player
@export var catapult_arm: Node3D
@export var catapult_bowl: Node3D
@export var max_arm_y_rotation: float = PI/4
@export var max_throw_strength: float = 1.6
@export var rotate_speed: float = 1

var player_in_area: bool = false
var interaction_mode: bool = false
var throw_strength: float = 0
var saved_head_position: Vector3
var saved_rotation: float
var player_head: Node3D

#connected in level script
signal throw_trash(time_held: float)

func handle_inputs(delta: float):
	#melee button enters interaction mode if near catapult
	#exits if in interaction mode
	if Input.is_action_just_pressed("melee"):
		if interaction_mode:
			interaction_mode = false
			player_head.position = saved_head_position
			player_instance.can_walk = true
			player_instance.visible = true
		elif player_in_area:
			interaction_mode = true
			saved_head_position = player_head.position
			player_head.global_position = $InteractionCamera.position
			player_instance.can_walk = false
			player_instance.visible = false
	
	#stop reading inputs if not in interaction mode
	if !interaction_mode:
		return
	
	#left and right turn the catapult. locked at quarter pi rotation
	if Input.is_action_pressed("move_left") && catapult_arm.rotation.y > -(max_arm_y_rotation):
		catapult_arm.rotate(Vector3(0,1,0),-rotate_speed * delta)
	if Input.is_action_pressed("move_right") && catapult_arm.rotation.y < (max_arm_y_rotation):
		catapult_arm.rotate(Vector3(0,1,0),rotate_speed * delta)
	
	#increase throw strength and send signal to level to throw trash
	if Input.is_action_pressed("jump") && throw_strength <= max_throw_strength:
		throw_strength += delta
	if Input.is_action_just_released("jump"):
		throw_trash.emit(throw_strength)
		throw_strength = 0
	#rotate based on charge time
	catapult_arm.rotation.x = 0.55 - throw_strength / 4

func _ready() -> void:
	player_head = $"../player/head"

func _process(delta: float) -> void:
	handle_inputs(delta)
	if interaction_mode:
		player_head.global_position = $InteractionCamera.position
	
#updates whether the player is near the catapult
func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is player:
		player_in_area = true
func _on_player_detection_body_exited(body: Node3D) -> void:
	if body is player:
		player_in_area = false
