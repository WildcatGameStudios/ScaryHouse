extends Node3D
@export var water_clean_amount: float = 10.0
@export var min_cooldown: float = 1.0
@export var max_cooldown: float = 4.0
@onready var gun_ray_cast: RayCast3D = $player/Gun_RayCast

# NEW ONREADYS: Visual guns and spawn point (Must match level.tscn structure!)
@onready var water_gun_visual: MeshInstance3D = $player/Hand_Pivot/Water_Gun 
@onready var tranquilizer_gun_visual: MeshInstance3D = $player/Hand_Pivot/Tranquilizer_Gun
@onready var gun_muzzle: Node3D = $player/Hand_Pivot/Gun_Muzzle
# END NEW ONREADYS

const PROJECTILE_SCENE = preload("res://scenes/levels/wash_windows/projectile.tscn")

var active_windows: Array[Node] = []
var all_windows: Array[Node] = []
var window_cooldown_timer: float = 0.0
var current_tool: String = "water" 

func _ready():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # FIX: Capture mouse focus
	
		for child in get_children():
			if child is Node3D and child.name.begins_with("Window_"):
				all_windows.append(child)
			
				child.window_cleaned.connect(_on_window_cleaned)
				child.monster_spotted.connect(_on_monster_spotted)
				child.window_hit.connect(_on_window_broken)
			
	# NEW: Initialize the visible gun
		switch_tool(current_tool)
		start_new_round()

# --------------------------------------------------------------------------------------
# INPUT AND SHOOTING
# --------------------------------------------------------------------------------------

func _input(event):
	# Tool Switch using MOUSE BUTTONS for visual swapping
	# NOTE: These actions need to be assigned in Input Map!
	if Input.is_action_just_pressed("fire_water"):
		if current_tool != "water":
			switch_tool("water")
			# If the user clicks water button while holding water gun, fire immediately
		else:
			handle_shot("water")
			
	if Input.is_action_just_pressed("fire_tranquilizer"):
		if current_tool != "tranquilizer":
			switch_tool("tranquilizer")
		else:
			handle_shot("tranquilizer")
			
func switch_tool(tool: String):
	# Toggles the visual guns
		current_tool = tool
		water_gun_visual.visible = (tool == "water")
		tranquilizer_gun_visual.visible = (tool == "tranquilizer")

func handle_shot(tool: String):
	# --- FIND THE AIMING VECTOR ---
	var start_point: Vector3 = gun_muzzle.global_transform.origin
	var target_point: Vector3
	
	# Check if the raycast hit something
	if gun_ray_cast.is_colliding():
		target_point = gun_ray_cast.get_collision_point()
	else:
		# If the raycast misses, project a target point far away 
		# (This is the end point of the RayCast in world space)
		target_point = gun_ray_cast.to_global(gun_ray_cast.target_position)

	# Calculate the normalized direction from the muzzle to the target point
	var shoot_direction: Vector3 = (target_point - start_point).normalized()
	
	# ---------------------------------
	
	# 1. Spawn the projectile instance
	var projectile = PROJECTILE_SCENE.instantiate()
	get_parent().add_child(projectile) 
	
	# 2. Set position and initial rotation based on the calculated direction
	projectile.global_transform.origin = start_point
	
	# LookAt() rotates the projectile to face the target point
	projectile.look_at(target_point, Vector3.UP, true) 
	# 3. Configure the projectile (color and type)
	var mesh = projectile.get_node("Mesh") as MeshInstance3D
	var material = mesh.get_material_override() as StandardMaterial3D
	
	if tool == "water":
		projectile.type = "water"
		projectile.damage = water_clean_amount * 5 
		if material:
			material.albedo_color = Color.BLUE
	elif tool == "tranquilizer":
		projectile.type = "tranquilizer"
		if material:
			material.albedo_color = Color.YELLOW


func _physics_process(delta):
	# Only keep the window cycling logic here. Shooting is now in _input.
	if window_cooldown_timer > 0:
		window_cooldown_timer -= delta
	else: 
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
	
