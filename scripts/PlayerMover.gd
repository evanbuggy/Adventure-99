extends CharacterBody3D

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var pivot: Node3D = $Pivot
@onready var statemachine: Node = $StateMachine

func _physics_process(delta):
	spring_arm.position = position
	spring_arm.position.y = position.y + 12
	pivot.look_at(position + statemachine.move_input.rotated(Vector3.UP, 1.5 * PI), Vector3.UP)
	set_velocity(statemachine.move_velocity)
	set_up_direction(Vector3.UP)
	set_floor_snap_length(statemachine.move_snap)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
