extends Control
# Rennansicht (Top-Down-Grundgerüst): Ein Fahrzeug fährt automatisch eine
# Strecke ab, keine Spielereingabe. KI-Gegner (siehe ai_opponent_generator.gd)
# bilden ein volles, regelkonformes Feld und fahren mit einer aus den
# StatsCalculator-Werten abgeleiteten Grundpace, die von Runde zu Runde leicht
# schwankt (an Zuverlässigkeit/Reifenverschleiß gekoppelt) – so verschieben
# sich Positionen während des Rennens tatsächlich, statt von Anfang an
# festzustehen. Kein echtes Fahrphysik-Modell, sondern ein Platzhalter.

const AI_OPPONENT_COUNT := 19  # 20 Fahrzeuge insgesamt inkl. Spieler, volles DTM-1990-Feld
const LANE_OFFSETS: Array[float] = [0.0, 10.0, -10.0, 20.0, -20.0, 14.0, -14.0, 6.0, -6.0]

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
var _rng: RandomNumberGenerator
# [{name, path_follow, base_lap_time_s, current_lap_time_s, variance,
#   total_progress, laps_done, finished, finish_time_s}]
var ai_opponents: Array = []


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

	_rng = RandomNumberGenerator.new()
	_rng.randomize()

	_setup_track(track)
	_setup_pace(track)
	_spawn_ai_opponents(track)
	_update_live_position()

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
	path_follow.v_offset = 0.0  # Spieler fährt auf der Mittelspur, KI fächert seitlich auf

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


# Grobe Volatilitäts-Schätzung aus Zuverlässigkeit/Verschleiß: unzuverlässigere
# oder verschleißanfälligere Autos schwanken stärker von Runde zu Runde.
# Platzhalter-Balancing-Konstanten, analog zu denen in stats_calculator.gd.
func _variance_for(stats: Dictionary) -> float:
	var failure_norm: float = clamp(stats["failure_risk_pct"] / 40.0, 0.0, 1.0)
	var wear_norm: float = clamp(stats["tire_wear_rate"] / 3.0, 0.0, 1.0)
	return clamp(0.012 + failure_norm * 0.035 + wear_norm * 0.02, 0.012, 0.08)


func _generate_ai_colors(count: int) -> Array:
	var colors: Array = []
	# Roten Bereich um den Hue-Nullpunkt aussparen, das ist die Spieler-Farbe.
	var hue_start := 0.08
	var hue_span := 0.84
	for i in range(count):
		var hue: float = hue_start + hue_span * (float(i) / max(count, 1))
		colors.append(Color.from_hsv(hue, 0.65, 0.9))
	return colors


func _lane_offset(index: int) -> float:
	return LANE_OFFSETS[index % LANE_OFFSETS.size()]


func _spawn_ai_opponents(track: Dictionary) -> void:
	var generated: Array = AiOpponentGenerator.generate(AI_OPPONENT_COUNT, PartsDatabase, _rng)
	var colors: Array = _generate_ai_colors(generated.size())

	for i in range(generated.size()):
		var entry: Dictionary = generated[i]
		var stats: Dictionary = StatsCalculator.calculate(entry["car"], PartsDatabase)
		var base_pace: float = _lap_time_from_stats(stats, track)

		var opponent_follow := PathFollow2D.new()
		opponent_follow.loop = true
		opponent_follow.rotates = true
		opponent_follow.v_offset = _lane_offset(i + 1)  # Spur 0 bleibt dem Spieler vorbehalten

		var sprite := Polygon2D.new()
		sprite.color = colors[i]
		sprite.polygon = PackedVector2Array([Vector2(-12, -6), Vector2(12, -6), Vector2(12, 6), Vector2(-12, 6)])
		opponent_follow.add_child(sprite)
		path_2d.add_child(opponent_follow)

		ai_opponents.append({
			"name": entry["name"],
			"path_follow": opponent_follow,
			"base_lap_time_s": base_pace,
			"current_lap_time_s": base_pace,
			"variance": _variance_for(stats),
			"total_progress": 0.0,
			"laps_done": 0,
			"finished": false,
			"finish_time_s": 0.0,
		})


