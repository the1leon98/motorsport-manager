# motorsport-manager

Ein Motorsport-Management-Spiel mit tiefer technischer Fahrzeugsimulation. Der Spieler leitet ein Team in verschiedenen Motorsport-Klassen, baut Rennwagen bis ins Detail selbst auf und tritt gegen ein Reglement an, das aktiv umgangen werden kann – auf eigenes Risiko.

---

## Über das Projekt

Kein reines "PS hochdrehen"-Manager-Spiel: Ziel ist es, dass technisch versierte Spieler ein Fahrzeug wirklich bis ins Detail konfigurieren können – Motor, Fahrwerk, Reifen, Elektronik, sogar Betriebsstoffe – und dass sich jede Änderung spürbar und realistisch auf Fahrleistung und Fahrverhalten auswirkt. Dazu kommt ein Reglement-System: Vor jeder Saison gibt es technische Vorgaben, vor jedem Rennen eine Prüfstation – und wer schummelt, kann versuchen, die Prüfer zu bestechen.

---

## Kernidee

- **Team-Management** in mehreren Motorsport-Klassen: DTM, Formel 1, Kart, Prototypen (Le Mans)
- **Nahezu vollständige technische Anpassung** jedes Fahrzeugs, nicht nur oberflächliche Werte
- **Realistische Abhängigkeiten**: jedes Bauteil wirkt sich auf andere Bauteile und auf die Fahrleistung aus
- **Reglement als Spielmechanik**: Saisonvorgaben, Prüfstation, Bestechungsoption
- **Historische Saisons**: konkrete vergangene Saisons mit den damals gefahrenen Strecken wählbar

---

## Geplanter Funktionsumfang (Vollversion)

Der folgende Umfang ist das langfristige Ziel über die gesamte Entwicklungszeit – nicht der aktuelle Stand (siehe [Aktueller Stand](#aktueller-stand--demo-scope) weiter unten).

### Fahrzeug-Anpassung – so gut wie alles einstellbar

- **Motor**: Hubraum, Zylinderzahl/-anordnung, Aufladung (Sauger / Turbo / Kompressor)
- **Ansaugsystem**: Ansaugkrümmer, Luftfilter, Drosselklappe
- **Zündsystem**: Zündkerzen verschiedener Marken mit unterschiedlichen Wärmewerten
- **Kühlsystem**: verschiedene Kühler-Marken/-Größen, dazu passende, unterschiedliche Kühlflüssigkeiten
- **Schmierung**: Motoröl mit unterschiedlicher Viskosität, je nach Motor und Leistung passend zu wählen
- **Kraftstoffsystem**: Einspritzung, Kraftstoffgemische
- **Getriebe**: Anzahl Gänge, Übersetzung, Schaltgeschwindigkeit
- **Fahrwerk**: Federn, Dämpfer, Stabilisatoren, Sturz, Spur, Fahrzeughöhe
- **Bremsen**: Scheiben-/Belagmaterial, Bremskraftverteilung
- **Reifen**: Compound, Größe, Luftdruck
- **Aerodynamik**: Frontsplitter, Heckspoiler, Diffusor, Unterboden
- **Chassis/Karosserie**: Material (Stahl / Aluminium / Carbon), Gewicht, Steifigkeit
- **Elektronik**: ECU-Mapping, ggf. Traktionskontrolle/ABS (abhängig vom jeweiligen Reglement)
- **Ballast**: Gewicht und Position

Alles ist gegenseitig abhängig: z. B. beeinflusst der Motor die passende Kühlerauslegung und Kühlflüssigkeit, die Motorleistung die sinnvolle Ölviskosität, das Fahrwerk-Setup den Reifenverschleiß usw.

### Reglement & Prüfstation

- Vor jeder Saison erhält der Spieler die technischen Vorgaben als Brief/Dokument (ca. 5–10 Regeln: z. B. Aufladung erlaubt ja/nein, PS-Obergrenze, Mindestgewicht)
- Vor jedem Rennen: Pflichtprüfung in der Prüfstation
  - Regelkonform → Startfreigabe
  - Nicht konform → Rennsperre, keine Punkte
- Alternative: Prüfer gegen individuelles Bestechungsgeld "überzeugen" – funktioniert, ist aber teuer und mit Restrisiko verbunden

### Klassen & historische Saisons

- Spielbare Klassen: DTM, Formel 1, Kart, Prototypen (Le Mans)
- Auswahl konkreter historischer Saisons (z. B. "DTM 1998" oder "Formel 1 1973“), inklusive der damals tatsächlich gefahrenen Strecken der jeweiligen Saison

### Karriere-Modus

- Aktuell geplant: eine Saison am Stück als Team-Manager spielen
- Mehrsaisonige Karriere mit Auf-/Abstieg zwischen Klassen: mögliche spätere Erweiterung, aktuell nicht fix eingeplant

### Mehrspieler

- Aktuell nicht fest eingeplant, aber als Idee im Hinterkopf für eine mögliche spätere Version (z. B. online gegen andere Manager)

### Grafik & Präsentation

- Pixelart-Grafik
- Live-Rennsimulation aus der Top-Down-Ansicht (Vogelperspektive auf die Strecke)
- Plattform: Desktop (Windows, Mac)

---

## Aktueller Stand / Demo-Scope

Die Entwicklung startet bewusst klein, mit einer einzigen Klasse und einem begrenzten Bauteil-Pool, um das Grundsystem (Bauteil-Interaktion, Reglement, Prüfstation, Rennsimulation) sauber aufzubauen, bevor der volle Umfang folgt.

- Demo-Klasse: **DTM**
- Demo-Regelwerk: **"DTM Demo 2026"**
- Bauteil-Pool Demo: 5 Motoren, 4 Getriebe, 4 Fahrwerke, 5 Reifen, 3 Bremsanlagen, 4 Aero-Teile
- 9 live einstellbare Setup-Parameter (Getriebeübersetzung, Federhärte, Dämpfer, Stabilisator, Sturz, Spur, Reifenluftdruck, ECU-Mapping, Ballast)

Details, konkrete Werte und das Formelmodell: siehe [`docs/GDD.md`](docs/GDD.md).

---

## Tech Stack

- **Engine**: Godot 4 (GDScript)
- **Plattform**: Windows, Mac (Desktop-Export)
- **Entwicklung**: unterstützt durch Claude Code

---

## Roadmap

1. Fundament (Projekt-Setup, GDD)
2. Bauteil- & Datenmodell (Statberechnung, ohne Grafik)
3. Regelwerk & Prüfstation
4. Prototyp-Rennen (ein Auto, eine Strecke, Rundenzeit)
5. KI-Gegner
6. Karriere-/Team-Ebene (Kalender, Budget, Werkstatt-UI)
7. Pixelart-Grafik
8. Historische Inhalte (weitere Saisons, Strecken, Klassen)
9. Feinschliff, Balancing, Distribution

---

## Projektstruktur

```
motorsport-manager/
├── README.md
├── docs/
│   └── GDD.md
├── project.godot
├── data/
│   ├── parts/
│   ├── regulations/
│   └── tracks/
├── scripts/
│   ├── core/
│   ├── ui/
│   └── race/
├── scenes/
└── assets/
```

---

## Lizenz

Dieses Repository ist öffentlich einsehbar, es handelt sich jedoch um ein privates Soloprojekt – **alle Rechte vorbehalten**. Quellcode, Konzept und Inhalte dürfen ohne ausdrückliche Erlaubnis nicht kopiert, verändert oder weiterverwendet werden.

---

## Status

Frühe Entwicklungs-/Konzeptphase.
