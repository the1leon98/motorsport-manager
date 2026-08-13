extends Node
# TEST-SKRIPT für Phase 1 – noch keine Grafik, nur Konsolenausgabe.
#
# EINRICHTUNG:
# 1. Neue Szene anlegen: ein einzelner Node (z.B. "TestStats"), dieses Skript daran hängen.
# 2. Sicherstellen, dass PartsDatabase als Autoload eingerichtet ist (siehe parts_database.gd).
# 3. Szene ausführen (F6) und die "Ausgabe"-Konsole in Godot beobachten.

func _ready() -> void:
	# Ein Frame warten, damit der PartsDatabase-Autoload garantiert fertig geladen hat.
	await get_tree().process_frame

	var car := CarConfig.new()
	car.engine_id = "E1"       # Voss S4 2.5 Sport Evolution
	car.gearbox_id = "G1"      # Steinbrenner RG5
	car.chassis_id = "C2"      # Van Dijk Sport
	car.tire_id = "T2"         # Clermont Medium
	car.brake_id = "B2"        # Bergamo Sport
	car.rear_wing_id = "A2"    # Voss Heckflügel "Normal"
	car.diffuser_id = "A4"     # Voss Frontspoiler
	car.gear_ratio = 4.0
	car.camber_deg = -2.5
	car.tire_pressure_bar = 2.0
	car.ecu_mapping = "race"
	car.ballast_kg = 30.0

	var stats: Dictionary = StatsCalculator.calculate(car, PartsDatabase)
	print("\n--- Fahrzeug-Stats ---")
	for key in stats.keys():
		print("%s: %s" % [key, str(stats[key])])

	var result: Dictionary = RegulationValidator.validate(car, stats, PartsDatabase, "dtm_demo_2026", 1)
	print("\n--- Regelkonformität (dtm_demo_2026, Rennen 1) ---")
	print("Konform: %s" % result["compliant"])
	for v in result["violations"]:
		print(" - %s" % v)

	# Testfall 2: bewusst regelwidriges Auto (verbotenes Getriebe + Spoiler)
	var illegal_car := CarConfig.new()
	illegal_car.engine_id = "E3"
	illegal_car.gearbox_id = "G3"      # verboten laut Regelwerk
	illegal_car.chassis_id = "C3"
	illegal_car.tire_id = "T3"
	illegal_car.brake_id = "B3"        # vor Rennen 3 gesperrt
	illegal_car.rear_wing_id = "A3"    # verboten laut Regelwerk
	illegal_car.diffuser_id = "A4"
	illegal_car.ballast_kg = 0.0

	var illegal_stats: Dictionary = StatsCalculator.calculate(illegal_car, PartsDatabase)
	var illegal_result: Dictionary = RegulationValidator.validate(illegal_car, illegal_stats, PartsDatabase, "dtm_demo_2026", 1)
	print("\n--- Regelkonformität Testfall 2 (bewusst regelwidrig) ---")
	print("Konform: %s" % illegal_result["compliant"])
	for v in illegal_result["violations"]:
		print(" - %s" % v)
