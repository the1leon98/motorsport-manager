extends Control
# Autohaus: kaufbare Fahrzeuge gegen Budget. In der Demo genau ein Chassis
# (siehe data/cars/showroom.json); gekaufte Fahrzeuge landen im Team-Inventar
# und stehen danach in der Werkstatt zur Auswahl.

@onready var budget_label: Label = $MarginContainer/VBoxContainer/BudgetLabel
@onready var car_name_label: Label = $MarginContainer/VBoxContainer/CarCard/CardContent/NameLabel
@onready var description_label: Label = $MarginContainer/VBoxContainer/CarCard/CardContent/DescriptionLabel
@onready var price_label: Label = $MarginContainer/VBoxContainer/CarCard/CardContent/PriceLabel
@onready var buy_button: Button = $MarginContainer/VBoxContainer/CarCard/CardContent/BuyButton
@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton

var car_data: Dictionary = {}


func _ready() -> void:
	var all_cars: Array = PartsDatabase.get_all_cars()
	car_data = all_cars[0] if not all_cars.is_empty() else {}

	back_button.pressed.connect(func(): SceneManager.goto_screen("hub"))
	buy_button.pressed.connect(_on_buy_pressed)

	if car_data.is_empty():
		car_name_label.text = "Kein Fahrzeug verfügbar"
		buy_button.disabled = true
	else:
		car_name_label.text = car_data["name"]
		description_label.text = car_data["description"]
		price_label.text = "Preis: %s" % GameState.format_money(car_data["price"])

	_refresh()


func _on_buy_pressed() -> void:
	if GameState.buy_car(car_data["id"]):
		status_label.text = "Gekauft! Das Fahrzeug steht jetzt in der Werkstatt zur Verfügung."
	else:
		status_label.text = "Nicht genug Budget."
	_refresh()


func _refresh() -> void:
	budget_label.text = "Budget: %s" % GameState.format_money(GameState.team.budget)
	if not car_data.is_empty():
		buy_button.disabled = float(car_data["price"]) > GameState.team.budget
