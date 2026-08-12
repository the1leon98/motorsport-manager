extends Resource
class_name Team
# Laufzeit-Zustand eines Teams: besessene Fahrzeuge, Budget, Saisonfortschritt.
# Kein Speichern/Laden auf Festplatte im Grundgerüst – geht bei Neustart verloren.

@export var cars: Array[CarConfig] = []
@export var budget: float = 0.0
@export var current_race_number: int = 1
@export var selected_car_index: int = -1  # Index in cars, -1 = kein Fahrzeug gewählt
