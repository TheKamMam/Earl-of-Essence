extends Essence

@export var dash_speed := 600
@export var dash_time := .125
@export var dash_cooldown := .5
var is_dashing := false

func cast_effect() -> void:
	if is_dashing:
		return
	
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var prev_max_speed := player.velocity_component.max_speed
	var hitbox := HitboxComponent.create_instance()
	var collision_shape := CollisionShape2D.new()
	collision_shape.shape = CapsuleShape2D.new()
	collision_shape.shape.radius = 10.0
	collision_shape.shape.height = 30.0
	
	
	hitbox.position = Vector2.ZERO
	hitbox.collision_shape = collision_shape
	hitbox.collision_mask = 4
	hitbox.collision_layer = 4
	collision_shape.position = Vector2(0, -14)
	hitbox.damage_value = 10
	player.call_deferred("add_child", hitbox)
	hitbox.call_deferred("add_child", collision_shape)
	player.hurtbox_component.disable()
	
	player.velocity_component.set_max_speed(dash_speed)
	player.velocity_component.dash_velocity(dir)
	player.velocity_component.move(player)
	player.has_control = false
	is_dashing = true
	player.ghost_timer.start()
	await player.get_tree().create_timer(dash_time).timeout
	player.ghost_timer.stop()
	player.has_control = true
	hitbox.queue_free()
	player.hurtbox_component.enable()
	player.velocity_component.set_max_speed(prev_max_speed)
	effect_finished.emit()
	
	await player.get_tree().create_timer(dash_cooldown).timeout
	is_dashing = false
	player.using_essence = false
