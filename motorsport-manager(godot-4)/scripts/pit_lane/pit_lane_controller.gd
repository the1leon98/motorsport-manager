extends Control
# Boxengasse / Prüfstation: gleicht das aktuell gewählte Fahrzeug gegen das
# Regelwerk ab. Konform -> Startfreigabe. Nicht konform -> Sperre oder
# Bestechung gegen Geld (mit Restrisiko, aufzufliegen).

const BASE_BRIBE_COST := 15000.0
const CAUGHT_RISK := 0.10  # fixe 10% Restrisiko laut GDD Abschnitt 8

const SEVERITY_BY_RULE_TYPE := {
	"max_power": 2,
	"min_weight": 2,
	"max_boost": 2,
	"tire_allowance": 1,
	"banned_part": 3,
	"part_unlock": 3,
	"max_camber": 1,
	"min_ballast_if_underweight": 1,
}

@onready var no_car_panel: CenterContainer = $NoCarPanel
@onready var no_car_back_button: Button = $NoCarPanel/VBoxContainer/BackButton

@onready var content_container: MarginContainer = $ContentContainer
@onready var track_label: Label = $ContentContainer/VBoxContainer/TrackLabel
@onready var compliance_label: Label = $ContentContainer/VBoxContainer/ComplianceLabel
@onready var bribe_button: Button = $ContentContainer/VBoxContainer/BribeButton
@onready var garage_button: Button = $ContentContainer/VBoxContainer/GarageButton
@onready var race_button: Button = $ContentContainer/VBoxContainer/RaceButton
@onready var status_label: Label = $ContentContainer/VBoxContainer/StatusLabel
@onready var back_button: Button = $ContentContainer/VBoxContainer/BackButton

var current_result: Dictionary = {}
var bribe_cost: float = 0.0


func _ready() -> void:
	back_button.pressed.connect(func(): SceneManager.goto_screen("hub"))
	no_car_back_button.pressed.connect(func(): SceneManager.goto_screen("autohaus"))
	garage_button.pressed.connect(func(): SceneManager.goto_screen("garage"))
	race_button.pressed.connect(func(): SceneManager.goto_screen("race"))
	bribe_button.pressed.connect(_on_bribe_pressed)

	if not GameState.has_any_car():
		no_car_panel.visible = true
		content_container.visible = false
		return

	no_car_panel.visible = false
	content_container.visible = true
	_check_car()


func _check_car() -> void:
	var car: CarConfig = GameState.get_selected_car()
	var stats: Dictionary = StatsCalculator.calculate(car, PartsDatabase)
	current_result = RegulationValidator.validate(car, stats, PartsDatabase, GameState.REGULATION_ID, GameState.team.current_race_number)

	var track: Dictionary = GameState.get_current_track()
	track_label.text = "Rennen %d: %s" % [GameState.team.current_race_number, track.get("name", "-")]

	if current_result["compliant"]:
		compliance_label.text = "✓ Fahrzeug ist regelkonform. Startfreigabe erteilt."
		bribe_button.visible = false
		GameState.race_cleared = true
		status_label.text = ""
	else:
		var lines: Array = ["✗ Nicht regelkonform:"]
		for v in current_result["violations"]:
			lines.append(" - %s" % v)
		compliance_label.text = "\n".join(lines)

		bribe_cost = _calculate_bribe_cost(current_result["violation_rules"])
		bribe_button.text = "Bestechen (%s)" % GameState.format_money(bribe_cost)
		bribe_button.visible = true
		bribe_button.disabled = bribe_cost > GameState.team.budget
		GameState.race_cleared = false
		status_label.text = ""

	race_button.disabled = not GameState.race_cleared


func _calculate_bribe_cost(violation_rules: Array) -> float:
	var total: float = 0.0
	for rule in violation_rules:
		var severity: int = SEVERITY_BY_RULE_TYPE.get(rule["type"], 1)
		total += BASE_BRIBE_COST * severity
	return total * (1.0 + CAUGHT_RISK)


func _on_bribe_pressed() -> void:
	if bribe_cost > GameState.team.budget:
		status_label.text = "Nicht genug Budget für die Bestechung."
		return

	GameState.team.budget -= bribe_cost
	var caught: bool = randf() < CAUGHT_RISK
	if caught:
		GameState.team.budget -= bribe_cost
		status_label.text = "Bestechung erfolgreich, aber aufgeflogen! Zusatzstrafe: %s. Startfreigabe trotzdem erteilt." % GameState.format_money(bribe_cost)
	else:
		status_label.text = "Bestechung erfolgreich und unbemerkt. Startfreigabe erteilt."

	GameState.race_cleared = true
	bribe_button.disabled = true
	race_button.disabled = false
