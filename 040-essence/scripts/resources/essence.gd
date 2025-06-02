class_name Essence
extends Resource

signal health_changed
signal effect_finished

enum TYPE {MULTIPLE_USE, SINGLE_USE}

@export var icon: Texture
@export_range(0, 100, 1) var max_health: int
@export var decrement := 10
@export var type: TYPE

var health: set = set_health
var player: Player

func set_health(new_health: int) -> void:
	health = new_health
	health_changed.emit()

func cast() -> void:
	cast_effect()
	
	await effect_finished
	if type == TYPE.MULTIPLE_USE:
		health -= decrement
	else:
		Events.essence_depleted.emit(self)
		player.using_essence = false
		return
	
	if not can_cast_effect():
		Events.essence_depleted.emit(self)
		player.using_essence = false

func cast_effect() -> void:
	pass

func can_cast_effect() -> bool:
	return (health - decrement) > 0

func create_instance() -> Essence:
	var essence_inst: Essence = self.duplicate()
	essence_inst.health = essence_inst.max_health
	
	return essence_inst
