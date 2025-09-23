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
	get_transition(delta)
	if state != null : 
		state_logic(delta)

func state_logic(delta) : 
	match state:
		"inactive":
			parent.inactive(delta)
		"active":
			parent.active(delta)
		"dying":
			parent.dying(delta)
	
func get_transition(delta):
	match state:
		"inactive":
			if parent.activate_timer <= 0:
				set_state("active")
		"active":
			if parent.dying_rolls_timer <= 0:	
				if randf() < parent.start_dying_chance:
					set_state("dying")
				else:
					parent.dying_rolls_timer = parent.time_between_dying_rolls
		"dying":
			pass
	
func enter_state(new_state, old_state) :
	match state:
		"active":
			parent.enter_active()
		"dying":
			parent.enter_dying()
	
func exit_state(old_state, new_state) : 
	match new_state:
		"inactive":
			parent.exit_inactive()
		"active":
			parent.exit_active()
		"dying":
			parent.exit_dying()


func set_state(new_state) : 
	previous_state = state
	state = new_state
	
	if previous_state != null : 
		exit_state(previous_state, state)
		
	if state != null : 
		enter_state(new_state , previous_state)
		

func add_state(state_name) : 
	states[state_name] = states.size()
