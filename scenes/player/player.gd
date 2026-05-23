extends CharacterBody2D

@export var acceleration := 500.0
@export var max_speed := 400.0
@export var rotation_speed := 3.0
@export var friction := 0.98

@export var laser_scene: PackedScene
@export var fire_rate := 0.15

## Handling player ship growth
var mass := 1.0
@export var mass_growth_scale := 0.02
@onready var mass_label = get_tree().current_scene.get_node("UI/MassLabel")

@export var min_acceleration := 120.0
@export var min_rotation_speed := 1.2

@export var min_zoom := 1.5
@export var max_zoom := 0.7
@export var zoom_smoothing := 4.0

@onready var camera = $Camera2D

@export var base_magnet_radius := 200.0
@export var magnet_growth := 12.0
@export var max_magnet_radius := 900.0

var can_shoot := true
var visual_scale := 1.0

func _ready():
	update_scale()
	update_ui()
	update_magnet()

func _physics_process(delta):

	visual_scale = lerp(visual_scale, 1.0, 8.0 * delta)

	if abs(visual_scale - 1.0) > 0.001:
		update_scale()

	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
		
	if Input.is_action_just_pressed("ui_cancel"):
		end_run()

	# Rotation
	var rotation_input := Input.get_axis("move_left", "move_right")
	rotation += rotation_input * get_effective_rotation_speed() * delta

	# Forward thrust
	if Input.is_action_pressed("move_forward"):
		var direction := Vector2.UP.rotated(rotation)
		velocity += direction * get_effective_acceleration() * delta

	velocity = velocity.limit_length(max_speed)

	# Drag
	var drag_strength = max(4.0 / mass, 0.5)
	velocity = velocity.move_toward(Vector2.ZERO, drag_strength * delta * 20)

	update_camera_zoom(delta)
	move_and_slide()

func get_effective_acceleration():

	return max(
		acceleration / mass,
		min_acceleration
	)


func get_effective_rotation_speed():

	return max(
		rotation_speed / sqrt(mass),
		min_rotation_speed
	)

func get_magnet_strength():

	return 1400.0 + mass * 60.0

func update_camera_zoom(delta):

	# Convert mass into a 0→1 ratio
	var zoom_ratio = clamp((mass - 1.0) / 40.0, 0.0, 1.0)

	# Interpolate between min and max zoom
	var target_zoom = lerp(min_zoom, max_zoom, zoom_ratio)

	# Smoothly move camera zoom
	camera.zoom = camera.zoom.lerp(
		Vector2.ONE * target_zoom,
		zoom_smoothing * delta
	)

func end_run():
	var gm = get_tree().current_scene.get_node("GameManager")

	if gm:
		gm.set_final_mass(mass)
		gm.end_run()

func shoot():

	can_shoot = false

	var laser = laser_scene.instantiate()

	get_tree().current_scene.add_child(laser)

	laser.global_position = $Muzzle.global_position
	laser.rotation = rotation

	laser.direction = Vector2.UP.rotated(rotation)

	await get_tree().create_timer(fire_rate).timeout

	can_shoot = true

func update_magnet():

	var radius = min(
		base_magnet_radius + mass * magnet_growth,
		max_magnet_radius
	)

	var shape = $MagnetArea/CircleShape2D.shape

	if shape is CircleShape2D:
		shape.radius = radius

# -------------------------
# MASS SYSTEM
# -------------------------

func add_mass(amount: float):

	print('amount:', amount)
	mass += amount
	print('mass:', mass)

	# Tiny absorption pulse
	visual_scale = 1.08

	update_scale()

	update_ui()
	update_magnet()

func update_ui():

	mass_label.text = \
	"Mass: " + str(snappedf(mass, 0.1)) + \
	"\nAccel: " + str(snappedf(get_effective_acceleration(), 1)) + \
	"\nTurn: " + str(snappedf(get_effective_rotation_speed(), 0.1))

func update_scale():

	var base_scale = 1.0 + mass * mass_growth_scale

	scale = Vector2.ONE * base_scale * visual_scale


func _on_magnet_area_area_entered(area):
	if area.has_method("set_target"):
		area.set_target(self)
