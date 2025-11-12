extends Control

@export var buttons: Array[Button]
var world: Node3D
var enabled: bool = false

func enable_menu():
	visible = true
	enabled = true
	for node in buttons:
		node.disabled = false
func disable_menu():
	visible = false
	enabled = false
	for node in buttons:
		node.disabled = true

func toggle():
	if enabled:
		disable_menu()
	else:
		enable_menu()

func main_menu():
	var menu = load("res://scenes/general/main_menu.tscn")
	get_tree().change_scene_to_packed(menu)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	disable_menu()
	world = get_tree().get_nodes_in_group("world")[0]
	$"VBoxContainer/Main Menu".pressed.connect(main_menu)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle()
