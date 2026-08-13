extends Node
class_name GarageViewModel
# Reine Anzeige-Logik für die Werkstatt: aus einem CarConfig werden fertig
# formatierte Stats-/Regelkonformitäts-Texte, ohne dass dafür ein laufender
# Szenenbaum (OptionButton/HSlider/Label-Nodes) nötig ist. garage_controller.gd
# bleibt dadurch reine Node-Verdrahtung.
# Reine Utility-Klasse: GarageViewModel.build(car) -> Dictionary


static func build(car: CarConfig) -> Dictionary:
	var evaluation: Dictionary = CarEvaluation.evaluate(car)
	var stats: Dictionary = evaluation["stats"]
	var stats_text: String = "PS: %.0f    Gewicht: %.0f kg    Topspeed: %.0f km/h\n0-100: %.2f s    Kurvengrip: %.1f    Bremsweg: %.0f m\nReifenverschleiß: %.2f    Ausfallrisiko: %.1f%%" % [
		stats["power_hp"], stats["weight_kg"], stats["topspeed_kmh"],
		stats["accel_0_100_s"], stats["corner_grip_index"], stats["braking_distance_m"],
		stats["tire_wear_rate"], stats["failure_risk_pct"],
	]

	var result: Dictionary = evaluation["compliance"]
	var compliance_text: String
	if result["compliant"]:
		compliance_text = "✓ Regelkonform"
	else:
		var lines: Array = ["✗ Nicht regelkonform:"]
		for v in result["violations"]:
			lines.append(" - %s" % v)
		compliance_text = "\n".join(lines)

	return {
		"stats_text": stats_text,
		"compliance_text": compliance_text,
		"compliant": result["compliant"],
	}
