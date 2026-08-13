extends Control
# Boxengasse / Prüfstation: gleicht das aktuell gewählte Fahrzeug gegen das
# Regelwerk ab. Konform -> Startfreigabe. Nicht konform -> Sperre oder
# Bestechung gegen Geld.
#
# Bestechungsmodell (GDD Abschnitt 8): Der Bestechungspreis selbst enthält
# bereits einen Risikoaufschlag (Basiskosten × Schweregrad × (1+Restrisiko)).
# Fliegt die Bestechung zusätzlich auf, kommen eine separate Zusatzstrafe in
# Höhe der reinen Basiskosten sowie ein Ruf-Verlust (team.reputation) dazu.
# Ein niedrigerer Ruf erhöht wiederum das Restrisiko künftiger Bestechungen –
# wiederholtes Schummeln wird also mit der Zeit riskanter.

const BASE_BRIBE_COST := 15000.0
const MIN_CAUGHT_RISK := 0.10   # fixe 10% Basis-Restrisiko laut GDD Abschnitt 8
const MAX_CAUGHT_RISK := 0.50
const REPUTATION_LOSS_ON_CAUGHT := 15.0

@onready var no_car_panel: CenterContainer = $NoCarPanel
@onready var no_car_back_button: Button = $NoCarPanel/VBoxContainer/BackButton

@onready var content_container: MarginContainer = $ContentContainer
@onready var track_label: Label = $ContentContainer/VBoxContainer/TrackLabel
@onready var compliance_label: Label = $ContentContainer/VBoxContainer/ComplianceLabel
@onready var bribe_button: Button = $ContentContainer/VBoxContainer/BribeButton
@onready var risk_label: Label = $ContentContainer/VBoxContainer/RiskLabel
@onready var garage_button: Button = $ContentContainer/VBoxContainer/GarageButton
@onready var race_button: Button = $ContentContainer/VBoxContainer/RaceButton
@onready var status_label: Label = $ContentContainer/VBoxContainer/StatusLabel
@onready var back_button: Button = $ContentContainer/VBoxContainer/BackButton
@onready var bribe_confirm_dialog: ConfirmationDialog = $BribeConfirmDialog

var current_result: Dictionary = {}
var bribe_cost: float = 0.0
var caught_penalty: float = 0.0
var current_risk: float = 0.0


func _ready() -> void:
	back_button.pressed.connect(func(): SceneManager.goto_screen("hub"))
	no_car_back_button.pressed.connect(func(): SceneManager.goto_screen("autohaus"))
	garage_button.pressed.connect(func(): SceneManager.goto_screen("garage"))
	race_button.pressed.connect(func(): SceneManager.goto_screen("race"))
	bribe_button.pressed.connect(_on_bribe_pressed)
	bribe_confirm_dialog.confirmed.connect(_on_bribe_confirmed)

	if not GameState.has_any_car():
		no_car_panel.visible = true
		content_container.visible = false
		return

	no_car_panel.visible = false
	content_container.visible = true
	_check_car()


func _check_car() -> void:
	var car: CarConfig = GameState.get_selected_car()
	current_result = CarEvaluation.evaluate(car)["compliance"]

	var track: Dictionary = GameState.get_current_track()
	track_label.text = "Rennen %d: %s" % [GameState.team.current_race_number, track.get("name", "-")]

	if current_result["compliant"]:
		compliance_label.text = "✓ Fahrzeug ist regelkonform. Startfreigabe erteilt."
		bribe_button.visible = false
		risk_label.visible = false
		GameState.race_cleared = true
		status_label.text = ""
	else:
		var lines: Array = ["✗ Nicht regelkonform:"]
		for v in current_result["violations"]:
			lines.append(" - %s" % v)
		compliance_label.text = "\n".join(lines)

		current_risk = _effective_caught_risk()
		var costs: Dictionary = _calculate_bribe_costs(current_result["violation_rules"], current_risk)
		bribe_cost = costs["bribe_cost"]
		caught_penalty = costs["caught_penalty"]

		bribe_button.text = "Bestechen (%s)" % MoneyFormat.format(bribe_cost)
		bribe_button.visible = true
		bribe_button.disabled = bribe_cost > GameState.team.budget

		risk_label.text = "Risiko aufzufliegen: %d%% (Ruf aktuell %d/100) – bei Auffliegen zusätzlich %s Strafe + Ruf-Verlust" % [
			int(round(current_risk * 100.0)), int(round(GameState.team.reputation)), MoneyFormat.format(caught_penalty),
		]
		risk_label.visible = true

		GameState.race_cleared = false
		status_label.text = ""

	race_button.disabled = not GameState.race_cleared


func _effective_caught_risk() -> float:
	var reputation_penalty: float = (100.0 - GameState.team.reputation) * 0.003
	return clamp(MIN_CAUGHT_RISK + reputation_penalty, MIN_CAUGHT_RISK, MAX_CAUGHT_RISK)


func _calculate_bribe_costs(violation_rules: Array, risk: float) -> Dictionary:
	var base_total: float = 0.0
	for rule in violation_rules:
		var severity: int = RegulationValidator.severity_for(rule)
		base_total += BASE_BRIBE_COST * severity
	return {"bribe_cost": base_total * (1.0 + risk), "caught_penalty": base_total}


func _on_bribe_pressed() -> void:
	if bribe_cost > GameState.team.budget:
		status_label.text = "Nicht genug Budget für die Bestechung."
		return

	bribe_confirm_dialog.dialog_text = "Bestechung für %s zahlen?\nRisiko aufzufliegen: %d%%. Bei Auffliegen zusätzlich %s Strafe + Ruf-Verlust." % [
		MoneyFormat.format(bribe_cost), int(round(current_risk * 100.0)), MoneyFormat.format(caught_penalty),
	]
	bribe_confirm_dialog.popup_centered()


func _on_bribe_confirmed() -> void:
	GameState.team.budget -= bribe_cost
	var caught: bool = randf() < current_risk
	if caught:
		GameState.team.budget -= caught_penalty
		GameState.team.reputation = max(0.0, GameState.team.reputation - REPUTATION_LOSS_ON_CAUGHT)
		status_label.text = "Bestechung erfolgreich, aber aufgeflogen! Zusatzstrafe: %s. Ruf sinkt auf %d/100. Startfreigabe trotzdem erteilt." % [
			MoneyFormat.format(caught_penalty), int(round(GameState.team.reputation)),
		]
	else:
		status_label.text = "Bestechung erfolgreich und unbemerkt. Startfreigabe erteilt."

	GameState.race_cleared = true
	bribe_button.disabled = true
	risk_label.visible = false
	race_button.disabled = false
