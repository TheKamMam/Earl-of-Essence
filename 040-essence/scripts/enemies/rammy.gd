extends Enemy

@onready var velocity_component: VelocityComponent = %VelocityComponent
@onready var pathfind_component: PathfindComponent = %PathfindComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var sprite: Sprite2D = %Sprite
@onready var knockback_timer: Timer = %KnockbackTimer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var shader_player: AnimationPlayer = %ShaderPlayer

@onready var acceleration := velocity_component.acceleration
var knockback_strength := 100.0

var state_machine: CallableStateMachine = CallableStateMachine.new()


func _ready() -> void:
	if not is_node_ready(): await ready
	
	state_machine.add_states(follow_state, enter_follow_state, Callable())
	state_machine.add_states(knockback_state, enter_knockback_state, leave_knockback_state)
	state_machine.set_initial_state(follow_state)
	
	velocity_component.set_max_speed(randf_range(velocity_component.max_speed - 15, velocity_component.max_speed + 15))


func _physics_process(delta: float) -> void:
	state_machine.update()

func enter_follow_state() -> void:
	player = Utils.get_player()

func follow_state() -> void:
	var target := player.global_position if player else global_position
	
	pathfind_component.set_target_position(target)
	pathfind_component.follow_path()
	velocity_component.move(self)
	
	if velocity.x < 0:
		sprite.flip_h = false
	elif velocity.x > 0:
		sprite.flip_h = true
	
	#if global_position.distance_to(target) < 75:
		#state_machine.change_state(knockback_windup_state)

func enter_knockback_state() -> void:
	var knockback_dir := -global_position.direction_to(player.global_position)
	velocity_component.accelerate_in_direction(knockback_dir * knockback_strength)
	velocity_component.set_acceleration(18)
	velocity_component.move(self)
	animation_player.play("knockback")
	knockback_timer.start()

func knockback_state() -> void:
	if not knockback_timer.is_stopped():
		velocity_component.decelerate()
		velocity_component.move(self)
		return
	
	animation_player.play("RESET")
	state_machine.change_state(follow_state)

func leave_knockback_state() -> void:
	velocity_component.set_acceleration(acceleration)


func _on_hitbox_component_hit_area(area: HurtboxComponent) -> void:
	if state_machine.current_state == follow_state.get_method():
		state_machine.change_state(knockback_state)

func _on_health_component_health_changed() -> void:
	SfxPlayer.play_randomized_pitch(preload("res://assets/SFX/Hit_Hurt11.wav"))
	shader_player.play("flash")
	if not health_component.has_health_remaining():
		call_deferred("die")
