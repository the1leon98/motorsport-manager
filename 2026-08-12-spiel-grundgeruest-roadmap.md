# Spiel-Grundgerüst Roadmap

> **Was das hier ist:** Kein klassischer bite-sized Implementierungsplan mit
> Code (wie `2026-08-12-werkstatt-ui-mvp.md` oder
> `2026-08-12-werkstatt-setup-slider-fastfollow.md`). Das hier ist eine
> **Phasen-Roadmap auf Meta-Ebene**: Sie zerlegt "ein spielbares Grundgerüst
> bauen" in einzelne, unabhängig umsetzbare Subsysteme, legt die sinnvolle
> Reihenfolge fest und listet pro Phase die offenen Design-Entscheidungen auf,
> die geklärt sein müssen, bevor dafür ein echter Implementierungsplan (mit
> Tasks, Code, Verifikation) geschrieben werden kann. **Kein Code in diesem
> Dokument, keine Aufgabe wurde umgesetzt.**
>
> Vorgehen: Für jede Phase wird, wenn sie dran ist, ein eigener Plan nach dem
> Muster der beiden bisherigen Werkstatt-Pläne geschrieben (Ziel/Architektur/
> Global Constraints/Task-für-Task mit Code) und dann inline umgesetzt.

## Ziel

Ein durchspielbares **Grundgerüst** (Platzhalter-Grafik, minimale Inhalte),
bei dem der komplette Spielfluss einmal komplett steht:

> Hauptmenü → "Schnelles Spiel" oder "Karriere" → Hub-Übersicht → Werkstatt /
> Autohaus / Boxengasse / Saison-Ansicht → Rennen (Top-Down) → zurück zum Hub

Ist dieser Loop einmal geschlossen, kann jede Phase danach unabhängig mit
echten Inhalten (Fahrzeuge, Bauteile, Strecken, KI, Grafik) aufgefüllt werden,
ohne die Grundstruktur nochmal anzufassen.

## Bezug zur README-Roadmap

Dieses Dokument verfeinert README-Roadmap-Punkte 4 und 6 ("Prototyp-Rennen",
"Karriere-/Team-Ebene") zu konkreten Phasen und ordnet sie neu ein, weil der
Nutzer explizit ein durchgängiges Grundgerüst vor weiteren Einzelfeatures
haben möchte. Punkte 5 (KI-Gegner), 7 (Low-Poly-3D-Werkstatt), 8 (historische
Inhalte) und 9 (Feinschliff) bleiben bewusst **nach** diesem Grundgerüst –
siehe "Explizit nicht Teil des Grundgerüsts" unten.

## Ist-Stand (was schon existiert)

- **Core-Logik** (Phase 1/2 laut README, fertig): `PartsDatabase` (Autoload,
  lädt `data/parts/*.json` + `data/regulations/*.json`), `CarConfig`
  (Resource für **ein** Fahrzeug), `StatsCalculator`, `RegulationValidator`.
- **Werkstatt-Screen** (`scenes/garage/GarageScreen.tscn` +
  `scripts/garage/garage_controller.gd`): Bauteil-Dropdowns, alle 9
  Setup-Slider, Live-Stats, Regelkonformitäts-Anzeige – für **ein** fest
  einprogrammiertes Default-Auto.
- **Kein** Hauptmenü, **keine** Szenen-Navigation: `project.godot` setzt
  aktuell `teststats.tscn` (ein Phase-1-Test-Überbleibsel) als
  `run/main_scene`. Das Spiel "startet" also faktisch nirgendwo Richtiges.
- **Kein** Team-/Karriere-/Budget-Datenmodell: Es gibt genau ein `CarConfig`,
  keine Vorstellung von "mehreren besessenen Fahrzeugen", keinem Geld, keinem
  Spielstand.
- **Keine** Renn-Logik, **keine** Streckendaten (`data/tracks/` existiert laut
  Projektstruktur-Vorschlag, aber der Ordner ist leer/nicht angelegt).
