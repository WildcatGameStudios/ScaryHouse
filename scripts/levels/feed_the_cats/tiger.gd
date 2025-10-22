extends CharacterBody3D

@export var walk_speed : float = 10

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

var current_path : Path3D
