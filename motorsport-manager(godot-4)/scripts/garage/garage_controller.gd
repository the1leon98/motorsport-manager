extends Control
# Werkstatt-Bildschirm (Platzhalter-UI): Bauteile wählen, Setup einstellen,
# Live-Stats + Regelkonformität anzeigen.

const REGULATION_ID := "dtm_demo_2026"
const CURRENT_RACE_NUMBER := 1

@onready var parts_panel: VBoxContainer = $MarginContainer/HBoxContainer/PartsPanel
@onready var setup_panel: VBoxContainer = $MarginContainer/HBoxContainer/SetupPanel
@onready var stats_panel: VBoxContainer = $MarginContainer/HBoxContainer/StatsPanel

var car := CarConfig.new()


func _ready() -> void:
	await get_tree().process_frame  # PartsDatabase-Autoload fertig laden lassen
	print("GarageScreen bereit. Panels: %s / %s / %s" % [parts_panel, setup_panel, stats_panel])


func _refresh() -> void:
	pass  # wird in Task 4 und 5 mit echter Logik gefüllt
