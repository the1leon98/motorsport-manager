extends Node
class_name RegulationValidator
# Prüft eine CarConfig gegen ein Regelwerk aus data/regulations/*.json.
# Reine Utility-Klasse: RegulationValidator.validate(car, stats, PartsDatabase, "dtm_demo_2026")


static func validate(car: CarConfig, stats: Dictionary, db: Node, regulation_id: String, current_race_number: int = 1) -> Dictionary:
	var regulation: Dictionary = db.get_regulation(regulation_id)
	var violations: Array = []

	if regulation.is_empty():
		push_error("RegulationValidator: Regelwerk nicht gefunden: %s" % regulation_id)
		return {"compliant": false, "violations": ["Regelwerk nicht gefunden: %s" % regulation_id]}

	var engine: Dictionary = db.get_part("engine", car.engine_id)
	var installed_ids: Array = [
		car.engine_id, car.gearbox_id, car.chassis_id,
		car.tire_id, car.brake_id, car.rear_wing_id, car.diffuser_id,
	]

	for rule in regulation.get("rules", []):
		match rule["type"]:
			"max_power":
				if stats["power_hp"] > rule["value_hp"]:
					violations.append("Leistung %.0f PS überschreitet Limit von %d PS" % [stats["power_hp"], rule["value_hp"]])

			"min_weight":
				if stats["weight_kg"] < rule["value_kg"]:
					violations.append("Gewicht %.0f kg unter Mindestgewicht von %d kg" % [stats["weight_kg"], rule["value_kg"]])

			"max_boost":
				if rule.get("applies_to_aspiration", []).has(engine.get("aspiration", "")):
					var boost: float = engine.get("boost_bar_max", 0.0)
					if boost > rule["value_bar"]:
						violations.append("Ladedruck %.1f bar überschreitet Limit von %.1f bar" % [boost, rule["value_bar"]])

			"tire_allowance":
				if not rule["allowed_part_ids"].has(car.tire_id):
					violations.append("Reifen %s ist für dieses Rennwochenende nicht homologiert" % car.tire_id)

			"banned_part":
				if installed_ids.has(rule["part_id"]):
					violations.append("Bauteil %s ist nicht zulässig (%s)" % [rule["part_id"], rule.get("reason", "")])

			"part_unlock":
				if installed_ids.has(rule["part_id"]) and current_race_number < rule["unlocks_from_race"]:
					violations.append("Bauteil %s ist erst ab Rennen %d freigegeben (%s)" % [rule["part_id"], rule["unlocks_from_race"], rule.get("reason", "")])

			"max_camber":
				if car.camber_deg < rule["value_deg"]:
					violations.append("Sturz %.1f° überschreitet erlaubtes Maximum von %.1f°" % [car.camber_deg, rule["value_deg"]])

			"min_ballast_if_underweight":
				var raw_weight: float = stats["weight_kg"] - car.ballast_kg
				var min_weight_rule: Dictionary = _find_rule(regulation, "min_weight")
				if not min_weight_rule.is_empty() and raw_weight < min_weight_rule["value_kg"]:
					if car.ballast_kg < rule["value_kg"]:
						violations.append("Mindestens %d kg Ballast erforderlich, da das Fahrzeug ohne Ballast unter dem Mindestgewicht liegt" % rule["value_kg"])

	return {"compliant": violations.is_empty(), "violations": violations}


static func _find_rule(regulation: Dictionary, type: String) -> Dictionary:
	for rule in regulation.get("rules", []):
		if rule["type"] == type:
			return rule
	return {}
