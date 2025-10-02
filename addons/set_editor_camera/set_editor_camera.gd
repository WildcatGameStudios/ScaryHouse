@tool
extends EditorPlugin

var hbox: HBoxContainer
var x_input: LineEdit
var y_input: LineEdit
var z_input: LineEdit
var go_button: Button

func _enter_tree():
	hbox = HBoxContainer.new()

	# Input fields for X, Y, Z
	x_input = LineEdit.new()
	x_input.placeholder_text = "X"
	x_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(x_input)

	y_input = LineEdit.new()
	y_input.placeholder_text = "Y"
	y_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(y_input)

	z_input = LineEdit.new()
	z_input.placeholder_text = "Z"
	z_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(z_input)

	# Button
	go_button = Button.new()
	go_button.text = "Go"
	go_button.pressed.connect(_on_go_pressed)
	hbox.add_child(go_button)

	# Add to 3D editor toolbar
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, hbox)

func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, hbox)
	hbox.queue_free()

func _on_go_pressed():
	var x = x_input.text.to_float()
	var y = y_input.text.to_float()
	var z = z_input.text.to_float()
	var pos = Vector3(x, y, z)

	var editor_interface = get_editor_interface()
	var spatial_editor = editor_interface.get_editor_viewport_3d()
	if spatial_editor:
		var cam = spatial_editor.get_camera_3d()
		if cam:
			cam.global_position = pos
			cam.look_at(Vector3.ZERO, Vector3.UP) # optional: look at origin
