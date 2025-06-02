extends Node


func get_player() -> Player:
	var player = get_tree().get_first_node_in_group("player")
	return player
