@tool
extends EditorPlugin

var hbox: HBoxContainer
var x_input: LineEdit
var y_input: LineEdit
var z_input: LineEdit
var go_button: Button

func _enter_tree():
	hbox = HBoxContainer.new() # to add to toolbar all at once
	
	# x input
	x_input = LineEdit.new()
	x_input.placeholder_text = "X=0" # default value is 0
	x_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL # scroll for long input
	hbox.add_child(x_input) # add to hbox
	
	# y input
	y_input = LineEdit.new()
	y_input.placeholder_text = "Y=0"
	y_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(y_input)
	
	# z input
	z_input = LineEdit.new()
	z_input.placeholder_text = "Z=0"
	z_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(z_input)
	
	# go button
	go_button = Button.new()
	go_button.text = "Go"
	go_button.pressed.connect(_on_go_pressed) # call _on_go_pressed when pressed
	hbox.add_child(go_button)
	
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, hbox) # add to toolbar
	
func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, hbox) # remove from toolbar
	hbox.queue_free()
	
func _on_go_pressed():
	var x = x_input.text.to_float() # convert inputs to numbers, .to_float() deals with string to float conversion very well
	var y = y_input.text.to_float()
	var z = z_input.text.to_float()
	var pos = Vector3(x, y, z) # create vector from inputs
	var cam = EditorInterface.get_editor_viewport_3d().get_camera_3d() # get reference to editor camera
	
	cam.global_position = pos # set position to pos, however this sets a central pivot only applied after some time
	await get_tree().create_timer(.5).timeout # pause to let pevious transport happen, you will end up looking at the point you want
	cam.global_position += 2 * (pos - cam.global_position) # set position to opposite side but same distance from pivot, this makes the camera end up on the old pivot
	# see details about why the camera is set this way in the README
