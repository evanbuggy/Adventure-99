extends Node

@export var initial_state : StatePlayer

var current_state : StatePlayer
var states : Dictionary = {}

func _ready():
	for child in get_children():
		if child is StatePlayer:
			states[child.name] = child
			child.Change.connect(on_child_transition)
	
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta):
	if current_state:
		current_state.PhysUpdate(delta)

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name)
	if current_state:
		current_state.exit()
	new_state.enter()
