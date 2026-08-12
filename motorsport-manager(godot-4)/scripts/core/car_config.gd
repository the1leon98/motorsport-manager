extends Resource
class_name CarConfig
# Repräsentiert ein zusammengebautes Fahrzeug: gewählte Bauteil-IDs + Setup-Parameter.
# Als Resource speicherbar (.tres), z.B. um den Autozustand eines Spielstands abzulegen.

# Marketing-Name aus dem Autohaus (z.B. "Voss GT30"), unabhängig von den
# austauschbaren Bauteilen darunter. Für die Anzeige in Hub/Werkstatt.
@export var model_name: String = ""

# --- Bauteilwahl (IDs aus data/parts/*.json) ---
@export var engine_id: String = ""
@export var gearbox_id: String = ""
@export var chassis_id: String = ""
@export var tire_id: String = ""
@export var brake_id: String = ""
@export var rear_wing_id: String = ""   # optional, "" = kein Heckspoiler montiert
@export var diffuser_id: String = ""    # optional, "" = kein Diffusor montiert

# --- Setup-Parameter, siehe GDD Abschnitt 5 ---
@export var gear_ratio: float = 3.9         # 3.2 (lang/Topspeed) .. 4.6 (kurz/Beschleunigung)
@export var spring_rate: float = 100.0      # 60 .. 140 N/mm
@export var damper: float = 5.0             # 1 .. 10 Klicks
@export var sway_bar: float = 5.0           # 1 .. 10
@export var camber_deg: float = -2.5        # -4.0 .. -1.0 Grad
@export var toe_deg: float = 0.0            # -0.5 .. 0.5 Grad
@export var tire_pressure_bar: float = 2.0  # 1.6 .. 2.4 bar
@export_enum("qualifying", "race", "fuelsaving") var ecu_mapping: String = "race"
@export var ballast_kg: float = 20.0        # 0 .. 60 kg

# Verschleißzustand 0.0 (neu) .. 1.0 (komplett verschlissen).
# Wird erst ab Phase mit Renn-/Trainingssimulation tatsächlich hochgezählt.
@export var wear_state: float = 0.0
