extends Node3D

enum ingredient_type {
	EMPTY,
	BLUEBERRY,
	CANDYCORN,
	CREEPY,
	GHOULISH,
	MOON,
	PHANTOM,
	PUMPKIN,
	TWILIGHT,
	VAMPIRIC,
	WRETCHED,
	#now for the mixed drinks
	PUMPKIN_GHOULISH,
	PHANTOM_MOON,
	CANDYCORN_WRETCHED,
	VAMPIRIC_CREEPY,
	BLUEBERRY_TWILIGHT,
	PUMPKIN_PHANTOM,
	GHOULISH_MOON,
	CANDYCORN_VAMPIRIC,
	CREEPY_WRETCHED,
	BLUEBERRY_PHANTOM,
	TWILIGHT_MELON,
	PUMPKIN_CREEPY,
	GHOULISH_VAMPIRIC,
	CANDYCORN_BLUEBERRY,
	WRETCHED_TWILIGHT
}

# Scene variables to keep track of
var ingredients
var current_collider: TargetScene = null
var bottle_mixer  # Reference to the bottle mixer

const INGREDIENTS = preload("res://scenes/levels/mix_the_drinks/ingredients.tscn")

@onready var ingredients_container: Node3D = $BarGrey/Ingredients
@onready var player: player = $StartPos/player
@onready var ray_cast: RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the raycast from within the player scene instance
	ray_cast = player.get_node("head/Camera3D/RayCast3D")
	
	if ray_cast == null:
		print("ERROR: RayCast3D node not found in player scene!")
		return
	
	# Get reference to the bottle mixer
	bottle_mixer = $BarGrey/Bottle
	if bottle_mixer == null:
		print("ERROR: Bottle mixer not found!")
	else:
		print("Bottle mixer found: ", bottle_mixer.name)
	
	ingredients = ingredients_container.get_children()
	for i in ingredients:
		i.set_piece()

func get_target_scene_from_collider(collider) -> TargetScene:
	# If the collider itself is a TargetScene, return it
	if collider is TargetScene:
		return collider
	
	# Otherwise, check the collider's parents
	var parent = collider.get_parent()
	while parent != null:
		if parent is TargetScene:
			return parent
		parent = parent.get_parent()
	
	return null

# NEW FUNCTION: Check if collider is part of the bottle
func is_bottle_collider(collider) -> bool:
	# Check if collider is the bottle itself or any of its children
	var node = collider
	while node != null:
		if node == bottle_mixer:
			return true
		node = node.get_parent()
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Check if ray_cast is valid before using it
	if ray_cast == null:
		return
	
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		
		# Check if we're looking at the bottle mixer OR any of its children
		if is_bottle_collider(collider):
			#print("Looking at bottle mixer!")
			
			if Input.is_action_just_pressed("select"):
				interact_with_bottle()
		
		# Check if we're looking at an ingredient
		else:
			var target_scene = get_target_scene_from_collider(collider)
			
			if target_scene and target_scene.is_in_group("ingredients"):
				current_collider = target_scene
				#print('Hit ingredient: ', target_scene.type)
				
				if Input.is_action_just_pressed("select"):
					pickup_handler(target_scene)
	else:
		current_collider = null

func interact_with_bottle():
	# Check if player is holding an ingredient using get_hand_object()
	var hand_ingredient = player.get_hand_object(1)
	
	if hand_ingredient != null:
		# Get the ingredient type before removing it
		var ingredient_type_value = hand_ingredient.type
		
		# Remove the ingredient from player's hand
		var removed_ingredient = player.remove_hand_object(1)
		
		if removed_ingredient != null:
			# Add ingredient to bottle
			bottle_mixer.add_ingredient(ingredient_type_value)
			
			# Free the hand object since we don't need it anymore
			removed_ingredient.queue_free()
			
			#print("Added ingredient to bottle: ", ingredient_type.keys()[ingredient_type_value])
			
			# Check if bottle is full (has 2 ingredients)
			if bottle_mixer.is_full():
				# Mix the drink and handle the result
				handle_drink_mixing()
	else:
		print("No ingredient in hand to add to bottle")

