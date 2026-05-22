extends CharacterBody2D

@export var acceleration := 500.0
@export var max_speed := 400.0
@export var rotation_speed := 3.0
@export var friction := 0.98

func _physics_process(delta):

	# Rotation
	var rotation_input := Input.get_axis("move_left", "move_right")
	rotation += rotation_input * rotation_speed * delta

	# Forward thrust
	if Input.is_action_pressed("move_forward"):
		var direction := Vector2.UP.rotated(rotation)
		velocity += direction * acceleration * delta

	# Clamp speed
	velocity = velocity.limit_length(max_speed)

	# Apply friction
##	velocity *= friction
	velocity = velocity.move_toward(Vector2.ZERO, 20 * delta)

	move_and_slide()
