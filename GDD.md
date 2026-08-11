# Game Design Document – Motorsport Manager (Arbeitstitel)

**Version:** 0.2 (Demo-Scope + Grafik-Konzept)
**Stand:** August 2026
**Demo-Klasse:** DTM (Deutsche Tourenwagen Masters) – fiktive Saison "DTM Demo 2026"

> Hinweis: Alle Hersteller-/Markennamen sind fiktiv, um spätere Lizenzprobleme zu vermeiden. Reale Vorbilder (Motorenbauart, Kennzahlen, Spielreferenzen für den Grafikstil) dienen nur als Realismus-/Stil-Referenz.

---

## 1. Vision

Ein Motorsport-Manager-Spiel, bei dem der Spieler ein Team führt, Fahrzeuge aus einzelnen Bauteilen zusammenbaut, gegen ein Regelwerk antritt (inkl. Grauzonen/Bestechung) und Rennen als Live-Top-Down-Simulation erlebt. Zwei stilistisch konsistente Grafikwelten: Pixelart für Rennen, Low-Poly-3D für die Werkstatt. Desktop (Windows/Mac).

---

## 2. Scope der Demo

- 1 Klasse: DTM
- 1 Regelwerk: "DTM Demo 2026"
- 1 Strecke (Platzhalter, z.B. fiktiver "Norring")
- Bauteil-Pools: 5 Motoren, 4 Getriebe, 4 Fahrwerke, 5 Reifen, 3 Bremsanlagen, 4 Aero-Teile (3 Heckspoiler + 1 Heckdiffusor)
- 9 Setup-Parameter, live einstellbar
- Prüfstation + Bestechungs-Mechanik als Kernfeature
- Grafik-Konzept (siehe Abschnitt 3): 2D-Pixelart-Rennansicht + Low-Poly-3D-Werkstatt

---

## 3. Grafik & Perspektive

Zwei unterschiedliche, aber stilistisch konsistente Darstellungsarten je nach Spielmodus.

### 3.1 Rennansicht

- 2D-Pixelart
- Top-Down-Perspektive (Vogelperspektive auf die Strecke), Stil-Vorbild: F1 Clash
- Live-Simulation in Echtzeit, keine reine Rundenzeiten-Berechnung

### 3.2 Werkstatt / Boxengasse

- Low-Poly-3D, bewusst kein Fotorealismus – Stil-Vorbild: Art of Rally (reduzierte Formen, flache Farben statt aufwändiger PBR-Texturen)
- Freie Kamera, Auto von allen Seiten betrachtbar – Vorbild fürs Prinzip: Forza-Horizon-Garage
- Eingebaute Bauteile sind am Fahrzeug sichtbar (z. B. ein montierter Turbo erscheint im Motorraum-Modell) – Vorbild fürs Prinzip: Night-Runners, aber in Low-Poly statt Fotorealismus umgesetzt
- Bauteile müssen erkennbar, aber nicht fotorealistisch nachgebildet sein (z. B. eine Zündkerze ist an Form/Farbe erkennbar, ohne jedes Detail nachzubilden)

### 3.3 Technisches Konzept: Bauteil-Sockets

- Das Basis-Chassis jeder Fahrzeugklasse besitzt feste Attachment-Points (Sockets) pro Bauteilkategorie: Motorraum, Bremssättel je Rad, Ansaugöffnung, Heckbereich für Aero usw.
- Jedes Bauteil ist ein eigenes kleines Low-Poly-Mesh, das beim Wechsel im Menü am zugehörigen Socket ein-/ausgehängt wird
- Diese Architektur ist unabhängig vom Grafikstil – sie funktioniert auch, falls einzelne Assets später aufgewertet werden sollen

---

## 4. Bauteile

### 4.1 Motoren (5)

