# DNDSheetAPP – Technische Architektur

## Autoloads (Singletons)
- **SaveSystem**: JSON-basiertes Speichern/Laden in `user://saves/`
- **AudioManager**: UI-Sound-Effekte und Hintergrundmusik über AudioStreamPlayer-Pool
- **GameManager**: Hält aktuellen Charakter und Charakterliste, koordiniert Szenenübergänge

## Resource-Typen
- **CharacterData**: Alle Charakter-Daten (Attribute, HP, Skills, Ausrüstung)
- **ItemData**: Ausrüstungsgegenstände mit Typ, Gewicht, Wert, Waffen-/Rüstungswerten
- **SpellData**: Zauber mit Level, Schule, Komponenten, Schaden

## Szenenstruktur (geplant)
```
Main (Control)
├── CharacterList (VBoxContainer)   — Seitenleiste mit allen Charakteren
└── SheetView (Control)             — Charakterbogen-Hauptansicht
    ├── HeaderSection               — Name, Klasse, Rasse, Level
    ├── AttributesSection           — STR / DEX / CON / INT / WIS / CHA
    ├── CombatSection               — HP, AC, Initiative, Speed
    ├── SkillsSection               — Alle Fertigkeiten mit Proficienz
    ├── InventorySection            — Ausrüstung, Münzen
    └── SpellsSection               — Zauberbuch, Slots
```

## Signals-Architektur
- GameManager sendet Signals an UI-Nodes (nicht umgekehrt)
- UI-Nodes verbinden sich im `_ready()` mit GameManager-Signals
- Keine direkten Node-Referenzen über Szenengrenzen
- SaveSystem-Signals für Lade-/Speicher-Feedback

## Datenspeicherung
- Format: JSON in `user://saves/characters.json`
- Array von Charakter-Dictionaries
- Identifikation über `character_name` (eindeutig)

## Konventionen
- Typ-Annotierungen überall
- `@export` für Inspector-konfigurierbare Werte
- Signals für Node-Kommunikation
- Godot 4.3 API (kein Godot 3!)
