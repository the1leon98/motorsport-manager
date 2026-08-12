extends Resource
class_name Team
# Laufzeit-Zustand eines Teams: besessene Fahrzeuge, Budget, Saisonfortschritt.
# Wird über SaveManager (scripts/core/save_manager.gd) als Teil von
# SaveData nach user://savegame.tres gespeichert/geladen.

@export var cars: Array[CarConfig] = []
@export var budget: float = 0.0
@export var current_race_number: int = 1
@export var selected_car_index: int = -1  # Index in cars, -1 = kein Fahrzeug gewählt
