class_name HitboxComponent
extends Area2D

const HITBOX_COMPONENT_SCENE = preload("res://scenes/components/hitbox_component.tscn")

signal hit_area(area: HurtboxComponent)

@export var damage_value: float = 1.0
@export var collision_shape: CollisionShape2D
@export var disable_time := 1.0

@onready var disable_timer: Timer = %DisableTimer


func _ready() -> void:
	if not is_node_ready(): await ready
	
	area_entered.connect(on_area_entered)
	disable_timer.wait_time = disable_time
	disable_timer.timeout.connect(func(): collision_shape.set_deferred("disabled", false))

func disable() -> void:
	collision_shape.set_deferred("disabled", true)

func enable() -> void:
	collision_shape.set_deferred("disabled", false)

func on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		var damage_inst := DamageInstance.new(damage_value, 0)
		area.health_component.take_damage(damage_inst)
		hit_area.emit(area)

static func create_instance() -> HitboxComponent:
	var hitbox_inst := HITBOX_COMPONENT_SCENE.instantiate()
	return hitbox_inst
