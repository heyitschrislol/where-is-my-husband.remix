extends Node

@export var initial_state : State

var current_state : State
var states : Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
func _process(delta: float):
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float):
		if current_state:
			current_state.physics_update(delta)
func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return

	# Clean up the previous state
	if current_state:
		current_state.exit()

	# Intialize the new state
	new_state.enter()
	current_state = new_state
	#var new_state = states.get(new_state_name.to_lower())
	#if !new_state:
		#return
