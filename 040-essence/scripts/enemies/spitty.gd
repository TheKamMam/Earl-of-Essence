extends Enemy

const SPITTY_BULLET_SCENE = preload("res://scenes/objects/spitty_bullet.tscn")

@onready var velocity_component: VelocityComponent = %VelocityComponent
@onready var pathfind_component: PathfindComponent = %PathfindComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var hurtbox_component: HurtboxComponent = %HurtboxComponent
@onready var shoot_timer: Timer = %ShootTimer
@onready var bullet_marker: Marker2D = %BulletMarker
@onready var sprite: Sprite2D = %Sprite
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var shader_player: AnimationPlayer = %ShaderPlayer

var state_machine: CallableStateMachine = CallableStateMachine.new()

func _ready() -> void:
	state_machine.add_states(follow_state, enter_follow_state, Callable())
	state_machine.add_states(shoot_windup_state, enter_shoot_windup_state, Callable())
	state_machine.add_states(shoot_state, enter_shoot_state, leave_shoot_state)
	state_machine.set_initial_state(follow_state)
	
	velocity_component.set_max_speed(randf_range(velocity_component.max_speed - 5, velocity_component.max_speed + 5))

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
	
	if global_position.distance_to(target) < 100:
		state_machine.change_state(shoot_windup_state)

func enter_shoot_windup_state() -> void:
	if shoot_timer.is_stopped():
		shoot_timer.start()
		velocity_component.decelerate()

func shoot_windup_state() -> void:
	if not shoot_timer.is_stopped():
		return
	
	print("preparing to shoot")
	if global_position.direction_to(player.global_position).x < 0:
		sprite.flip_h = false
		sprite.offset = Vector2(-64, 0)
		bullet_marker.position = Vector2(-16, -10)
	elif global_position.direction_to(player.global_position).x > 0:
		sprite.flip_h = true
		sprite.offset = Vector2(64, 0)
		bullet_marker.position = Vector2(16, -10)
	state_machine.change_state(shoot_state)

func enter_shoot_state() -> void:
	animation_player.play("wind_up")
	await animation_player.animation_finished

func shoot() -> void:
	var dir := global_position.direction_to(player.global_position)
	var bullet_inst := SPITTY_BULLET_SCENE.instantiate()
	bullet_inst.add_collision_exception_with(self)
	bullet_inst.global_position = bullet_marker.global_position
	bullet_inst.direction = dir
	SfxPlayer.play_randomized_pitch(preload("res://assets/SFX/Laser_Shoot14.wav"))
	get_tree().current_scene.add_child(bullet_inst)

func shoot_state() -> void:
	if global_position.distance_to(player.global_position) > 100:
		state_machine.change_state(follow_state)
	else:
		state_machine.change_state(shoot_windup_state)

func leave_shoot_state() -> void:
	pass


func _on_health_component_health_changed() -> void:
	velocity_component.decelerate()
	SfxPlayer.play_randomized_pitch(preload("res://assets/SFX/Hit_Hurt11.wav"))
	shader_player.play("flash")
	if not health_component.has_health_remaining():
		call_deferred("die")
