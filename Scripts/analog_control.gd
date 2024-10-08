extends CharacterBody3D

signal current_velocity(player_velocity)
signal current_dir(player_dir)
signal current_speed(player_speed)
signal meter_change(meter)
signal send_cam_rotation(cam_rotation)

# Initial Variables. Mainly focused around movement
@export var move_input := Vector3.ZERO
@export var move_dir := Vector3.ZERO
@export var move_speed := 0
@export var move_previous_input := Vector3.ZERO
@export var move_skid := 0
@export var move_gravity := 500
@export var move_shoot_timer := 0
@export var move_landing := 0
@export var vec_store := 0
@export var anim_store := "anim_player_jump"
@export var anim_frame_count := 0
@export var vec_array_store = [Vector3.ZERO, Vector3.ZERO]
@export var meter := 5
@export var meter_charge = 500
@export var air_dash_uses := 2
@export var allowed_to_recharge := true
@export var move_velocity := Vector3.ZERO
var move_snap := 0
var dust = preload("res://scenes/particles/dust_footstep.tscn")
var collision_left = preload("res://scenes/particles/collision_left.tscn")
var collision_right = preload("res://scenes/particles/collision_right.tscn")

# Caches SpringArm3D.
@onready var cache_spring_arm: SpringArm3D = $SpringArm3D

# Sets deadzones for stick.
func _ready():
	InputMap.action_set_deadzone("stick_left", 0.1)
	InputMap.action_set_deadzone("stick_right", 0.1)
	InputMap.action_set_deadzone("stick_up", 0.1)
	InputMap.action_set_deadzone("stick_down", 0.1)

