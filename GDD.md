# Game Design Document – Motorsport Manager (Arbeitstitel)

**Version:** 0.2 (Demo-Scope + Grafik-Konzept)
**Stand:** August 2026
**Demo-Klasse:** DTM (Deutsche Tourenwagen Meisterschaft) – fiktive Saison "DTM Demo 2026"

> Hinweis: Alle Hersteller-/Markennamen sind fiktiv, um spätere Lizenzprobleme zu vermeiden. Kennzahlen, Preise und technische Historie orientieren sich dagegen bewusst eng an der echten DTM-Saison 1990 (letzte Saison mit vorgeschriebenen Saugmotoren): Voss GT30 Sport Evolution ≈ BMW M3 Sport Evolution, Brandt R4 2.5-16 (Evolution/Evolution II) ≈ Mercedes-Benz 190E 2.5-16 (Evolution/Evolution II), Kessler R6 3.0 24V ≈ Opel Omega 3000 24V, Falkner V8 3.6 Allrad ≈ Audi V8 quattro. Preise in "Renn-Mark (RM)" sind zahlenmäßig an reale 1990er-DM-Werte angelehnt (z.B. 85.000 RM Fahrzeugpreis ≈ realer BMW-M3-Sport-Evolution-Neupreis von 85.000 DM), wo keine belastbare Quelle vorlag, sind es plausible Schätzwerte im selben Preisrahmen.

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

Alle fünf sind Saugmotoren – Turbo/Kompressor sind im Regelwerk verboten (siehe Abschnitt 7), analog zum echten DTM-Reglement ab 1990.

| ID | Name | Bauart | PS | Max. Drehmoment (Nm) | Gewicht (kg) | Zuverlässigkeit (1–10) | Preis (RM) | Reales Vorbild |
|----|------|--------|----|----|----|----|----|----|
| E1 | Voss S4 2.5 Sport Evolution | Sauger, R4 | 340 | 260 | 140 | 9 | 118.000 | BMW M3 Sport Evolution (S14B25) |
| E2 | Brandt R4 2.5-16 Evolution II | Sauger, R4, 16V | 330 | 260 | 138 | 8 | 126.000 | Mercedes-Benz 190E 2.5-16 Evolution II |
| E3 | Brandt R4 2.5-16 Evolution | Sauger, R4, 16V | 300 | 240 | 136 | 9 | 98.000 | Mercedes-Benz 190E 2.5-16 Evolution |
| E4 | Kessler R6 3.0 24V | Sauger, R6 | 360 | 338 | 175 | 7 | 132.000 | Opel Omega 3000 24V (Irmscher-Renntechnik) |
| E5 | Falkner V8 3.6 Allrad | Sauger, V8 | 420 | 390 | 205 | 8 | 168.000 | Audi V8 quattro (Saisonbeginn-Leistung) |

### 4.2 Getriebe (4)

Reine H-Schaltung mit Kupplungspedal – sequenzielle Schaltgetriebe sind (wie 1990 real) nicht homologiert.

| ID | Name | Gänge | Schaltzeit (ms) | Gewicht (kg) | Zuverlässigkeit | Preis (RM) |
|----|------|----|----|----|----|----|
| G1 | Steinbrenner RG5 | 5 | 80 | 45 | 9 | 32.000 |
| G2 | Kronberg SG5 Sport | 5 | 50 | 42 | 7 | 58.000 |
| G3 | Ashford SEQ-1 Prototyp | 6 (sequenziell) | 35 | 40 | 6 | 95.000 |
| G4 | Steinbrenner RG6+ Kundensport | 6 | 90 | 48 | 10 | 46.000 |

### 4.3 Fahrwerke – Hardware (4)

Definiert den *Verstellbereich* für die Setup-Parameter (Abschnitt 5), nicht die Einstellung selbst.

