extends Node
# Autoload-Singleton: kapselt Szenenwechsel, damit jeder Screen über denselben
# Mechanismus zum nächsten wechselt, statt Pfade einzeln zu duplizieren.
#
# EINRICHTUNG IN GODOT:
# Project > Project Settings > Autoload
#   Path: res://scripts/core/scene_manager.gd
#   Node Name: SceneManager
#   -> "Add" klicken

const SCREENS := {
	"main_menu": "res://scenes/main_menu/MainMenu.tscn",
	"hub": "res://scenes/hub/HubScreen.tscn",
	"garage": "res://scenes/garage/GarageScreen.tscn",
	"autohaus": "res://scenes/autohaus/AutohausScreen.tscn",
	"pit_lane": "res://scenes/pit_lane/PitLaneScreen.tscn",
	"season": "res://scenes/season/SeasonScreen.tscn",
	"race": "res://scenes/race/RaceScreen.tscn",
}


func goto_screen(screen_key: String) -> void:
	var path: String = SCREENS.get(screen_key, "")
	if path == "":
		push_error("SceneManager: unbekannter Screen-Key: %s" % screen_key)
		return
	get_tree().change_scene_to_file(path)
