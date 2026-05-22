extends Area2D

@export var speed := 1200.0

var direction := Vector2.ZERO

func _process(delta):
	position += direction * speed * delta

func _on_area_entered(area):

	if area.has_method("take_damage"):
		area.take_damage(1)

	queue_free()
