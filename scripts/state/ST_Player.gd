extends Node
class_name StatePlayer

var MOV_MaxInputSpeed = 0
var MOV_InputMag = 0

@export var move_input := Vector3.ZERO
@export var move_dir := Vector3.ZERO
var move_velocity := Vector3.ZERO
var move_speed := 0
var move_gravity := 500
var move_snap := 0

signal Change

func Enter():
	pass

func Exit():
	pass

func Update(_delta: float):
	pass

func PhysUpdate(_delta: float): 
	pass
