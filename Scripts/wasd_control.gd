extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed_x = 0
@export var speed_z = 0
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# Vertical impulse applied to the character upon jumping in meters per second.
@export var jump_impulse = 20

var velocity = Vector3.ZERO

var last_direction = Vector3.ZERO

func _physics_process(delta):
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO
	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		direction.z += 1
	if Input.is_action_pressed("move_up"):
		direction.z -= 1
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.look_at(position + velocity, Vector3.UP)
		last_direction.x = direction.x
		last_direction.z = direction.z
	
	if Input.is_action_pressed("move_right") || Input.is_action_pressed("move_left"):
		if speed_x < 15:
			speed_x += 1
	else:
		if speed_x > 0:
			speed_x -= 1
			
	if Input.is_action_pressed("move_up") || Input.is_action_pressed(("move_down")):
		if speed_z < 15:
			speed_z += 1
	else:
		if speed_z > 0:
			speed_z -= 1
	
	# Ground velocity
	velocity.x = speed_x * last_direction.x
	velocity.z = speed_z * last_direction.z
	# Vertical velocity
	velocity.y -= fall_acceleration * delta
	# Moving the character
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
	velocity = velocity
	# Jumping.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y += jump_impulse
