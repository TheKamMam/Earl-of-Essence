extends CharacterBody2D

@export var speed := 250
var direction := Vector2.RIGHT

func _ready() -> void:
	rotation = direction.angle()

func _process(delta: float) -> void:
	var collision := move_and_collide(direction * speed * delta)
	if collision != null:
		queue_free()


func _on_hitbox_component_hit_area(area: HurtboxComponent) -> void:
	set_process(false)
	queue_free()
