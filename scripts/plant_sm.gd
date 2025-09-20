extends Node
class_name StateMachine

# Create variables to keep track of states
var state  = null 
var previous_state = null

var states = {}
# Find parent
@onready var parent = get_parent()

func _ready() -> void:
	add_state("inactive")
	add_state("active")
	add_state("dying")
	set_state("inactive")

# Check if there is a state to execute 
func _physics_process(delta):
	if state != null : 
		state_logic(delta)
	

func state_logic(delta) : 
	match state:
		"inactive":
			parent.inactive()
		"active":
			parent.active()
		"dying":
			parent.dying()
	
func get_transition(delta):
	return null
	
func enter_state(new_state, old_state) : 
	match new_state:
		"inactive":
			parent.enter_inactive()
		"active":
			parent.enter_active()
		"dying":
			parent.enter_dying()
	
func exit_state(old_state, new_state) : 
	pass


func set_state(new_state) : 
	previous_state = state
	state = new_state
	
	if previous_state != null : 
		exit_state(previous_state, state)
		
	if state != null : 
		enter_state(new_state , previous_state)
		

func add_state(state_name) : 
	states[state_name] = states.size()
