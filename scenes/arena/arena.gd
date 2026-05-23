extends Node2D

@export var size := Vector2(2000, 1200)
@export var show_debug := true

@export var world_drift := Vector2(12, 4)

# -------------------------
# INIT
# -------------------------

func _ready():
	queue_redraw()


# -------------------------
# CORE BOUNDS API
# -------------------------

func get_bounds() -> Rect2:
	# Centered arena: (0,0) is world center
	return Rect2(-size * 0.5, size)


# -------------------------
# CAMERA CLAMP (CRITICAL)
# -------------------------

func clamp_camera_position(cam: Camera2D) -> Vector2:

	var bounds = get_bounds()

	# Correct world-space camera size
	var viewport_size = get_viewport_rect().size
	var visible_size = viewport_size / cam.zoom

	var half_view = visible_size * 0.5

	var min_pos = bounds.position + half_view
	var max_pos = bounds.end - half_view

	# Prevent invalid ranges (very high zoom edge case safety)
	if min_pos.x > max_pos.x:
		var cx = bounds.position.x + bounds.size.x * 0.5
		min_pos.x = cx
		max_pos.x = cx

	if min_pos.y > max_pos.y:
		var cy = bounds.position.y + bounds.size.y * 0.5
		min_pos.y = cy
		max_pos.y = cy

	var pos = cam.global_position

	pos.x = clamp(pos.x, min_pos.x, max_pos.x)
	pos.y = clamp(pos.y, min_pos.y, max_pos.y)

	return pos


# -------------------------
# DEBUG DRAW
# -------------------------

func _draw():

	if not show_debug:
		return

	var rect = get_bounds()

	# Arena fill (helps readability)
	draw_rect(rect, Color(0, 1, 0, 0.05), true)

	# Arena outline
	draw_rect(rect, Color(0, 1, 0, 0.3), false, 4.0)

	# Center crosshair
	draw_line(Vector2(-25, 0), Vector2(25, 0), Color(1, 1, 1, 0.4), 2)
	draw_line(Vector2(0, -25), Vector2(0, 25), Color(1, 1, 1, 0.4), 2)

	# Corner markers (debug alignment)
	var tl = rect.position
	var tr = Vector2(rect.end.x, rect.position.y)
	var bl = Vector2(rect.position.x, rect.end.y)
	var br = rect.end

	var c = Color(1, 1, 1, 0.25)

	draw_circle(tl, 8, c)
	draw_circle(tr, 8, c)
	draw_circle(bl, 8, c)
	draw_circle(br, 8, c)


# -------------------------
# OPTIONAL: CAMERA DEBUG OVERLAY
# -------------------------

func draw_camera_debug(cam: Camera2D):

	if not show_debug or cam == null:
		return

	var viewport_size = get_viewport_rect().size
	var visible_size = viewport_size / cam.zoom
	var rect = Rect2(cam.global_position - visible_size * 0.5, visible_size)

	# Camera view (blue)
	draw_rect(rect, Color(0.2, 0.6, 1.0, 0.2), true)
	draw_rect(rect, Color(0.2, 0.6, 1.0, 0.9), false, 2.0)
