extends SpringArm3D

@export var cam_sensitivity := 0.3

func _ready():
	set_as_top_level(true)

func _physics_process(_delta):
	rotation_degrees.y -= (Input.get_action_strength("cam_stick_right") - Input.get_action_strength("cam_stick_left"))
	rotation_degrees.x -= (Input.get_action_strength("cam_stick_down") - Input.get_action_strength("cam_stick_up"))

func _unhandled_input(event: InputEvent):
	
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * cam_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		
		rotation_degrees.y -= event.relative.x * cam_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
