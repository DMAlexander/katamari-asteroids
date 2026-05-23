extends Area2D

@export var value := 1.0

@export var acceleration := 1400.0
@export var max_speed := 900.0
@export var drag := 0.96

var target: Node2D = null
var velocity := Vector2.ZERO
var can_seek := false

func _ready():
	await get_tree().create_timer(0.15).timeout
	can_seek = true

	# Small random burst when spawned
	velocity = Vector2(
		randf_range(-150, 150),
		randf_range(-150, 150)
	)

func _process(delta):

	if target and can_seek:

		var dir = (target.global_position - global_position).normalized()

		var pull_strength = acceleration

		if target.has_method("get_magnet_strength"):
			pull_strength = target.get_magnet_strength()

		velocity += dir * pull_strength * delta

	velocity *= drag

	velocity = velocity.limit_length(max_speed)

	global_position += velocity * delta


func set_target(t):
	target = t


func _on_body_entered(body):

	if body.has_method("add_mass"):

		body.add_mass(value)

		queue_free()
