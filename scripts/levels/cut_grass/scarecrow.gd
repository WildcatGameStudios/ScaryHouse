extends Node3D

class_name scarecrow

signal player_enter
signal player_left



# refrences 
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_3d: CollisionShape3D = $player_detect/CollisionShape3D



func _ready() : 
	# set our shape to a unique instance 
	var coll_shape = collision_shape_3d.shape.duplicate()
	self.collision_shape_3d.shape = coll_shape

func activate() : 
	print(name , " actiavting")
	animation_player.play("activate")
	

func deactivate () : 
	animation_player.play('deactivate')


func _on_player_detect_body_entered(body: Node3D) -> void:
	if body.has_method("player") : 
		emit_signal("player_enter")


func _on_player_detect_body_exited(body: Node3D) -> void:
	if body.has_method("player") : 
		emit_signal("player_left")
