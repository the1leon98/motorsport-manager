extends Control
# Rennansicht (Top-Down-Grundgerüst): Ein Fahrzeug fährt automatisch eine
# Strecke ab, keine Spielereingabe, kein Gegner (siehe Roadmap Phase I).
# Die Fahrleistung (Rundenzeit) leitet sich grob aus den StatsCalculator-
# Werten ab – kein echtes Fahrphysik-Modell, sondern ein Platzhalter.

@onready var path_2d: Path2D = $TrackContainer/Path2D
@onready var path_follow: PathFollow2D = $TrackContainer/Path2D/PathFollow2D
@onready var track_line: Line2D = $TrackContainer/TrackLine
@onready var lap_label: Label = $Hud/LapLabel
@onready var time_label: Label = $Hud/TimeLabel
@onready var finish_panel: CenterContainer = $FinishPanel
@onready var finish_time_label: Label = $FinishPanel/VBoxContainer/FinishTimeLabel
@onready var back_button: Button = $FinishPanel/VBoxContainer/BackButton

var total_laps: int = 1
var lap_time_s: float = 60.0
var elapsed: float = 0.0
var total_progress: float = 0.0
var laps_done: int = 0
var finished: bool = false


func _ready() -> void:
	finish_panel.visible = false
	back_button.pressed.connect(func(): SceneManager.goto_screen("hub"))

	if not GameState.race_cleared or not GameState.has_any_car():
		SceneManager.goto_screen("pit_lane")
		return

	var track: Dictionary = GameState.get_current_track()
	if track.is_empty() or not track.get("playable", false):
		SceneManager.goto_screen("season")
		return

	_setup_track(track)
	_setup_pace(track)

	GameState.race_cleared = false  # verbraucht: nächstes Rennen braucht eine neue Boxengasse-Freigabe
	_update_hud()


func _setup_track(track: Dictionary) -> void:
	var waypoints: Array = track["waypoints"]

	var curve := Curve2D.new()
	for wp in waypoints:
		curve.add_point(Vector2(wp["x"], wp["y"]))
	path_2d.curve = curve
	path_follow.loop = true
	path_follow.rotates = true

	var closed_points: PackedVector2Array = PackedVector2Array()
	for wp in waypoints:
		closed_points.append(Vector2(wp["x"], wp["y"]))
	closed_points.append(Vector2(waypoints[0]["x"], waypoints[0]["y"]))
	track_line.points = closed_points

	total_laps = int(track["laps"])


func _setup_pace(track: Dictionary) -> void:
	var car: CarConfig = GameState.get_selected_car()
	var stats: Dictionary = StatsCalculator.calculate(car, PartsDatabase)

	var corner_grip_norm: float = clamp(stats["corner_grip_index"] / 15.0, 0.0, 1.0)
	var avg_speed_kmh: float = stats["topspeed_kmh"] * lerp(0.45, 0.9, corner_grip_norm)
	var avg_speed_ms: float = avg_speed_kmh / 3.6

	var track_length_m: float = float(track["length_km"]) * 1000.0
	lap_time_s = track_length_m / avg_speed_ms


func _process(delta: float) -> void:
	if finished:
		return

	elapsed += delta
	total_progress += delta / lap_time_s
	laps_done = int(floor(total_progress))
	path_follow.progress_ratio = fmod(total_progress, 1.0)

	if laps_done >= total_laps:
		_finish_race()
		return

	_update_hud()


func _update_hud() -> void:
	lap_label.text = "Runde %d/%d" % [min(laps_done + 1, total_laps), total_laps]
	time_label.text = "Zeit: %s" % _format_time(elapsed)


func _finish_race() -> void:
	finished = true
	lap_label.text = "Runde %d/%d" % [total_laps, total_laps]
	finish_time_label.text = "Zielzeit: %s" % _format_time(elapsed)
	finish_panel.visible = true


func _format_time(t: float) -> String:
	var minutes: int = int(t) / 60
	var seconds: float = fmod(t, 60.0)
	return "%02d:%05.2f" % [minutes, seconds]
