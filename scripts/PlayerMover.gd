extends CharacterBody3D

# Caches SpringArm3D.
@onready var cache_spring_arm: SpringArm3D = $SpringArm3D
@export var move_input := Vector3.ZERO
@export var move_dir := Vector3.ZERO
var move_velocity := Vector3.ZERO
var move_speed := 0
var move_gravity := 500
var move_snap := 0

func _physics_process(delta):
	var MOV_InputMag = Vector3.ZERO.distance_to(move_input)
	
	# Calculates how high the player's speed should be when inputting via the control stick.
	var MOV_MaxInputSpeed = MOV_InputMag * 90
	
	# Handles what direction is being inputted.
	move_input.x = Input.get_action_strength("stick_right") - Input.get_action_strength("stick_left")
	move_input.z = Input.get_action_strength("stick_down") - Input.get_action_strength("stick_up")
	move_input = move_input.rotated(Vector3.UP, cache_spring_arm.rotation.y)
	cache_spring_arm.position = position
	cache_spring_arm.position.y = position.y + 12
	
	if Vector3.ZERO.distance_to(move_input) > 0.1 * sqrt(2.0):
		move_dir = move_input.normalized()
		$Pivot.look_at(position + move_input.rotated(Vector3.UP, 1.5 * PI), Vector3.UP)
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
	set_velocity(move_velocity)
	set_up_direction(Vector3.UP)
	set_floor_snap_length(move_snap)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
	move_velocity = velocity

func _ready():
	InputMap.action_set_deadzone("stick_left", 0.1)
	InputMap.action_set_deadzone("stick_right", 0.1)
	InputMap.action_set_deadzone("stick_up", 0.1)
	InputMap.action_set_deadzone("stick_down", 0.1)
