extends Node2D

@onready var cpu_particles: CPUParticles2D = %CPUParticles2D

func _ready():
	ghosting()
 
func set_property(tx_pos):
	global_position = tx_pos
 
func ghosting():
	cpu_particles.emitting = true
	await cpu_particles.finished
	queue_free()
