extends Area3D

class_name Hitbox

var blacklist: Array[Hurtbox]
# the invariant must be upheld that collisions and sleeping_collisions are
# mutually exclusive.
var collisions: Array[Hurtbox]
var sleeping_collisions : Array[Hurtbox]
var to_remove: Array[Hurtbox]

var cooling_down: bool = false
var cooldown_timer: Timer

@export var cooldown: float = 1.0
@export var blacklist_type: Array[Hurtbox.HurtboxType]

## hit signal
## This signal is emitted when the hitbox detects hurtboxes within itself while
## not cooling down from a previous hit. See Hitbox._process for its usage.
## The origin of the collision is the vector mean of the positions of each
## colliding hurtbox.
signal hit(origin: Vector3, damage: int, knockback: float)

## cooldown_timeout
## This signal is emitted when the hitbox can be triggered again.
signal cooldown_timeout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cooldown_timer = $cooldown
	cooldown_timer.wait_time = cooldown

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	prune_collisions()
	check_sleeping_collisions()
	
	if not self.collisions.is_empty() and not cooling_down:
		var origin: Vector3 = Vector3.ZERO
		var damage: int = -1 # negative damage is invalid
		var knockback: float = -1.0 # negative knockback is invalid
		var to_swap: Array = []
		for c in collisions:
			damage = max(damage, c.hurt_damage)
			knockback = max(knockback, c.knockback)
			origin += c.global_position
			c.triggered = true
			# if it is a one shot, then remove 
			if c.one_shot : 
				to_swap.append(c)
		for c in to_swap:
			collisions.erase(c)
			sleeping_collisions.append(c)
			
		origin /= collisions.size()
		hit.emit(origin, damage, knockback)
		cooling_down = true
		cooldown_timer.start()
		
		
## prune_collisions
## This function is used in conjunction with check_sleeping_collisions to
## ensure that no elements are added to or removed from our collisions array
## while the arrays are being iterated through. It's a concurrency measure that
## may help minimize data races.
func prune_collisions() -> void:
	for area in to_remove:
		if self.collisions.has(area):
			self.collisions.erase(area)
			# the follosing should not generate an error, as it must've entered
			# first before exiting...
			area.tree_exiting.disconnect(_collision_exiting_tree)
		if self.sleeping_collisions.has(area) : 
			self.sleeping_collisions.erase(area)
			area.tree_exiting.disconnect(_collision_exiting_tree)
	to_remove.clear()

## add_blacklist
## This function adds a Hurtbox to the current blacklisted hurtboxes. A
## blacklisted hurtbox won't cause this hitbox to emit a signal upon contact.
func add_blacklist(target: Hurtbox) -> void:
	if not self.blacklist.has(target):
		self.blacklist.append(target)

## remove_blacklist
## This function removes a Hurtbox tofrom the blacklisted hurtboxes list. A
## blacklisted hurtbox won't cause this hitbox to register it upon contact.
func remove_blacklist(target: Hurtbox):
	if self.blacklist.has(target):
		self.blacklist.erase(target)

func _on_area_entered(area: Area3D) -> void:
	if is_instance_of(area, Hurtbox):
		if not self.collisions.has(area) and \
			not self.blacklist.has(area) and \
			not self.blacklist_type.has(area.type):
			if area.enabled:
				self.collisions.append(area)
				area.tree_exiting.connect(_collision_exiting_tree.bind(area))
			else:
				self.sleeping_collisions.append(area)
				area.tree_exiting.connect(_collision_exiting_tree.bind(area))

func check_sleeping_collisions():
	var to_swap: Array[Hurtbox]
	for c in sleeping_collisions:
		if c.enabled and not c.triggered:
			to_swap.append(c)
	for c in to_swap:
		collisions.append(c)
		sleeping_collisions.erase(c)

func _on_area_exited(area: Area3D) -> void:
	if is_instance_of(area, Hurtbox):
		self.to_remove.append(area)


func _on_cooldown_timeout() -> void:
	cooling_down = false
	emit_signal("cooldown_timeout")

func _collision_exiting_tree(c: Hurtbox) -> void:
	if blacklist.has(c):
		blacklist.erase(c)
	if collisions.has(c):
		collisions.erase(c)
	if sleeping_collisions.has(c):
		sleeping_collisions.erase(c)