func _process(delta: float) -> void:
	if finished:
		return

	elapsed += delta
	total_progress += delta / lap_time_s
	laps_done = int(floor(total_progress))
	path_follow.progress_ratio = fmod(total_progress, 1.0)

	for opp in ai_opponents:
		_advance_opponent(opp, delta)

	_update_live_position()

	if laps_done >= total_laps:
		_finish_race()
		return

	_update_hud()


func _advance_opponent(opp: Dictionary, delta: float) -> void:
	if opp["finished"]:
		return

	opp["total_progress"] += delta / opp["current_lap_time_s"]
	var new_laps_done: int = int(floor(opp["total_progress"]))
	if new_laps_done > opp["laps_done"]:
		opp["laps_done"] = new_laps_done
		opp["current_lap_time_s"] = opp["base_lap_time_s"] * (1.0 + _rng.randf_range(-opp["variance"], opp["variance"]))

	if opp["total_progress"] >= total_laps:
		opp["finished"] = true
		opp["finish_time_s"] = elapsed
		opp["total_progress"] = float(total_laps)
		opp["path_follow"].progress_ratio = 0.0
	else:
		opp["path_follow"].progress_ratio = fmod(opp["total_progress"], 1.0)


# Baut die aktuelle Reihenfolge (Spieler + alle KI-Autos) nach zurückgelegter
# Distanz auf; im Ziel angekommene Autos liegen immer vor noch fahrenden.
func _ranking_entries() -> Array:
	var entries: Array = [{
		"name": "Du", "is_player": true, "finished": false,
		"total_progress": total_progress, "finish_time_s": 0.0,
	}]
	for opp in ai_opponents:
		entries.append({
			"name": opp["name"], "is_player": false, "finished": opp["finished"],
			"total_progress": opp["total_progress"], "finish_time_s": opp["finish_time_s"],
		})
	entries.sort_custom(_is_ahead)
	return entries


func _is_ahead(a: Dictionary, b: Dictionary) -> bool:
	if a["finished"] != b["finished"]:
		return a["finished"]
	if a["finished"] and b["finished"]:
		return a["finish_time_s"] < b["finish_time_s"]
	return a["total_progress"] > b["total_progress"]


func _update_live_position() -> void:
	var entries: Array = _ranking_entries()
	for i in range(entries.size()):
		if entries[i]["is_player"]:
			position_label.text = "Platz %d/%d" % [i + 1, entries.size()]
			return


func _update_hud() -> void:
	lap_label.text = "Runde %d/%d" % [min(laps_done + 1, total_laps), total_laps]
	time_label.text = "Zeit: %s" % _format_time(elapsed)


func _finish_race() -> void:
	finished = true
	lap_label.text = "Runde %d/%d" % [total_laps, total_laps]
	finish_time_label.text = "Zielzeit: %s" % _format_time(elapsed)
	finish_panel.visible = true

	# Wer beim Zieleinlauf des Spielers noch unterwegs ist, bekommt seine
	# Restdistanz mit der zuletzt gültigen Pace hochgerechnet.
	for opp in ai_opponents:
		if not opp["finished"]:
			var remaining_laps: float = float(total_laps) - opp["total_progress"]
			opp["finish_time_s"] = elapsed + remaining_laps * opp["current_lap_time_s"]
			opp["finished"] = true

	GameState.advance_race()
	_show_results()


func _show_results() -> void:
	var entries: Array = [{"name": "Du", "total_time_s": elapsed, "is_player": true}]
	for opp in ai_opponents:
		entries.append({
			"name": opp["name"],
			"total_time_s": opp["finish_time_s"],
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
