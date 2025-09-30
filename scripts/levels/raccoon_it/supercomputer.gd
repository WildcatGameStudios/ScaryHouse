extends Node3D
class_name supercomputer

# refrences
@onready var component_container: Node3D = $main_combiner/component_container

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
	board.push_back([Piece.RED, Piece.EMPTY, Piece.EMPTY])
	board.push_back([Piece.EMPTY, Piece.EMPTY, Piece.EMPTY])
	board.push_back([Piece.EMPTY, Piece.EMPTY, Piece.EMPTY])
	board.push_back([Piece.EMPTY, Piece.EMPTY, Piece.EMPTY])
	
	

# return first free slot_id of board return -1 if none 
# alignment is if searching for specific dimension 0 for row 1 for col 
# -1 is default for alignment meaning we dont care 
func return_first_free (offset : int = 0, alignment = -1) -> int : 
	var result = -1
	# variables for traversing board
	var row
	var col
	
	if alignment == -1 : 
		# for all slot, check if empty and if so return i
		for i in range(offset, 12) : 
			row = i / 3
			col = i  % 3
			if board[row][col] == Piece.EMPTY : 
				result = i
				break
		
		# check back 
		# if offset was not 0 and non found - check back
		if offset != 0 and result != -1: 
			for i in range(0, offset) : 
				row = i / 3
				col = i  % 3
				if board[row][col] == Piece.EMPTY : 
					result = i
					break
	elif alignment == 0 : 
		# check all elms in row 
		row = offset / 3
		for i in range(3) : 
			col = (offset + 0) % 3
			if board[row][col] == Piece.EMPTY : 
				result = i
				break
	
	return result

# slot id is index of component, new_piece is obj of component
func set_piece (new_piece, slot_id : int) : 
	print("Set called")
	# array indexes for slot 
	var row = slot_id / 3
	var col = slot_id % 3
	
	
	board[row][col] = new_piece.type # set type for board 
	
	# add to scene under CSGBox3D for correct transform
	var parent = components[slot_id]
	print("Name is " + parent.name)
	parent.add_child(new_piece)
	new_piece.global_position = parent.global_position
	

# remove piece at slot_id
func remove_piece(slot_id) : 
	var row = slot_id / 3
	var col = slot_id % 3
	board[row][col] = Piece.EMPTY
	var parent = components[slot_id].get_child(2)
	parent.remove_child(2)


# evalute computer board, return true if win and return false if not win
# update visuals to reflect state 
func evaluate_board () -> bool: 
	var is_win : bool = true
	
	var row
	var col
	for i in range(board.size()) : 
		for j in range(board[i].size()) :
			row = i / 3
			col = i % 3
			if board[row][col] == Piece.RED : 
				if RED_FLAG : 
					return false
	
	return is_win
