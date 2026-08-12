extends Control
# Hub-Übersicht: zentraler Bildschirm zwischen Werkstatt, Autohaus, Boxengasse
# und Saison-Ansicht. Platzhalter-"Karte" im Gran-Turismo-Stil: Standorte als
# Pins auf einer einfachen Hintergrundfläche statt eines klassischen Menüs.

@onready var budget_label: Label = $HeaderBar/MarginContainer/HBoxContainer/BudgetLabel
@onready var car_label: Label = $HeaderBar/MarginContainer/HBoxContainer/CarLabel
@onready var next_race_label: Label = $HeaderBar/MarginContainer/HBoxContainer/NextRaceLabel

@onready var main_menu_button: Button = $MainMenuButton
@onready var garage_pin: Button = $MapArea/GaragePin
@onready var autohaus_pin: Button = $MapArea/AutohausPin
@onready var pit_lane_pin: Button = $MapArea/PitLanePin
@onready var season_pin: Button = $MapArea/SeasonPin


func _ready() -> void:
	main_menu_button.pressed.connect(func(): SceneManager.goto_screen("main_menu"))
	garage_pin.pressed.connect(func(): SceneManager.goto_screen("garage"))
	autohaus_pin.pressed.connect(func(): SceneManager.goto_screen("autohaus"))
	pit_lane_pin.pressed.connect(func(): SceneManager.goto_screen("pit_lane"))
	season_pin.pressed.connect(func(): SceneManager.goto_screen("season"))
	_refresh_header()


func _refresh_header() -> void:
	budget_label.text = "Budget: %s" % GameState.format_money(GameState.team.budget)

	var selected_car: CarConfig = GameState.get_selected_car()
	car_label.text = "Fahrzeug: %s" % (_car_display_name(selected_car) if selected_car else "keins")

	var has_car: bool = GameState.has_any_car()
	garage_pin.disabled = not has_car
	pit_lane_pin.disabled = not has_car

	var track: Dictionary = GameState.get_current_track()
	next_race_label.text = "Nächstes Rennen: %s (Rennen %d/%d)" % [
		track.get("name", "-"), GameState.team.current_race_number, PartsDatabase.get_all_tracks().size(),
	]


func _car_display_name(car: CarConfig) -> String:
	var chassis: Dictionary = PartsDatabase.get_part("chassis", car.chassis_id)
	return chassis.get("name", car.chassis_id)
