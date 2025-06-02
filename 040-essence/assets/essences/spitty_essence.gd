extends Essence


const PLAYER_BULLET_SCENE = preload("res://scenes/objects/player_bullet.tscn")

func cast_effect() -> void:
	var dir := player.global_position.direction_to(player.get_global_mouse_position())
	var bullet_inst := PLAYER_BULLET_SCENE.instantiate()
	bullet_inst.add_collision_exception_with(player)
	bullet_inst.global_position = player.essence_ui.global_position
	bullet_inst.direction = dir
	SfxPlayer.play_randomized_pitch(preload("res://assets/SFX/Laser_Shoot14.wav"))
	player.owner.add_child(bullet_inst)
	effect_finished.emit()
	player.using_essence = false
