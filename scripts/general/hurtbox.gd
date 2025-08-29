extends Area3D

class_name Hurtbox

enum HurtboxType {
	Player,
	Enemy,
	Environment
}

## The damage this hurtbox deals to its target.
@export var hurt_damage: int = 1
## The knockback this hurtbox deals to its target.
@export var knockback: float = 100.0
## What kind of damage this hurtbox deals. There are three types:
## - Environment: e.g. lava, spikes, or killzone
## - Enemy: e.g. zombie, enemy trap, or enemy projectile
## - Player: e.g. melee, player bomb, or player projectile
@export var type: HurtboxType = HurtboxType.Environment
## Activation of hurtbox.
@export var enabled: bool = true:
	get(): return enabled
	set(v):
		if v:
			triggered = false
		enabled = v
## Whether this hurtbox deals continuous damage or only triggers damage once
## upon entering a hitbox.
@export var one_shot : bool = false

# internal variable used by hitbox to deactivate one_shots after hitting
var triggered: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# TODO: hurtboxes should have extended functionality: cooldowns of their own,
# animations of their shape/functionality, etc.
