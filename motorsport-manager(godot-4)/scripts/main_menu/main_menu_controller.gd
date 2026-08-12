extends Control
# Hauptmenü: Einstiegspunkt des Spiels. "Schnelles Spiel" und "Karriere"
# unterscheiden sich im Grundgerüst noch nicht (siehe Roadmap Phase B) –
# beide starten einen frischen Spielstand und führen zum Hub.

@onready var quick_play_button: Button = $CenterContainer/VBoxContainer/QuickPlayButton
@onready var career_button: Button = $CenterContainer/VBoxContainer/CareerButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	quick_play_button.pressed.connect(_on_quick_play_pressed)
	career_button.pressed.connect(_on_career_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_quick_play_pressed() -> void:
	GameState.start_new_game("quick")
	SceneManager.goto_screen("hub")


func _on_career_pressed() -> void:
	GameState.start_new_game("career")
	SceneManager.goto_screen("hub")


func _on_quit_pressed() -> void:
	get_tree().quit()
