extends CharacterBody2D

# -------------------------
# MOVEMENT
# -------------------------
@export var acceleration := 500.0
@export var max_speed := 400.0
@export var rotation_speed := 3.0

# -------------------------
# SHOOTING
# -------------------------
@export var laser_scene: PackedScene
@export var fire_rate := 0.15
var can_shoot := true

# -------------------------
# MASS SYSTEM
# -------------------------
var mass := 1.0
@export var mass_growth_scale := 0.02
var visual_scale := 1.0

# -------------------------
# UI
# -------------------------
@onready var mass_label = get_tree().current_scene.get_node("UI/MassLabel")

# -------------------------
# MAGNET SYSTEM
# -------------------------
@export var base_magnet_radius := 200.0
@export var magnet_growth := 12.0
@export var max_magnet_radius := 900.0

# -------------------------
# CAMERA
# -------------------------
@onready var camera = $Camera2D
@export var zoom_smoothing := 6.0
@export var min_zoom := 1.5
@export var max_zoom := 0.7

# -------------------------
# PHYSICS TUNING
# -------------------------
@export var min_acceleration := 120.0
@export var min_rotation_speed := 1.2

# -------------------------
# LIFECYCLE
# -------------------------
func _ready():
	update_scale()
	update_ui()
	update_magnet()


func _physics_process(delta):

	# smooth visual pulse after pickup
	visual_scale = lerp(visual_scale, 1.0, 8.0 * delta)
	update_scale()

	# input shooting
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

	# rotation
	var rotation_input := Input.get_axis("move_left", "move_right")
	rotation += rotation_input * get_effective_rotation_speed() * delta

	# thrust
	if Input.is_action_pressed("move_forward"):
		var direction := Vector2.UP.rotated(rotation)
		velocity += direction * get_effective_acceleration() * delta

	# speed cap
	velocity = velocity.limit_length(max_speed)

	# drag
	var drag_strength = max(4.0 / mass, 0.5)
	velocity = velocity.move_toward(Vector2.ZERO, drag_strength * delta * 20)

	# physics step
	apply_pre_move_bounds()
	move_and_slide()
	apply_post_move_bounds()
	update_camera(delta)


# -------------------------
# MOVEMENT HELPERS
# -------------------------

func get_effective_acceleration():
	return max(acceleration / mass, min_acceleration)


func get_effective_rotation_speed():
	return max(rotation_speed / sqrt(mass), min_rotation_speed)

func apply_pre_move_bounds():
	var arena = get_tree().current_scene.get_node("Arena")
	var bounds = arena.get_bounds()

	var pos = global_position

	# hard prevent starting outside bounds
	pos.x = clamp(pos.x, bounds.position.x, bounds.end.x)
	pos.y = clamp(pos.y, bounds.position.y, bounds.end.y)

	global_position = pos
	
func apply_post_move_bounds():

	var arena = get_tree().current_scene.get_node("Arena")
	var bounds = arena.get_bounds()

	var pos = global_position

	if pos.x < bounds.position.x:
		pos.x = bounds.position.x
		velocity.x = abs(velocity.x)

	elif pos.x > bounds.end.x:
		pos.x = bounds.end.x
		velocity.x = -abs(velocity.x)

	if pos.y < bounds.position.y:
		pos.y = bounds.position.y
		velocity.y = abs(velocity.y)

	elif pos.y > bounds.end.y:
		pos.y = bounds.end.y
		velocity.y = -abs(velocity.y)

	global_position = pos

# -------------------------
# CAMERA
# -------------------------

func update_camera(delta):

	var arena = get_tree().current_scene.get_node("Arena")

	# smooth follow
	camera.global_position = camera.global_position.lerp(
		global_position,
		zoom_smoothing * delta
	)

	# clamp to arena
	camera.global_position = arena.clamp_camera_position(camera)


func update_camera_zoom(delta):

	var zoom_ratio = clamp((mass - 1.0) / 40.0, 0.0, 1.0)
	var target_zoom = lerp(min_zoom, max_zoom, zoom_ratio)

	camera.zoom = camera.zoom.lerp(
		Vector2.ONE * target_zoom,
		zoom_smoothing * delta
	)


# -------------------------
# SHOOTING
# -------------------------

func shoot():

	can_shoot = false

	var laser = laser_scene.instantiate()
	get_tree().current_scene.add_child(laser)

	laser.global_position = $Muzzle.global_position
	laser.rotation = rotation
	laser.direction = Vector2.UP.rotated(rotation)

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true


# -------------------------
# MAGNET
# -------------------------

func update_magnet():

	var radius = min(
		base_magnet_radius + mass * magnet_growth,
		max_magnet_radius
	)

	var shape = $MagnetArea/CircleShape2D.shape

	if shape is CircleShape2D:
		shape.radius = radius


# -------------------------
# BOUNDS (IMPORTANT)
# -------------------------

func apply_player_bounds():

	var arena = get_tree().current_scene.get_node("Arena")
	var bounds = arena.get_bounds()

	var pos = global_position

	if pos.x < bounds.position.x:
		pos.x = bounds.position.x
		velocity.x = abs(velocity.x)

	elif pos.x > bounds.end.x:
		pos.x = bounds.end.x
		velocity.x = -abs(velocity.x)

	if pos.y < bounds.position.y:
		pos.y = bounds.position.y
		velocity.y = abs(velocity.y)

	elif pos.y > bounds.end.y:
		pos.y = bounds.end.y
		velocity.y = -abs(velocity.y)

	global_position = pos


# -------------------------
# MASS SYSTEM
# -------------------------

func add_mass(amount: float):

	mass += amount
	visual_scale = 1.08

	update_scale()
	update_ui()
	update_magnet()


func update_scale():

	var base_scale = 1.0 + mass * mass_growth_scale
	scale = Vector2.ONE * base_scale * visual_scale


func update_ui():

	mass_label.text = (
		"Mass: " + str(snappedf(mass, 0.1)) +
		"\nAccel: " + str(snappedf(get_effective_acceleration(), 1)) +
		"\nTurn: " + str(snappedf(get_effective_rotation_speed(), 0.1))
	)


# -------------------------
# GAME END
# -------------------------

func end_run():

	var gm = get_tree().current_scene.get_node("GameManager")

	if gm:
		gm.set_final_mass(mass)
		gm.end_run()


func _on_magnet_area_area_entered(area):
	print("MAGNET HIT:", area.name)

	if area.has_method("set_target"):
		area.set_target(self)
