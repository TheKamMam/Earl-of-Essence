class_name HealthComponent
extends Node2D


signal health_changed

@export var max_health: float = 100.0
@export var health: float

func _ready() -> void:
	if not is_node_ready(): await ready
	
	if health == 0:
		health = max_health

func take_damage(damage: DamageInstance) -> void:
	health -= clamp(damage.damage_value, 0, max_health)
	health_changed.emit()

func get_current_health() -> float:
	return health

func has_health_remaining() -> bool:
	return health > 0
