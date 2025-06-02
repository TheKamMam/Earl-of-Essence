extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func go_to_next_packed_scene(next_scene: PackedScene) -> void:
	animation_player.play("fade_in")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(next_scene)
	animation_player.play("fade_out")

func go_to_next_file_name_scene(next_scene: StringName) -> void:
	animation_player.play("fade_in")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(next_scene)
	animation_player.play("fade_out")
