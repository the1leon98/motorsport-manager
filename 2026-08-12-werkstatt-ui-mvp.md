# Werkstatt-UI (Platzhalter-Grafik) Implementation Plan

> Hinweis zur Ausführung: Dieser Plan wird direkt in dieser Unterhaltung Task für
> Task umgesetzt (kein Subagent-System verfügbar). Jeder Task liefert vollständige,
> kopierfertige Dateien bzw. exakte Editor-Schritte. Checkboxen (`- [ ]`) dienen dem
> Fortschritts-Tracking.

**Goal:** Eine spielbare, grafisch schlichte Werkstatt-Szene, in der man für jede
Bauteilkategorie ein Teil aus der `PartsDatabase` auswählt, ausgewählte
Setup-Parameter per Slider einstellt, und live berechnete Fahrzeugstats sowie die
Regelkonformität gegen das aktive Regelwerk angezeigt bekommt.

**Architecture:** Eine Godot-`Control`-Szene (`GarageScreen.tscn`) mit
`OptionButton`s je Bauteilkategorie, `HSlider`n für ausgewählte Setup-Parameter,
und einem Textbereich für Stats + Regelverstöße. Ein `garage_controller.gd`-Skript
verbindet UI-Events mit `CarConfig`, ruft `StatsCalculator` und
`RegulationValidator` (alle aus Phase 1, `scripts/core/`) auf und aktualisiert die
Anzeige bei jeder Änderung. Reine 2D-UI mit Standard-Controls – keine 3D-Werkstatt-
grafik in diesem Plan, das ist ein eigener, späterer Plan (Roadmap Punkt 7).

**Tech Stack:** Godot 4 / GDScript. Wiederverwendet `scripts/core/parts_database.gd`
(Autoload `PartsDatabase`), `car_config.gd` (`CarConfig`), `stats_calculator.gd`
(`StatsCalculator`), `regulation_validator.gd` (`RegulationValidator`) aus Phase 1.

## Global Constraints

