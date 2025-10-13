extends Node3D

#enum for piece options
enum Piece {
	EMPTY,
	RED,
	BLUE,
	GREEN,
	PURPLE
	}

signal complete

# keep track of computer progress 
var comp_fixed : bool = false 
var in_inspect : bool = false 
var selected_index : int = -1

# scene variables to keep track of 
var near_comp : bool = false
var near_table : bool = false
var hover_index : int = 0
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
			if near_comp : exit_comp_view()
			elif near_table : exit_table_view()
			else : print("Trouble! Near nothing but in inspect")
		else :
			if near_comp : 
				enter_comp_view()
			if near_table : 
				enter_table_view()
	
	# if we are inspecting, what are actions
	if in_inspect : 
		if near_table : 
			
			# hover current piece 
			components[hover_index].toggle_hover_anim(true)
			var landing_index : int
			# if input found 
			if Input.is_action_just_pressed("move_left") : # left 
				# unhover piece 
				components[hover_index].toggle_hover_anim(false)
				hover_index -= 3;
				if hover_index < 0 :
					hover_index = 9
			if Input.is_action_just_pressed("move_right") : # right
				components[hover_index].toggle_hover_anim(false)
				hover_index += 3;
				if hover_index > 11 :
					hover_index = 0
				
			if Input.is_action_just_pressed("move_forward") : # up
				components[hover_index].toggle_hover_anim(false)
				# if were top row 
				if hover_index == 0 or (hover_index - 1) / 3 != hover_index / 3 :
					hover_index += 2
				else : 
					hover_index -= 1
			if Input.is_action_just_pressed("move_back") : # down
				components[hover_index].toggle_hover_anim(false)
				# if were bottom
				if (hover_index + 1) / 3 != hover_index / 3 :
					hover_index -= 2
				else : 
					hover_index += 1
				
			# if we hit select 
			if Input.is_action_just_pressed("select") : 
				# # hide piece 
				components[hover_index].hide_component()
				
				# create new component and get type of component
				var selected_piece = COMPONENT.instantiate()
				selected_piece.type = components[hover_index].type
				player.add_hand_object(selected_piece, 1, Vector3(2.0,2.0,2.0))
				
				selected_piece.set_piece()
				selected_index = hover_index
				# exit 
				exit_table_view()
			
			
		if near_comp : 
			
			if Input.is_action_just_pressed("move_left") : 
				# dec piece 
				#print("-----------")
				#print("Old Index : " + str(hover_index))
				hover_index -= 1
				# catch edge case
				if hover_index < 0 : 
					hover_index = 11
				#print("New Index : " + str(hover_index))
				# set visual for computer
				supercomputer.set_hover(hover_index)
				
			if Input.is_action_just_pressed("move_right") : 
				# inc piece 
				#print("-----------")
				#print("Old Index : " + str(hover_index))
				hover_index += 1
				# catch edge case
				if hover_index > 11 : 
					hover_index = 0
				#print("New Index : " + str(hover_index))
				# set visual for computer
				supercomputer.set_hover(hover_index)
				
				
			if Input.is_action_just_pressed("move_forward") : 
				# if were top row 
				#print("-----------")
				#print("Old Index : " + str(hover_index))
				if hover_index / 3 == 0 : 
					hover_index += 9
				else : 
					hover_index -=3
				#print("New Index : " + str(hover_index))
				supercomputer.set_hover(hover_index)
				
			if Input.is_action_just_pressed("move_back") : 
				#print("-----------")
				#print("Old Index : " + str(hover_index))
				if hover_index / 3 == 3 : 
					hover_index -= 9
				else : 
					hover_index += 3
				#print("New Index : " + str(hover_index))
				supercomputer.set_hover(hover_index)
			
			if Input.is_action_just_pressed("select") : 
				# if we dont have someting in our hand
				var current_piece = supercomputer.get_piece(hover_index)
				if selected_index == -1 : 
					if current_piece.type != Piece.EMPTY : # if slot isnt empty 
						# set new hover 
						supercomputer.set_hover(hover_index, current_piece.type)
						supercomputer.remove_piece(hover_index)
					
				else : # if we do 
					if current_piece.type != Piece.EMPTY : 
						# swap pieces
						var temp_type = current_piece.type
						supercomputer.set_piece(supercomputer.get_hover_piece(), hover_index)
						supercomputer.set_hover(hover_index, temp_type)
					else : 
						# put down piece 
						supercomputer.set_piece(supercomputer.get_hover_piece(), hover_index)
						supercomputer.set_hover(hover_index, Piece.EMPTY)
						selected_index = -1
						if supercomputer.evaluate_board() : 
							win_level()
							exit_comp_view()
						
			
			
	
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
	player.can_walk = false
	#print("Entering computer view")
	# switch both cameras
	player.toggle_camera(false)
	comp_camera.current = true
	# set first piece 
	hover_index = 0
	
	# check for piece being held 
	if selected_index != -1 :  # if piece is being held 
		# add into tree and set up in tree 
		var piece = player.get_hand_object() # assumes hand object is component
		var type = Piece.EMPTY
		if piece != null : 
			type = piece.type
		supercomputer.set_hover(hover_index, type)
		var old_piece = player.remove_hand_object() # remove right hand piece after placing into hover 
		old_piece.queue_free()
	else : 
		supercomputer.set_hover(0, Piece.EMPTY)
	
	in_inspect = true
	# double check that these are set correct 
	near_comp = true
	near_table = false

func exit_comp_view () -> void : 
	player.can_walk = true
	#print("Exiting computer view")
	player.toggle_camera(true)
	comp_camera.current = false
	# If there is hover, put back into hand 
	if supercomputer.get_hover_piece().type != Piece.EMPTY : 
		var return_piece = COMPONENT.instantiate()
		return_piece.type = supercomputer.get_hover_piece().type
		
		# pass this to player 
		player.add_hand_object(return_piece, 1, Vector3(1.0,1.0,1.0))
		return_piece.set_piece()
		  
		selected_index = get_first_open(return_piece.type)
	# Reset hover 
	else : 
		selected_index = -1
	supercomputer.set_hover(0, Piece.EMPTY)
	
	in_inspect = false
	near_comp = true
	near_table = false

func enter_table_view () -> void : 
	player.can_walk = false
	#print("Entering table view")
	player.toggle_camera(false)
	var i = 0 
	# find first non hidden component for default 
	if selected_index == -1 : 
		#print("Finding next open piece")
		while true : 
			if i >= components.size() : 
				#print("erro no available piece")
				break
			
			if !components[i].hidden : 
				hover_index = i
				break
			else : 
				i += 1
	else : 
		#print("Setting first piece as " + str(selected_index))
		hover_index = selected_index
		components[hover_index].unhide_component()
		
	player.remove_hand_object()
	table_camera.current = true
	in_inspect = true
	
	near_comp = false
	near_table = true

func exit_table_view () -> void : 
	player.can_walk = true
	#print("Exit table view")
	player.toggle_camera(true)
	table_camera.current = false
	components[hover_index].toggle_hover_anim(false) # disable hover on table
	in_inspect = false 
	
	near_comp = false
	near_table = true

# get first open piece of a type given a type to the table
# return -1 if none 
# type is offset int for col 
func get_first_open(type) : 
	for i in range(3) : 
		var curr_spot = i + 3 * (type - 1)
		# check if open 
		if components[curr_spot].hidden  : 
			return curr_spot
	return -1

func win_level () : 
	emit_signal("win")
	print("GAME WON!!!!!!!!!")




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
