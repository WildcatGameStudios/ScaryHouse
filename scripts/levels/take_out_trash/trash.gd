extends CharacterBody3D
class_name Trash

#emitted when enters right bin or despawns
#connected in level script for penalties / score increment
signal despawn(in_bin: bool)

@export_enum("TRASH","RECYCLE") var trash_type: int
#@export var timer: Timer

var gravity: Vector3 = Vector3(0,-3,0)

#do stuff when it goes in the trash
func in_trash(area: Area3D):
	#exit if area doesn't have a parent
	if area.get_parent() == null:
		return
	#exit if area is not a trash or recycling bin
	if !(area.get_parent() is TrashBin):
		return
	
	#check if it's the right bin and do stuff if so
	if area.get_parent().trash_type == trash_type:
		despawn.emit(true)
		self.queue_free()

func _ready() -> void:
	$Area3D.area_entered.connect(in_trash)

func _physics_process(delta: float) -> void:
	if move_and_slide():
		despawn.emit(false)
		self.queue_free()
	velocity += gravity * delta