| ID | Name | Bauart | PS | Max. Drehmoment (Nm) | Gewicht (kg) | Zuverlässigkeit (1–10) | Preis (€) | Besonderheit |
|----|------|--------|----|----|----|----|----|----|
| E1 | Voss V8 4.0 Sauger | Sauger, V8 | 460 | 430 | 185 | 9 | 180.000 | Lineare Leistungsentfaltung, hohe Drehzahlgrenze (8.200 U/min), kein Turboloch |
| E2 | Brandt I4 2.0 Turbo | Turbo, I4 | 520 | 480 | 145 | 6 | 160.000 | Turboloch bei niedrigen Drehzahlen, günstig, verschleißanfällig |
| E3 | Kessler V6 3.2 BiTurbo | Bi-Turbo, V6 | 560 | 560 | 168 | 7 | 240.000 | Höchste Leistung, Ladedruck einstellbar, teuer |
| E4 | Falkner V8 4.2 Kompressor | Kompressor, V8 | 500 | 510 | 205 | 8 | 200.000 | Kein Turboloch, aber +15% Verbrauch (Riemenantrieb dauerhaft aktiv) |
| E5 | Reiner V10 4.5 Sauger | Sauger, V10 | 480 | 450 | 178 | 8 | 260.000 | Sehr hohe Drehzahlgrenze (9.000 U/min), leicht, teuer |

**Aufladungs-Logik (für spätere Formel):**
- *Sauger:* lineare Leistungskurve, kein Lag, geringster Verbrauch
- *Turbo:* Leistungseinbruch unter ca. 4.000 U/min ("Lag"), dafür höchste Peak-Leistung pro kg
- *Kompressor:* keine Verzögerung, aber konstanter Leistungsverlust durch mechanischen Antrieb (~Verbrauchsmalus)

### 4.2 Getriebe (4)

| ID | Name | Gänge | Schaltzeit (ms) | Gewicht (kg) | Zuverlässigkeit | Preis (€) |
|----|------|----|----|----|----|----|
| G1 | Standard-Sequential | 6 | 80 | 45 | 9 | 40.000 |
| G2 | Sport-Sequential | 6 | 50 | 42 | 7 | 70.000 |
| G3 | Race-Sequential | 7 | 35 | 40 | 6 | 110.000 |
| G4 | Verstärktes Standardgetriebe | 6 | 90 | 50 | 10 | 35.000 |

### 4.3 Fahrwerke – Hardware (4)

Definiert den *Verstellbereich* für die Setup-Parameter (Abschnitt 5), nicht die Einstellung selbst.

| ID | Name | Gewicht (kg) | Preis (€) | Verstellbereich | Besonderheit |
|----|------|----|----|----|----|
| C1 | Standard-Fahrwerk | 60 | 50.000 | normal | Robust, verzeihend |
| C2 | Sport-Fahrwerk | 52 | 90.000 | erweitert | Steiferer Grundsetup |
| C3 | Renn-Fahrwerk Pro | 45 | 150.000 | maximal | Empfindlich – Fehleinstellung wirkt stärker |
| C4 | Leichtbau-Fahrwerk | 38 | 130.000 | erweitert | Schnellerer Verschleiß bei Kerbs |

### 4.4 Reifen (5)

| ID | Name | Grip trocken | Grip nass | Verschleißfaktor | Optimales Temperaturfenster |
|----|------|----|----|----|----|
| T1 | Hart | 6/10 | 2/10 | 0.6 | breit |
| T2 | Medium | 7.5/10 | 3/10 | 1.0 | mittel |
| T3 | Weich | 9/10 | 3/10 | 1.6 | schmal |
| T4 | Regen | 3/10 | 9/10 | 1.2 | schmal (kalt) |
| T5 | Intermediate | 5/10 | 7/10 | 1.1 | mittel |

### 4.5 Bremsanlagen (3)

| ID | Name | Bremsleistung | Gewicht (kg) | Preis (€) | Besonderheit |
|----|------|----|----|----|----|
| B1 | Stahl Standard | 7/10 | 22 | 25.000 | Unempfindlich gg. Temperatur |
| B2 | Verbund Sport | 8.5/10 | 16 | 55.000 | Gute Balance |
| B3 | Carbon-Keramik Race | 10/10 | 11 | 120.000 | Braucht Mindesttemperatur, sonst Leistungseinbruch |

### 4.6 Aero (4: 3 Heckspoiler + 1 Heckdiffusor)

