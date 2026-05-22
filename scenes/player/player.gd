extends CharacterBody2D

@export var acceleration := 500.0
@export var max_speed := 400.0
@export var rotation_speed := 3.0
@export var friction := 0.98

@export var laser_scene: PackedScene
@export var fire_rate := 0.15

## Make player attract mass
@export var magnet_radius := 200.0
@export var magnet_strength := 8.0

## Handling player ship growth
var mass := 1.0
@export var mass_growth_scale := 0.02
@onready var mass_label = get_tree().current_scene.get_node("UI/MassLabel")

var can_shoot := true
var visual_scale := 1.0

func _ready():
	update_scale()
	update_ui()

func _physics_process(delta):

	visual_scale = lerp(visual_scale, 1.0, 8.0 * delta)

	if abs(visual_scale - 1.0) > 0.001:
		update_scale()

	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

	# Rotation
	var rotation_input := Input.get_axis("move_left", "move_right")
	rotation += rotation_input * rotation_speed * delta

	# Forward thrust
	if Input.is_action_pressed("move_forward"):
		var direction := Vector2.UP.rotated(rotation)
		velocity += direction * acceleration * delta

	velocity = velocity.limit_length(max_speed)

	# Drag
	velocity = velocity.move_toward(Vector2.ZERO, 20 * delta)

	move_and_slide()

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

func update_ui():

	mass_label.text = "Mass: " + str(snapped(mass, 0.1))

func update_scale():

	var base_scale = 1.0 + mass * mass_growth_scale

	scale = Vector2.ONE * base_scale * visual_scale


func _on_magnet_area_area_entered(area):
	if area.has_method("set_target"):
		area.set_target(self)
