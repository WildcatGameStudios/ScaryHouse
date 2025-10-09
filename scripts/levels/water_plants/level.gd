extends Node3D

@onready var player: player = $player
@onready var items: Node = $items
var pick_up_ray: RayCast3D = RayCast3D.new()
var seeing: CSGSphere3D = CSGSphere3D.new()

func _ready() -> void:
	player.camera_3d.add_child(pick_up_ray)
	pick_up_ray.target_position = Vector3(0,0,-3)
	pick_up_ray.global_position = player.camera_3d.global_position
	player.camera_3d.add_child(seeing)
	seeing.radius = .01
	seeing.position.z = -1
	seeing.visible = false

func _process(delta: float) -> void:
	var coll = pick_up_ray.get_collider()
	if coll in  items.get_children():
		seeing.visible = true
		if Input.is_action_just_pressed("e"):
			coll.use_collision = false
			items.remove_child(coll)
			player.add_hand_object(coll)
			coll.position = Vector3(0,.2,0)
	else:
		seeing.visible = false
