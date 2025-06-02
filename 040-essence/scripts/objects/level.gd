extends Node2D



var total_enemies_needed: int = 0
var total_enemies_defeated: int = 0

func _ready() -> void:
	if not is_node_ready(): await ready
	
	Events.enemy_died.connect(on_enemy_died)
	Events.essence_collected.connect(on_essence_collected)
	for spawner: EnemySpawner in get_all_spawners():
		total_enemies_needed += spawner.total_enemies_to_spawn
	

func on_enemy_died(enemy: Enemy) -> void:
	total_enemies_defeated += 1
	if total_enemies_defeated >= total_enemies_needed:
		Events.all_enemies_defeated.emit()

func on_essence_collected(essence: EssenceUI) -> void:
	Events.level_can_start.emit()

func get_all_spawners() -> Array[EnemySpawner]:
	var all_enemy_spawners: Array[EnemySpawner] = []
	for child in get_children():
		if child is EnemySpawner:
			all_enemy_spawners.append(child)
	
	return all_enemy_spawners
