extends Enemy

const DASH_PARTICLES_SCENE = preload("res://scenes/objects/dash_particles.tscn")

@onready var velocity_component: VelocityComponent = %VelocityComponent
@onready var pathfind_component: PathfindComponent = %PathfindComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var dash_timer: Timer = %DashTimer
@onready var dash_cooldown_timer: Timer = %DashCooldownTimer
@onready var sprite: Sprite2D = %Sprite
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var shader_player: AnimationPlayer = %ShaderPlayer

@export var dash_speed := 750.0

var state_machine: CallableStateMachine = CallableStateMachine.new()


func _ready() -> void:
	if not is_node_ready(): await ready
	
	state_machine.add_states(follow_state, enter_follow_state, Callable())
	state_machine.add_states(dash_windup_state, enter_dash_windup_state, Callable())
	state_machine.add_states(dash_state, enter_dash_state, leave_dash_state)
	state_machine.set_initial_state(follow_state)
	
	velocity_component.set_max_speed(randf_range(velocity_component.max_speed - 10, velocity_component.max_speed + 10))


func _physics_process(delta: float) -> void:
	state_machine.update()

func enter_follow_state() -> void:
	pass

func follow_state() -> void:
	player = Utils.get_player()
	var target = player.global_position
	
	pathfind_component.set_target_position(target)
	pathfind_component.follow_path()
	velocity_component.move(self)
	
	if velocity.x < 0:
		sprite.flip_h = false
	elif velocity.x > 0:
		sprite.flip_h = true
	
	if global_position.distance_to(target) < 75 && dash_cooldown_timer.is_stopped():
		state_machine.change_state(dash_windup_state)

func enter_dash_windup_state() -> void:
	if dash_timer.is_stopped():
		dash_timer.start()
		velocity_component.decelerate()
		animation_player.play("dash_windup")

func dash_windup_state() -> void:
	if not dash_timer.is_stopped():
		return
	
	print("preparing dash")
	if velocity.x < 0:
		sprite.flip_h = false
	elif velocity.x > 0:
		sprite.flip_h = true
	state_machine.change_state(dash_state)

func spawn_dash_particles() -> void:
	var part_inst := DASH_PARTICLES_SCENE.instantiate()
	part_inst.set_property(global_position)
	get_tree().current_scene.call_deferred("add_child", part_inst)

func enter_dash_state() -> void:
	var dir := global_position.direction_to(player.global_position if player else global_position)
	velocity_component.set_max_speed(dash_speed)
	velocity_component.dash_velocity(dir)
	spawn_dash_particles()
	velocity_component.move(self)

func dash_state() -> void:
	velocity_component.decelerate()
	if velocity.x < 0:
		sprite.flip_h = false
	elif velocity.x > 0:
		sprite.flip_h = true
	velocity_component.move(self)
	if velocity_component.velocity.length() < 25:
		state_machine.change_state(follow_state)

func leave_dash_state() -> void:
	velocity_component.set_max_speed(100)
	animation_player.play("RESET")
	dash_cooldown_timer.start()

func _on_health_component_health_changed() -> void:
	velocity_component.decelerate()
	SfxPlayer.play_randomized_pitch(preload("res://assets/SFX/Hit_Hurt11.wav"))
	shader_player.play("flash")
	if not health_component.has_health_remaining():
		call_deferred("die")
