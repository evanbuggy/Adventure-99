extends MarginContainer

@export var shake_timer := 0
@onready var tex = get_node("Number")
var pos_default = get_position()
var shake_positions = [0, 9, 7, 2, 1, 6, 8, 3]
@onready var num_array := [preload("res://textures/meter_num_0000.png"),
							preload("res://textures/meter_num_0001.png"),
							preload("res://textures/meter_num_0002.png"),
							preload("res://textures/meter_num_0003.png"),
							preload("res://textures/meter_num_0004.png"),
							preload("res://textures/meter_num_0005.png")]

func _on_player_meter_change(meter):
	tex.set_texture(num_array[meter])
	shake_timer = 7

func _physics_process(_delta):
	if shake_timer > 0:
		tex.set_position(Vector2(shake_positions[shake_timer], shake_positions[shake_timer]), true)
		shake_timer -= 1
