extends Control
# Hauptmenü: Einstiegspunkt des Spiels. "Schnelles Spiel" und "Karriere"
# unterscheiden sich im Grundgerüst noch nicht (siehe Roadmap Phase B) –
# beide führen über die Slot-Auswahl zum Hub. Es gibt SaveManager.SLOT_COUNT
# unabhängige Speicherstand-Slots; die Slot-Auswahl wird dynamisch befüllt
# (siehe _build_slot_row), analog zur Kalenderliste in season_controller.gd.

@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var quick_play_button: Button = $CenterContainer/VBoxContainer/QuickPlayButton
@onready var career_button: Button = $CenterContainer/VBoxContainer/CareerButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var confirm_dialog: ConfirmationDialog = $DeleteSaveConfirmDialog
@onready var slot_picker_window: Window = $SlotPickerWindow
@onready var slot_list: VBoxContainer = $SlotPickerWindow/MarginContainer/SlotList

var _picker_mode: String = ""       # "load" oder "new"
var _pending_new_game_mode: String = ""
var _confirm_action: String = ""    # "delete" oder "overwrite"
var _confirm_slot: int = -1


func _ready() -> void:
	_refresh_continue_button()
	continue_button.pressed.connect(func(): _open_slot_picker("load"))
	quick_play_button.pressed.connect(func(): _open_slot_picker("new", "quick"))
	career_button.pressed.connect(func(): _open_slot_picker("new", "career"))
	quit_button.pressed.connect(_on_quit_pressed)
	confirm_dialog.confirmed.connect(_on_confirm_dialog_confirmed)
	slot_picker_window.close_requested.connect(func(): slot_picker_window.hide())


func _refresh_continue_button() -> void:
	continue_button.visible = SaveManager.any_save_exists()


func _open_slot_picker(mode: String, new_game_mode: String = "") -> void:
	_picker_mode = mode
	_pending_new_game_mode = new_game_mode
	slot_picker_window.title = "Spielstand laden" if mode == "load" else "Neues Spiel – Slot wählen"
	_populate_slot_list()
	slot_picker_window.popup_centered()


func _populate_slot_list() -> void:
	for child in slot_list.get_children():
		child.queue_free()
	for slot in range(SaveManager.SLOT_COUNT):
		slot_list.add_child(_build_slot_row(slot, SaveManager.get_slot_info(slot)))


func _build_slot_row(slot: int, info: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)

	var label := Label.new()
	label.custom_minimum_size = Vector2(260, 0)
	label.text = _slot_description(slot, info)
	row.add_child(label)

	var action_button := Button.new()
	if _picker_mode == "load":
		action_button.text = "Laden"
		action_button.disabled = not info["exists"]
		action_button.pressed.connect(func(): _on_load_slot_pressed(slot))
	else:
		action_button.text = "Überschreiben" if info["exists"] else "Spiel starten"
		action_button.pressed.connect(func(): _on_start_new_game_pressed(slot))
	row.add_child(action_button)

	if info["exists"]:
		var delete_button := Button.new()
		delete_button.text = "Löschen"
		delete_button.pressed.connect(func(): _on_delete_slot_pressed(slot))
		row.add_child(delete_button)

	return row


func _slot_description(slot: int, info: Dictionary) -> String:
	if not info["exists"]:
		return "Slot %d: leer" % (slot + 1)
	var mode_text: String = "Karriere" if info["game_mode"] == "career" else "Schnelles Spiel"
	return "Slot %d: %s · Rennen %d · %s" % [
		slot + 1, mode_text, info["current_race_number"], GameState.format_money(info["budget"]),
	]


func _on_load_slot_pressed(slot: int) -> void:
	slot_picker_window.hide()
	if SaveManager.load_game(slot):
		SceneManager.goto_screen("hub")
	else:
		push_error("Spielstand konnte nicht geladen werden.")
		_refresh_continue_button()


func _on_delete_slot_pressed(slot: int) -> void:
	_confirm_action = "delete"
	_confirm_slot = slot
	confirm_dialog.dialog_text = "Spielstand in Slot %d wirklich unwiderruflich löschen?" % (slot + 1)
	confirm_dialog.ok_button_text = "Löschen"
	confirm_dialog.popup_centered()


func _on_start_new_game_pressed(slot: int) -> void:
	if SaveManager.get_slot_info(slot)["exists"]:
		_confirm_action = "overwrite"
		_confirm_slot = slot
		confirm_dialog.dialog_text = "Slot %d überschreiben? Der bestehende Spielstand geht dabei verloren." % (slot + 1)
		confirm_dialog.ok_button_text = "Überschreiben"
		confirm_dialog.popup_centered()
	else:
		_start_new_game_in_slot(slot)


func _on_confirm_dialog_confirmed() -> void:
	match _confirm_action:
		"delete":
			SaveManager.delete_save(_confirm_slot)
			_populate_slot_list()
			_refresh_continue_button()
		"overwrite":
			_start_new_game_in_slot(_confirm_slot)
	_confirm_action = ""
	_confirm_slot = -1


func _start_new_game_in_slot(slot: int) -> void:
	GameState.start_new_game(_pending_new_game_mode)
	SaveManager.current_slot = slot
	slot_picker_window.hide()
	SceneManager.goto_screen("hub")


func _on_quit_pressed() -> void:
	get_tree().quit()