| ID | Name | Gewicht (kg) | Preis (RM) | Verstellbereich | Besonderheit |
|----|------|----|----|----|----|
| C1 | Steiner DT1 | 60 | 42.000 | normal | Robust, verzeihend |
| C2 | Van Dijk Sport | 52 | 72.000 | erweitert | Steiferer Grundsetup |
| C3 | Höglund Race | 45 | 128.000 | maximal | Empfindlich – Fehleinstellung wirkt stärker |
| C4 | Steiner DT1 Clubsport | 38 | 110.000 | erweitert | Schnellerer Verschleiß bei Kerbs |

### 4.4 Reifen (5)

| ID | Name | Grip trocken | Grip nass | Verschleißfaktor | Preis (RM) |
|----|------|----|----|----|----|
| T1 | Waldmann Hart | 6/10 | 2/10 | 0.6 | 2.800 |
| T2 | Clermont Medium | 7.5/10 | 3/10 | 1.0 | 3.200 |
| T3 | Kanagawa Weich | 9/10 | 3/10 | 1.6 | 3.800 |
| T4 | Clermont Regen | 3/10 | 9/10 | 1.2 | 2.600 |
| T5 | Waldmann Intermediate | 5/10 | 7/10 | 1.1 | 3.000 |

### 4.5 Bremsanlagen (3)

| ID | Name | Bremsleistung | Gewicht (kg) | Preis (RM) | Besonderheit |
|----|------|----|----|----|----|
| B1 | Terlingen Serienbremse | 7/10 | 22 | 18.000 | Unempfindlich gg. Temperatur |
| B2 | Bergamo Sport | 8.5/10 | 16 | 42.000 | Gute Balance |
| B3 | Redwood Racing 6-Kolben | 10/10 | 12 | 88.000 | Mehrkolben-Rennsattel, ab Rennen 3 verfügbar |

### 4.6 Aero (4: 3 Heckflügel-Stellungen + 1 Frontspoiler)

Reales Vorbild: der verstellbare Heckflügel des BMW M3 Sport Evolution mit den Stellungen "Monza" (wenig Abtrieb/Widerstand), "Normal" und "Nürburgring" (viel Abtrieb/Widerstand).

| ID | Name | Abtrieb | Luftwiderstand | Preis (RM) |
|----|------|----|----|----|
| A1 | Voss Heckflügel "Monza" | 3/10 | 2/10 | 9.000 |
| A2 | Voss Heckflügel "Normal" | 6/10 | 5/10 | 14.000 |
| A3 | Voss Heckflügel "Nürburgring" | 9/10 | 8/10 | 22.000 |
| A4 | Voss Frontspoiler (3-fach verstellbar) | +2/10 (additiv) | +1/10 | 16.000 |

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
3. Aufladung: **Turbo & Kompressor verboten** – nur Saugmotoren zulässig (analog zur realen DTM-Regeländerung ab 1990)
4. Reifen: nur homologierte Trockenreifen (Hart/Medium/Weich) pro Rennwochenende, max. **8 Sätze**
5. Aero: Heckflügel max. Stellung **"Normal"** – **A3 ("Nürburgring") ist nicht zulässig**
6. Bremsen: Redwood Racing 6-Kolben (B3) erst **ab Saisonrennen 3** freigegeben
7. Getriebe: nur klassische Schaltung mit Kupplungspedal – **G3 (sequenzieller Prototyp) ist nicht zulässig**
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
  "name": "Voss S4 2.5 Sport Evolution",
  "aspiration": "natural",
  "power_hp": 340,
  "torque_nm": 260,
  "weight_kg": 140,
  "reliability": 9,
  "price": 118000,
  "mesh": "res://assets/models/parts/engines/e1_voss_s4.tres",
  "socket": "engine_bay"
}
```

```json
{
  "regulation_id": "dtm_demo_2026",
  "rules": [
    { "type": "max_power", "value": 550 },
    { "type": "min_weight", "value": 1050 },
    { "type": "banned_aspiration", "values": ["turbo", "kompressor"] },
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
