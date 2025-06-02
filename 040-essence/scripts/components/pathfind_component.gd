class_name PathfindComponent
extends Node2D

@onready var nav_agent: NavigationAgent2D = %NavAgent
@onready var interval_timer: Timer = %IntervalTimer

@export var velocity_component: VelocityComponent
@export var interval_time: float = 1.0

func _ready() -> void:
	if not is_node_ready(): await ready
	
	interval_timer.wait_time = interval_time


func set_target_position(target_position: Vector2) -> void:
	if not interval_timer.is_stopped():
		return
	
	nav_agent.target_position = target_position
	interval_timer.start()

func force_set_target_position(target_position: Vector2) -> void:
	nav_agent.target_position = target_position
	interval_timer.start()

func follow_path() -> void:
	if nav_agent.is_navigation_finished():
		velocity_component.decelerate()
		return
	
	var direction := (nav_agent.get_next_path_position() - global_position).normalized()
	velocity_component.accelerate_in_direction(direction)
	nav_agent.set_velocity_forced(velocity_component.velocity)

func on_velocity_computed(velocity: Vector2) -> void:
	var new_direction := velocity.normalized()
	var current_direction := velocity_component.velocity.normalized()
	var halfway := new_direction.lerp(current_direction, 1.0 - exp(velocity_component.acceleration * get_physics_process_delta_time()))
	velocity_component.velocity = halfway * velocity_component.velocity.length()
