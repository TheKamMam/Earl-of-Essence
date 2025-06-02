class_name VelocityComponent
extends Node2D

@export var max_speed := 100.0
@export var acceleration := 10.0

var velocity := Vector2.ZERO
var velocity_override := Vector2.ZERO
var speed_multiplier := 1.0
var acceleration_multiplier := 1.0

func accelerate_to_velocity(new_velocity: Vector2) -> void:
	velocity = velocity.lerp(new_velocity, 1.0 - exp(-acceleration * get_physics_process_delta_time()))

func accelerate_in_direction(direction: Vector2) -> void:
	accelerate_to_velocity(direction * max_speed)

func get_max_velocity(direction: Vector2) -> Vector2:
	return direction * max_speed

func dash_velocity(direction: Vector2) -> void:
	velocity = get_max_velocity(direction)

func decelerate() -> void:
	accelerate_to_velocity(Vector2.ZERO)

func move(character_body: CharacterBody2D) -> void:
	character_body.velocity = velocity_override if velocity_override else velocity
	character_body.move_and_slide()

func set_max_speed(new_maxspeed: float) -> void:
	max_speed = new_maxspeed

func set_acceleration(new_accel: float) -> void:
	acceleration = new_accel
