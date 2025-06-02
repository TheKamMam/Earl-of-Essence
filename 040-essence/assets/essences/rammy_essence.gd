extends Essence

@export var invincibility_time := 3.0

func cast_effect() -> void:
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
	
	player.velocity_component.set_max_speed(200)
	player.hurtbox_component.disable()
	player.shader_player.play("rammy")
	
	await player.get_tree().create_timer(invincibility_time).timeout
	
	hitbox.queue_free()
	player.velocity_component.set_max_speed(125)
	player.hurtbox_component.enable()
	effect_finished.emit()
	player.using_essence = false
