extends AnimationPlayer

func _ready():
	play("anim_player_idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func idle():
	play("anim_player_idle")
