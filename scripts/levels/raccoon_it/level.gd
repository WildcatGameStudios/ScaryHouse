extends Node3D

#enum for piece options
enum Piece {
	EMPTY,
	RED,
	BLUE,
	GREEN,
	PURPLE
	}


# keep track of computer progress 
var comp_fixed : bool = false 
var in_inspect : bool = false
var selected_piece : Node3D  

# scene variables to keep track of 
var near_comp : bool = false
var near_table : bool = false
var hover_piece : int = 0
var components

# grid of all the pieces
var grid : Array[Array] = [
	[Piece.EMPTY, Piece.EMPTY, Piece.EMPTY],
	[Piece.EMPTY, Piece.EMPTY, Piece.EMPTY],
	[Piece.EMPTY, Piece.EMPTY, Piece.EMPTY],
	[Piece.EMPTY, Piece.EMPTY, Piece.EMPTY]
]

var camera_rot : Vector3 = Vector3(-20,90,0)


const COMPONENT = preload("res://scenes/levels/raccoon_it/component.tscn")


# scene ref
@onready var inspect_point: Marker3D = $inspect_point
@onready var player: player = $player
@onready var component_container: Node3D = $component_container
@onready var comp_camera: Camera3D = $comp_camera
@onready var table_camera: Camera3D = $table_camera



func _ready() -> void : 
	components = component_container.get_children()
	for i in components :
		i.set_piece()


func _physics_process(delta: float) -> void:
	# check if we are trying to view something 
	if Input.is_action_just_pressed("e") : 
		if in_inspect : 
			if near_comp : exit_comp_view()
			if near_table : exit_table_view()
		else :
			if near_comp : enter_comp_view()
			if near_table : enter_table_view()
	
	# if we are inspecting, what are actions
	if in_inspect : 
		if near_table : 
			# hover current piece 
			components[hover_piece].toggle_hover_anim(true)
			
			# if input found 
			if Input.is_action_just_pressed("move_left") : # left 
				# unhover piece 
				components[hover_piece].toggle_hover_anim(false)
				hover_piece -= 3;
				if hover_piece < 0 :
					hover_piece = 9
			if Input.is_action_just_pressed("move_right") : # right
				components[hover_piece].toggle_hover_anim(false)
				hover_piece += 3;
				if hover_piece > 11 :
					hover_piece = 0
			if Input.is_action_just_pressed("move_forward") : # up
				components[hover_piece].toggle_hover_anim(false)
				
				# if were top row 
				if hover_piece == 0 or (hover_piece - 1) / 3 != hover_piece / 3 :
					hover_piece += 2
				else : 
					hover_piece -= 1
			if Input.is_action_just_pressed("move_back") : # down
				components[hover_piece].toggle_hover_anim(false)
				# if were bottom
				if (hover_piece + 1) / 3 != hover_piece / 3 :
					hover_piece -= 2
				else : 
					hover_piece += 1
				
			# if we hit select 
			if Input.is_action_just_pressed("select") : 
				# # hide piece 
				components[hover_piece].hide_component()
				
				var hands = player.get_hand_positions()
				
				selected_piece = COMPONENT.instantiate()
				
				selected_piece.type = components[hover_piece].type
				
				player.add_child(selected_piece)
				selected_piece.position = hands[1]
				
				# exit 
				exit_table_view()
		if near_comp : 
			pass
	

func enter_comp_view () -> void : 
	# switch both cameras
	player.toggle_camera(false)
	comp_camera.current = true
	
	in_inspect = true

func exit_comp_view () -> void : 
	player.toggle_camera(true)
	comp_camera.current = false
	
	in_inspect = false

func enter_table_view () -> void : 
	player.toggle_camera(false)
	table_camera.current = true
	
	in_inspect = true

func exit_table_view () -> void : 
	player.toggle_camera(true)
	table_camera.current = false
	
	in_inspect = false




func insert_piece () : 
	pass

func check_state () -> bool : 
	
	return false


func _on_comp_interact_area_body_entered(body: Node3D) -> void:
	if body.has_method("player") :
		near_comp = true


func _on_comp_interact_area_body_exited(body: Node3D) -> void:
	if body.has_method("player") : 
		near_comp = false


func _on_table_interact_area_body_entered(body: Node3D) -> void:
	if body.has_method("player") :
		near_table = true


func _on_table_interact_area_body_exited(body: Node3D) -> void:
	if body.has_method("player") : 
		near_table = false
