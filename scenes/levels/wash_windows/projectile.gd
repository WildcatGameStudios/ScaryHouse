extends CharacterBody3D
# --- Properties set by level.gd ---
var speed: float = 80.0
var damage: float = 10.0 # Cleanliness added (for water) or hit flag (for tranq)
var lifetime: float = 3.0
var type: String = "water" # "water" or "tranquilizer"
var direction: Vector3 = Vector3.ZERO

# --- Initialization ---
func _ready():
	# Set up a timer to destroy the projectile after its lifetime, 
	# in case it misses everything.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var timer = Timer.new()
	add_child(timer)
	timer.start(lifetime)
	timer.timeout.connect(queue_free)

func setup_movement(aim_vector: Vector3): # <--- NEW FUNCTION
	self.direction = aim_vector

func _physics_process(delta):
	# Move the projectile straight forward based on its forward direction
	# (The global_transform in level.gd sets the correct rotation)
	velocity = direction * speed
	
	# move_and_slide is used to detect collisions while moving
	var collision_info = move_and_slide()
	
	# Check for immediate collision with any physical object
	if collision_info:
		var collider = collision_info.get_collider()
		
		# We try to check if the hit object belongs to a Game_Window scene
		# We assume the window's Game_Window root is the great-grandparent of the collider
		if collider is CollisionShape3D and collider.get_parent() and collider.get_parent().get_parent() is Game_Window:
			# We successfully hit a Game_Window's Area3D collider
			var window_root = collider.get_parent().get_parent() as Game_Window
			
			# Pass the hit information to the window's script
			if type == "water":
				# Water only hits once per block for cleaning amount
				window_root.receive_water_hit(damage) 
			elif type == "tranquilizer":
				window_root.receive_tranquilizer_hit()
				
		# Always destroy the projectile on any impact to prevent shooting through objects
		queue_free() 