- **Datenlücke:** Die GDD-Tabellen (Abschnitt 4) beschreiben 5 Motoren /
  4 Getriebe / 4 Fahrwerke / 5 Reifen / 3 Bremsen / 4 Aero-Teile mit Preisen.
  Die tatsächlichen `data/parts/*.json`-Dateien enthalten aktuell nur
  3 Motoren / 3 Getriebe / 3 Fahrwerke / 3 Reifen / 3 Bremsen / 5 Aero-Teile,
  **ohne Preisfeld**. Diese Lücke muss vor Phase A (Content-Design) bewusst
  aufgelöst werden (GDD an Ist-Daten anpassen oder Ist-Daten auf GDD-Umfang
  erweitern).

---

## Phasenübersicht

| # | Phase | Abhängig von | Ergebnis |
|---|---|---|---|
| A | Content-Design: Fahrzeuge, Bauteile, Strecken | – (kann parallel laufen) | Datenblätter/JSON-Entwürfe für alle Inhalte |
| B | Navigations-Grundgerüst + Hauptmenü | – | Spiel startet in echtem Hauptmenü, Szenenwechsel möglich |
| C | Team-/Fahrzeug-Datenmodell | B | Budget, Fahrzeug-Inventar, Spielstand-Grundgerüst |
| D | Hub-Übersicht | B, C | Zentraler Bildschirm mit Zugriff auf alle Unterbereiche |
| E | Autohaus | C, D, A (Fahrzeugdaten) | Fahrzeuge kaufen, landen im Inventar |
| F | Werkstatt-Mehrfachfahrzeug-Umbau | C, E | Bestehende Werkstatt arbeitet auf Inventar-Fahrzeugen statt Fixauto |
| G | Boxengasse / Prüfstation + Bestechung | C, F | Vor-Rennen-Freigabe-Screen, nutzt `RegulationValidator` |
| H | Saison-Ansicht | C, A (Streckendaten) | Rennkalender, Rennauswahl |
| I | Rennansicht (Top-Down-Grundgerüst) | G, H, A (Streckendaten) | Ein Auto fährt eine Strecke, Rundenzeit |
| J | Grundgerüst-Loop schließen & Ende-zu-Ende-Test | alle oben | Kompletter Spielfluss einmal durchspielbar |

Die Buchstaben sind bewusst keine Zahlen – die Reihenfolge B→C→D→E→F→G→H→I→J
ist der empfohlene Umsetzungspfad, aber A läuft davon unabhängig als
Content-Design-Strang und muss nur *rechtzeitig vor* E und I fertig sein.

---

## Phase A: Content-Design – Fahrzeuge, Bauteile, Strecken

**Ziel:** Alle Inhalte, die die späteren Screens brauchen, sind fertig
designt (als Datenblatt/JSON-Entwurf, nicht als 3D-/Pixelart-Assets – das ist
Roadmap-Punkt 7) und liegen bereit zum Einfügen.

**Warum zuerst / parallel:** Autohaus (E) und Rennansicht (I) sind ohne echte
Fahrzeug- bzw. Streckendaten nicht sinnvoll baubar oder testbar. Reines
Datendesign braucht keinen Code und blockiert die Code-Phasen nicht, wenn es
parallel läuft.

**Grober Umfang:**
- Bauteil-Pools entweder auf GDD-Umfang erweitern oder GDD auf Ist-Umfang
  kürzen (siehe Datenlücke oben) – **muss zuerst entschieden werden**.
- Preisfeld (`price`) für alle Bauteile ergänzen (aktuell in keiner JSON
  vorhanden, aber für Phase E zwingend nötig).
- Für das Autohaus: Konzept "kaufbares Fahrzeug" definieren – ist das ein
  reines Chassis (+ Basis-Motor/Getriebe als Startausstattung), das dann in
  der Werkstatt weiter bestückt wird? Oder ein Komplett-Fahrzeug mit fixer
  Bauteil-Kombination? Aktuell modelliert `CarConfig` nur *ein* Fahrzeug ohne
  Kaufpreis-Konzept – das ist eine echte Design-Entscheidung, keine
  technische Frage.
- Mindestens 1–2 Platzhalter-Strecken definieren (Layout, Länge, Anzahl
  Kurven, Start/Ziel) für Phase I und H. GDD nennt bisher nur "Norring" als
  Namensplatzhalter ohne konkretes Layout.
- Ergebnis pro Kategorie als Tabelle/JSON-Entwurf im GDD oder in `data/`
  ablegen, damit Phase E/H/I direkt darauf aufbauen können.

