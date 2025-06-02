class_name HurtboxComponent
extends Area2D

signal hit(area: Area2D)

enum TYPE {DISABLE_SELF, DISABLE_OTHER, DISABLE_BOTH}
@export var type := TYPE.DISABLE_SELF


@export var health_component: HealthComponent
@export var collision_shape: CollisionShape2D
@export var disable_time := 1.0
@export var detect_only := false
@export var exclude_siblings := true

@onready var disable_timer: Timer = %DisableTimer


func _ready() -> void:
	if not is_node_ready(): await ready
	
	if detect_only:
		monitorable = false
	
	area_entered.connect(on_hit)
	disable_timer.wait_time = disable_time
	disable_timer.timeout.connect(func(): collision_shape.set_deferred("disabled", false))
	

func disable() -> void:
	collision_shape.set_deferred("disabled", true)

func enable() -> void:
	collision_shape.set_deferred("disabled", false)

func on_hit(area: Area2D) -> void:
	if area is HitboxComponent:
		if area.get_parent() == get_parent():
			return
		match type:
			0:
				collision_shape.set_deferred("disabled", true)
				disable_timer.start()
			1:
				area.collision_shape.set_deferred("disabled", true)
				area.disable_timer.start()
			2:
				collision_shape.set_deferred("disabled", true)
				disable_timer.start()
				area.collision_shape.set_deferred("disabled", true)
				area.disable_timer.start()
	
	hit.emit(area)
