extends TextureRect

func _on_player_send_cam_rotation(cam_rotation):
	position.y = cam_rotation.x * 500
	position.x = cam_rotation.y * 500
