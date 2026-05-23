extends Node

var run_time := 0.0
var run_active := true

var debris_killed := 0
var final_mass := 0.0

@onready var results_label: Label = $"../UI/ResultsLabel"

func _ready():
	if results_label:
		results_label.visible = false

func _process(delta):

	if not run_active:
		return

	run_time += delta


# -------------------------
# EVENTS FROM GAME
# -------------------------

func add_kill():
	debris_killed += 1


func set_final_mass(mass: float):
	final_mass = mass


# -------------------------
# END RUN
# -------------------------

func end_run():

	run_active = false

	var score = int(run_time * 10.0 + debris_killed * 50.0 + final_mass * 100.0)

	if results_label:
		results_label.visible = true
		results_label.text = get_results_text(score)

func get_results_text(score: int) -> String:

	return """
RUN COMPLETE

Time Survived: %0.1f
Debris Destroyed: %d
Final Mass: %0.1f

SCORE: %d
""" % [run_time, debris_killed, final_mass, score]
