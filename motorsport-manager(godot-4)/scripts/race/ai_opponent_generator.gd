extends Node
class_name AiOpponentGenerator
# Erzeugt zufällige, aber garantiert regelkonforme Gegner-Fahrzeuge für die
# Rennansicht (race_controller.gd). Bauteile werden nur aus dem jeweils
# legalen Teil des PartsDatabase-Pools gezogen (siehe _legal_part_ids/
# _legal_aero_ids: keine gesperrten/verbotenen Bauteile, kein zu extremer
# Sturz), damit KI-Teams nie mit einem eigentlich unzulässigen Auto antreten
# – im Gegensatz zum Spieler, der das nur in der Boxengasse geprüft bekommt,
# gibt es für die KI keine nachträgliche Kontrolle. Setup-Parameter sind
# ansonsten frei innerhalb der in car_config.gd dokumentierten Bandbreiten
# gewürfelt; ihre Pace folgt danach aus derselben StatsCalculator-Formel wie
# beim Spielerauto, statt aus einem freihändigen Zufalls-Multiplikator.

const TEAM_NAMES := [
	"Rivera Racing", "Ostmark Racing", "Corvin Motorsport", "Nordlicht Racing",
	"Vantera Team", "Rennstahl Racing", "Meridian Motorsport", "Habicht Renntechnik",
	"Lindqvist Team", "Delacroix Competition", "Bellano Corse", "Astrid Racing",
	"Turmwerk Racing", "Vindonia Racing", "Westland Team", "Bergland Racing",
	"Rothental Racing", "Argenta Motorsport", "Polarstern Racing", "Concordia Racing",
	"Adalpin Motorsport", "Kastell Racing",
]


static func generate(count: int, db: Node, rng: RandomNumberGenerator) -> Array:
	var regulation: Dictionary = db.get_regulation(GameState.REGULATION_ID)
	var race_number: int = GameState.team.current_race_number

	var available_names: Array = TEAM_NAMES.duplicate()
	var opponents: Array = []
	for i in range(count):
		var name_index: int = rng.randi_range(0, available_names.size() - 1)
		var team_name: String = available_names.pop_at(name_index)
		opponents.append({"name": team_name, "car": _random_car(db, rng, regulation, race_number)})
	return opponents


static func _random_car(db: Node, rng: RandomNumberGenerator, regulation: Dictionary, race_number: int) -> CarConfig:
	var car := CarConfig.new()
	car.engine_id = _pick(rng, _legal_part_ids(db, "engine", regulation, race_number))
	car.gearbox_id = _pick(rng, _legal_part_ids(db, "gearbox", regulation, race_number))
	car.chassis_id = _pick(rng, _legal_part_ids(db, "chassis", regulation, race_number))
	car.tire_id = _pick(rng, _legal_part_ids(db, "tire", regulation, race_number))
	car.brake_id = _pick(rng, _legal_part_ids(db, "brake", regulation, race_number))
	if rng.randf() < 0.6:
		car.rear_wing_id = _pick(rng, _legal_aero_ids(db, "rear_wing", regulation, race_number))
	if rng.randf() < 0.4:
		car.diffuser_id = _pick(rng, _legal_aero_ids(db, "diffuser", regulation, race_number))

	car.gear_ratio = rng.randf_range(3.2, 4.6)
	car.spring_rate = rng.randf_range(60.0, 140.0)
	car.damper = rng.randf_range(1.0, 10.0)
	car.sway_bar = rng.randf_range(1.0, 10.0)
	car.camber_deg = rng.randf_range(_min_legal_camber(regulation), -1.0)
	car.toe_deg = rng.randf_range(-0.5, 0.5)
	car.tire_pressure_bar = rng.randf_range(1.6, 2.4)
	car.ecu_mapping = ["qualifying", "race", "fuelsaving"][rng.randi_range(0, 2)]
	car.ballast_kg = rng.randf_range(0.0, 60.0)

	_ensure_weight_compliance(car)
	return car


