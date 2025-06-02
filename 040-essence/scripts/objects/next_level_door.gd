extends Area2D

@export var next_level: PackedScene
var valid_to_next_scene := false

func _ready() -> void:
	if not is_node_ready(): await ready
	
	Events.all_enemies_defeated.connect(on_all_enemies_defeated)

func on_all_enemies_defeated() -> void:
	show()
	valid_to_next_scene = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player && valid_to_next_scene:
		ScreenTransition.go_to_next_packed_scene(next_level)
