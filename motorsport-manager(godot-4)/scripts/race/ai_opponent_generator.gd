extends Node
class_name AiOpponentGenerator
# Erzeugt zufällige Gegner-Fahrzeuge für die Rennansicht (race_controller.gd).
# Kein separates Balancing-Modell: Gegner bekommen zufällige Bauteile aus
# demselben Pool wie die Werkstatt (PartsDatabase) und einen zufälligen Punkt
# innerhalb der gültigen Setup-Bandbreite (siehe car_config.gd) – ihre Pace
# folgt danach aus derselben StatsCalculator-Formel wie beim Spielerauto,
# statt aus einem freihändigen Zufalls-Multiplikator.

const TEAM_NAMES := [
	"Rivera Racing", "Kessler Motorsport", "Vantage Team", "Ostmark Racing",
	"Falkner Team", "Corvin Motorsport", "Nordlicht Racing", "Silberpfeil Team",
]


static func generate(count: int, db: Node, rng: RandomNumberGenerator) -> Array:
	var available_names: Array = TEAM_NAMES.duplicate()
	var opponents: Array = []
	for i in range(count):
		var name_index: int = rng.randi_range(0, available_names.size() - 1)
		var team_name: String = available_names.pop_at(name_index)
		opponents.append({"name": team_name, "car": _random_car(db, rng)})
	return opponents


static func _random_car(db: Node, rng: RandomNumberGenerator) -> CarConfig:
	var car := CarConfig.new()
	car.engine_id = _random_part_id(db, "engine", rng)
	car.gearbox_id = _random_part_id(db, "gearbox", rng)
	car.chassis_id = _random_part_id(db, "chassis", rng)
	car.tire_id = _random_part_id(db, "tire", rng)
	car.brake_id = _random_part_id(db, "brake", rng)
	if rng.randf() < 0.6:
		car.rear_wing_id = _random_aero_id(db, "rear_wing", rng)
	if rng.randf() < 0.4:
		car.diffuser_id = _random_aero_id(db, "diffuser", rng)

	car.gear_ratio = rng.randf_range(3.2, 4.6)
	car.spring_rate = rng.randf_range(60.0, 140.0)
	car.damper = rng.randf_range(1.0, 10.0)
	car.sway_bar = rng.randf_range(1.0, 10.0)
	car.camber_deg = rng.randf_range(-4.0, -1.0)
	car.toe_deg = rng.randf_range(-0.5, 0.5)
	car.tire_pressure_bar = rng.randf_range(1.6, 2.4)
	car.ecu_mapping = ["qualifying", "race", "fuelsaving"][rng.randi_range(0, 2)]
	car.ballast_kg = rng.randf_range(0.0, 60.0)
	return car


static func _random_part_id(db: Node, category: String, rng: RandomNumberGenerator) -> String:
	var options: Array = db.get_all_parts(category)
	if options.is_empty():
		return ""
	return options[rng.randi_range(0, options.size() - 1)]["id"]


static func _random_aero_id(db: Node, subtype: String, rng: RandomNumberGenerator) -> String:
	var matches: Array = []
	for part in db.get_all_parts("aero"):
		if part.get("type", "") == subtype:
			matches.append(part)
	if matches.is_empty():
		return ""
	return matches[rng.randi_range(0, matches.size() - 1)]["id"]
