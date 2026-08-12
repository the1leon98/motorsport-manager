extends Node
# Autoload-Singleton: liest/schreibt den Spielstand (GameState.team +
# GameState.game_mode) als SaveData-Resource unter einem festen Pfad.
#
# EINRICHTUNG IN GODOT:
# Project > Project Settings > Autoload
#   Path: res://scripts/core/save_manager.gd
#   Node Name: SaveManager
#   -> "Add" klicken

const SAVE_PATH := "user://savegame.tres"


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> bool:
	var data := SaveData.new()
	data.game_mode = GameState.game_mode
	data.team = GameState.team
	var err: Error = ResourceSaver.save(data, SAVE_PATH)
	if err != OK:
		push_error("Speichern fehlgeschlagen (Fehlercode %d)" % err)
		return false
	return true


func load_game() -> bool:
	if not has_save():
		return false
	var data := ResourceLoader.load(SAVE_PATH, "SaveData", ResourceLoader.CACHE_MODE_IGNORE) as SaveData
	if data == null:
		push_error("Spielstand konnte nicht geladen werden oder ist beschädigt: %s" % SAVE_PATH)
		return false
	GameState.game_mode = data.game_mode
	GameState.team = data.team
	GameState.race_cleared = false
	return true


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
