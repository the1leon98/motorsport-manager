extends Node
class_name CarEvaluation
# Bündelt Stats-Berechnung und Regelkonformitätsprüfung für ein Fahrzeug
# hinter einem einzigen Aufruf. Vorher haben Werkstatt und Boxengasse beide
# StatsCalculator.calculate() + RegulationValidator.validate(car, stats, db,
# GameState.REGULATION_ID, GameState.team.current_race_number) unabhängig
# voneinander zusammengesetzt.
# Reine Utility-Klasse: CarEvaluation.evaluate(car) -> Dictionary


static func evaluate(car: CarConfig) -> Dictionary:
	var stats: Dictionary = StatsCalculator.calculate(car, PartsDatabase)
	var compliance: Dictionary = RegulationValidator.validate(
		car, stats, PartsDatabase, GameState.REGULATION_ID, GameState.team.current_race_number
	)
	return {"stats": stats, "compliance": compliance}
