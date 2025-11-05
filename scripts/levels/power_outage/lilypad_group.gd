extends Node3D


func _ready():
	for pad in get_tree().get_nodes_in_group("lilypads"):
		var anim_player = pad.get_node("AnimatableBody3D/AnimationPlayer")
		if pad == $lilypad5 or pad == $lilypad3 or pad == $lilypad6:
			anim_player.play("Circle")
			anim_player.seek(randf() * anim_player.current_animation_length)
		else:
			anim_player.play("Float")
			anim_player.seek(randf() * anim_player.current_animation_length)
		