| ID | Name | Abtrieb | Luftwiderstand | Preis (€) |
|----|------|----|----|----|
| A1 | Heckspoiler Low | 3/10 | 2/10 | 20.000 |
| A2 | Heckspoiler Medium | 6/10 | 5/10 | 35.000 |
| A3 | Heckspoiler High | 9/10 | 8/10 | 55.000 |
| A4 | Heckdiffusor Standard | +2/10 (additiv) | +1/10 | 40.000 |

---

## 5. Setup-Parameter (live einstellbar am fertigen Auto)

| Parameter | Bereich | Wirkung |
|---|---|---|
| Getriebeübersetzung (Endübersetzung) | 3.2 – 4.6 | kurz = mehr Beschleunigung, weniger Topspeed; lang = umgekehrt |
| Federhärte (vorne/hinten getrennt) | 60 – 140 N/mm | härter = weniger Wanken/mehr Grip auf glattem Belag, weniger mechanischer Grip auf Bodenwellen |
| Dämpfer (Zug-/Druckstufe) | 1 – 10 Klicks | Lastwechselverhalten, Kerb-Stabilität, Reifentemperaturaufbau |
| Stabilisator (vorne/hinten) | 1 – 10 | verschiebt Balance Unter-/Übersteuern |
| Sturz (vorne/hinten) | -4.0° bis -1.0° | negativer = mehr Kurvengrip, mehr Reifenverschleiß, weniger Geradeausgrip |
| Spur (vorne/hinten) | -0.5° bis +0.5° | Vorspur = Stabilität, Nachspur = Einlenkfreude, Extremwerte = mehr Verschleiß |
| Reifenluftdruck | 1.6 – 2.4 bar | niedriger = mehr Grip/mehr Verschleiß; höher = weniger Rollwiderstand/mehr Topspeed |
| ECU-Mapping | Presets: Qualifying / Race / Fuelsaving | höhere Stufe = mehr PS, mehr Verschleiß & Verbrauch |
| Ballast | 0 – 60 kg, Position 30–70% Front/Heck | erreicht Mindestgewicht, verschiebt Balance vorne/hinten |

---

## 6. Formelmodell (Demo-Version, vereinfacht)

Ziel: kein echtes Physik-Modell, sondern ein gewichtetes Kennlinien-System, das sich real anfühlt.

```
Gesamtgewicht = Chassis.Gewicht + Motor.Gewicht + Getriebe.Gewicht + Bremse.Gewicht + Ballast
              → muss ≥ Mindestgewicht (Regel) sein, sonst Pflicht-Ballast

Endleistung(PS) = Motor.PS × ECU_Faktor(Mapping) × (1 - Verschleiß_Malus)

Topspeed        ∝ Endleistung / (Luftwiderstand(Aero) × Gesamtgewicht) × Getriebe_lang_Faktor

Beschleunigung  ∝ Endleistung / Gesamtgewicht × Getriebe_kurz_Faktor × Reifengrip_trocken

Kurvengrip_Index ∝ Reifen.Grip × Sturz_Faktor × Federhärte_Faktor × Stabilisator_Faktor
                   × (1 + Abtrieb(Aero)) × Luftdruck_Faktor

Bremsweg        ∝ 1 / (Bremse.Bremsleistung × Reifengrip × (1 + Abtrieb))

Verschleißrate  ∝ Reifen.Verschleißfaktor × Sturz_Extremität × Spur_Extremität × ECU_Mapping_Stufe

Ausfallrisiko   ∝ (11 - Motor.Zuverlässigkeit) × (11 - Getriebe.Zuverlässigkeit) × ECU_Mapping_Stufe
```

Jeder `_Faktor` ist für die Demo eine einfache lineare Interpolation zwischen Min/Max des jeweiligen Parameterbereichs (Abschnitt 5). Reicht für die Demo völlig aus und ist später beliebig verfeinerbar.

---

## 7. Regelwerk "DTM Demo 2026"

