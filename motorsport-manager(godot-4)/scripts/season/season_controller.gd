extends Control
# Saison-Ansicht: Kalender der 11 DTM-Demo-2026-Strecken. In der Beta ist nur
# das erste Rennen (Norring) tatsächlich spielbar; die übrigen 10 sind als
# Vorschau für die spätere Vollsaison gelistet, aber gesperrt.

@onready var list_container: VBoxContainer = $ScrollContainer/ListContainer
@onready var back_button: Button = $BackButton


func _ready() -> void:
	back_button.pressed.connect(func(): SceneManager.goto_screen("hub"))
	_populate()


func _populate() -> void:
	for track in PartsDatabase.get_all_tracks():
		list_container.add_child(_build_row(track))


func _build_row(track: Dictionary) -> Control:
	var row := PanelContainer.new()

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	row.add_child(hbox)

	var name_label := Label.new()
	name_label.custom_minimum_size = Vector2(260, 0)
	name_label.text = "%d. %s" % [track["track_number"], track["name"]]
	hbox.add_child(name_label)

	var info_label := Label.new()
	info_label.custom_minimum_size = Vector2(220, 0)
	info_label.text = "%.1f km · %d Kurven · %d Runden" % [track["length_km"], track["corners"], track["laps"]]
	hbox.add_child(info_label)

	var status_label := Label.new()
	status_label.custom_minimum_size = Vector2(180, 0)
	status_label.text = _status_text(track)
	hbox.add_child(status_label)

	var select_button := Button.new()
	select_button.text = "Fahren"
	select_button.disabled = not _is_selectable(track)
	select_button.pressed.connect(func(): SceneManager.goto_screen("pit_lane"))
	hbox.add_child(select_button)

	return row


func _is_selectable(track: Dictionary) -> bool:
	return track.get("playable", false) and track["track_number"] == GameState.team.current_race_number


func _status_text(track: Dictionary) -> String:
	if track["track_number"] < GameState.team.current_race_number:
		return "Absolviert"
	if track["track_number"] == GameState.team.current_race_number:
		return "Nächstes Rennen" if track.get("playable", false) else "Nächstes Rennen (nicht in der Demo spielbar)"
	return "Kommt später"
