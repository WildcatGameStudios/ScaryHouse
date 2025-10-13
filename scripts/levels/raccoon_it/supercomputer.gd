extends Node3D
class_name supercomputer

# refrences
@onready var component_container: Node3D = $main_combiner/component_container
@onready var hover_piece: Node3D = $main_combiner/component_container/hover_piece

# innternal variables
var components
var board = []
var translation_position = Vector3(0.85,-0.616,0.477)

enum Piece {
	EMPTY, 
	RED, 
	BLUE, 
	GREEN,
	PURPLE,
}

var RED_FLAG : bool = false
var BLUE_FLAG : bool = false
var GREEN_FLAG : bool = false


const COMPONENT = preload("res://scenes/levels/raccoon_it/component.tscn")

func _ready() -> void:
	components = component_container.get_children()
	
	# set board full of null for pieces
	for i in range(components.size()) : 
		# create new piece 
		var new_piece = COMPONENT.instantiate()
		new_piece.visible = false
		# parent piece 
		components[i].add_child(new_piece)
		# add piece to board 
		board.push_back(new_piece)
	
	

# slot id is index of component, new_piece is obj of component
func set_piece (new_piece, slot_id : int) : 
	board[slot_id].type  = new_piece.type
	board[slot_id].visible = true
	board[slot_id].set_piece()

# remove piece at slot_id
func remove_piece(slot_id) : 
	board[slot_id].type = Piece.EMPTY
	board[slot_id].visible = false
	

func get_piece(slot_id) : 
	return board[slot_id]


# set hover piece
func set_hover(slot_id : int, new_type = hover_piece.type) : 
	# set hover piece positionA
	if board[slot_id].type == Piece.EMPTY : 
		hover_piece.position = components[slot_id].position
	else : 
		hover_piece.position = components[slot_id].position + Vector3(0,0.2, 0)
	
	# set hover piece type 
	hover_piece.type = new_type
	hover_piece.set_piece()
	
	if new_type == Piece.EMPTY : 
		disable_hover()
	else : 
		enable_hover()

func enable_hover() : 
	hover_piece.visible = true
	hover_piece.toggle_hover_anim(true)

func disable_hover () : 
	hover_piece.visible = false
	hover_piece.toggle_hover_anim(false)

func get_hover_piece () : 
	return hover_piece

# evalute computer board, return true if win and return false if not win
# update visuals to reflect state 
func evaluate_board () -> bool: 
	# check each col for all parts first 
	var id
	
	# for each col 
	for i in range(3) : 
		RED_FLAG = false
		GREEN_FLAG = false
		BLUE_FLAG = false
		# for each item in the col 
		for j in range(4) : 
			id = i + (j * 3)
			# if select type, validate flag 
			if board[id].type == Piece.RED : RED_FLAG = true
			if board[id].type == Piece.GREEN : GREEN_FLAG = true
			if board[id].type == Piece.BLUE : BLUE_FLAG = true
		
		if not (RED_FLAG and BLUE_FLAG and GREEN_FLAG) : 
			# game was not won 
			return false
	# if we got to this point then each col has requirments
	# now check that no row has duplicate 
	var total_pieces = 0
	for i in range(12) : 
		# if we hit new row 
		if (i % 3) == 0 : 
			RED_FLAG = false
			GREEN_FLAG = false
			BLUE_FLAG = false 
		
		if board[i].type == Piece.RED : 
			if !RED_FLAG : 
				RED_FLAG = true
				total_pieces += 1
			else : return false
		if board[i].type == Piece.GREEN : 
			if !GREEN_FLAG : 
				GREEN_FLAG = true
				total_pieces += 1
			else : return false
		if board[i].type == Piece.BLUE : 
			if !BLUE_FLAG : 
				BLUE_FLAG = true
				total_pieces += 1
			else : return false
		if board[i].type == Piece.PURPLE : 
			total_pieces += 1
		
	# final check - did they use all pieces
	return total_pieces == 12
