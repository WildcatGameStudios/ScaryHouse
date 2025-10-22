extends Node3D

class_name scarecrow

signal player_enter
signal player_left



# refrences 
@onready var eye_l: CSGBox3D = $eye_L
@onready var eye_r: CSGBox3D = $eye_R
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var eye_mat : StandardMaterial3D


func _ready() : 
	eye_mat = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.0,0.0,0.0,0.0)
	
	eye_l.material = eye_mat
	eye_r.material = eye_mat

func activate() : 
	eye_mat.albedo_color = Color(108.0 / 255, 0.0, 149.0 / 255)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(171.0 / 255, 129.0 /255, 1.0 )
	eye_mat.emission_energy_multiplier = 3
	animation_player.play("activate")
	

func deactivate () : 
	eye_mat.albedo_color = Color(0.0,0.0,0.0,0.0)
	eye_mat.emission_enabled = false
	animation_player.play('deactivate')


func _on_player_detect_body_entered(body: Node3D) -> void:
	if body.has_method("player") : 
		emit_signal("player_enter")


func _on_player_detect_body_exited(body: Node3D) -> void:
	if body.has_method("player") : 
		emit_signal("player_left")
