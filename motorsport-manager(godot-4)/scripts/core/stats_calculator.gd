extends Node
class_name StatsCalculator
# Implementiert das vereinfachte Formelmodell aus der GDD (Abschnitt 6).
# Reine Utility-Klasse: StatsCalculator.calculate(car, PartsDatabase) -> Dictionary

# ---- Balancing-Konstanten ----
# Platzhalter, gedacht zum Austesten/Anpassen – keine "echte" Physik, sondern
# kalibriert auf plausible Zielwerte (z.B. Topspeed ~290 km/h bei mittlerem Setup).
const BASE_VEHICLE_WEIGHT_KG := 780.0  # Rohkarosserie/Räder/Sicherheitszelle/Tank – nicht in data/parts enthalten
const TOPSPEED_CONSTANT := 1000.0
const ACCEL_CONSTANT := 1.16
const BRAKE_CONSTANT := 357.0
const FAILURE_CONSTANT := 0.5

const ECU_PRESETS := {
	"qualifying": {"power": 1.05, "wear": 1.3, "consumption": 1.3},
	"race":       {"power": 1.00, "wear": 1.0, "consumption": 1.0},
	"fuelsaving": {"power": 0.90, "wear": 0.7, "consumption": 0.7},
}


static func calculate(car: CarConfig, db: Node) -> Dictionary:
	var engine: Dictionary = db.get_part("engine", car.engine_id)
	var gearbox: Dictionary = db.get_part("gearbox", car.gearbox_id)
	var chassis: Dictionary = db.get_part("chassis", car.chassis_id)
	var tire: Dictionary = db.get_part("tire", car.tire_id)
	var brake: Dictionary = db.get_part("brake", car.brake_id)
	var rear_wing: Dictionary = db.get_part("aero", car.rear_wing_id) if car.rear_wing_id != "" else {}
	var diffuser: Dictionary = db.get_part("aero", car.diffuser_id) if car.diffuser_id != "" else {}

	var ecu: Dictionary = ECU_PRESETS.get(car.ecu_mapping, ECU_PRESETS["race"])

	# --- Gewicht ---
	var weight_kg: float = BASE_VEHICLE_WEIGHT_KG \
		+ float(chassis.get("weight_kg", 0)) \
		+ float(engine.get("weight_kg", 0)) \
		+ float(gearbox.get("weight_kg", 0)) \
		+ float(brake.get("weight_kg", 0)) \
		+ car.ballast_kg

	# --- Leistung ---
	var wear_malus: float = car.wear_state * 0.15  # bis zu -15% bei Totalverschleiß
	var power_hp: float = float(engine.get("power_hp", 0)) * ecu["power"] * (1.0 - wear_malus)

	# --- Aero ---
	var downforce: float = float(rear_wing.get("downforce", 0)) + float(diffuser.get("downforce", 0))
	var drag: float = float(rear_wing.get("drag", 0)) + float(diffuser.get("drag", 0))
	var drag_factor: float = 1.0 + drag / 10.0

	# --- Setup-Faktoren: lineare Interpolation zwischen Min/Max (siehe GDD Abschnitt 5) ---
	var gear_accel_factor: float = _normalize(car.gear_ratio, 3.2, 4.6)  # 0 = lang/Topspeed, 1 = kurz/Beschleunigung
	var gear_topspeed_factor: float = 1.0 - gear_accel_factor

	var camber_extremity: float = _normalize(abs(car.camber_deg), 1.0, 4.0)
	var toe_extremity: float = _normalize(abs(car.toe_deg), 0.0, 0.5)

	var pressure_norm: float = _normalize(car.tire_pressure_bar, 1.6, 2.4)  # 0 = niedrig, 1 = hoch
	var pressure_grip_mod: float = lerp(1.1, 0.9, pressure_norm)            # niedriger Druck = mehr Grip
	var pressure_topspeed_mod: float = lerp(0.95, 1.05, pressure_norm)      # höherer Druck = mehr Topspeed

	var camber_grip_mod: float = lerp(0.9, 1.15, camber_extremity)
	var spring_mod: float = lerp(0.95, 1.05, _normalize(car.spring_rate, 60.0, 140.0))
	var sway_mod: float = lerp(0.97, 1.03, _normalize(car.sway_bar, 1.0, 10.0))

	var grip_dry_norm: float = float(tire.get("grip_dry", 5.0)) / 10.0

	# --- Topspeed (km/h) ---
	var topspeed_kmh: float = TOPSPEED_CONSTANT * (power_hp / (weight_kg * drag_factor)) \
		* lerp(0.85, 1.15, gear_topspeed_factor) * pressure_topspeed_mod
	topspeed_kmh = clamp(topspeed_kmh, 150.0, 340.0)

	# --- Beschleunigung 0-100 km/h (Sekunden, niedriger = besser) ---
	var power_to_weight: float = power_hp / weight_kg
	var accel_0_100_s: float = ACCEL_CONSTANT / (power_to_weight * grip_dry_norm \
		* lerp(0.85, 1.15, gear_accel_factor))
	accel_0_100_s = clamp(accel_0_100_s, 2.0, 8.0)

	# --- Kurvengrip-Index (unitless, höher = besser) ---
	var corner_grip_index: float = float(tire.get("grip_dry", 5.0)) \
		* camber_grip_mod * spring_mod * sway_mod \
		* (1.0 + downforce / 10.0) * pressure_grip_mod
	corner_grip_index = clamp(corner_grip_index, 0.0, 15.0)

	# --- Bremsweg 100-0 km/h (Meter, niedriger = besser) ---
	var braking_distance_m: float = BRAKE_CONSTANT / (float(brake.get("brake_power", 5.0)) \
		* grip_dry_norm * (1.0 + downforce / 10.0))
	braking_distance_m = clamp(braking_distance_m, 20.0, 80.0)

	# --- Reifenverschleiß-Rate (Index, höher = verschleißt schneller) ---
	var tire_wear_rate: float = float(tire.get("wear_factor", 1.0)) \
		* lerp(0.9, 1.3, camber_extremity) * lerp(0.95, 1.2, toe_extremity) * ecu["wear"]

	# --- Ausfallrisiko (% pro Rennen) ---
	var failure_risk_pct: float = FAILURE_CONSTANT \
		* (11 - int(engine.get("reliability", 10))) \
		* (11 - int(gearbox.get("reliability", 10))) * ecu["wear"]
	failure_risk_pct = clamp(failure_risk_pct, 0.0, 40.0)

	return {
		"weight_kg": weight_kg,
		"power_hp": power_hp,
		"topspeed_kmh": topspeed_kmh,
		"accel_0_100_s": accel_0_100_s,
		"corner_grip_index": corner_grip_index,
		"braking_distance_m": braking_distance_m,
		"tire_wear_rate": tire_wear_rate,
		"failure_risk_pct": failure_risk_pct,
	}


static func _normalize(value: float, min_val: float, max_val: float) -> float:
	return clamp((value - min_val) / (max_val - min_val), 0.0, 1.0)
