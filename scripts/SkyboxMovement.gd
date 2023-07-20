extends TextureRect

func _physics_process(_delta):
	if Input.is_action_just_pressed("pad_action_1"):
		position.x = position.x + 20

func _on_player_send_cam_rotation(cam_rotation):
	position.y = cam_rotation.x * 500
	position.x = cam_rotation.y * 500