**Offene Fragen an dich, bevor ein Detailplan für Phase A geschrieben werden
kann:**
- Sollen die Bauteil-Pools auf GDD-Umfang (5/4/4/5/3/4) erweitert werden,
  oder bleibt es beim reduzierten Demo-Umfang (aktuell 3/3/3/3/3/5)?
->es soll erweitert werden auf 544534.
- Wie viele kaufbare Fahrzeuge soll das Autohaus für die Demo anbieten (z.B.
  3–5 Chassis in unterschiedlichen Preisklassen)?
->es soll erstmal nur 1 geben. (Vorbild ist der BMW E30)
- Wie viele Strecken für die Demo-Saison (mindestens 1 zum Testen, wie viele
  für eine "Saison" in Phase H)?
->in der Demo nur 1 Strecke. Am Ende sollen erstmal nur 11 Strecken in der DTM angezeigt werden, da das Vorbild die DTM Saison 1990 ist.

---

## Phase B: Navigations-Grundgerüst + Hauptmenü

**Ziel:** Das Spiel startet in einem echten Hauptmenü ("Schnelles Spiel" /
"Karriere" / ggf. "Beenden") statt im Phase-1-Testscene, und es gibt einen
generischen Mechanismus, um zwischen Szenen zu wechseln, den alle späteren
Screens (Hub, Werkstatt, Autohaus, Boxengasse, Saison, Rennen) nutzen.

**Warum zuerst:** Reine Infrastruktur – jede weitere Phase braucht einen Weg,
von einem Screen zum nächsten zu wechseln. Ohne das bleibt jeder Screen eine
isolierte Testszene wie aktuell die Werkstatt.

**Grober Umfang:**
- `run/main_scene` in `project.godot` von `teststats.tscn` auf ein neues
  `MainMenu.tscn` umstellen.
- Einfacher Szenenwechsel-Mechanismus (z.B. ein Autoload, der
  `get_tree().change_scene_to_file(...)` kapselt, oder ein Root-Node mit
  austauschbarem Container) – Godot-4-Standardmuster, keine Fremdbibliothek
  nötig.
- Hauptmenü selbst: 2–3 Buttons, "Schnelles Spiel" → (vorerst) direkt zur
  Werkstatt oder zu Phase D, sobald die existiert; "Karriere" → Platzhalter,
  der erst mit Phase C/D echten Inhalt bekommt.

**Offene Fragen:**
- Unterscheiden sich "Schnelles Spiel" und "Karriere" für das Grundgerüst
  überhaupt schon (z.B. Karriere = mit Budget/Fortschritt, Schnelles Spiel =
  ein Rennen ohne Speicherstand), oder führen im Grundgerüst erstmal beide
  zum selben Hub (Unterscheidung kommt erst später mit echtem Inhalt)?
->in der Demo soll es erstmal keinen Unterschied geben. später können wir es ja erweitern.

---

## Phase C: Team-/Fahrzeug-Datenmodell

**Ziel:** Ein `Team`- bzw. `SaveGame`-Datenmodell, das mehrere besessene
Fahrzeuge (statt der aktuellen festen Werkstatt-Instanz), ein Budget und den
Fortschritt in der Saison hält.

**Warum an dieser Stelle:** Autohaus (E), die Werkstatt-Anpassung (F) und die
Saison-Ansicht (H) brauchen alle denselben zugrunde liegenden Zustand (welche
Fahrzeuge besitze ich, wie viel Geld habe ich, wo stehe ich in der Saison).
Muss also vor allen dreien stehen.

**Grober Umfang:**
- Neue Resource-Klasse (Arbeitstitel `Team`), die eine `Array[CarConfig]`
  (statt der aktuellen Einzel-`car`-Variable in `garage_controller.gd`), ein
  `budget: float`-Feld und einen Saisonfortschritt (z.B. `current_race_number`
  – das Feld gibt es als Konstante schon im Werkstatt-Screen, müsste aber ins
  Team-Modell wandern) enthält.
- Vermutlich als Autoload (`GameState` o.ä.), damit alle Screens denselben
  Zustand sehen, ohne ihn manuell durchzureichen.
- **Kein** Speichern/Laden auf Festplatte in dieser Phase (das wäre ein
  eigenes späteres Thema) – nur Laufzeit-Zustand, der beim Neustart verloren
  geht. Explizit klären, ob das für das Grundgerüst reicht.

