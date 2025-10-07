extends Node3D
@export var water_clean_amount: float = 10.0 # How much cleanliness is gained per second of water contact
@export var min_cooldown: float = 1.0
@export var max_cooldown: float = 4.0
@onready var gun_ray_cast: RayCast3D = $player/Gun_RayCast

var active_windows: Array[Node] = []
var all_windows: Array[Node] = []
var active_shots: Array[String] = [] # Tracks raycasts hitting windows
var window_cooldown_timer: float = 0.0


func _ready():
	# Gather all windows
	for child in get_children():
		# Using the "Window_" prefix to find all instantiated scenes
		if child is Node3D and child.name.begins_with("Window_"):
			all_windows.append(child)
			
			# Connect signals for game flow
			child.window_cleaned.connect(_on_window_cleaned)
			child.monster_spotted.connect(_on_monster_spotted)
			child.window_hit.connect(_on_window_broken)
			
	# Start the game flow
	start_new_round()

# This simulates water/tranquilizer shots hitting a window
func simulate_hit(window_node: Node3D, tool: String):
	var window_script: Game_Window = window_node # <-- UPDATED CAST

	if tool == "water":
		window_script.receive_water_hit(water_clean_amount)
	elif tool == "tranquilizer":
		window_script.receive_tranquilizer_hit()

func _input(event):
	# Check for instant-fire tranquilizer shot (single press)
	if event.is_action_just_pressed("fire_tranquilizer"):
		handle_shot("tranquilizer")
	
func handle_shot(tool: String):
	# This handles single-fire tools (like the tranquilizer gun)
	if gun_ray_cast.is_colliding():
		var hit_object = gun_ray_cast.get_collider()
		
		# Check if the hit object is a CollisionShape3D belonging to a Game_Window
		var collider_node = hit_object as CollisionShape3D
		if collider_node and collider_node.get_parent() and collider_node.get_parent().get_parent() is Game_Window:
			var window_root: Game_Window = collider_node.get_parent().get_parent()
			
			if tool == "tranquilizer":
				window_root.receive_tranquilizer_hit()

func _physics_process(delta):
# --- Continuous Water Spray Logic ---
	if Input.is_action_pressed("fire_water"):
		var hit_object = gun_ray_cast.get_collider()
	
		if hit_object:
		# We assume the window's Area3D is the grandparent of the CollisionShape3D
			var collider_node = hit_object as CollisionShape3D
			if collider_node and collider_node.get_parent() and collider_node.get_parent().get_parent() is Game_Window:
				var window_root: Game_Window = collider_node.get_parent().get_parent()
			
			# 1. Clean window if it's open for cleaning
				if window_root.current_state == Game_Window.State.OPEN_CLEAN:
					window_root.receive_water_hit(water_clean_amount * delta)
			
			# 2. Trigger monster attack if player sprays monster
				elif window_root.current_state == Game_Window.State.OPEN_MONSTER:
				# Hitting monster with water causes immediate attack (as per level description)
					window_root.receive_water_hit(water_clean_amount * delta) 

# Cooldown for opening/closing windows (Keep existing logic)
	if window_cooldown_timer > 0:
		window_cooldown_timer -= delta
	if window_cooldown_timer <= 0:
		handle_window_cycle()

func start_new_round():
	# Find two dirty, non-active windows to start the game
	for window in all_windows:
		var window_script: Game_Window = window # <-- UPDATED CAST
		if not window_script.is_clean and not window_script.is_active:
			active_windows.append(window)
			window_script.is_active = true
			if active_windows.size() == 2:
				break
				
	# Initial activation of the windows
	for window in active_windows:
		(window as Game_Window).activate_window() # <-- UPDATED CAST
		
	set_next_cooldown()

func handle_window_cycle():
	# Find an active window and randomly cycle its state (open/closed)
	if active_windows.is_empty():
		print("LEVEL CLEARED! 🥳")
		return

	# Pick a random active window to close and another to open
	var window_to_close = active_windows[randi() % active_windows.size()]
	(window_to_close as Game_Window).close_shutters() # <-- UPDATED CAST
	
	var window_to_open = active_windows[randi() % active_windows.size()]
	(window_to_open as Game_Window).activate_window() # <-- UPDATED CAST
	
	set_next_cooldown()

func set_next_cooldown():
	# Adjust cooldown based on game difficulty
	var cleaned_count = all_windows.filter(func(w): return (w as Game_Window).is_clean).size() # <-- UPDATED CAST
	var speedup_factor = float(cleaned_count) / float(all_windows.size()) * 0.5 
	
	var current_max = max_cooldown - (max_cooldown * speedup_factor)
	var current_min = min_cooldown - (min_cooldown * speedup_factor)
	
	window_cooldown_timer = randf_range(current_min, current_max)
	print("Next window cycle in: ", window_cooldown_timer, "s")


func _on_window_cleaned(window: Node3D):
	active_windows.erase(window)
	print(window.name, " is CLEAN! 🧼")
	
	# Bring in a new window for the cycle
	var new_window_found = false
	for w in all_windows:
		var w_script: Game_Window = w # <-- UPDATED CAST
		if not w_script.is_clean and not w_script.is_active:
			active_windows.append(w)
			w_script.is_active = true
			w_script.activate_window()
			new_window_found = true
			break
			
	if not new_window_found and active_windows.is_empty():
		print("LEVEL CLEARED! 🍾")

func _on_monster_spotted(window: Node3D):
	print(window.name, " MONSTER SPOTTED! Prepare tranquilizer. ⚠️")
	
	var monster_scene = preload("res://scenes/levels/wash_windows/monster.tscn")
	var monster = monster_scene.instantiate()
	
	# Attach to the monster spawn point and set the monster instance
	window.monster_spawn.add_child(monster)
	(window as Game_Window).monster_instance = monster
	
	# Connect the monster's attack signal
	monster.attack_player.connect(_on_monster_attacks.bind(window))

func _on_monster_attacks(window: Node3D):
	print("PLAYER HIT! Damage Dealt. 💥")
	(window as Game_Window).close_shutters()

func _on_window_broken(window: Node3D):
	print(window.name, " BROKEN! A Large Amount of Money Has Been Deducted. - 💸")
	
	# Treat as finished to stop it from being recycled
	(window as Game_Window).is_clean = true
	active_windows.erase(window)
	
