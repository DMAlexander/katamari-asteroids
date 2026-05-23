extends Area2D

enum DebrisSize {
	LARGE,
	MEDIUM,
	SMALL
}

@export var health := 3
@export var mass_pickup_scene: PackedScene
@export var size := DebrisSize.LARGE
##@export var debris_scene: PackedScene

var velocity := Vector2.ZERO

func _ready():
	apply_size_data()
	
func apply_size_data():

	match size:

		DebrisSize.LARGE:
			scale = Vector2.ONE * 2.0
			health = 6

		DebrisSize.MEDIUM:
			scale = Vector2.ONE * 1.3
			health = 3

		DebrisSize.SMALL:
			scale = Vector2.ONE * 0.7
			health = 1

func _process(delta):

	global_position += velocity * delta

	velocity *= 0.98

func take_damage(amount: int):
	health -= amount

	if health <= 0:
		destroy()


func destroy():
	
	var gm = get_tree().current_scene.get_node("GameManager")

	if gm:
		gm.add_kill()

	match size:

		DebrisSize.LARGE:
			spawn_split_debris(DebrisSize.MEDIUM, 2)

		DebrisSize.MEDIUM:
			spawn_split_debris(DebrisSize.SMALL, 2)

		DebrisSize.SMALL:
			spawn_mass()

	queue_free()

func spawn_split_debris(new_size, amount):

	for i in range(amount):

		var new_debris = preload("res://scenes/debris/debris.tscn").instantiate()

		get_tree().current_scene.add_child(new_debris)

		new_debris.global_position = global_position

		new_debris.size = new_size
		new_debris.apply_size_data()

		# Random burst direction
		var angle = randf_range(0, TAU)

		var burst = Vector2.RIGHT.rotated(angle) * randf_range(80, 180)

		new_debris.velocity = burst

func spawn_mass():

	for i in range(2):

		if mass_pickup_scene == null:
			break

		var pickup = mass_pickup_scene.instantiate()

		get_tree().current_scene.add_child(pickup)

		pickup.global_position = global_position + Vector2(
			randf_range(-8, 8),
			randf_range(-8, 8)
		)

func get_ram_requirement():

	match size:

		DebrisSize.SMALL:
			return 5.0

		DebrisSize.MEDIUM:
			return 12.0

		DebrisSize.LARGE:
			return 25.0

	return 999.0

# Laser collision (optional safety hook)
func _on_area_entered(area):

	if area.has_method("queue_free"):
		area.queue_free()


func _on_body_entered(body):

	if body.has_method("add_mass"):

		if body.mass >= get_ram_requirement():

			call_deferred("destroy")