**Offene Fragen:**
- Startbudget-Höhe für "Karriere"?
->erstmal 200.000 (Geldeinheit weiß ich noch nicht aber ich denke ich werde etwas eigenes erstellen)
- Bekommt "Schnelles Spiel" ein Fahrzeug automatisch gestellt (kein
  Autohaus-Zwang), damit man direkt ins Rennen kann?
->nein man kann sich ein Auto selber raussuchen

---

## Phase D: Hub-Übersicht

**Ziel:** Zentraler Bildschirm nach Auswahl "Karriere" (bzw. reduziert auch
für "Schnelles Spiel"), von dem aus man Werkstatt, Autohaus, Boxengasse und
Saison-Ansicht erreicht – die eigentliche "Menüansicht zwischen den
verschiedenen Dingen", die du beschrieben hast.

**Warum an dieser Stelle:** Kann erst gebaut werden, wenn Navigation (B) und
Team-Zustand (C) stehen. Die Unterbereiche selbst (E/F/G/H) können zunächst
als leere Platzhalter-Screens verlinkt werden und danach nach und nach mit
Inhalt gefüllt werden – genau das "nach und nach alles haben", das du
beschrieben hast.

**Grober Umfang:**
- Einfaches Menü/Grid mit 4 Buttons (Werkstatt, Boxengasse, Autohaus, Saison)
  + Anzeige von Budget/aktuellem Fahrzeug/nächstem Rennen als Kopfzeile.
- Jeder Button wechselt über den Mechanismus aus Phase B zur jeweiligen Szene.

**Offene Fragen:** keine größeren – reine Verdrahtung, sobald B/C stehen.
->kleine Ergänzung: Ich will es im Style wie Gran Turismo haben also eine Art Map mit verschiedenen Standorten.
---

## Phase E: Autohaus

**Ziel:** Bildschirm zum Kauf neuer Fahrzeuge gegen Budget; gekaufte
Fahrzeuge landen im Team-Inventar (Phase C) und stehen danach in der
Werkstatt (Phase F) zur Auswahl.

**Warum an dieser Stelle:** Braucht Team-Datenmodell (C), Hub-Einbindung (D)
und echte Fahrzeugdaten (A).

**Grober Umfang:**
- Liste der kaufbaren Fahrzeuge (aus Phase A) mit Preis, Kauf-Button.
- Kauf prüft Budget, zieht Preis ab, erstellt neues `CarConfig` (oder
  vordefinierte Vorlage) im Team-Inventar.
- Sperre/Ausgrauen, wenn Budget nicht reicht.

**Offene Fragen:**
- Kann man ein Fahrzeug auch wieder verkaufen (für's Grundgerüst vermutlich
  nein, nice-to-have für später)?
->Man soll die Fahrzeuge später an Händler verkaufen können. Entweder unbenutzte oder Autos mit wenig Rennen oder wenig Erfolgen für weniger. Wenn ein Auto aber zum Beispiel eine Meisterschaft gewonnen hat steigt der Verkaufspreis. (Man soll im späteren Spiel Fahrzeuge mehrfach kaufen können im Autohaus)

---

## Phase F: Werkstatt-Mehrfachfahrzeug-Umbau

**Ziel:** Die bestehende `GarageScreen`/`garage_controller.gd` so umbauen,
dass sie auf einem aus dem Team-Inventar gewählten Fahrzeug arbeitet statt
auf der aktuell fest im Skript erzeugten `car := CarConfig.new()`-Instanz.

**Warum an dieser Stelle:** Ergibt erst Sinn, sobald es überhaupt mehrere
Fahrzeuge geben kann (nach C/E).

**Grober Umfang:**
- Fahrzeug-Auswahl (z.B. Dropdown/Tabs) am oberen Rand der Werkstatt, befüllt
  aus `Team`-Inventar.
- `_set_default_car()` entfällt oder wird zum Fallback für "noch kein
  Fahrzeug gekauft".
- Rest der Werkstatt-Logik (Bauteil-Dropdowns, Slider, Stats, Compliance)
  bleibt unverändert – reine Datenquellen-Umstellung.

**Offene Fragen:** keine – technische Anpassung, keine neue Design-Frage.

---

## Phase G: Boxengasse / Prüfstation + Bestechung