1. Max. Leistung: **550 PS**
2. Mindestgewicht: **1.050 kg** (inkl. Fahrer)
3. Aufladung: Turbo & Kompressor erlaubt, max. Ladedruck **1.4 bar**
4. Reifen: nur homologierte Trockenreifen (Hart/Medium/Weich) pro Rennwochenende, max. **8 Sätze**
5. Aero: Heckspoiler max. Klasse **"Medium"** – **A3 (High) ist nicht zulässig**
6. Bremsen: Carbon-Keramik (B3) erst **ab Saisonrennen 3** freigegeben
7. Getriebe: max. **6 Gänge** – **G3 (7-Gang) ist nicht zulässig**
8. Sturz: max. **-3.0°** vorne wie hinten
9. Ballast: mind. **20 kg**, wenn Fahrzeuggewicht ohne Ballast unter Mindestgewicht liegt

*(Regel 5 und 7 sind bewusst so gewählt, dass verlockende, aber unzulässige Bauteile existieren – Grundlage für die Bestechungs-Mechanik.)*

---

## 8. Prüfstation & Bestechung

- Vor jedem Rennen: automatischer Abgleich Auto-Konfiguration gegen aktives Regelwerk
- **Konform:** Rennfreigabe
- **Nicht konform:** Rennsperre + 0 Punkte, ODER gegen Bestechungsgeld "durchwinken lassen"
- Bestechungskosten-Formel (Demo): `Basiskosten × Schweregrad_des_Verstoßes × (1 + Restrisiko)`
  - Restrisiko: kleine Chance, dass die Bestechung auffliegt (zusätzliche Strafe/Imageschaden) – in Demo z.B. fixe 10%

---

## 9. Datenstruktur (Beispiel-Schema, JSON)

Jedes Bauteil referenziert zusätzlich sein Low-Poly-Mesh und den Socket, an dem es in der Werkstatt-Ansicht sichtbar wird (siehe Abschnitt 3.3).

```json
{
  "id": "E1",
  "category": "engine",
  "name": "Voss V8 4.0 Sauger",
  "aspiration": "naturally_aspirated",
  "power_hp": 460,
  "torque_nm": 430,
  "weight_kg": 185,
  "reliability": 9,
  "price": 180000,
  "mesh": "res://assets/models/parts/engines/e1_voss_v8.tres",
  "socket": "engine_bay"
}
```

```json
{
  "regulation_id": "dtm_demo_2026",
  "rules": [
    { "type": "max_power", "value": 550 },
    { "type": "min_weight", "value": 1050 },
    { "type": "banned_part", "part_id": "A3" },
    { "type": "banned_part", "part_id": "G3" }
  ]
}
```

---

## 10. Repo-Struktur (Vorschlag)

```
motorsport-manager/
├── README.md
├── docs/
│   └── GDD.md
├── project.godot
├── data/
│   ├── parts/
│   │   ├── engines.json
│   │   ├── gearboxes.json
│   │   ├── chassis.json
│   │   ├── tires.json
│   │   ├── brakes.json
│   │   └── aero.json
│   ├── regulations/
│   │   └── dtm_demo_2026.json
│   └── tracks/
├── scripts/
│   ├── core/          # Bauteil-/Statberechnung, Regel-Validator
│   ├── ui/             # HUD, Menüs
│   ├── race/           # Renn-Simulation, KI (2D Top-Down)
│   └── garage/         # Freie Kamera, Bauteil-Socket-System (3D)
├── scenes/
│   ├── race/            # 2D-Pixelart-Szenen
│   └── garage/           # Low-Poly-3D-Szenen
└── assets/
    ├── sprites/           # Pixelart für die Rennansicht
    ├── models/parts/       # Low-Poly-Meshes je Bauteil (Motoren, Bremsen, Aero, ...)
    └── textures/
```

---

## 11. Offene Punkte für später

- Zündkerzen, Ansaugung, Kühlsystem, Motoröl als eigene Bauteilkategorien (noch nicht in Demo-Scope)
- Low-Poly-Assets für alle Bauteilkategorien der Vollversion (Asset-Pipeline/Workflow noch festzulegen)
- Weitere Klassen (F1, Kart, Prototyp) als eigene Regelwerke/Teile-Pools
- Historische Saisons/Strecken als Datenpakete