- Godot 4.x, GDScript (kein C#)
- Bestehende Autoload `PartsDatabase` wiederverwenden, nicht duplizieren
- Schnittstellen von `CarConfig`/`StatsCalculator`/`RegulationValidator` aus Phase 1
  nicht verändern (keine Breaking Changes)
- Reine UI-Platzhaltergrafik (Standard-Godot-Controls: `Label`, `OptionButton`,
  `HSlider`), keine Low-Poly-3D-Werkstatt in diesem Plan
- Diese MVP-Version exponiert 4 von 9 Setup-Parametern als Slider
  (`gear_ratio`, `camber_deg`, `tire_pressure_bar`, `ballast_kg`); die restlichen
  (`spring_rate`, `damper`, `sway_bar`, `toe_deg`) bleiben auf `CarConfig`-Default
  und sind ein eigener Fast-Follow-Task
- **Kein automatisiertes Test-Framework vorhanden** (kein GUT-Addon installiert):
  Jeder "Test"-Schritt in diesem Plan ist ein manueller Verifikationsschritt
  (Szene mit F6 starten, Editor-Ausgabe/UI-Zustand mit dem erwarteten Ergebnis
  vergleichen) statt eines automatisierten `pytest`-Laufs
- Regelwerk-ID für alle Prüfungen: `dtm_demo_2026`, Rennnummer: `1`

---

### Task 1: Szenen-Grundgerüst

**Files:**
- Create: `scenes/garage/GarageScreen.tscn`
- Create: `scripts/garage/garage_controller.gd`

**Interfaces:**
- Consumes: `CarConfig` (aus `scripts/core/car_config.gd`), Autoload `PartsDatabase`
- Produces: Node-Referenzen `parts_panel`, `setup_panel`, `stats_panel` (von späteren
  Tasks im selben Skript verwendet), leere Stub-Funktion `_refresh()`

- [ ] **Schritt 1: Szene im Godot-Editor anlegen**

  Neue Szene erstellen mit folgender Node-Struktur (Scene > New Scene > Other Node > `Control` als Root):

  | Node-Name | Typ | Parent |
  |---|---|---|
  | `GarageScreen` | `Control` | (Root) |
  | `MarginContainer` | `MarginContainer` | `GarageScreen` |
  | `HBoxContainer` | `HBoxContainer` | `MarginContainer` |
  | `PartsPanel` | `VBoxContainer` | `HBoxContainer` |
  | `SetupPanel` | `VBoxContainer` | `HBoxContainer` |
  | `StatsPanel` | `VBoxContainer` | `HBoxContainer` |

  Einstellungen im Inspector:
  - `GarageScreen`: oben im Viewport auf "Layout" → "Full Rect" klicken
  - `MarginContainer`: ebenfalls "Layout" → "Full Rect"; dann Inspector → Theme
    Overrides → Constants → `margin_left`/`margin_top`/`margin_right`/`margin_bottom`
    je auf `24` setzen
  - `HBoxContainer`: Inspector → Theme Overrides → Constants → `separation` auf `32`
  - `PartsPanel`, `SetupPanel`, `StatsPanel`: jeweils Inspector → Layout →
    Container Sizing → Horizontal → Häkchen bei "Expand" setzen

  Szene speichern unter `scenes/garage/GarageScreen.tscn`.

- [ ] **Schritt 2: Skript-Skelett erstellen**

  ```gdscript
  extends Control
  # Werkstatt-Bildschirm (Platzhalter-UI): Bauteile wählen, Setup einstellen,
  # Live-Stats + Regelkonformität anzeigen.

  const REGULATION_ID := "dtm_demo_2026"
  const CURRENT_RACE_NUMBER := 1

  @onready var parts_panel: VBoxContainer = $MarginContainer/HBoxContainer/PartsPanel
  @onready var setup_panel: VBoxContainer = $MarginContainer/HBoxContainer/SetupPanel
  @onready var stats_panel: VBoxContainer = $MarginContainer/HBoxContainer/StatsPanel

  var car := CarConfig.new()


  func _ready() -> void:
  	await get_tree().process_frame  # PartsDatabase-Autoload fertig laden lassen
  	print("GarageScreen bereit. Panels: %s / %s / %s" % [parts_panel, setup_panel, stats_panel])


  func _refresh() -> void:
  	pass  # wird in Task 4 und 5 mit echter Logik gefüllt
  ```

  Dieses Skript an den `GarageScreen`-Root-Node hängen und die Szene speichern.

- [ ] **Schritt 3: Verifikation**

  Szene mit F6 starten. Erwartung: kein rotes Fehler-Popup, im Ausgabe-Panel
  erscheint die Zeile `GarageScreen bereit. Panels: <VBoxContainer#...> / ...`
  (drei gültige Node-Referenzen, kein `<Null>`). Das Spielfenster zeigt eine
  leere, dunkle Fläche – das ist erwartet, da die drei Panels noch keine Kinder
  haben.

- [ ] **Schritt 4: Commit**

  ```bash
  git add scenes/garage/GarageScreen.tscn scripts/garage/garage_controller.gd
  git commit -m "feat(garage): Szenen-Grundgerüst für Werkstatt-UI"
  ```

---

### Task 2: Bauteil-Dropdowns

**Files:**
- Modify: `scripts/garage/garage_controller.gd`

**Interfaces:**
- Consumes: `PartsDatabase.get_all_parts(category: String) -> Array` (Phase 1)
- Produces: `part_option_buttons: Dictionary` (field_name -> `OptionButton`),
  von Task 4/5 nicht direkt benötigt, aber für spätere Erweiterungen (z.B.
  Kaufsperren) verfügbar

- [ ] **Schritt 1: Konstanten, Default-Auto und Aufbau-Funktionen ergänzen**

  Am Anfang der Klasse (nach den bestehenden `const`s) ergänzen:

  ```gdscript
  const PART_CATEGORIES := [
  	{"key": "engine", "label": "Motor", "field": "engine_id"},
  	{"key": "gearbox", "label": "Getriebe", "field": "gearbox_id"},
  	{"key": "chassis", "label": "Fahrwerk", "field": "chassis_id"},
  	{"key": "tire", "label": "Reifen", "field": "tire_id"},
  	{"key": "brake", "label": "Bremse", "field": "brake_id"},
  ]

  const AERO_SLOTS := [
  	{"subtype": "rear_wing", "label": "Heckspoiler", "field": "rear_wing_id"},
  	{"subtype": "diffuser", "label": "Diffusor", "field": "diffuser_id"},
  ]
  ```

  Nach der bestehenden `var car := CarConfig.new()`-Zeile ergänzen:

  ```gdscript
  var part_option_buttons: Dictionary = {}  # field_name -> OptionButton
  ```

  `_ready()` erweitern (ersetzt die bisherige `_ready()`-Funktion komplett):

  ```gdscript
  func _ready() -> void:
  	await get_tree().process_frame  # PartsDatabase-Autoload fertig laden lassen
  	_set_default_car()
  	_build_part_selectors()
  	_refresh()
  ```

  Neue Funktionen am Ende der Datei ergänzen:

  ```gdscript
  func _set_default_car() -> void:
  	car.engine_id = "E1"
  	car.gearbox_id = "G1"
  	car.chassis_id = "C1"
  	car.tire_id = "T2"
  	car.brake_id = "B1"
  	car.rear_wing_id = "A2"
  	car.diffuser_id = "A4"


  func _build_part_selectors() -> void:
  	for entry in PART_CATEGORIES:
  		_add_part_row(entry["key"], entry["label"], entry["field"])
  	for entry in AERO_SLOTS:
  		_add_aero_row(entry["subtype"], entry["label"], entry["field"])


  func _add_part_row(category: String, label_text: String, field: String) -> void:
  	var label := Label.new()
  	label.text = label_text
  	parts_panel.add_child(label)

  	var option := OptionButton.new()
  	var parts: Array = PartsDatabase.get_all_parts(category)
  	for part in parts:
  		var display_text: String = part["name"]
  		if category == "engine":
  			display_text = "%s (%.0f PS)" % [part["name"], float(part.get("power_hp", 0))]
  		option.add_item(display_text)
  		option.set_item_metadata(option.item_count - 1, part["id"])
  	_select_current_value(option, car.get(field))
  	option.item_selected.connect(func(index: int) -> void:
  		car.set(field, option.get_item_metadata(index))
  		_refresh()
  	)
  	parts_panel.add_child(option)
  	part_option_buttons[field] = option


  func _add_aero_row(subtype: String, label_text: String, field: String) -> void:
  	var label := Label.new()
  	label.text = label_text
  	parts_panel.add_child(label)

  	var option := OptionButton.new()
  	var all_aero: Array = PartsDatabase.get_all_parts("aero")
  	for part in all_aero:
  		if part.get("subtype", "") == subtype:
  			option.add_item(part["name"])
  			option.set_item_metadata(option.item_count - 1, part["id"])
  	_select_current_value(option, car.get(field))
  	option.item_selected.connect(func(index: int) -> void:
  		car.set(field, option.get_item_metadata(index))
  		_refresh()
  	)
  	parts_panel.add_child(option)
  	part_option_buttons[field] = option


  func _select_current_value(option: OptionButton, current_id) -> void:
  	for i in option.item_count:
  		if option.get_item_metadata(i) == current_id:
  			option.select(i)
  			return
  ```

- [ ] **Schritt 2: Verifikation**

  Szene mit F6 starten. Erwartung: 7 Label/Dropdown-Paare erscheinen im linken
  Bereich (Motor, Getriebe, Fahrwerk, Reifen, Bremse, Heckspoiler, Diffusor).
  Jedes Dropdown zeigt die passenden Bauteilnamen (Motor-Dropdown zusätzlich mit
  PS-Angabe), die Vorauswahl entspricht `_set_default_car()` (z.B. Motor zeigt
  "Voss V8 4.0 Sauger"). Auswahl ändern löst keinen Fehler aus (auch wenn optisch
  noch nichts passiert, da `_refresh()` noch leer ist).

- [ ] **Schritt 3: Commit**

  ```bash
  git add scripts/garage/garage_controller.gd
  git commit -m "feat(garage): Bauteil-Dropdowns mit Live-Auswahl"
  ```

---

### Task 3: Setup-Slider

**Files:**
- Modify: `scripts/garage/garage_controller.gd`

**Interfaces:**
- Consumes: `CarConfig`-Felder `gear_ratio`, `camber_deg`, `tire_pressure_bar`,
  `ballast_kg`, `ecu_mapping` (Phase 1)
- Produces: `setup_sliders: Dictionary`, `ecu_option_button: OptionButton`

- [ ] **Schritt 1: Konstanten, Variablen und Aufbau-Funktionen ergänzen**

  Nach `AERO_SLOTS` ergänzen:

  ```gdscript
  const ECU_OPTIONS := ["qualifying", "race", "fuelsaving"]
  const ECU_LABELS := {"qualifying": "Qualifying", "race": "Race", "fuelsaving": "Fuelsaving"}
  ```

  Nach `var part_option_buttons: Dictionary = {}` ergänzen:

  ```gdscript
  var setup_sliders: Dictionary = {}  # field_name -> HSlider
  var ecu_option_button: OptionButton
  ```

  `_ready()` erweitern (Zeile `_build_part_selectors()` ergänzen um):

  ```gdscript
  	_build_setup_controls()
  ```

  (direkt nach `_build_part_selectors()`, vor `_refresh()`)

  Neue Funktionen am Ende der Datei ergänzen:

  ```gdscript
  func _build_setup_controls() -> void:
  	_add_slider("gear_ratio", "Getriebeübersetzung", 3.2, 4.6, 0.05)
  	_add_slider("camber_deg", "Sturz (°)", -4.0, -1.0, 0.1)
  	_add_slider("tire_pressure_bar", "Reifendruck (bar)", 1.6, 2.4, 0.05)
  	_add_slider("ballast_kg", "Ballast (kg)", 0.0, 60.0, 1.0)

  	var ecu_label := Label.new()
  	ecu_label.text = "ECU-Mapping"
  	setup_panel.add_child(ecu_label)

  	ecu_option_button = OptionButton.new()
  	for ecu_key in ECU_OPTIONS:
  		ecu_option_button.add_item(ECU_LABELS[ecu_key])
  		ecu_option_button.set_item_metadata(ecu_option_button.item_count - 1, ecu_key)
  	_select_current_value(ecu_option_button, car.ecu_mapping)
  	ecu_option_button.item_selected.connect(func(index: int) -> void:
  		car.ecu_mapping = ecu_option_button.get_item_metadata(index)
  		_refresh()
  	)
  	setup_panel.add_child(ecu_option_button)


  func _add_slider(field: String, label_text: String, min_val: float, max_val: float, step: float) -> void:
  	var label := Label.new()
  	label.text = label_text
  	setup_panel.add_child(label)

  	var slider := HSlider.new()
  	slider.min_value = min_val
  	slider.max_value = max_val
  	slider.step = step
  	slider.value = car.get(field)
  	slider.value_changed.connect(func(value: float) -> void:
  		car.set(field, value)
  		_refresh()
  	)
  	setup_panel.add_child(slider)
  	setup_sliders[field] = slider
  ```

- [ ] **Schritt 2: Verifikation**

  Szene mit F6 starten. Erwartung: im mittleren Bereich erscheinen 4 Label/Slider-
  Paare sowie ein Label/Dropdown-Paar für ECU-Mapping. Die Slider-Startpositionen
  entsprechen den `CarConfig`-Defaults (z.B. Sturz-Slider bei -2.5°, Reifendruck
  bei 2.0 bar). Slider bewegen löst keinen Fehler aus.

- [ ] **Schritt 3: Commit**

  ```bash
  git add scripts/garage/garage_controller.gd
  git commit -m "feat(garage): Setup-Slider für Getriebeübersetzung, Sturz, Reifendruck, Ballast, ECU"
  ```

---

### Task 4: Live-Stats-Anzeige

**Files:**
- Modify: `scripts/garage/garage_controller.gd`

**Interfaces:**
- Consumes: `StatsCalculator.calculate(car: CarConfig, db: Node) -> Dictionary` (Phase 1)
- Produces: `stats_label: Label`, gefüllte `_refresh()`-Funktion (Stats-Teil)

- [ ] **Schritt 1: Stats-Panel und `_refresh()` implementieren**

  Nach `var ecu_option_button: OptionButton` ergänzen:

  ```gdscript
  var stats_label: Label
  ```

  `_ready()` erweitern (nach `_build_setup_controls()` ergänzen):

  ```gdscript
  	_build_stats_panel()
  ```

  Die bisherige Stub-Funktion `_refresh()` komplett ersetzen durch:

  ```gdscript
  func _build_stats_panel() -> void:
  	stats_label = Label.new()
  	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD
  	stats_panel.add_child(stats_label)


  func _refresh() -> void:
  	var stats: Dictionary = StatsCalculator.calculate(car, PartsDatabase)
  	stats_label.text = "PS: %.0f    Gewicht: %.0f kg    Topspeed: %.0f km/h\n0-100: %.2f s    Kurvengrip: %.1f    Bremsweg: %.0f m\nReifenverschleiß: %.2f    Ausfallrisiko: %.1f%%" % [
  		stats["power_hp"], stats["weight_kg"], stats["topspeed_kmh"],
  		stats["accel_0_100_s"], stats["corner_grip_index"], stats["braking_distance_m"],
  		stats["tire_wear_rate"], stats["failure_risk_pct"],
  	]
  ```

- [ ] **Schritt 2: Verifikation**

  Szene mit F6 starten. Erwartung: rechts erscheint ein Text mit PS/Gewicht/
  Topspeed/Beschleunigung/Kurvengrip/Bremsweg/Verschleiß/Ausfallrisiko für das
  Default-Auto. Werte sollten in der Größenordnung der Konsolenausgabe aus
  `test_stats.gd` (Phase 1) liegen. Ein Bauteil wechseln oder einen Slider
  bewegen → der Text aktualisiert sich sofort mit neuen, plausibel veränderten
  Werten (z.B. anderer Motor → andere PS-Zahl).

- [ ] **Schritt 3: Commit**

  ```bash
  git add scripts/garage/garage_controller.gd
  git commit -m "feat(garage): Live-Stats-Anzeige"
  ```

---

### Task 5: Regelkonformitäts-Anzeige

**Files:**
- Modify: `scripts/garage/garage_controller.gd`

**Interfaces:**
- Consumes: `RegulationValidator.validate(car, stats, db, regulation_id, race_number) -> Dictionary` (Phase 1)
- Produces: `compliance_label: Label`, vollständige `_refresh()`-Funktion

- [ ] **Schritt 1: Compliance-Label ergänzen**

  Nach `var stats_label: Label` ergänzen:

  ```gdscript
  var compliance_label: Label
  ```

  `_build_stats_panel()` erweitern (Funktion komplett ersetzen):

  ```gdscript
  func _build_stats_panel() -> void:
  	stats_label = Label.new()
  	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD
  	stats_panel.add_child(stats_label)

  	compliance_label = Label.new()
  	compliance_label.autowrap_mode = TextServer.AUTOWRAP_WORD
  	stats_panel.add_child(compliance_label)
  ```

  `_refresh()` erweitern (am Ende der Funktion ergänzen, nach der bestehenden
  `stats_label.text = ...`-Zeile):

  ```gdscript
  	var result: Dictionary = RegulationValidator.validate(car, stats, PartsDatabase, REGULATION_ID, CURRENT_RACE_NUMBER)
  	if result["compliant"]:
  		compliance_label.text = "✅ Regelkonform"
  	else:
  		var lines: Array = ["❌ Nicht regelkonform:"]
  		for v in result["violations"]:
  			lines.append(" - %s" % v)
  		compliance_label.text = "\n".join(lines)
  ```

- [ ] **Schritt 2: Verifikation (kompletter manueller Durchlauf)**

  Szene mit F6 starten.
  1. Default-Auto → Erwartung: "✅ Regelkonform"
  2. Getriebe-Dropdown auf "Race-Sequential" (G3) stellen → Erwartung: "❌ Nicht
     regelkonform", Zeile zu Bauteil G3 erscheint
  3. Heckspoiler auf "Heckspoiler High" (A3) stellen → zusätzliche Verstoß-Zeile
     zu A3 erscheint
  4. Bremse auf "Carbon-Keramik Race" (B3) stellen → zusätzliche Verstoß-Zeile
     zu B3 erscheint (Freigabe erst ab Rennen 3)
  5. Ballast-Slider auf 0 stellen, Fahrwerk auf "Leichtbau-Fahrwerk" (C4) → sofern
     das Gewicht unter das Mindestgewicht fällt, erscheint die entsprechende
     Verstoß-Zeile

- [ ] **Schritt 3: Commit**

  ```bash
  git add scripts/garage/garage_controller.gd
  git commit -m "feat(garage): Regelkonformitäts-Anzeige mit Verstoß-Liste"
  ```

---

## Self-Review

- **Spec-Abdeckung:** Bauteil-Auswahl (Task 2), Setup-Parameter (Task 3),
  Live-Stats (Task 4), Regelkonformität (Task 5) – alle vier Ziele aus dem Goal
  sind durch je einen Task abgedeckt.
- **Platzhalter-Scan:** Kein Task enthält "TBD", "später ergänzen" o.ä. – jeder
  Code-Block ist vollständig copy-paste-fertig.
- **Typkonsistenz:** Funktionsnamen (`_refresh`, `_build_part_selectors`,
  `_add_part_row`, `_add_aero_row`, `_select_current_value`,
  `_build_setup_controls`, `_add_slider`, `_build_stats_panel`) und Feldnamen
  (`engine_id`, `gearbox_id`, `chassis_id`, `tire_id`, `brake_id`,
  `rear_wing_id`, `diffuser_id`, `gear_ratio`, `camber_deg`,
  `tire_pressure_bar`, `ballast_kg`, `ecu_mapping`) sind über alle Tasks hinweg
  identisch verwendet und stimmen mit `car_config.gd` aus Phase 1 überein.

## Offen für Fast-Follow (nicht Teil dieses Plans)

- Slider für `spring_rate`, `damper`, `sway_bar`, `toe_deg` ergänzen
- Kauf-/Budget-Logik (Bauteile aktuell ohne Preisprüfung wählbar)
- Low-Poly-3D-Werkstattansicht (eigener Plan, siehe Roadmap Punkt 7)
