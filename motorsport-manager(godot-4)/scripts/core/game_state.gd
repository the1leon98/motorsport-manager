extends Node
# Autoload-Singleton: hält den Laufzeit-Zustand des aktuellen Spielstands
# (Team-Inventar, Budget, Saisonfortschritt) und die Übergänge zwischen den
# Screens, die diesen Zustand gemeinsam benötigen.
#
# EINRICHTUNG IN GODOT:
# Project > Project Settings > Autoload
#   Path: res://scripts/core/game_state.gd
#   Node Name: GameState
#   -> "Add" klicken

const STARTING_BUDGET := 200000.0
const REGULATION_ID := "dtm_demo_2026"

var game_mode: String = "career"  # "quick" oder "career" – im Grundgerüst ohne Unterschied
var team: Team = Team.new()
var race_cleared: bool = false    # von der Boxengasse gesetzt, von der Rennansicht geprüft


func start_new_game(mode: String) -> void:
	game_mode = mode
	team = Team.new()
	team.budget = STARTING_BUDGET
	team.current_race_number = 1
	team.selected_car_index = -1
	team.reputation = 100.0
	race_cleared = false


func has_any_car() -> bool:
	return not team.cars.is_empty()


func get_selected_car() -> CarConfig:
	if team.selected_car_index >= 0 and team.selected_car_index < team.cars.size():
		return team.cars[team.selected_car_index]
	return null


func select_car(index: int) -> void:
	if index >= 0 and index < team.cars.size():
		team.selected_car_index = index


func buy_car(car_id: String) -> bool:
	var car_data: Dictionary = PartsDatabase.get_car(car_id)
	if car_data.is_empty():
		return false

	var price: float = float(car_data.get("price", 0))
	if price > team.budget:
		return false

	var starter: Dictionary = car_data.get("starter_parts", {})
	var new_car := CarConfig.new()
	new_car.model_name = car_data.get("name", "")
	new_car.engine_id = starter.get("engine_id", "")
	new_car.gearbox_id = starter.get("gearbox_id", "")
	new_car.chassis_id = starter.get("chassis_id", "")
	new_car.tire_id = starter.get("tire_id", "")
	new_car.brake_id = starter.get("brake_id", "")

	team.budget -= price
	team.cars.append(new_car)
	if team.selected_car_index == -1:
		team.selected_car_index = team.cars.size() - 1
	return true


func get_current_track() -> Dictionary:
	for track in PartsDatabase.get_all_tracks():
		if track["track_number"] == team.current_race_number:
			return track
	return {}


func advance_race() -> void:
	var total_tracks: int = PartsDatabase.get_all_tracks().size()
	team.current_race_number = min(team.current_race_number + 1, total_tracks)


static func format_money(amount: float) -> String:
	var rounded: int = int(round(amount))
	var negative: bool = rounded < 0
	var digits: String = str(abs(rounded))
	var grouped: String = ""
	var count: int = 0
	for i in range(digits.length() - 1, -1, -1):
		grouped = digits[i] + grouped
		count += 1
		if count % 3 == 0 and i != 0:
			grouped = "." + grouped
	return ("-" if negative else "") + grouped
