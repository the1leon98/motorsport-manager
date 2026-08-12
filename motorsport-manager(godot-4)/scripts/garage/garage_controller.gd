extends Control
# Werkstatt-Bildschirm (Platzhalter-UI): Bauteile wählen, Setup einstellen,
# Live-Stats + Regelkonformität anzeigen.

const REGULATION_ID := "dtm_demo_2026"
const CURRENT_RACE_NUMBER := 1

const PART_CATEGORIES := [
	{"key": "engine", "label": "Motor", "field": "engine_id"},
	{"key": "gearbox", "label": "Getriebe", "field": "gearbox_id"},
	{"key": "chassis", "label": "Fahrwerk", "field": "chassis_id"},
	{"key": "tire", "label": "Reifen", "field": "tire_id"},
	{"key": "brake", "label": "Bremse", "field": "brake_id"},
]

const AERO_SLOTS := [
	{"subtype": "rear_wing", "label": "Heckspoiler", "field": "rear_wing_id"},
	{"subtype": "diffuser", "label": "Diffusor", "field": "diffuser_id"},
]

@onready var parts_panel: VBoxContainer = $MarginContainer/HBoxContainer/PartsPanel
@onready var setup_panel: VBoxContainer = $MarginContainer/HBoxContainer/SetupPanel
@onready var stats_panel: VBoxContainer = $MarginContainer/HBoxContainer/StatsPanel

var car := CarConfig.new()
var part_option_buttons: Dictionary = {}  # field_name -> OptionButton


func _ready() -> void:
	await get_tree().process_frame  # PartsDatabase-Autoload fertig laden lassen
	_set_default_car()
	_build_part_selectors()
	_refresh()


func _refresh() -> void:
	pass  # wird in Task 4 und 5 mit echter Logik gefüllt


func _set_default_car() -> void:
	car.engine_id = "E1"
	car.gearbox_id = "G1"
	car.chassis_id = "C1"
	car.tire_id = "T2"
	car.brake_id = "B1"
	car.rear_wing_id = "A2"
	car.diffuser_id = "A4"


func _build_part_selectors() -> void:
	for entry in PART_CATEGORIES:
		_add_part_row(entry["key"], entry["label"], entry["field"])
	for entry in AERO_SLOTS:
		_add_aero_row(entry["subtype"], entry["label"], entry["field"])


func _add_part_row(category: String, label_text: String, field: String) -> void:
	var label := Label.new()
	label.text = label_text
	parts_panel.add_child(label)

	var option := OptionButton.new()
	var parts: Array = PartsDatabase.get_all_parts(category)
	for part in parts:
		var display_text: String = part["name"]
		if category == "engine":
			display_text = "%s (%.0f PS)" % [part["name"], float(part.get("power_hp", 0))]
		option.add_item(display_text)
		option.set_item_metadata(option.item_count - 1, part["id"])
	_select_current_value(option, car.get(field))
	option.item_selected.connect(func(index: int) -> void:
		car.set(field, option.get_item_metadata(index))
		_refresh()
	)
	parts_panel.add_child(option)
	part_option_buttons[field] = option


func _add_aero_row(subtype: String, label_text: String, field: String) -> void:
	var label := Label.new()
	label.text = label_text
	parts_panel.add_child(label)

	var option := OptionButton.new()
	var all_aero: Array = PartsDatabase.get_all_parts("aero")
	for part in all_aero:
		if part.get("type", "") == subtype:
			option.add_item(part["name"])
			option.set_item_metadata(option.item_count - 1, part["id"])
	_select_current_value(option, car.get(field))
	option.item_selected.connect(func(index: int) -> void:
		car.set(field, option.get_item_metadata(index))
		_refresh()
	)
	parts_panel.add_child(option)
	part_option_buttons[field] = option


func _select_current_value(option: OptionButton, current_id) -> void:
	for i in option.item_count:
		if option.get_item_metadata(i) == current_id:
			option.select(i)
			return
