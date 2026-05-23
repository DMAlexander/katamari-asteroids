extends Node2D

@export var size := Vector2(2000, 1200)
@export var show_debug := true

func _ready():
	queue_redraw()


# -------------------------
# CORE API
# -------------------------

func get_bounds() -> Rect2:
	# Centered arena: (0,0) is the middle of the world
	return Rect2(-size * 0.5, size)


# -------------------------
# DEBUG DRAW
# -------------------------

func _draw():

	if not show_debug:
		return

	var rect = get_bounds()

	# --- faint fill (helps readability) ---
	draw_rect(rect, Color(0, 1, 0, 0.05), true)

	# --- boundary outline ---
	draw_rect(rect, Color(0, 1, 0, 0.3), false, 4.0)

	# --- center crosshair ---
	draw_line(Vector2(-25, 0), Vector2(25, 0), Color(1, 1, 1, 0.4), 2)
	draw_line(Vector2(0, -25), Vector2(0, 25), Color(1, 1, 1, 0.4), 2)

	# --- corner markers (very useful for camera debugging) ---
	var tl = rect.position
	var tr = Vector2(rect.end.x, rect.position.y)
	var bl = Vector2(rect.position.x, rect.end.y)
	var br = rect.end

	var c = Color(1, 1, 1, 0.25)
	draw_circle(tl, 8, c)
	draw_circle(tr, 8, c)
	draw_circle(bl, 8, c)
	draw_circle(br, 8, c)
