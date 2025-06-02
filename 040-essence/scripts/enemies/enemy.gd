class_name Enemy
extends CharacterBody2D

const ESSENCE_COLLECTABLE_SCENE = preload("res://scenes/essence/essence_collectable.tscn")

@export var essence: Essence

var player: Player

func _ready() -> void:
	if not is_node_ready(): await ready
	
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func die() -> void:
	var essence_inst: EssenceUI = ESSENCE_COLLECTABLE_SCENE.instantiate()
	essence_inst.essence = essence
	essence_inst.global_position = global_position
	Events.enemy_died.emit(self)
	get_tree().current_scene.add_child(essence_inst)
	queue_free()
