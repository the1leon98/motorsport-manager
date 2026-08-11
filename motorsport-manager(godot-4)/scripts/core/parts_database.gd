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


func _ready() -> void:
	_load_all_parts()
	_load_all_regulations()


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
