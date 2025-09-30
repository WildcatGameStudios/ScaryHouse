extends Node3D

@onready var csg_cylinder_3d: CSGCylinder3D = $CSGCylinder3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


enum Piece {
	EMPTY, 
	RED, 
	BLUE, 
	GREEN,
	PURPLE,
}

@export var type : Piece = Piece.EMPTY

var hidden = false

func _ready() -> void : 
	pass

func toggle_hover_anim(toggle : bool) -> void : 
	if toggle : 
		animation_player.play("bounce")
	else : 
		animation_player.play("RESET")

func set_piece () -> void : 
	var new_mat = StandardMaterial3D.new()
	
	match (type) :
		Piece.EMPTY : 
			new_mat.albedo_color = Color(0,0,0)
		Piece.RED : 
			new_mat.albedo_color = Color(231.0/255.0,92.0/255.0,81.0/255.0)
		Piece.GREEN : 
			new_mat.albedo_color = Color(78.0/255.0,165.0/255.0,96.0/255.0)
		Piece.BLUE : 
			new_mat.albedo_color = Color(36.0/255.0,154.0/255.0,255.0/255.0)
		Piece.PURPLE : 
			new_mat.albedo_color = Color(143.0/255.0,127.0/255.0,221.0/255.0)
	
	csg_cylinder_3d.material = new_mat
	

func hide_component() -> void : 
	hidden = true
	csg_cylinder_3d.visible = false

func unhide_component() -> void : 
	hidden = false
	csg_cylinder_3d.visible = true