**Ziel:** Screen, auf dem das aktuell in der Werkstatt eingestellte Fahrzeug
vor dem nächsten Rennen geprüft wird (nutzt `RegulationValidator`, der schon
existiert) – konform → Startfreigabe, nicht konform → Sperre oder
Bestechungsoption (GDD Abschnitt 8).

**Warum an dieser Stelle:** Fachlich unabhängig von Autohaus, aber baut auf
demselben Team-Zustand (C) und dem umgebauten Werkstatt-Fahrzeug (F) auf.

**Grober Umfang:**
- Wiederverwendung von `RegulationValidator.validate(...)` (bereits in
  Werkstatt integriert, hier nur der Verstoß/Freigabe-Teil ohne Live-Editing).
- Bei Verstoß: Anzeige der Bestechungskosten-Formel aus GDD Abschnitt 8
  (`Basiskosten × Schweregrad × (1 + Restrisiko)`), Button "Bestechen"
  (zieht Budget ab, gewährt Freigabe, mit fixer 10%-Restrisiko-Chance auf
  Zusatzstrafe laut GDD).
- Freigabe ist Voraussetzung, um von hier zu Phase I (Rennen) zu wechseln.

**Offene Fragen:**
- Konkrete "Basiskosten" und "Schweregrad"-Werte pro Verstoßtyp – GDD nennt
  nur die Formel, keine konkreten Zahlen. Muss vor dem Detailplan definiert
  werden.
-> den Basiswert für eine Bestechung kannst du dir selber aussuchen/ausrechnen. Aber bitte ich will die Werte von Geld und Preisen so Realgetreu wie möglich halten.

---

## Phase H: Saison-Ansicht

**Ziel:** Kalenderartige Übersicht der Rennen einer Saison mit Auswahl des
nächsten Rennens.

**Warum an dieser Stelle:** Braucht Team-Fortschritt (C) und mindestens die
Streckennamen/-anzahl aus Phase A.

**Grober Umfang:**
- Liste der Rennen (Streckenname, Rennnummer, Status: absolviert/nächstes/
  zukünftig).
- Auswahl "nächstes Rennen" → Übergang zu Boxengasse (G) für dieses Rennen.

**Offene Fragen:**
- Anzahl Rennen der Demo-Saison (siehe Phase-A-Fragen).
->11 Rennen mit jeweils Quali.(in der Beta soll man aber erstmal nur das eine rennen testen können, keine quali oder alle 11 rennen)
- Werden Rennergebnisse/Punkte für's Grundgerüst schon gespeichert und
  angezeigt, oder reicht "Rennen X von Y" ohne Ergebnishistorie fürs Erste?
->erstmal keine Rennergebnisse fürs grundgerüst speichern

---

## Phase I: Rennansicht (Top-Down-Grundgerüst)

**Ziel:** Minimal spielbare 2D-Top-Down-Rennszene: eine Strecke aus Phase A,
das in der Werkstatt konfigurierte Fahrzeug fährt sie ab, Rundenzeit wird
angezeigt. **Ohne KI-Gegner** (die ist README-Roadmap-Punkt 5, bewusst
separat).

**Warum an dieser Stelle:** Fachlich der komplexeste neue Baustein (neue
Szenen-Art, neue Physik-/Bewegungslogik), deshalb zuletzt vor dem
Zusammenschluss – alle anderen Screens sollten stehen, damit man von der
Boxengasse aus tatsächlich dorthin wechseln kann.

**Grober Umfang:**
- Einfache Streckenrepräsentation (z.B. Wegpunkte/Spline aus Phase-A-Daten).
- Fahrzeug-Bewegung, die zumindest grob `StatsCalculator`-Werte (Topspeed,
  Beschleunigung, Kurvengrip, Bremsweg) einfließen lässt – kein echtes
  Fahrphysik-Modell, das wäre deutlich größerer Scope.
- Start/Ziel-Erkennung, Rundenzeit-Anzeige.
- Rückkehr zum Hub (D) nach Rennende.

