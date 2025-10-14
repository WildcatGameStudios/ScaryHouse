# BottleMixer.gd
extends Node3D

class_name Bottle_Mixer

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
	# mixed drinks
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

var ingredients: Array = []  # Store ingredient types that have been added
var drink_recipes: Array = []

func _ready():
	initialize_recipes()

func initialize_recipes():
	# stores: [ingredient1, ingredient2, result_drink]
	drink_recipes = [
		[ingredient_type.PUMPKIN, ingredient_type.GHOULISH, ingredient_type.PUMPKIN_GHOULISH],
		[ingredient_type.PHANTOM, ingredient_type.MOON, ingredient_type.PHANTOM_MOON],
		[ingredient_type.CANDYCORN, ingredient_type.WRETCHED, ingredient_type.CANDYCORN_WRETCHED],
		[ingredient_type.VAMPIRIC, ingredient_type.CREEPY, ingredient_type.VAMPIRIC_CREEPY],
		[ingredient_type.BLUEBERRY, ingredient_type.TWILIGHT, ingredient_type.BLUEBERRY_TWILIGHT],
		[ingredient_type.PUMPKIN, ingredient_type.PHANTOM, ingredient_type.PUMPKIN_PHANTOM],
		[ingredient_type.GHOULISH, ingredient_type.MOON, ingredient_type.GHOULISH_MOON],
		[ingredient_type.CANDYCORN, ingredient_type.VAMPIRIC, ingredient_type.CANDYCORN_VAMPIRIC],
		[ingredient_type.CREEPY, ingredient_type.WRETCHED, ingredient_type.CREEPY_WRETCHED],
		[ingredient_type.BLUEBERRY, ingredient_type.PHANTOM, ingredient_type.BLUEBERRY_PHANTOM],
		[ingredient_type.TWILIGHT, ingredient_type.MOON, ingredient_type.TWILIGHT_MELON],
		[ingredient_type.PUMPKIN, ingredient_type.CREEPY, ingredient_type.PUMPKIN_CREEPY],
		[ingredient_type.GHOULISH, ingredient_type.VAMPIRIC, ingredient_type.GHOULISH_VAMPIRIC],
		[ingredient_type.CANDYCORN, ingredient_type.BLUEBERRY, ingredient_type.CANDYCORN_BLUEBERRY],
		[ingredient_type.WRETCHED, ingredient_type.TWILIGHT, ingredient_type.WRETCHED_TWILIGHT]
	]

func add_ingredient(ingredient_type_value: int):
	if ingredients.size() < 2:
		ingredients.append(ingredient_type_value)
		print("Bottle now contains: ", get_ingredient_names())
	else:
		print("Bottle is already full!")

func is_full() -> bool:
	return ingredients.size() >= 2

func mix_drink() -> Dictionary:
	var result = {
		"success": false,
		"drink_type": ingredient_type.EMPTY,
		"recipe_name": "Failed Mixture",
		"description": "An unsuccessful combination of ingredients",
		"color": Color.GRAY,
		"ingredient1": -1,
		"ingredient2": -1
	}
	
	# Store the actual ingredients used
	result.ingredient1 = ingredients[0]
	result.ingredient2 = ingredients[1]
	
	# Check both possible orders of ingredients
	var found_recipe = find_recipe(ingredients[0], ingredients[1])
	if not found_recipe:
		found_recipe = find_recipe(ingredients[1], ingredients[0])
	
	if found_recipe:
		result.success = true
		result.drink_type = found_recipe[2]  # result_drink
		result.recipe_name = get_recipe_name(found_recipe[2])
		result.color = get_mixed_drink_color(found_recipe[2])
	return result

func find_recipe(ingredient1: int, ingredient2: int) -> Array:
	for recipe in drink_recipes:
		if recipe[0] == ingredient1 and recipe[1] == ingredient2:
			return recipe
	return []

func get_recipe_name(drink_type: int) -> String:
	# Convert the enum value to a readable name
	var base_name = ingredient_type.keys()[drink_type]
	# Replace underscores with spaces and add "Potion" or "Brew"
	return base_name.replace("_", " ") + " Drink"

func get_mixed_drink_color(drink_type: int) -> Color:
	# Define colors for mixed drinks using the same format as your ingredient script
	match drink_type:
		ingredient_type.PUMPKIN_GHOULISH:
			return Color(220.0/255.0, 150.0/255.0, 90.0/255.0)   # Spooky orange-brown
		ingredient_type.PHANTOM_MOON:
			return Color(225.0/255.0, 225.0/255.0, 240.0/255.0)  # Ghostly pale blue-white
		ingredient_type.CANDYCORN_WRETCHED:
			return Color(210.0/255.0, 170.0/255.0, 110.0/255.0)  # Muted candy corn
		ingredient_type.VAMPIRIC_CREEPY:
			return Color(120.0/255.0, 30.0/255.0, 30.0/255.0)    # Deep blood red
		ingredient_type.BLUEBERRY_TWILIGHT:
			return Color(100.0/255.0, 80.0/255.0, 180.0/255.0)   # Deep twilight blue
		ingredient_type.PUMPKIN_PHANTOM:
			return Color(255.0/255.0, 200.0/255.0, 150.0/255.0)  # Soft peach-orange
		ingredient_type.GHOULISH_MOON:
			return Color(200.0/255.0, 190.0/255.0, 170.0/255.0)  # Pale ghastly beige
		ingredient_type.CANDYCORN_VAMPIRIC:
			return Color(200.0/255.0, 100.0/255.0, 80.0/255.0)   # Red-orange candy
		ingredient_type.CREEPY_WRETCHED:
			return Color(140.0/255.0, 130.0/255.0, 100.0/255.0)  # Muddy olive
		ingredient_type.BLUEBERRY_PHANTOM:
			return Color(150.0/255.0, 150.0/255.0, 220.0/255.0)  # Soft blue-lavender
		ingredient_type.TWILIGHT_MELON:
			return Color(180.0/255.0, 160.0/255.0, 210.0/255.0)  # Muted twilight purple
		ingredient_type.PUMPKIN_CREEPY:
			return Color(220.0/255.0, 140.0/255.0, 80.0/255.0)   # Dark pumpkin orange
		ingredient_type.GHOULISH_VAMPIRIC:
			return Color(160.0/255.0, 80.0/255.0, 70.0/255.0)    # Bloody brown-red
		ingredient_type.CANDYCORN_BLUEBERRY:
			return Color(150.0/255.0, 140.0/255.0, 200.0/255.0)  # Purple-blue candy
		ingredient_type.WRETCHED_TWILIGHT:
			return Color(130.0/255.0, 120.0/255.0, 150.0/255.0)  # Dark murky purple
		_:
			return Color.GRAY


func get_ingredient_names() -> Array:
	var names = []
	for ingredient in ingredients:
		names.append(ingredient_type.keys()[ingredient])
	return names

func clear_bottle():
	ingredients.clear()
	print("Bottle cleared")
