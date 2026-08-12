extends Control
# Rennansicht (Top-Down-Grundgerüst): Ein Fahrzeug fährt automatisch eine
# Strecke ab, keine Spielereingabe. KI-Gegner (siehe ai_opponent_generator.gd)
# fahren als Platzhalter-Konkurrenz mit fester Pace mit; da alle Fahrzeuge in
# diesem Modell konstante Pace fahren, ergibt sich die Zielreihenfolge direkt
# aus dem Vergleich der Rundenzeiten. Die Fahrleistung selbst leitet sich grob
# aus den StatsCalculator-Werten ab – kein echtes Fahrphysik-Modell, sondern
# ein Platzhalter.

const AI_OPPONENT_COUNT := 5
const AI_CAR_COLORS: Array[Color] = [
	Color(0.2, 0.4, 0.9), Color(0.95, 0.75, 0.1), Color(0.55, 0.2, 0.85),
	Color(0.15, 0.75, 0.55), Color(0.9, 0.5, 0.15),
]

@onready var path_2d: Path2D = $TrackContainer/Path2D
@onready var path_follow: PathFollow2D = $TrackContainer/Path2D/PathFollow2D
@onready var track_line: Line2D = $TrackContainer/TrackLine
@onready var lap_label: Label = $Hud/LapLabel
@onready var time_label: Label = $Hud/TimeLabel
@onready var position_label: Label = $Hud/PositionLabel
@onready var finish_panel: CenterContainer = $FinishPanel
@onready var finish_time_label: Label = $FinishPanel/VBoxContainer/FinishTimeLabel
@onready var results_list: VBoxContainer = $FinishPanel/VBoxContainer/ResultsList
@onready var back_button: Button = $FinishPanel/VBoxContainer/BackButton

var total_laps: int = 1
var lap_time_s: float = 60.0
var elapsed: float = 0.0
var total_progress: float = 0.0
var laps_done: int = 0
var finished: bool = false
var ai_opponents: Array = []  # [{name: String, path_follow: PathFollow2D, lap_time_s: float}]


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
	_spawn_ai_opponents(track)
	_update_position_estimate()

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
	lap_time_s = _lap_time_from_stats(stats, track)


func _lap_time_from_stats(stats: Dictionary, track: Dictionary) -> float:
	var corner_grip_norm: float = clamp(stats["corner_grip_index"] / 15.0, 0.0, 1.0)
	var avg_speed_kmh: float = stats["topspeed_kmh"] * lerp(0.45, 0.9, corner_grip_norm)
	var avg_speed_ms: float = avg_speed_kmh / 3.6

	var track_length_m: float = float(track["length_km"]) * 1000.0
	return track_length_m / avg_speed_ms


func _spawn_ai_opponents(track: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var generated: Array = AiOpponentGenerator.generate(AI_OPPONENT_COUNT, PartsDatabase, rng)
	for i in range(generated.size()):
		var entry: Dictionary = generated[i]
		var stats: Dictionary = StatsCalculator.calculate(entry["car"], PartsDatabase)

		var opponent_follow := PathFollow2D.new()
		opponent_follow.loop = true
		opponent_follow.rotates = true

		var sprite := Polygon2D.new()
		sprite.color = AI_CAR_COLORS[i % AI_CAR_COLORS.size()]
		sprite.polygon = PackedVector2Array([Vector2(-12, -6), Vector2(12, -6), Vector2(12, 6), Vector2(-12, 6)])
		opponent_follow.add_child(sprite)
		path_2d.add_child(opponent_follow)

		ai_opponents.append({
			"name": entry["name"],
			"path_follow": opponent_follow,
			"lap_time_s": _lap_time_from_stats(stats, track),
		})


func _update_position_estimate() -> void:
	var better_count: int = 0
	for opp in ai_opponents:
		if opp["lap_time_s"] < lap_time_s:
			better_count += 1
	position_label.text = "Platz %d/%d" % [better_count + 1, ai_opponents.size() + 1]


func _process(delta: float) -> void:
	if finished:
		return

	elapsed += delta
	total_progress += delta / lap_time_s
	laps_done = int(floor(total_progress))
	path_follow.progress_ratio = fmod(total_progress, 1.0)

	for opp in ai_opponents:
		opp["path_follow"].progress_ratio = fmod(elapsed / opp["lap_time_s"], 1.0)

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
	GameState.advance_race()
	_show_results()


func _show_results() -> void:
	var entries: Array = [{"name": "Du", "total_time_s": elapsed, "is_player": true}]
	for opp in ai_opponents:
		entries.append({
			"name": opp["name"],
			"total_time_s": opp["lap_time_s"] * total_laps,
			"is_player": false,
		})
	entries.sort_custom(func(a, b): return a["total_time_s"] < b["total_time_s"])

	for child in results_list.get_children():
		child.queue_free()

	var player_position: int = 1
	for i in range(entries.size()):
		var entry: Dictionary = entries[i]
		if entry["is_player"]:
			player_position = i + 1

		var row := Label.new()
		row.text = "%d. %s – %s" % [i + 1, entry["name"], _format_time(entry["total_time_s"])]
		if entry["is_player"]:
			row.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		results_list.add_child(row)

	position_label.text = "Platz %d/%d" % [player_position, entries.size()]


func _format_time(t: float) -> String:
	var minutes: int = int(t) / 60
	var seconds: float = fmod(t, 60.0)
	return "%02d:%05.2f" % [minutes, seconds]
