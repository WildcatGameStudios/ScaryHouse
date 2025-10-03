@tool
extends EditorPlugin

var hbox: HBoxContainer
var x_input: LineEdit
var y_input: LineEdit
var z_input: LineEdit
var go_button: Button

func _enter_tree():
	hbox = HBoxContainer.new() # to add to toolbar all at once
	
	x_input = LineEdit.new() # x input
	x_input.placeholder_text = "x=0" # default value is 0
	x_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL # scroll for long input
	hbox.add_child(x_input) # add to hbox
	
	y_input = LineEdit.new() # y input
	y_input.placeholder_text = "y=0"
	y_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(y_input)
	
	z_input = LineEdit.new() # z input
	z_input.placeholder_text = "z=0"
	z_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(z_input)
	
	go_button = Button.new() # go button
	go_button.text = "Go"
	go_button.pressed.connect(_on_go_pressed) # call _on_go_pressed when pressed
	hbox.add_child(go_button)
	
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, hbox) # add to toolbar
	
func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, hbox) # remove from toolbar
	hbox.queue_free()
	
func _on_go_pressed():
	EditorInterface.get_editor_viewport_3d().get_camera_3d().global_position = Vector3(x_input.text.to_float(),y_input.text.to_float(),z_input.text.to_float())
