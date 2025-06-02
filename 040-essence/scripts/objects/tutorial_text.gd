extends Control

func _ready() -> void:
	Events.level_can_start.connect(on_level_started)


func on_level_started() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(255, 255, 255, 0), 1)
