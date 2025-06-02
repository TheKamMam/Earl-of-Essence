extends Node


func play(audio: AudioStream, single=false) -> void:
	if not audio:
		return
		
	if single:
		stop()

	for player in get_children():
		player = player as AudioStreamPlayer
		
		if not player.playing:
			player.stream = audio
			player.play()
			break


func stop() -> void:
	for player in get_children():
		player = player as AudioStreamPlayer
		player.stop()

func play_randomized_pitch(audio: AudioStream, single: bool = false) -> void:
	if not audio:
		return
	
	if single:
		stop()
	
	for player: AudioStreamPlayer in get_children():
		if not player.playing:
				player.stream = audio
				player.pitch_scale = randf_range(0.85, 1.15)
				player.play()
