extends Node3D

var player_near_bag : bool = false
var bag_picked_up : bool = false
var current_state : game_state = game_state.BEGIN
enum game_state {
	BEGIN, 
	PHASE_ONE, 
	PHASE_TWO, 
	PHASE_THREE
} 

# scene refs
@onready var feed_bag: Node3D = $FeedBag
@onready var start_marker: Marker3D = $markers/start_marker
@onready var player: player = $player

func _physics_process(delta: float) -> void:
	if player.position.z < start_marker.position.z : 
		current_state = game_state.PHASE_ONE
		

func _input(event: InputEvent) -> void: 
	if Input.is_action_just_pressed("e") : 
		if player_near_bag : 
			# pick up bag if there
			feed_bag.position = Vector3(-0.67, -0.5, 0.0)
			feed_bag.rotate(Vector3(1.0,0.0,0.0), deg_to_rad(12))
			feed_bag.get_parent().remove_child(feed_bag)
			
			player.add_hand_object(feed_bag)
			


func _on_bag_area_body_entered(body: Node3D) -> void:
	player_near_bag = true


func _on_bag_area_body_exited(body: Node3D) -> void:
	player_near_bag = false
