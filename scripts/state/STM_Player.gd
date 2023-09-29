extends StatePlayer

@export var initial_state : StatePlayer

var current_state : StatePlayer
var states : Dictionary = {}

func _ready():
	for child in get_children():
		states[child.name] = child
		child.Change.connect(on_child_transition)
	
	if initial_state:
		initial_state.Enter()
		current_state = initial_state
	
	InputMap.action_set_deadzone("stick_left", 0.1)
	InputMap.action_set_deadzone("stick_right", 0.1)
	InputMap.action_set_deadzone("stick_up", 0.1)
	InputMap.action_set_deadzone("stick_down", 0.1)

func _process(delta):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta):
	if current_state:
		current_state.PhysUpdate(delta)

	MOV_InputMag = Vector3.ZERO.distance_to(move_input)
	
	# Calculates how high the player's speed should be when inputting via the control stick.
	MOV_MaxInputSpeed = MOV_InputMag * 90
	
	# Handles what direction is being inputted.
	move_input.x = Input.get_action_strength("stick_right") - Input.get_action_strength("stick_left")
	move_input.z = Input.get_action_strength("stick_down") - Input.get_action_strength("stick_up")
	
	if Vector3.ZERO.distance_to(move_input) > 0.1 * sqrt(2.0):
		move_dir = move_input
		if move_speed < MOV_MaxInputSpeed:
			move_speed += 2
		else:
			move_speed -= 2
	else:
		if move_speed > 0:
			move_speed -= 2
	
	move_velocity.x = move_dir.x * move_speed
	move_velocity.z = move_dir.z * move_speed
	move_velocity.y -= move_gravity * delta

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name)
	if current_state:
		current_state.exit()
	new_state.enter()
