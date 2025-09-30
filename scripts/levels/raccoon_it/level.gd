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
var selected_index : int = -1

# scene variables to keep track of 
var near_comp : bool = false
var near_table : bool = false
var hover_piece : int = 0
var components # array to hold table components children 
var preview_piece

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
@onready var supercomputer: Node3D = $supercomputer



func _ready() -> void : 
	components = component_container.get_children()
	for i in components :
		i.set_piece()


func _physics_process(delta: float) -> void:
	# check if we are trying to view something 
	if Input.is_action_just_pressed("e") : 
		if in_inspect : 
			print("Toggling out of view")
			if near_comp : exit_comp_view()
			if near_table : exit_table_view()
		else :
			print("Toggling in view")
			if near_comp : enter_comp_view()
			if near_table : enter_table_view()
	
	# if we are inspecting, what are actions
	if in_inspect : 
		if near_table : 
			
			# hover current piece 
			components[hover_piece].toggle_hover_anim(true)
			var landing_index : int
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
				
				# create new component and get type of component
				var selected_piece = COMPONENT.instantiate()
				selected_piece.type = components[hover_piece].type
				
				player.add_hand_object(selected_piece, 1, Vector3(2.0,2.0,2.0))
				
				selected_piece.set_piece()
				selected_index = hover_piece
				# exit 
				exit_table_view()
			
			
		if near_comp : 
			
			if Input.is_action_just_pressed("move_left") : 
				# first remove curr piece
				supercomputer.remove_piece(hover_piece)
				
				# find next free piece 
				hover_piece = supercomputer.return_first_free(hover_piece)
				
			if Input.is_action_just_pressed("move_right") : 
				supercomputer.remove_piece(hover_piece)
				hover_piece += 4
			if Input.is_action_just_pressed("move_forward") : 
				supercomputer.remove_piece(hover_piece)
				hover_piece -= 1
			if Input.is_action_just_pressed("move_back") : 
				supercomputer.remove_piece(hover_piece)
				
			
			
		
	else : 
		# not in inspect, thus in "roam" mode for room 
		if Input.is_action_just_pressed("r") : 
			if selected_index != -1 : 
				# remove selected piece from player 
				player.remove_hand_object(1) 
				
				# reset table 
				components[selected_index].unhide_component()
				
				# reset selected index
				selected_index = -1
	

func enter_comp_view () -> void : 
	# switch both cameras
	player.toggle_camera(false)
	comp_camera.current = true
	hover_piece = supercomputer.return_first_free()
	
	# check for piece being held 
	if selected_index != -1 :  # if piece is being held 
		preview_piece = COMPONENT.instantiate() # make piece
		preview_piece.type = components[selected_index].type # set type
		hover_piece = supercomputer.return_first_free()
		
		# add into tree and set up in tree 
		supercomputer.set_piece(preview_piece, hover_piece)
		preview_piece.set_piece()
		preview_piece.toggle_hover_anim(true)
	
	in_inspect = true

func exit_comp_view () -> void : 
	player.toggle_camera(true)
	comp_camera.current = false
	# if there is a child ( only 1 ever for supercomputer as of now ) 
	
	in_inspect = false

func enter_table_view () -> void : 
	player.toggle_camera(false)
	var i = 0 
	# find first non hidden component for default 
	while true : 
		if i >= components.size() : 
			print("erro no available piece")
			break
		
		if !components[i].hidden : 
			hover_piece = i
			break
		else : 
			i += 1
		
		
	table_camera.current = true
	in_inspect = true

func exit_table_view () -> void : 
	player.toggle_camera(true)
	table_camera.current = false
	components[hover_piece].toggle_hover_anim(false) # disable hover on table
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
