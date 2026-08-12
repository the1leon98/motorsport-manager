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

const ECU_OPTIONS := ["qualifying", "race", "fuelsaving"]
const ECU_LABELS := {"qualifying": "Qualifying", "race": "Race", "fuelsaving": "Fuelsaving"}

@onready var parts_panel: VBoxContainer = $MarginContainer/HBoxContainer/PartsPanel
@onready var setup_panel: VBoxContainer = $MarginContainer/HBoxContainer/SetupPanel
@onready var stats_panel: VBoxContainer = $MarginContainer/HBoxContainer/StatsPanel

var car := CarConfig.new()
var part_option_buttons: Dictionary = {}  # field_name -> OptionButton
var setup_sliders: Dictionary = {}  # field_name -> HSlider
var ecu_option_button: OptionButton
var stats_label: Label
var compliance_label: Label


func _ready() -> void:
	await get_tree().process_frame  # PartsDatabase-Autoload fertig laden lassen
	_set_default_car()
	_build_part_selectors()
	_build_setup_controls()
	_build_stats_panel()
	_refresh()


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


func _build_setup_controls() -> void:
	_add_slider("gear_ratio", "Getriebeübersetzung", 3.2, 4.6, 0.05)
	_add_slider("spring_rate", "Federhärte (N/mm)", 60.0, 140.0, 1.0)
	_add_slider("damper", "Dämpfer (Klicks)", 1.0, 10.0, 1.0)
	_add_slider("sway_bar", "Stabilisator", 1.0, 10.0, 1.0)
	_add_slider("camber_deg", "Sturz (°)", -4.0, -1.0, 0.1)
	_add_slider("toe_deg", "Spur (°)", -0.5, 0.5, 0.05)
	_add_slider("tire_pressure_bar", "Reifendruck (bar)", 1.6, 2.4, 0.05)
	_add_slider("ballast_kg", "Ballast (kg)", 0.0, 60.0, 1.0)

	var ecu_label := Label.new()
	ecu_label.text = "ECU-Mapping"
	setup_panel.add_child(ecu_label)

	ecu_option_button = OptionButton.new()
	for ecu_key in ECU_OPTIONS:
		ecu_option_button.add_item(ECU_LABELS[ecu_key])
		ecu_option_button.set_item_metadata(ecu_option_button.item_count - 1, ecu_key)
	_select_current_value(ecu_option_button, car.ecu_mapping)
	ecu_option_button.item_selected.connect(func(index: int) -> void:
		car.ecu_mapping = ecu_option_button.get_item_metadata(index)
		_refresh()
	)
	setup_panel.add_child(ecu_option_button)


func _add_slider(field: String, label_text: String, min_val: float, max_val: float, step: float) -> void:
	var label := Label.new()
	label.text = label_text
	setup_panel.add_child(label)

	var slider := HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = step
	slider.value = car.get(field)
	slider.value_changed.connect(func(value: float) -> void:
		car.set(field, value)
		_refresh()
	)
	setup_panel.add_child(slider)
	setup_sliders[field] = slider


func _build_stats_panel() -> void:
	stats_label = Label.new()
	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	stats_panel.add_child(stats_label)

	compliance_label = Label.new()
	compliance_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	stats_panel.add_child(compliance_label)


func _refresh() -> void:
	var stats: Dictionary = StatsCalculator.calculate(car, PartsDatabase)
	stats_label.text = "PS: %.0f    Gewicht: %.0f kg    Topspeed: %.0f km/h\n0-100: %.2f s    Kurvengrip: %.1f    Bremsweg: %.0f m\nReifenverschleiß: %.2f    Ausfallrisiko: %.1f%%" % [
		stats["power_hp"], stats["weight_kg"], stats["topspeed_kmh"],
		stats["accel_0_100_s"], stats["corner_grip_index"], stats["braking_distance_m"],
		stats["tire_wear_rate"], stats["failure_risk_pct"],
	]

	var result: Dictionary = RegulationValidator.validate(car, stats, PartsDatabase, REGULATION_ID, CURRENT_RACE_NUMBER)
	if result["compliant"]:
		compliance_label.text = "✓ Regelkonform"
	else:
		var lines: Array = ["✗ Nicht regelkonform:"]
		for v in result["violations"]:
			lines.append(" - %s" % v)
		compliance_label.text = "\n".join(lines)
