class_name Player
extends CharacterBody2D

@onready var velocity_component: VelocityComponent = %velocityComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var hurtbox_component: HurtboxComponent = %HurtboxComponent
@onready var essence_ui: EssenceUI = %EssenceUI
@onready var sprite: AnimatedSprite2D = %Sprite
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var shader_player: AnimationPlayer = %ShaderPlayer
@onready var ghost_timer: Timer = %GhostTimer

const GHOST_DASH_PARTICLES_SCENE = preload("res://scenes/player/ghost_dash_particles.tscn")

var has_control := true
var using_essence := false
var current_collected_collectables: Array[Node2D] = []

func _ready() -> void:
	if not is_node_ready(): await ready
	Global.player = self
	ghost_timer.timeout.connect(add_ghost)
	Events.essence_depleted.connect(on_essence_depleted)
	health_bar.max_value = health_component.max_health
	health_bar.value = health_component.health
	health_label.text = str(int(health_component.health)) + "/" + str(int(health_component.max_health))

func _physics_process(_delta: float) -> void:
	if has_control:
		var move_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if move_dir != Vector2.ZERO:
			move(move_dir)
		else:
			deccelerate()
	
	
	velocity_component.move(self)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("cast"):
		if not using_essence && essence_ui.essence:
			using_essence = true
			essence_ui.cast()

func move(dir: Vector2) -> void:
	velocity_component.accelerate_in_direction(dir)
	
	var anim_velocity := velocity.normalized()
	if anim_velocity.x:
		sprite.scale.x = .125 if velocity.x > 0 else -.125
	if anim_velocity.y >= .6:
		sprite.play("down")
		essence_ui.position = Vector2(0, -6)
	elif anim_velocity.y <= -.6:
		sprite.play("up")
		essence_ui.position = Vector2(0, -27)
	else:
		sprite.play("side")
		if anim_velocity.x > 0:
			essence_ui.position = Vector2(6, -8)
			essence_ui.icon.flip_h = false
		elif anim_velocity.x < 0:
			essence_ui.position = Vector2(-6, -8)
			essence_ui.icon.flip_h = true

func deccelerate() -> void:
	sprite.play("idle")
	essence_ui.position = Vector2(0, -6)
	velocity_component.decelerate()

func add_ghost() -> void:
	var ghost = GHOST_DASH_PARTICLES_SCENE.instantiate()
	ghost.set_property(global_position, sprite.scale)
	get_tree().current_scene.call_deferred("add_child", ghost)

func _on_health_component_health_changed() -> void:
	SfxPlayer.play_randomized_pitch(preload("res://assets/SFX/Hit_Hurt13.wav"))
	health_bar.value = health_component.health
	health_label.text = str(int(health_component.health)) + "/" + str(int(health_component.max_health))
	shader_player.play("flash")
	if not health_component.has_health_remaining():
		ScreenTransition.go_to_next_file_name_scene("res://scenes/levels/game_over.tscn")

func add_collectable(collectable: CollectableComponent) -> void:
	current_collected_collectables.append(collectable)
	if not collectable.collected.is_connected(on_collectable_collected):
		collectable.collected.connect(on_collectable_collected)

func on_collectable_collected(collectable: CollectableComponent) -> void:
	var host := collectable.host
	if host is EssenceUI:
		Events.essence_collected.emit(host)
		essence_ui.essence = host.essence
		essence_ui.essence.player = self
		SfxPlayer.play(preload("res://assets/SFX/Jump5.wav"))
		essence_ui.show()
	
	
	if current_collected_collectables.has(collectable):
		current_collected_collectables.erase(collectable)

func on_essence_depleted(essence: Essence) -> void:
	if not essence == essence_ui.essence:
		return
	
	essence_ui.essence = null
	essence_ui.hide()
