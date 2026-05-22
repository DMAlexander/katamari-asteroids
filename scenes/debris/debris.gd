extends Area2D

@export var health := 3
@export var mass_pickup_scene: PackedScene

func take_damage(amount: int):
	health -= amount

	if health <= 0:
		destroy()


func destroy():

	# Spawn mass pickups
	for i in range(2):
		if mass_pickup_scene == null:
			break

		var pickup = mass_pickup_scene.instantiate()

		get_tree().current_scene.add_child(pickup)

		pickup.global_position = global_position + Vector2(
			randf_range(-8, 8),
			randf_range(-8, 8)
		)

	queue_free()


# Laser collision (optional safety hook)
func _on_area_entered(area):

	if area.has_method("queue_free"):
		area.queue_free()
