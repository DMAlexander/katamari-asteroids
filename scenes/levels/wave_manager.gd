extends Node

@export var debris_scene: PackedScene
@export var spawn_area := Vector2(1000, 600)

var time_alive := 0.0
var spawn_timer := 0.0

@export var base_spawn_rate := 2.0
@export var min_spawn_rate := 0.4

func _process(delta):

	time_alive += delta

	# spawn faster over time
	var difficulty = clamp(time_alive / 120.0, 0.0, 1.0)
	var spawn_rate = lerp(base_spawn_rate, min_spawn_rate, difficulty)

	spawn_timer -= delta

	if spawn_timer <= 0.0:
		spawn_debris(difficulty)
		spawn_timer = spawn_rate

func spawn_debris(difficulty: float):

	var debris = debris_scene.instantiate()
	get_tree().current_scene.add_child(debris)

	# random position around screen edges
	var side = randi() % 4
	var pos = Vector2.ZERO

	match side:
		0: pos = Vector2(randf() * spawn_area.x, -50)
		1: pos = Vector2(randf() * spawn_area.x, spawn_area.y + 50)
		2: pos = Vector2(-50, randf() * spawn_area.y)
		3: pos = Vector2(spawn_area.x + 50, randf() * spawn_area.y)

	debris.global_position = pos

	# scale difficulty affects size
	var roll = randf()

	if roll < 0.5 + difficulty * 0.2:
		debris.size = debris.DebrisSize.SMALL
	elif roll < 0.8:
		debris.size = debris.DebrisSize.MEDIUM
	else:
		debris.size = debris.DebrisSize.LARGE

	debris.apply_size_data()
