class_name DamageInstance
extends RefCounted

@export var damage_value: float
@export var damage_position: Vector2
@export var knockback_value: float

func _init(damage: float, knockback: float) -> void:
	damage_value = damage
	knockback_value = knockback
