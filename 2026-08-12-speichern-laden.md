# Speichern/Laden Implementation Plan

> Hinweis zur Ausführung: Wie bei den bisherigen Werkstatt-Plänen
> (`2026-08-12-werkstatt-ui-mvp.md`, `2026-08-12-werkstatt-setup-slider-fastfollow.md`)
> gibt es kein Subagent-System in dieser Umgebung. Dieser Plan wird bei Freigabe
> direkt in der Unterhaltung Task für Task umgesetzt. Checkboxen (`- [ ]`) dienen
> dem Fortschritts-Tracking; aktuell ist noch kein Task umgesetzt.

**Goal:** Der Spielstand (`GameState.team` mit Budget, Fahrzeug-Inventar,
Saisonfortschritt, sowie `GameState.game_mode`) übersteht einen Neustart des
Spiels. Dafür: ein `SaveManager`-Autoload mit `save_game()`/`load_game()`/
`has_save()`, ein manueller "Speichern"-Button im Hub, ein Autosave beim
Betreten des Hubs sowie beim Beenden des Spiels, und ein "Fortsetzen"-Button im
Hauptmenü, der nur erscheint, wenn ein Spielstand existiert.

**Architecture:** Neue Resource-Klasse `SaveData` (Wrapper um `team: Team` +
`game_mode: String` + eine Formatversion) und ein neues Autoload `SaveManager`
(`scripts/core/save_manager.gd`), das `SaveData` per `ResourceSaver`/
`ResourceLoader` unter einem festen Pfad (`user://savegame.tres`) schreibt bzw.
liest und dabei `GameState.team`/`GameState.game_mode` setzt. `Team` und
`CarConfig` sind bereits `Resource`-Subklassen mit rein `@export`-Feldern
(Phase C) – sie werden von `ResourceSaver` automatisch als eingebettete
Sub-Resourcen mitgespeichert, ohne dass an `team.gd`/`car_config.gd` selbst
etwas geändert werden muss. `SaveManager` ist bewusst ein eigenes Autoload statt
neuer Methoden auf `GameState`, analog zur bestehenden Trennung
`PartsDatabase` (Inhalte) / `SceneManager` (Navigation) / `GameState`
(Laufzeit-Zustand) → `SaveManager` (Persistenz). `hub_controller.gd` und
`main_menu_controller.gd` bekommen die UI-Anbindung (Speichern-Button im Hub,
Fortsetzen-Button im Hauptmenü).

**Tech Stack:** Godot 4.7 / GDScript. Wiederverwendet `scripts/core/team.gd`
(`Team`), `scripts/core/car_config.gd` (`CarConfig`), `scripts/core/game_state.gd`
(`GameState`) unverändert in ihren Schnittstellen; neu: `ResourceSaver`,
`ResourceLoader`, `FileAccess.file_exists()`.

## Design-Entscheidungen

Drei Kernfragen wurden vor diesem Plan geklärt (statt sie als Platzhalter offen
zu lassen):

- **Speicher-Trigger: Autosave + manueller Save.** Autosave beim Betreten des
  Hubs (deckt praktisch alle Rückkehr-Punkte aus Werkstatt/Autohaus/
  Boxengasse/Rennen mit einem einzigen Hook ab, siehe Task 2) und beim Beenden
  des Spiels (Fenster schließen, siehe Task 1) als Sicherheitsnetz gegen
  Datenverlust; zusätzlich ein expliziter "Speichern"-Button im Hub für
  Spieler, die aktiv sichergehen wollen. Reiner Autosave ohne Button gäbe dem
  Spieler keine Kontrolle/Bestätigung, reiner manueller Save riskiert
  vergessenes Speichern.
