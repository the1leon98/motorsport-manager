extends Resource
class_name SaveData
# Container für alles, was in einer Save-Datei landet. Team/CarConfig werden
# als eingebettete Sub-Resourcen automatisch mitgespeichert.

const CURRENT_FORMAT_VERSION := 1

@export var save_format_version: int = CURRENT_FORMAT_VERSION
@export var game_mode: String = "career"
@export var team: Team = null