**Offene Fragen:**
- Steuert der Spieler das Fahrzeug aktiv (Tastatur/Maus), oder ist es für
  das Grundgerüst eine reine Zeitfahr-Simulation ohne Spielereingabe (GDD
  Abschnitt 1 sagt "Live-Top-Down-Simulation", Abschnitt 3.1 nennt "Live-
  Simulation in Echtzeit, keine reine Rundenzeiten-Berechnung" – das deutet
  auf Spieler-Eingabe hin, sollte aber explizit bestätigt werden, da das den
  Umfang dieser Phase erheblich verändert)?
->Es soll keine Spielereingabe geben. (In der Endversion soll man nur falls das Auto während dem Rennen einen Schaden erleidet wie zb Motorschaden oder ähnliches soll aktiv einen speziell angezeigten knopf drücken damit das Auto in die box fährt und was austauschen kann wie in echt. Nur nicht in der Demo)Das Auto soll auch nur 6-12 Runden fahren wie in F1-Clash abhängig von der Länge des echten Rennens.
- Reicht ein einzelnes Auto ohne Gegner für "Grundgerüst", oder soll hier
  schon ein zweites, unbewegliches Platzhalter-Fahrzeug als Zielmarke stehen?
->1 Auto alleine reicht

---

## Phase J: Grundgerüst-Loop schließen & Ende-zu-Ende-Test

**Ziel:** Kein neuer Code, sondern der komplette Durchlauf einmal von vorne
bis hinten manuell verifiziert: Hauptmenü → Karriere → Hub → Autohaus
(Fahrzeug kaufen) → Werkstatt (einstellen) → Boxengasse (freigeben, ggf.
bestechen) → Saison-Ansicht (Rennen wählen) → Rennen (fahren) → zurück zum
Hub.

**Warum als eigene Phase:** Erfahrungsgemäß zeigen sich Lücken zwischen
Screens (fehlende Zustandsübergabe, falsche Rücksprünge) erst, wenn der
komplette Loop steht – das verdient einen eigenen, expliziten
Verifikationsdurchlauf statt "hoffentlich passt's".

