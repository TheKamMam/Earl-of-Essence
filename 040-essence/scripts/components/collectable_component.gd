class_name CollectableComponent
extends Node2D

signal collected(object: Node2D)

@export var host: Node2D
@export var collection_range: Area2D
@export var claim_range: Area2D
@export var auto_collect: bool = true
@export var disabled: bool = false

var collection_speed := -1.0
var target: Node2D
var player_inside_collection_area := false
var bodies_in_collection_area: Array[Node2D] = []

func _ready() -> void:
	if not is_node_ready(): await ready
	
	collection_range.body_entered.connect(on_collection_area_body_entered)
	collection_range.body_exited.connect(on_collection_area_body_exited)
	claim_range.body_entered.connect(on_claim_range_body_entered)

func _process(delta: float) -> void:
	if not target:
		pass
	
	else:
		host.global_position = host.global_position.lerp(target.global_position, 1.0 - exp(-collection_speed * delta))
		collection_speed += (10 * delta)

func _input(event: InputEvent) -> void:
	if disabled:
		return
	
	if event.is_action_pressed("collect"):
		if not player_inside_collection_area || auto_collect:
			return
		
		target = get_player()
		target.add_collectable(self)

func on_collection_area_body_entered(body: CollisionObject2D) -> void:
	if disabled:
		return
	
	if body is Player:
		if auto_collect:
			target = body
			
		player_inside_collection_area = true
	bodies_in_collection_area.append(body)

func on_collection_area_body_exited(body: CollisionObject2D) -> void:
	if disabled:
		return
	
	if body is Player:
		player_inside_collection_area = false
	bodies_in_collection_area.erase(body)

func on_claim_range_body_entered(body: CollisionObject2D) -> void:
	if disabled:
		return
	
	if body != target:
		return
		
	if auto_collect:
		target.add_collectable(self)
	
	collected.emit(self)
	host.queue_free()

func get_player() -> Player:
	for body in bodies_in_collection_area:
		if body is Player:
			return body
	
	return null