func _physics_process(delta):
	# Calculates the magnitude of move_input every frame.
	var MOV_InputMag = Vector3.ZERO.distance_to(move_input)
	
	# Calculates how high the player's speed should be when inputting via the control stick.
	var MOV_MaxInputSpeed = MOV_InputMag * 90
	
	# Sends Camera Rotation every frame.
	emit_signal("send_cam_rotation", $SpringArm3D.rotation)
	
	# Handles meter recharging.
	if meter_charge < 500 && meter < 5 && allowed_to_recharge:
		meter_charge += 1
		if meter_charge % 100 == 0 && meter_charge > 0:
			meter += 1
			emit_signal("meter_change", meter)
			print(meter_charge)
			print(meter)
	
	# Handles what direction is being inputted.
	move_input.x = Input.get_action_strength("stick_right") - Input.get_action_strength("stick_left")
	move_input.z = Input.get_action_strength("stick_down") - Input.get_action_strength("stick_up")
	move_input = move_input.rotated(Vector3.UP, cache_spring_arm.rotation.y)
	cache_spring_arm.position = position
	cache_spring_arm.position.y = position.y + 12
	
	# ! Shooting. This could use some work.
	if Input.is_action_just_pressed("pad_shoulder_r"):
		move_shoot_timer = 20
		if move_speed == 0:
			move_speed += 50 
		$AnimationPlayer.play("anim_player_shoot")
	
	if move_shoot_timer > 0:
		$Pivot/Area3D.set_collision_layer_value(2, false)
		move_shoot_timer -= 1
		# Activates the gun's hitbox only on the 15th frame.
		if move_shoot_timer == 15:
			# Sends out the player's velocity so enemies hit by the player will be able
			# to match the velocity of Ippan.
			emit_signal("current_velocity", velocity)
			$Pivot/Area3D.set_collision_layer_value(2, true)
	
	if is_on_floor():
			
		# Resetting the snap vector.
		if move_snap == 0:
			air_dash_uses = 2
			allowed_to_recharge = true
			move_snap = 2
			move_landing = 30
			vec_store = 0
			# If the player is not inputting anything on the stick while landing then set the speed to 0.
			if Vector3.ZERO.distance_to(move_input) < 0.2 * sqrt(2.0):
				move_speed = 0
		
		# ! Handles what kind of jump to perform before we enter the air.
		# ! There is definitely a better way of doing this as of now.
		# ! Too much repetition between the code for the normal jump and cartwheel jump.
		if Input.is_action_just_pressed("pad_jump") && move_skid == 0:
			move_velocity.y = 180
			move_snap = 0
			anim_store = "anim_player_jump"
			anim_frame_count = 5
		
		if Vector2.ZERO.distance_to(Vector2(move_velocity.x, move_velocity.z)) > 100 && Input.is_action_just_pressed("pad_shoulder_l") && meter >= 2:
			move_velocity.y = 200
			move_snap = 0
			vec_store = 1
			meter -= 2
			meter_charge = -200
			emit_signal("meter_change", meter)
			anim_frame_count = 900
			allowed_to_recharge = false
			anim_store = "anim_player_cartwheel_jump"
		
		# Moves the player if not skidding. Extra deadzone added here.
		if Vector3.ZERO.distance_to(move_input) > 0.1 * sqrt(2.0) && move_skid == 0:
			move_dir = move_input.normalized()
			# Sets where the player has to look.
			$Pivot.look_at(position + move_input.rotated(Vector3.UP, 1.5 * PI), Vector3.UP)
			
			# For setting animations. If not shooting, either walks or runs.
			# ! This could probably be included alongside the code for assigning move_dir.
			if move_shoot_timer == 0:
				if Vector3.ZERO.distance_to(move_input) > 0.4 * sqrt(2.0):
					$AnimationPlayer.play("anim_player_run", -1, Vector3.ZERO.distance_to(move_input), false)
					if ($AnimationPlayer.current_animation_position > 0.09 && $AnimationPlayer.current_animation_position < 0.11) || ($AnimationPlayer.current_animation_position > 0.24 && $AnimationPlayer.current_animation_position < 0.26):
						add_child(dust.instantiate())
				else:
					$AnimationPlayer.play("anim_player_walk")
			
			# Increments or decreases the move speed depending on if the player is accelerating or not.
			if move_speed < MOV_MaxInputSpeed:
				move_speed += 2
			else:
				move_speed -= 2
		else:
			# Timer begins for the landing animation. If over, play idle animation.
			if move_skid == 0:
				if move_shoot_timer == 0:
					if move_landing != 0:
						move_landing -= 1
						$AnimationPlayer.play("anim_player_land")
					else:
						$AnimationPlayer.idle()
			else:
				$AnimationPlayer.play("ANIM_PlayerSkid")
			
			# Decelerates the player.
			if move_speed > 0:
				move_speed -= 2
				move_skid = move_skid * move_speed
		
	else:
		# Decides what vector for the player to use in midair via assigning move_dir
		# a value from an array of vectors.
		# vec_array_store[0] = move_dir (Does not allow free movement)
		# vec_array_store[1] = move_input (Allows for free movement)
		move_dir = vec_array_store[vec_store]
		if Input.is_action_just_released("pad_jump") && move_velocity.y > 0:
			move_velocity.y = 20
		# Plays the animation depending on the amount of frames assigned to anim_frame_count.
		# This allows for the carthweel jump to loop instead of just playing once.
		# Will be useful for other animations in the future.
		if anim_frame_count > 0:
			anim_frame_count -= 1
			$Pivot.look_at(position + move_dir.rotated(Vector3.UP, 1.5 * PI), Vector3.UP)
			$AnimationPlayer.play(anim_store)
		
		# Air dash.
		if Input.is_action_just_pressed("pad_action_1") and move_speed >= 64 and Vector3.ZERO.distance_to(move_dir) > 0.6 * sqrt(2.0) && air_dash_uses != 0:
			if air_dash_uses == 2:
				anim_frame_count = 0
				move_dir = move_input
				move_speed = 150
				move_velocity.y = 50
				vec_store = 0
				air_dash_uses -= 1
				$Pivot.look_at(position + move_dir.rotated(Vector3.UP, 1.5 * PI), Vector3.UP)
				$AnimationPlayer.play("anim_player_air_dash")
			else:
				if meter >= 1:
					meter_charge = -200
					meter -= 1
					emit_signal("meter_change", meter)
					allowed_to_recharge = false
					anim_frame_count = 0
					move_dir = move_input
					move_speed = 110
					move_velocity.y = 50
					vec_store = 0
					air_dash_uses -= 1
					$Pivot.look_at(position + move_dir.rotated(Vector3.UP, 1.5 * PI), Vector3.UP)
					$AnimationPlayer.play("anim_player_air_dash")
		
		# Divekick.
		if Input.is_action_just_pressed("pad_action_2") && meter >= 1:
			anim_frame_count = 0
			meter -= 1
			emit_signal("meter_change", meter)
			allowed_to_recharge = false
			move_velocity.y -= 90
			move_speed += 50
			meter_charge = -200
			$AnimationPlayer.play("anim_player_dive")
		
		if is_on_wall():
			# Wall jump.
			if Input.is_action_just_pressed("pad_jump"):
				anim_frame_count = 0
				move_velocity.y = 120
				move_dir = move_dir.bounce(get_wall_normal())
				vec_store = 0
				if move_dir.rotated(Vector3.UP, (2 * PI) - cache_spring_arm.rotation.y).x >= 0:
					add_child(collision_left.instantiate())
				else:
					add_child(collision_right.instantiate())
				$Pivot.look_at(position + Vector3(move_dir.x, 0, move_dir.z).rotated(Vector3.UP, 1.5 * PI), Vector3.UP)
				$AnimationPlayer.play("anim_player_wall_jump")
			
			# Wall climb.
			if Input.is_action_pressed("pad_shoulder_l"):
				anim_frame_count = 0
				move_dir.x = get_wall_normal().rotated(Vector3.UP, PI).x
				move_dir.z = get_wall_normal().rotated(Vector3.UP, PI).z
				move_velocity.y = 60
				vec_store = 0
				$Pivot.look_at(position + move_dir.rotated(Vector3.UP, 1.5 * PI), Vector3.UP)
				$AnimationPlayer.play("anim_player_wall_climb", -1, 2, false)
	
	move_velocity.x = move_dir.x * move_speed
	move_velocity.z = move_dir.z * move_speed
	move_velocity.y -= move_gravity * delta
	
	# Setting the velocity.
	set_velocity(move_velocity)
	set_up_direction(Vector3.UP)
	set_floor_snap_length(move_snap)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
	move_velocity = velocity
	
	# Storing the current move_input vector for the next frame, so we can compare it for move_skid.
	move_previous_input = move_input
	
	# Stores the movement vectors inside this array.
	vec_array_store[0] = move_dir
	vec_array_store[1] = move_input
