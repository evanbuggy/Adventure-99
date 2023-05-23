extends GPUParticles3D
var timer = 12

func _process(_delta):
	if timer == 0:
		queue_free()
	timer -= 1