> **Verifiziert am 2026-08-12** per zwei separaten Headless-Läufen (kein
> Display verfügbar; gleiches Vorgehen wie bei den Save/Load-Verifikationen).
> Ein temporäres Autoload-Testskript (`test_e2e_run1.gd`, danach entfernt,
> `project.godot` währenddessen um einen Eintrag ergänzt und hinterher exakt
> zurückgesetzt) hat den kompletten Durchlauf inklusive Button-Klicks
> nachgestellt: Hauptmenü → "Karriere" → Hub → Autohaus (Voss GT30 kaufen) →
> Werkstatt (Fahrzeug/Compliance prüfen) → Hub → Boxengasse (über Hub-Pin,
> Startfreigabe) → Hub → Saison (11 Strecken gelistet, "Fahren" auf Norring) →
> Boxengasse (zweiter Zugang, Freigabe weiterhin gültig) → Rennen (Zeitfahren
> mit `Engine.time_scale` beschleunigt, 10 Runden, Zielzeit angezeigt) → Hub.
> Alle 62 Prüfpunkte (Budget-/Fahrzeuganzeigen, Pin-Sperren, Regelkonformität,
> Szenenübergänge) waren erfolgreich. Anschließend wurde `NOTIFICATION_WM_CLOSE_REQUEST`
> simuliert (derselbe Codepfad wie beim echten Fensterschließen), was
> erwartungsgemäß speichert und den Prozess beendet. Ein zweiter,
> unabhängiger Headless-Prozess (`test_e2e_run2.gd`) hat danach frisch
> gestartet, den "Fortsetzen"-Button geklickt und geprüft, dass Budget
> (55.000), Fahrzeug (Voss GT30) und Rennnummer (1) korrekt aus der
> `user://savegame.tres`-Datei geladen wurden – alle 11 Prüfpunkte
> erfolgreich. Der Loop schließt sich also durchgängig, inklusive
> Speichern/Laden über einen echten Prozess-Neustart hinweg.
>
> **Eine Beobachtung, kein Fehlschlag:** `GameState.team.current_race_number`
> wird nach einem abgeschlossenen Rennen aktuell nirgends erhöht – nach
> Rückkehr in den Hub zeigt "Nächstes Rennen" weiterhin "Norring (Rennen
> 1/11)", obwohl das Rennen bereits gefahren wurde, und die Saison-Ansicht
> würde bei erneutem Aufruf weiterhin nur Rennen 1 als "Fahren"-fähig
> anzeigen. Das ist keine Regression aus dieser Verifikation, sondern eine
> Lücke, die laut Phase-H-Notizen ("erstmal keine Rennergebnisse fürs
> Grundgerüst speichern") bisher bewusst ausgeklammert war, aber jetzt beim
> Ende-zu-Ende-Test sichtbar wurde: ohne Fortschritts-Inkrement bleibt die
> Demo-Saison faktisch bei einem einzigen wiederholbaren Rennen stehen. Fix
> wäre trivial (`GameState.team.current_race_number += 1` beim Renn-Ende),
> aber bewusst nicht in dieser reinen Verifikationsphase umgesetzt – siehe
> "Explizit nicht Teil des Grundgerüsts" unten (neuer Punkt
> "Saisonfortschritt nach Rennende").

---

## Explizit nicht Teil des Grundgerüsts

- **KI-Gegner** (README-Roadmap Punkt 5) – Rennansicht (I) ist im
  Grundgerüst bewusst Zeitfahren/Platzhalter ohne Gegner.
- **Low-Poly-3D-Werkstattgrafik** (README-Roadmap Punkt 7) – alle Screens
  bleiben im Grundgerüst reine 2D-Platzhalter-UI (Standard-Godot-Controls),
  wie schon in der bestehenden Werkstatt.
- **Speichern/Laden auf Festplatte** – ursprünglich zurückgestellt, ist
  aber mittlerweile umgesetzt und in Phase J mitverifiziert, siehe
  `2026-08-12-speichern-laden.md`.
- **Historische Inhalte, weitere Klassen** (README-Roadmap Punkt 8).
- **Feinschliff/Balancing** (README-Roadmap Punkt 9).
- **Fahrzeug-Verkauf im Autohaus**, **Rennergebnis-/Punkte-Historie** – als
  "nice to have später" in den jeweiligen Phasen vermerkt, nicht Teil des
  Grundgerüst-Minimalumfangs.
- ~~**Saisonfortschritt nach Rennende**~~ – **erledigt.** `race_controller.gd`
  ruft in `_finish_race()` bereits `GameState.advance_race()` auf, und
  `GameState.advance_race()` erhöht `team.current_race_number` (begrenzt auf
  die Gesamtzahl der Strecken). Beim Code-Review am 2026-08-12 im Rahmen der
  Content-Design-Phase (siehe unten) bereits im Code vorgefunden – kein
  offener Fix mehr nötig.

## Phase A – Nachtrag: reale DTM-1990-Bezüge (2026-08-12)

Die Bauteil-Pools waren zum Zeitpunkt dieses Nachtrags bereits auf den
Ziel-Umfang 5/4/4/5/3/4 erweitert und alle Preisfelder vorhanden (Reifen
ausgenommen, siehe unten) – der offene Rest von Phase A war die inhaltliche
Ausgestaltung. Auf expliziten Wunsch orientieren sich Fahrzeug, Motoren,
Getriebe, Fahrwerk, Reifen, Bremsen und Aero jetzt eng an der echten
DTM-Saison 1990 (BMW M3 Sport Evolution, Mercedes-Benz 190E 2.5-16
Evolution/Evolution II, Opel Omega 3000 24V, Audi V8 quattro; dazu reale
Zulieferer-Kategorien für Reifen/Bremsen/Fahrwerk/Getriebe). Markennamen
bleiben aus Lizenzgründen fiktiv (siehe GDD-Hinweis), Kennzahlen und Preise
(neue Währung **Renn-Mark/RM**) sind so nah wie recherchierbar an den realen
1990er-Werten. Dabei außerdem gefixt: das Preisfeld fehlte bisher bei allen
Reifen (jetzt ergänzt), und die Bremsen-Topstufe hieß "Carbon-Keramik" –
technisch anachronistisch für 1990 (Carbon-Keramik-Bremsen kamen erst ab den
2000ern auf), jetzt durch eine reale Mehrkolben-Stahlbremsanlage ersetzt. Die
Regel zum Ladedruck (`max_boost`) ist jetzt um eine neue, historisch
zutreffendere Regel `banned_aspiration` ergänzt (Turbo/Kompressor generell
verboten, analog zum echten Reglement-Wechsel 1990) –
`regulation_validator.gd` wurde entsprechend erweitert.

---

