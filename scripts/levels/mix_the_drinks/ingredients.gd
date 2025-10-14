extends Node3D
class_name TargetScene
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var hidden = false

enum ingredient_type {
	EMPTY,
	BLUEBERRY,
	CANDYCORN,
	CREEPY,
	GHOULISH,
	MOON,
	PHANTOM,
	PUMPKIN,
	TWILIGHT,
	VAMPIRIC,
	WRETCHED
	}
	
@export var type : ingredient_type = ingredient_type.EMPTY
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("ingredients")

func set_piece () -> void : 
	var new_mat = StandardMaterial3D.new()
	
	match (type) :
		ingredient_type.EMPTY : 
			new_mat.albedo_color = Color(0,0,0)
		ingredient_type.BLUEBERRY : 
			new_mat.albedo_color = Color(70.0/255.0, 130.0/255.0, 200.0/255.0)  # Blue
		ingredient_type.CANDYCORN : 
			new_mat.albedo_color = Color(255.0/255.0, 195.0/255.0, 80.0/255.0)  # Yellow-orange
		ingredient_type.CREEPY : 
			new_mat.albedo_color = Color(200.0/255.0, 160.0/255.0, 120.0/255.0)  # Caramel
		ingredient_type.GHOULISH : 
			new_mat.albedo_color = Color(210.0/255.0, 180.0/255.0, 140.0/255.0)  # Ginger root color
		ingredient_type.MOON : 
			new_mat.albedo_color = Color(255.0/255.0, 255.0/255.0, 200.0/255.0)  # Pale yellow
		ingredient_type.PHANTOM : 
			new_mat.albedo_color = Color(255.0/255.0, 218.0/255.0, 185.0/255.0)  # Peach
		ingredient_type.PUMPKIN : 
			new_mat.albedo_color = Color(255.0/255.0, 165.0/255.0, 0.0)  # Orange
		ingredient_type.TWILIGHT : 
			new_mat.albedo_color = Color(200.0/255.0, 180.0/255.0, 230.0/255.0)  # Pale purple
		ingredient_type.VAMPIRIC : 
			new_mat.albedo_color = Color(139.0/255.0, 0.0, 0.0)  # Dark red
		ingredient_type.WRETCHED : 
			new_mat.albedo_color = Color(180.0/255.0, 190.0/255.0, 140.0/255.0)  # Pale olive green
	
	mesh_instance.set_surface_override_material(0, new_mat)
	
	
func pick_up() -> void:
	hidden = true
	
func hide_component() -> void : 
	hidden = true
	mesh_instance.visible = false

func unhide_component() -> void : 
	hidden = false
	mesh_instance.visible = true
