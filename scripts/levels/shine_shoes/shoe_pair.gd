extends Node3D

@onready var right_shoe = $Right
@onready var left_shoe = $Left

@onready var animation_player = $AnimationPlayer

@export var shoe_material: Material

# Called when the node enters the scene tree for the first time.
func _ready():
	right_shoe.material = shoe_material
	left_shoe.material = shoe_material


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	animation_player.play("marching")
