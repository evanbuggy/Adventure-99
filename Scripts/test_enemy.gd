extends CharacterBody3D

signal has_been_hit_by_player()

@export var enemy_health := 3
@export var enemy_dir := Vector3(1, 0, 0)
@export var enemy_speed := 10
@export var enemy_gravity := 200
@export var enemy_velocity := Vector3.ZERO
@export var enemy_idle_timer := 670
var enemy_snap := 1.5
var enemy_hit := false
var enemy_vuln := false
var enemy_vuln_store := Vector3.ZERO
var hit_stop_timer := 0

func _on_player_current_velocity(player_velocity):
	enemy_vuln_store.x = player_velocity.x 
	enemy_vuln_store.z = player_velocity.z

func _on_hurtbox_area_entered(_area):
	enemy_hit = true

func _physics_process(delta):
	if enemy_snap == 0:
		if is_on_floor():
			enemy_snap = 1.5
			enemy_vuln = false
	
	if enemy_hit == false:
		if enemy_vuln == false:
			enemy_idle_timer -= 1
			if enemy_idle_timer < 70:
				$AnimationPlayer.play("anim_purro_look")
				enemy_velocity.x = 0
				enemy_velocity.z = 0
				if enemy_idle_timer == 0:
					enemy_idle_timer = 670
			else:
				enemy_dir = enemy_dir.rotated(Vector3.UP, PI / 180)
				enemy_velocity.x = enemy_dir.x * enemy_speed
				enemy_velocity.z = enemy_dir.z * enemy_speed
				$Pivot.look_at(position + enemy_dir.rotated(Vector3.UP, PI), Vector3.UP)
				$AnimationPlayer.play("anim_purro_walk")
		if hit_stop_timer > 0:
			Engine.time_scale = 0.01
			hit_stop_timer -= 1 
		else:
			Engine.time_scale = 1.0
	else:
		$AnimationPlayer.play("anim_purro_hit")
		enemy_velocity.x = enemy_vuln_store.x * 1.2
		enemy_velocity.z = enemy_vuln_store.z * 1.2
		enemy_snap = 0
		enemy_velocity.y = 70
		enemy_vuln = true
		hit_stop_timer = 5
		$Pivot.look_at(position + enemy_velocity.rotated(Vector3.UP, PI * 2), Vector3.UP)
	
	enemy_velocity.y -= enemy_gravity * delta 
	set_velocity(enemy_velocity)
	set_floor_snap_length(enemy_snap)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
	enemy_velocity = velocity
	enemy_hit = false
