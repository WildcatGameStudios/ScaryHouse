extends Node3D

@onready var player: player = $player
var orig_walk_speed: int
var orig_run_speed: int
var speed_effect: float = .2 # higher means holding items affects speed more
@onready var items: Node = $items
@onready var plants: Node = $plants
@onready var ray_cast_3d: RayCast3D = $player/head/Camera3D/RayCast3D
@onready var finish_timer = 180 # time to end level in seconds
var finished = false

func _ready() -> void:
	orig_walk_speed = player.walk_speed
	orig_run_speed = player.run_speed

func _process(delta: float) -> void:
	if not finished:
		if finish_timer <= 0:
			plants.queue_free()
			finished = true
		finish_timer -= delta
		if Input.is_action_just_pressed("e"):
			var collider = ray_cast_3d.get_collider()
			if player.head.get_child(3).get_children().size() < 4 and collider in items.get_children(): # if player looking at item
				collider.use_collision = false # turn collision off for item
				items.remove_child(collider) # remove from items to place in player's hand
				player.head.get_child(3).add_child(collider)
				collider.position = Vector3(-.5 * player.head.get_child(3).get_children().size() + .6,0,0) # slide held items
				player.walk_speed = orig_walk_speed / (player.head.get_child(3).get_children().size() * speed_effect + 1)
				player.run_speed = orig_run_speed / (player.head.get_child(3).get_children().size() * speed_effect + 1)
			elif collider and collider.get_parent() in plants.get_children(): # if player looking at plant
				var found = false
				for i in player.head.get_child(3).get_children(): # for each held item
					if found:
						i.position.x += .5 # move down all items above
					elif collider.get_parent().needs.back() == i.get_meta("item_type"): # if plant top need is an item the player is holding
						collider.get_parent().remove_need() # remove from player's hand to add to items
						player.head.get_child(3).remove_child(i)
						items.add_child(i)
						match i.get_meta("item_type"): # position to return to
							0: # water
								i.position = Vector3(-.9,.8,int(i.name) * .5)
							1: # flies
								i.position = Vector3(-.3,.65,int(i.name) * .5)
							2: # light
								i.position = Vector3(.3,.79,int(i.name) * .5)
							3: # fertilizer
								i.position = Vector3(.9,.7,int(i.name) * .5)
						i.use_collision = true
						found = true
						player.walk_speed = orig_walk_speed / (player.head.get_child(3).get_children().size() * speed_effect + 1)
						player.run_speed = orig_run_speed / (player.head.get_child(3).get_children().size() * speed_effect + 1)
