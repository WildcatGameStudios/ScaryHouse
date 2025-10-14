extends CharacterBody3D
class_name Trash

#emitted when enters right bin or collideds
#connected in level script for penalties / score increment and bin movement speed
signal collided(in_bin: bool)

@export_enum("TRASH","RECYCLE") var trash_type: int
@export var gravity_strength: float = 9

var gravity: Vector3 = Vector3(0,-gravity_strength,0)

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
		collided.emit(true)
		gravity = Vector3.ZERO
		velocity = Vector3(0,30,0)
		$HitBinParticles.emitting = true
		$CollisionShape3D.disabled = true
		$Area3D/CollisionShape3D.disabled = true
		await get_tree().create_timer(1.5).timeout
		self.queue_free()

func _ready() -> void:
	$Area3D.area_entered.connect(in_trash)

func _physics_process(delta: float) -> void:
	#when colliding and not hitting a bin
	if move_and_slide():
		collided.emit(false)
		$HitWallParticles.emitting = true
		$CollisionShape3D.disabled = true
		$Area3D/CollisionShape3D.disabled = true
		$MeshInstance3D.visible = false
		await get_tree().create_timer(0.5).timeout
		self.queue_free()
	velocity += gravity * delta