# Erhöht bei Bedarf den Ballast, falls das gewürfelte Auto ohne Ballast unter
# dem Mindestgewicht liegt oder die separate Ballastpflicht-Regel verletzt –
# beide Regeltypen hängen an derselben Ursache (fehlender Ballast), daher
# reicht eine einzige Korrektur nach der Bewertung.
static func _ensure_weight_compliance(car: CarConfig) -> void:
	var evaluation: Dictionary = CarEvaluation.evaluate(car)
	if evaluation["compliance"]["compliant"]:
		return

	var raw_weight: float = evaluation["stats"]["weight_kg"] - car.ballast_kg
	var min_weight_value: float = 0.0
	var min_ballast_value: float = 0.0
	var needs_ballast: bool = false
	for rule in evaluation["compliance"]["violation_rules"]:
		if rule["type"] == "min_weight":
			needs_ballast = true
			min_weight_value = rule["value_kg"]
		elif rule["type"] == "min_ballast_if_underweight":
			needs_ballast = true
			min_ballast_value = rule["value_kg"]

	if needs_ballast:
		var required_ballast: float = max(min_weight_value - raw_weight, min_ballast_value)
		car.ballast_kg = clamp(required_ballast, 0.0, 60.0)


static func _pick(rng: RandomNumberGenerator, ids: Array) -> String:
	if ids.is_empty():
		return ""
	return ids[rng.randi_range(0, ids.size() - 1)]


# Liefert alle Bauteil-IDs einer Kategorie, die aktuell nicht durch das
# Regelwerk gesperrt sind (verboten, noch nicht freigeschaltet, verbotene
# Aufladung bei Motoren, nicht homologierte Reifen).
static func _legal_part_ids(db: Node, category: String, regulation: Dictionary, race_number: int) -> Array:
	var ids: Array = []
	for part in db.get_all_parts(category):
		var id: String = part["id"]
		if _is_banned(id, regulation) or _is_locked(id, regulation, race_number):
			continue
		if category == "engine" and _is_aspiration_banned(part.get("aspiration", ""), regulation):
			continue
		if category == "tire" and not _is_tire_allowed(id, regulation):
			continue
		ids.append(id)
	return ids


static func _legal_aero_ids(db: Node, subtype: String, regulation: Dictionary, race_number: int) -> Array:
	var ids: Array = []
	for part in db.get_all_parts("aero"):
		if part.get("type", "") != subtype:
			continue
		var id: String = part["id"]
		if _is_banned(id, regulation) or _is_locked(id, regulation, race_number):
			continue
		ids.append(id)
	return ids


static func _is_banned(part_id: String, regulation: Dictionary) -> bool:
	for rule in regulation.get("rules", []):
		if rule["type"] == "banned_part" and rule["part_id"] == part_id:
			return true
	return false


static func _is_locked(part_id: String, regulation: Dictionary, race_number: int) -> bool:
	for rule in regulation.get("rules", []):
		if rule["type"] == "part_unlock" and rule["part_id"] == part_id and race_number < rule["unlocks_from_race"]:
			return true
	return false


static func _is_aspiration_banned(aspiration: String, regulation: Dictionary) -> bool:
	for rule in regulation.get("rules", []):
		if rule["type"] == "banned_aspiration" and rule.get("values", []).has(aspiration):
			return true
	return false


static func _is_tire_allowed(part_id: String, regulation: Dictionary) -> bool:
	for rule in regulation.get("rules", []):
		if rule["type"] == "tire_allowance":
			return rule["allowed_part_ids"].has(part_id)
	return true  # keine Reifen-Regel im Regelwerk -> keine Einschränkung


static func _min_legal_camber(regulation: Dictionary) -> float:
	for rule in regulation.get("rules", []):
		if rule["type"] == "max_camber":
			return rule["value_deg"]
	return -4.0
