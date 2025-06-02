class_name EnemySpawner
extends Node2D

@export var enemy_to_spawn: PackedScene
@onready var spawn_timer: Timer = %SpawnTimer
@export var spawn_time: int = 1
@export var total_enemies_to_spawn: int = 1

var enemies_spawned: int = 0
var can_start := false

func _ready() -> void:
	Events.level_can_start.connect(func(): can_start = true)
	spawn_timer.timeout.connect(spawn)
	spawn_timer.wait_time = spawn_time
	spawn_timer.start()

func spawn() -> void:
	if not can_start:
		return
	
	if not Global.player:
		spawn_timer.start()
		return
	
	if enemies_spawned >= total_enemies_to_spawn:
		spawn_timer.stop()
		return
	
	var enemy_inst: Enemy = enemy_to_spawn.instantiate()
	var spawn_pos := get_random_position()
	enemy_inst.global_position = spawn_pos
	owner.call_deferred("add_child", enemy_inst)
	Global.all_enemies.append(enemy_inst)
	enemies_spawned += 1
	spawn_timer.start()

func get_random_position() -> Vector2:
	var vpr = get_viewport_rect().size * randf_range(1.2, 1.4)
	var tr = Vector2(vpr.x, 0)
	var tl = Vector2(0, 0)
	var br = Vector2(vpr.x, vpr.y)
	var bl = Vector2(0, vpr.y)
	var sides = ["up", "down", "left", "right"].pick_random()
	var spawn_pos1 := Vector2.ZERO
	var spawn_pos2 := Vector2.ZERO
	
	match sides:
		"up":
			spawn_pos1 = tl
			spawn_pos2 = tr
		"down":
			spawn_pos1 = bl
			spawn_pos2 = br
		"left":
			spawn_pos1 = tl
			spawn_pos2 = bl
		"right":
			spawn_pos1 = tr
			spawn_pos2 = br
	
	return Vector2(randf_range(spawn_pos1.x, spawn_pos2.x), randf_range(spawn_pos1.y, spawn_pos2.y))
