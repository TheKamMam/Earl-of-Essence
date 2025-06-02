extends Control


func _on_button_pressed() -> void:
	ScreenTransition.go_to_next_file_name_scene("res://scenes/levels/level_1.tscn")