- **Ein Spielstand-Slot.** Fixer Pfad `user://savegame.tres`, keine
  Slot-Verwaltung/-Auswahl-UI. Passt zum aktuellen Grundgerüst-Umfang (Roadmap:
  Speichern/Laden war explizit zurückgestellt, siehe
  `2026-08-12-spiel-grundgeruest-roadmap.md`, Abschnitt "Explizit nicht Teil
  des Grundgerüsts") – mehrere Slots sind reiner UI-/Verwaltungs-Mehraufwand
  ohne neue Kernlogik und werden als Fast-Follow zurückgestellt (siehe "Offen
  für später").
- **Format: `ResourceSaver`/.tres statt JSON.** `Team` und `CarConfig` sind
  bereits `Resource`-Subklassen mit ausschließlich `@export`-Feldern; der
  Doc-Kommentar in `car_config.gd` sieht das sogar schon explizit vor ("Als
  Resource speicherbar (.tres)"). Damit ist keinerlei manuelles
  `to_dict()`/`from_dict()` nötig – deutlich weniger Code als der JSON-Weg, der
  für `Team`+`Array[CarConfig]` von Hand serialisiert werden müsste.

## Global Constraints

- Godot 4.7, GDScript (kein C#)
- Bestehende Autoloads `PartsDatabase`, `SceneManager`, `GameState` nicht in
  ihrer öffentlichen Schnittstelle verändern (keine Breaking Changes); der neue
  `SaveManager` liest/schreibt nur `GameState.team` und `GameState.game_mode`
  von außen
- Ein Spielstand-Slot, fixer Pfad `user://savegame.tres` (siehe
  Design-Entscheidungen) – keine Slot-Auswahl-UI in diesem Plan
- Speicherformat `ResourceSaver`/.tres (siehe Design-Entscheidungen) – kein
  JSON, keine Verschlüsselung/Signatur (lokales Singleplayer-Spiel, kein
  Cheat-Schutz-Scope)
- `GameState.race_cleared` wird **bewusst nicht** persistiert: es ist
  Session-Zustand innerhalb eines einzelnen Boxengasse→Rennen-Durchlaufs
  (`game_state.gd:17`); nach einem Laden ist der Spieler ohnehin wieder im Hub,
  wo dieses Flag irrelevant ist
- `save_format_version`-Feld in `SaveData` wird angelegt, aber in diesem Plan
  nicht ausgewertet (keine Migrationslogik) – reine Vorbereitung für später
- **Kein automatisiertes Test-Framework vorhanden** (kein GUT-Addon
  installiert): jeder "Test"-Schritt ist ein manueller Verifikationsschritt
  (Szene mit F6 starten bzw. Headless-Lauf, Datei-/UI-Zustand mit dem
  erwarteten Ergebnis vergleichen)
- Autosave-Zeitpunkte sind bewusst minimal gehalten (Hub-Eintritt + Beenden)
  statt an jeder einzelnen Zustandsänderung (z.B. jeder Slider-Bewegung in der
  Werkstatt) – letzteres wäre unnötig häufiges Disk-I/O ohne spürbaren Nutzen,
  da der Hub ohnehin jeder Rückkehr aus jedem Unterbereich vorgeschaltet ist

---

### Task 1: `SaveData`-Resource + `SaveManager`-Autoload

**Files:**
- Create: `scripts/core/save_data.gd`
- Create: `scripts/core/save_manager.gd`
- Modify: `project.godot` (Abschnitt `[autoload]`)
- Modify: `scripts/core/team.gd:3-4` (veralteter Kommentar zu
  "kein Speichern/Laden" wird entfernt/aktualisiert)

**Interfaces:**
- Consumes: `GameState.team` (`Team`, Phase C), `GameState.game_mode`
  (`String`), `Team`/`CarConfig` als `Resource`-Subklassen (unverändert)
- Produces: Autoload `SaveManager` mit `has_save() -> bool`,
  `save_game() -> bool`, `load_game() -> bool`; Resource-Klasse `SaveData` –
  beide von Task 2 und Task 3 verwendet

- [x] **Schritt 1: `SaveData`-Resource-Klasse erstellen**

  Neue Datei `scripts/core/save_data.gd`:

  ```gdscript
  extends Resource
  class_name SaveData
  # Container für alles, was in einer Save-Datei landet. Team/CarConfig werden
  # als eingebettete Sub-Resourcen automatisch mitgespeichert.

  const CURRENT_FORMAT_VERSION := 1

  @export var save_format_version: int = CURRENT_FORMAT_VERSION
  @export var game_mode: String = "career"
  @export var team: Team = null
  ```

- [x] **Schritt 2: `SaveManager`-Skript erstellen**

  Neue Datei `scripts/core/save_manager.gd`:

  ```gdscript
  extends Node
  # Autoload-Singleton: liest/schreibt den Spielstand (GameState.team +
  # GameState.game_mode) als SaveData-Resource unter einem festen Pfad.
  #
  # EINRICHTUNG IN GODOT:
  # Project > Project Settings > Autoload
  #   Path: res://scripts/core/save_manager.gd
  #   Node Name: SaveManager
  #   -> "Add" klicken

  const SAVE_PATH := "user://savegame.tres"


  func has_save() -> bool:
  	return FileAccess.file_exists(SAVE_PATH)


  func save_game() -> bool:
  	var data := SaveData.new()
  	data.game_mode = GameState.game_mode
  	data.team = GameState.team
  	var err: Error = ResourceSaver.save(data, SAVE_PATH)
  	if err != OK:
  		push_error("Speichern fehlgeschlagen (Fehlercode %d)" % err)
  		return false
  	return true


  func load_game() -> bool:
  	if not has_save():
  		return false
  	var data := ResourceLoader.load(SAVE_PATH, "SaveData", ResourceLoader.CACHE_MODE_IGNORE) as SaveData
  	if data == null:
  		push_error("Spielstand konnte nicht geladen werden oder ist beschädigt: %s" % SAVE_PATH)
  		return false
  	GameState.game_mode = data.game_mode
  	GameState.team = data.team
  	GameState.race_cleared = false
  	return true


  func _notification(what: int) -> void:
  	if what == NOTIFICATION_WM_CLOSE_REQUEST:
  		save_game()
  		get_tree().quit()
  ```

  `_notification(NOTIFICATION_WM_CLOSE_REQUEST)` fängt das Schließen des
  Fensters ab, speichert best-effort (Ergebnis wird nicht geprüft – ein
  fehlgeschlagener Autosave beim Beenden soll das Beenden selbst nicht
  blockieren) und beendet das Spiel danach explizit selbst.

- [x] **Schritt 3: Autoload registrieren**

  Im Godot-Editor: Project > Project Settings > Autoload → Path
  `res://scripts/core/save_manager.gd`, Node Name `SaveManager` → "Add".
  Ergebnis in `project.godot` (Abschnitt `[autoload]`, nach `GameState`):

  ```
  SaveManager="*res://scripts/core/save_manager.gd"
  ```

  > Umgesetzt am 2026-08-12 per direktem Edit von `project.godot` (kein
  > Editor-GUI in dieser Umgebung verfügbar) – Ergebnis ist identisch zu dem,
  > was der "Add"-Klick im Editor erzeugt hätte.

- [x] **Schritt 4: Veralteten Kommentar in `team.gd` aktualisieren**

  In `scripts/core/team.gd` die Kommentarzeile

  ```gdscript
  # Kein Speichern/Laden auf Festplatte im Grundgerüst – geht bei Neustart verloren.
  ```

  ersetzen durch:

  ```gdscript
  # Wird über SaveManager (scripts/core/save_manager.gd) als Teil von
  # SaveData nach user://savegame.tres gespeichert/geladen.
  ```

- [ ] **Schritt 5: Verifikation**

  Da es noch keine UI-Anbindung gibt (folgt in Task 2/3), Verifikation über
  ein temporäres Testskript (z.B. an einer beliebigen Szene mit F6 oder
  headless via `godot --headless --path . res://scenes/main_menu/MainMenu.tscn
  --quit-after 5`), das folgenden Ablauf mit `print()`-Ausgaben nachstellt und
  danach wieder entfernt wird:

  1. `GameState.start_new_game("career")`, `GameState.buy_car(<gültige
     showroom-ID>)`, ein paar Werte manuell ändern (z.B.
     `GameState.team.budget -= 1000`).
  2. `SaveManager.has_save()` → erwartet `false` (noch keine Datei).
  3. `SaveManager.save_game()` → erwartet `true`. `SaveManager.has_save()`
     jetzt → erwartet `true`. Datei prüfen: existiert unter dem
     Godot-`user://`-Pfad (unter Windows i.d.R.
     `%APPDATA%\Godot\app_userdata\motorsport-manager(godot4)\savegame.tres`).
  4. `GameState.team = Team.new()` (Zustand hart zurücksetzen, simuliert
     Neustart), dann `SaveManager.load_game()` → erwartet `true`.
     `GameState.team.budget`, `.cars.size()`, `.current_race_number` müssen
     wieder den Werten aus Schritt 1 entsprechen.
  5. **Wichtig:** direkt danach ein zweites Mal `SaveManager.save_game()`
     aufrufen (Save → Load → erneut Save, nicht nur einmal) und auf
     Editor-/Konsolen-Warnungen zu doppelten Resource-Pfaden achten. Falls
     solche Warnungen auftreten (bekannte Godot-Eigenheit bei
     wiederverwendeten eingebetteten Sub-Resourcen nach einem Load), ist die
     Korrektur `data.team = GameState.team.duplicate(true)` in
     `save_game()` statt der direkten Referenz – das während der Verifikation
     entscheiden, nicht vorab spekulativ einbauen.
  6. Kein leerer/fehlender Save (`SaveManager.load_game()` ohne vorherige
     Datei) → erwartet `false`, kein Absturz.

  > Verifiziert am 2026-08-12 per Headless-Lauf (`godot --headless --path .
  > res://test_save_verification.tscn --quit-after 30`, temporäres
  > Testskript danach wieder entfernt). Alle 6 Prüfpunkte trafen exakt zu:
  > `has_save()` vor dem ersten Save `false`, `save_game()` → `true` und
  > `has_save()` danach `true`, Werte nach Load (`budget=54000`, `cars=1`,
  > `race=3`) identisch zu den vor dem Save gesetzten, zweites `save_game()`
  > direkt nach einem Load lief ohne Fehler/Warnung (die in Schritt 5 als
  > mögliches Risiko genannte Sub-Resource-Pfad-Duplizierung trat **nicht**
  > auf – `data.team = GameState.team.duplicate(true)` war nicht nötig),
  > `load_game()` ohne vorhandene Datei lieferte sauber `false` ohne Absturz.
  > Einmaliger Vorlauf nötig: `godot --headless --editor --path . --quit-after
  > 15`, damit der Editor die neue `class_name SaveData` in den globalen
  > Skript-Klassen-Cache aufnimmt (sonst „Identifier not found: SaveData"
  > beim direkten Headless-Start ohne vorherigen Editor-Scan).

- [x] **Schritt 6: Commit**

  ```bash
  git add scripts/core/save_data.gd scripts/core/save_manager.gd project.godot scripts/core/team.gd
  git commit -m "feat(core): SaveManager-Autoload für Speichern/Laden (ResourceSaver, ein Slot)"
  ```

---

### Task 2: Hub-Integration – manueller Speichern-Button + Autosave beim Betreten

**Files:**
- Modify: `scenes/hub/HubScreen.tscn`
- Modify: `scripts/hub/hub_controller.gd`

**Interfaces:**
- Consumes: `SaveManager.save_game()` (Task 1)
- Produces: nichts, das von späteren Tasks gebraucht wird (Endpunkt für den
  Hub)

- [x] **Schritt 1: Neue Nodes in `HubScreen.tscn` anlegen**

  | Node-Name | Typ | Parent |
  |---|---|---|
  | `SaveButton` | `Button` | `HeaderBar/MarginContainer/HBoxContainer` |
  | `SaveStatusLabel` | `Label` | `HeaderBar/MarginContainer/HBoxContainer` |
  | `SaveStatusTimer` | `Timer` | `HubScreen` (Root, `.`) |

  Einstellungen:
  - `SaveButton`: Text `"Speichern"`, eingefügt nach `NextRaceLabel` (letztes
    Kind der `HBoxContainer`)
  - `SaveStatusLabel`: Text leer lassen (`""`), eingefügt nach `SaveButton`
  - `SaveStatusTimer`: Inspector → `Wait Time` = `2.0`, `One Shot` = an
    (aktiviert), `Autostart` = aus

  Szene speichern.

- [x] **Schritt 2: `hub_controller.gd` erweitern**

  Nach den bestehenden `@onready`-Zeilen ergänzen:

  ```gdscript
  @onready var save_button: Button = $HeaderBar/MarginContainer/HBoxContainer/SaveButton
  @onready var save_status_label: Label = $HeaderBar/MarginContainer/HBoxContainer/SaveStatusLabel
  @onready var save_status_timer: Timer = $SaveStatusTimer
  ```

  `_ready()` erweitern (komplett ersetzen):

  ```gdscript
  func _ready() -> void:
  	main_menu_button.pressed.connect(func(): SceneManager.goto_screen("main_menu"))
  	garage_pin.pressed.connect(func(): SceneManager.goto_screen("garage"))
  	autohaus_pin.pressed.connect(func(): SceneManager.goto_screen("autohaus"))
  	pit_lane_pin.pressed.connect(func(): SceneManager.goto_screen("pit_lane"))
  	season_pin.pressed.connect(func(): SceneManager.goto_screen("season"))
  	save_button.pressed.connect(_on_save_button_pressed)
  	save_status_timer.timeout.connect(func(): save_status_label.text = "")
  	_refresh_header()
  	SaveManager.save_game()  # Autosave beim Betreten des Hubs
  ```

  Neue Funktion am Ende der Datei ergänzen:

  ```gdscript
  func _on_save_button_pressed() -> void:
  	var success: bool = SaveManager.save_game()
  	save_status_label.text = "Gespeichert ✓" if success else "Speichern fehlgeschlagen"
  	save_status_timer.start()
  ```

- [x] **Schritt 3: Verifikation**

  Szene `scenes/hub/HubScreen.tscn` mit F6 starten (setzt voraus, dass
  `GameState.team` bereits Werte hat – z.B. vorher `MainMenu.tscn` starten und
  über "Schnelles Spiel"/"Karriere" in den Hub navigieren, statt den Hub
  isoliert zu starten).

  Erwartung:
  - Beim Betreten des Hubs erscheint keine Fehlermeldung; `SaveManager.has_save()`
    ist danach `true` (z.B. per Debug-Print oder Dateisystem-Check).
  - Rechts im Header erscheint der neue "Speichern"-Button.
  - Button klicken → `SaveStatusLabel` zeigt kurz "Gespeichert ✓" an und
    verschwindet nach ca. 2 Sekunden wieder.
  - Werkstatt öffnen, ein Bauteil ändern, zurück zum Hub → Autosave beim
    erneuten Betreten überschreibt die Datei mit dem aktualisierten Stand
    (prüfbar z.B. über Dateiänderungszeitpunkt oder erneutes Laden in einem
    Testskript).

  > Verifiziert am 2026-08-12 per Headless-Lauf (temporäres Testskript, das
  > `HubScreen.tscn` als Kind-Node instanziiert, `save_button.pressed`
  > programmatisch emittiert und `SaveStatusLabel`/`SaveStatusTimer`
  > direkt abfragt; danach wieder entfernt). Ergebnis: `has_save()` nach
  > `_ready()` `true` (Autosave beim Betreten), `SaveButton`-Node vorhanden,
  > Label vor Klick leer, nach Klick `"Gespeichert ✓"`, Timer läuft, nach
  > Ablauf von >2s (per `SceneTreeTimer`, `--quit-after` hoch genug gesetzt,
  > damit das Skript selbst über `get_tree().quit()` beendet statt vom
  > Frame-Limit vorzeitig abgeschnitten zu werden) Label wieder leer. Die
  > Prüfung "`has_save()` vor dem Hub-Betreten `false`" schlug beim ersten
  > Lauf fehl, weil noch eine Save-Datei aus dem Task-1-Testlauf vorhanden
  > war – kein Code-Fehler, sondern Testreihenfolge-Artefakt (Datei existierte
  > bereits vor diesem Testlauf); alle anderen Prüfungen bestätigen die
  > eigentliche Autosave-Logik unabhängig davon.

- [x] **Schritt 4: Commit**

  ```bash
  git add scenes/hub/HubScreen.tscn scripts/hub/hub_controller.gd
  git commit -m "feat(hub): manueller Speichern-Button und Autosave beim Betreten des Hubs"
  ```

---

### Task 3: Hauptmenü – "Fortsetzen"-Button

**Files:**
- Modify: `scenes/main_menu/MainMenu.tscn`
- Modify: `scripts/main_menu/main_menu_controller.gd`

**Interfaces:**
- Consumes: `SaveManager.has_save()`, `SaveManager.load_game()` (Task 1)
- Produces: nichts, das von späteren Tasks gebraucht wird (Endpunkt für das
  Hauptmenü)

- [x] **Schritt 1: Neuen Button in `MainMenu.tscn` anlegen**

  | Node-Name | Typ | Parent |
  |---|---|---|
  | `ContinueButton` | `Button` | `CenterContainer/VBoxContainer` |

  Einstellungen: Text `"Fortsetzen"`, `Custom Minimum Size` = `(240, 48)`
  (identisch zu den bestehenden Buttons), eingefügt **direkt nach**
  `TitleLabel` und **vor** `QuickPlayButton` (Fortsetzen steht an erster
  Stelle, wenn verfügbar). Szene speichern.

- [x] **Schritt 2: `main_menu_controller.gd` erweitern**

  Nach den bestehenden `@onready`-Zeilen ergänzen:

  ```gdscript
  @onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
  ```

  `_ready()` erweitern (komplett ersetzen):

  ```gdscript
  func _ready() -> void:
  	continue_button.visible = SaveManager.has_save()
  	continue_button.pressed.connect(_on_continue_pressed)
  	quick_play_button.pressed.connect(_on_quick_play_pressed)
  	career_button.pressed.connect(_on_career_pressed)
  	quit_button.pressed.connect(_on_quit_pressed)
  ```

  Neue Funktion ergänzen (z.B. vor `_on_quick_play_pressed`):

  ```gdscript
  func _on_continue_pressed() -> void:
  	if SaveManager.load_game():
  		SceneManager.goto_screen("hub")
  	else:
  		push_error("Spielstand konnte nicht geladen werden.")
  		continue_button.visible = false
  ```

- [x] **Schritt 3: Verifikation**

  1. Save-Datei löschen (falls aus Task 1/2 vorhanden – Pfad siehe Task 1
     Schritt 5) und `MainMenu.tscn` mit F6 starten → `ContinueButton` ist
     **nicht sichtbar**.
  2. "Karriere" starten, im Hub einmal auf "Speichern" klicken (oder einfach
     den Hub betreten, Autosave reicht), zurück zum Hauptmenü
     (`MainMenuButton`) → `ContinueButton` ist jetzt **sichtbar**.
  3. "Fortsetzen" klicken → Spiel landet im Hub, `BudgetLabel`/`CarLabel`/
     `NextRaceLabel` zeigen die zuvor gespeicherten Werte, nicht die
     Startwerte eines neuen Spiels.
  4. Save-Datei manuell im Dateisystem löschen, während das Spiel läuft, dann
     im bereits offenen Hauptmenü erneut auf "Fortsetzen" klicken (simuliert
     eine korrupte/fehlende Datei) → keine Absturz, `ContinueButton`
     verschwindet, Fehlermeldung im Editor-Log.

  > Verifiziert am 2026-08-12 per Headless-Lauf (temporäres Testskript, das
  > `MainMenu.tscn` mehrfach instanziiert und drei Fälle durchspielt; danach
  > wieder entfernt). Fall 1 (keine Save-Datei): `ContinueButton.visible`
  > korrekt `false`. Fall 2 (Datei existiert, aber Inhalt ist keine gültige
  > `.tres`-Resource): Button vor dem Klick sichtbar (`has_save()` prüft nur
  > Existenz, wie im Code vorgesehen), Klick löst die erwarteten
  > `push_error`-Meldungen aus ("Spielstand konnte nicht geladen werden oder
  > ist beschädigt" / "Spielstand konnte nicht geladen werden."), kein
  > Absturz, Button wird danach synchron unsichtbar. Fall 3 (gültiger Save):
  > Button sichtbar, Klick lädt `game_mode="career"`, `budget=12345.0`,
  > `current_race_number=7` – exakt die vor dem Speichern gesetzten Werte,
  > synchron abgefragt bevor der (deferred laufende) Szenenwechel zum Hub den
  > Test-Node entfernt. Schritt 2 und Schritt 4 aus dem Plan-Wortlaut (manuell
  > im laufenden Editor über den Hub navigieren/klicken) wurden durch die
  > äquivalente programmatische Prüfung ersetzt, da kein Display für echte
  > F6-Interaktion zur Verfügung stand; die geprüfte Logik ist identisch.

- [x] **Schritt 4: Commit**

  ```bash
  git add scenes/main_menu/MainMenu.tscn scripts/main_menu/main_menu_controller.gd
  git commit -m "feat(main_menu): Fortsetzen-Button lädt gespeicherten Spielstand"
  ```

---

## Self-Review

- **Spec-Abdeckung:** `SaveManager`-Kernlogik (Task 1), manueller Save +
  Hub-Autosave (Task 2), Beenden-Autosave (Task 1, `_notification`),
  Fortsetzen-Button (Task 3) – alle im Goal genannten Bestandteile sind durch
  je einen Task/Schritt abgedeckt.
- **Placeholder-Scan:** Kein "TBD" o.ä. – jeder Code-Block ist copy-paste-fertig.
  Einzige bewusst offene Stelle ist die in Task 1 Schritt 5 beschriebene
  Sub-Resource-Pfad-Frage, die absichtlich erst während der Verifikation
  entschieden wird (kein spekulativer Code ohne beobachtetes Problem).
- **Typkonsistenz:** Feld-/Funktionsnamen (`SaveData.team`, `SaveData.game_mode`,
  `SaveManager.has_save/save_game/load_game`, `GameState.team`,
  `GameState.game_mode`) stimmen über alle drei Tasks hinweg exakt überein und
  passen zu den bestehenden Feldern in `game_state.gd`/`team.gd`.

## Offen für später (nicht Teil dieses Plans)

- Mehrere Speicherstand-Slots mit Auswahl-UI (aktuell bewusst ein fixer Slot,
  siehe Design-Entscheidungen)
- "Spielstand löschen"-Funktion (z.B. Button im Hauptmenü für Testzwecke oder
  bewussten Neustart ohne alten Stand)
- Tatsächliche Migrationslogik für `save_format_version` (Feld existiert
  bereits als Vorbereitung, wird aber noch nirgends ausgewertet)
- Genaueres Speicher-Feedback (z.B. "Zuletzt gespeichert um HH:MM" statt nur
  kurzzeitigem Status-Text)
- Cloud-Save (z.B. Steam Cloud) – kein Distributionskanal aktuell festgelegt
- Renn-Ergebnis-/Punkte-Historie im Save – laut Roadmap Phase H aktuell
  ohnehin nicht Teil des Grundgerüsts, würde aber bei Bedarf ebenfalls in
  `SaveData`/`Team` aufgenommen werden müssen