func handle_drink_mixing():
	# Get the mixing result from the bottle
	var mixed_result = bottle_mixer.mix_drink()
	
	# Reappear all hidden ingredients
	for ingredient in ingredients:
		if ingredient.hidden:
			ingredient.unhide_component()
	
	# Clear the bottle
	bottle_mixer.clear_bottle()
	
	# Check what type we got back
	if mixed_result is Dictionary:
		# New system - Dictionary return
		if mixed_result.get("success", false):
			#print("Drink: ", mixed_result.get("recipe_name", ""))
			#print("Color: ", mixed_result.get("color", Color.GRAY))
			
			# Create the mixed bottle
			create_mixed_bottle(mixed_result)
		else:
			print("FAILED: ", mixed_result.get("description", "No valid recipe"))
			# Create a failed mixture bottle
			create_failed_mixture(mixed_result)
	else:
		# Old system - Integer return (fallback)
		print("Mixed drink created (basic): ", ingredient_type.keys()[mixed_result])
		# Create a basic mixed bottle
		create_basic_mixed_bottle(mixed_result)
		
func create_basic_mixed_bottle(drink_type: int):
	print("Creating basic mixed bottle: ", ingredient_type.keys()[drink_type])
	# Fallback implementation for basic bottles
	# const MIXED_BOTTLE = preload("res://path/to/mixed_bottle.tscn")
	# var mixed_bottle = MIXED_BOTTLE.instantiate()
	# mixed_bottle.drink_type = drink_type
	# player.add_hand_object(mixed_bottle, 1, Vector3(1.0, 1.0, 1.0))
	
func create_mixed_bottle(mix_result: Dictionary):
	print("Creating successful bottle: ", mix_result.recipe_name)
	# TODO: Implement mixed bottle creation
	# const MIXED_BOTTLE = preload("res://path/to/mixed_bottle.tscn")
	# var mixed_bottle = MIXED_BOTTLE.instantiate()
	# mixed_bottle.set_drink_properties(mix_result)
	# player.add_hand_object(mixed_bottle, 1, Vector3(1.0, 1.0, 1.0))

func create_failed_mixture(mix_result: Dictionary):
	print("Creating failed mixture")
	# TODO: Implement failed bottle creation
	# const FAILED_BOTTLE = preload("res://path/to/failed_bottle.tscn")
	# var failed_bottle = FAILED_BOTTLE.instantiate()
	# failed_bottle.set_drink_properties(mix_result)
	# player.add_hand_object(failed_bottle, 1, Vector3(1.0, 1.0, 1.0))

func pickup_handler(collider: TargetScene):
	var hand_ingredient = player.get_hand_object(1)
	if hand_ingredient == null:
		# Find which ingredient in the array was hit
		var ingredient_index = ingredients.find(collider)
		if ingredient_index != -1:
			# Hide the original piece
			ingredients[ingredient_index].hide_component()
			
			# Create new component and get type of component
			var selected_piece = INGREDIENTS.instantiate()
			selected_piece.type = ingredients[ingredient_index].type
			
			# Remove collision shapes completely
			remove_all_collision(selected_piece)
			
			# Add to player's hand
			player.add_hand_object(selected_piece, 1, Vector3(1.0, 1.0, 1.0))
			
			# Set up the visual appearance
			selected_piece.set_piece()
			
			print("Picked up: ", ingredient_type.keys()[collider.type])

func remove_all_collision(ingredient: TargetScene):
	# Remove all collision shapes
	var collision_shapes = ingredient.find_children("*", "CollisionShape3D", true)
	for collision_shape in collision_shapes:
		collision_shape.queue_free()
	
	# Also remove any collision polygons
	var collision_polygons = ingredient.find_children("*", "CollisionPolygon3D", true)
	for collision_polygon in collision_polygons:
		collision_polygon.queue_free()
