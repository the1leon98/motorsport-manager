extends Node
# Autoload-Singleton: liest/schreibt den Spielstand (GameState.team +
# GameState.game_mode) als SaveData-Resource. Unterstützt mehrere Slots;
# "current_slot" ist der zuletzt geladene/gestartete Slot und wird für
# Autosave und den Save-Button im Hub verwendet.
#
# EINRICHTUNG IN GODOT:
# Project > Project Settings > Autoload
#   Path: res://scripts/core/save_manager.gd
#   Node Name: SaveManager
#   -> "Add" klicken

const SLOT_COUNT := 3
const SAVE_PATH_FORMAT := "user://savegame_slot%d.tres"

var current_slot: int = 0


func _save_path(slot: int) -> String:
	return SAVE_PATH_FORMAT % slot


func has_save(slot: int = -1) -> bool:
	var target_slot: int = current_slot if slot < 0 else slot
	return FileAccess.file_exists(_save_path(target_slot))


func any_save_exists() -> bool:
	for slot in range(SLOT_COUNT):
		if has_save(slot):
			return true
	return false


func get_slot_info(slot: int) -> Dictionary:
	if not has_save(slot):
		return {"slot": slot, "exists": false}

	var data := ResourceLoader.load(_save_path(slot), "SaveData", ResourceLoader.CACHE_MODE_IGNORE) as SaveData
	if data == null or data.team == null:
		return {"slot": slot, "exists": false}

	return {
		"slot": slot,
		"exists": true,
		"game_mode": data.game_mode,
		"budget": data.team.budget,
		"current_race_number": data.team.current_race_number,
		"car_count": data.team.cars.size(),
	}


func save_game(slot: int = -1) -> bool:
	var target_slot: int = current_slot if slot < 0 else slot
	var data := SaveData.new()
	data.game_mode = GameState.game_mode
	data.team = GameState.team
	var err: Error = ResourceSaver.save(data, _save_path(target_slot))
	if err != OK:
		push_error("Speichern fehlgeschlagen (Fehlercode %d)" % err)
		return false
	current_slot = target_slot
	return true


func delete_save(slot: int) -> bool:
	if not has_save(slot):
		return true
	var err: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(_save_path(slot)))
	if err != OK:
		push_error("Spielstand konnte nicht gelöscht werden (Fehlercode %d)" % err)
		return false
	return true


func load_game(slot: int = -1) -> bool:
	var target_slot: int = current_slot if slot < 0 else slot
	if not has_save(target_slot):
		return false
	var data := ResourceLoader.load(_save_path(target_slot), "SaveData", ResourceLoader.CACHE_MODE_IGNORE) as SaveData
	if data == null:
		push_error("Spielstand konnte nicht geladen werden oder ist beschädigt: %s" % _save_path(target_slot))
		return false
	GameState.game_mode = data.game_mode
	GameState.team = data.team
	GameState.race_cleared = false
	current_slot = target_slot
	return true


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
