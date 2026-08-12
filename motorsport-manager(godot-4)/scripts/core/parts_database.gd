extends Node
# Autoload-Singleton: lädt alle Bauteil- und Regelwerk-JSON-Dateien beim Spielstart.
#
# EINRICHTUNG IN GODOT:
# Project > Project Settings > Autoload
#   Path: res://scripts/core/parts_database.gd
#   Node Name: PartsDatabase
#   -> "Add" klicken
# Danach ist "PartsDatabase" im ganzen Projekt als globaler Zugriffspunkt verfügbar,
# z.B. PartsDatabase.get_part("engine", "E1")

const PARTS_PATH := "res://data/parts/"
const REGULATIONS_PATH := "res://data/regulations/"
const CARS_PATH := "res://data/cars/showroom.json"
const TRACKS_PATH := "res://data/tracks/tracks.json"

const PART_FILES := {
	"engine": "engines.json",
	"gearbox": "gearboxes.json",
	"chassis": "chassis.json",
	"tire": "tires.json",
	"brake": "brakes.json",
	"aero": "aero.json",
}

# Neue Regelwerke hier eintragen, sobald weitere Saisons/Klassen dazukommen.
const REGULATION_FILES := [
	"dtm_demo_2026.json",
]

var parts: Dictionary = {}       # category -> { id: Dictionary(part_data) }
var regulations: Dictionary = {} # regulation_id -> Dictionary(regulation_data)
var cars: Dictionary = {}        # car_id -> Dictionary(car_data), z.B. für das Autohaus
var tracks: Array = []           # Array[Dictionary(track_data)], sortiert nach track_number


func _ready() -> void:
	_load_all_parts()
	_load_all_regulations()
	_load_all_cars()
	_load_all_tracks()


func _load_all_parts() -> void:
	for category in PART_FILES.keys():
		var file_path: String = PARTS_PATH + PART_FILES[category]
		var list: Array = _load_json_array(file_path)
		var indexed: Dictionary = {}
		for part in list:
			indexed[part["id"]] = part
		parts[category] = indexed
		print("PartsDatabase: %d %s-Bauteile geladen" % [indexed.size(), category])


func _load_all_regulations() -> void:
	for file_name in REGULATION_FILES:
		var data: Dictionary = _load_json_dict(REGULATIONS_PATH + file_name)
		if data.has("regulation_id"):
			regulations[data["regulation_id"]] = data
	print("PartsDatabase: %d Regelwerk(e) geladen" % regulations.size())


func _load_all_cars() -> void:
	var list: Array = _load_json_array(CARS_PATH)
	for car_data in list:
		cars[car_data["id"]] = car_data
	print("PartsDatabase: %d kaufbare(s) Fahrzeug(e) geladen" % cars.size())


func _load_all_tracks() -> void:
	tracks = _load_json_array(TRACKS_PATH)
	tracks.sort_custom(func(a, b): return a["track_number"] < b["track_number"])
	print("PartsDatabase: %d Strecke(n) geladen" % tracks.size())


func get_part(category: String, id: String) -> Dictionary:
	if parts.has(category) and parts[category].has(id):
		return parts[category][id]
	push_error("PartsDatabase: Bauteil nicht gefunden: %s/%s" % [category, id])
	return {}


func get_all_parts(category: String) -> Array:
	if parts.has(category):
		return parts[category].values()
	return []


func get_regulation(regulation_id: String) -> Dictionary:
	return regulations.get(regulation_id, {})


func get_car(id: String) -> Dictionary:
	if cars.has(id):
		return cars[id]
	push_error("PartsDatabase: Fahrzeug nicht gefunden: %s" % id)
	return {}


func get_all_cars() -> Array:
	return cars.values()


func get_track(id: String) -> Dictionary:
	for track in tracks:
		if track["id"] == id:
			return track
	push_error("PartsDatabase: Strecke nicht gefunden: %s" % id)
	return {}


func get_all_tracks() -> Array:
	return tracks


# ---- interne Hilfsfunktionen ----

func _load_json_array(path: String) -> Array:
	var result = _load_json(path)
	return result if result is Array else []


func _load_json_dict(path: String) -> Dictionary:
	var result = _load_json(path)
	return result if result is Dictionary else {}


func _load_json(path: String):
	if not FileAccess.file_exists(path):
		push_error("PartsDatabase: Datei nicht gefunden: %s" % path)
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_error("PartsDatabase: JSON-Fehler in %s: %s" % [path, json.get_error_message()])
		return null
	return json.data
