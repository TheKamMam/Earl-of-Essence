class_name EssenceUI
extends Node2D

@onready var icon: TextureRect = %Icon

@export var essence: Essence: set = set_essence


func set_essence(new_essence: Essence) -> void:
	if not is_node_ready(): await ready
	
	if new_essence != null:
		essence = new_essence.create_instance()
		icon.texture = essence.icon
		essence.health_changed.connect(on_health_changed)
	else:
		essence = null

func cast() -> void:
	if not essence:
		return
	
	essence.cast()

func on_health_changed() -> void:
	if not essence:
		return
