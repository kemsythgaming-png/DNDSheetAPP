# CLAUDE.md — DNDSheetAPP

## Projektübersicht
- **Art**: D&D 5e Charakterbogen-Applikation (UI-App, kein Spiel)
- **Godot-Version**: 4.3
- **Sprache**: GDScript (kein C#)
- **Plattform**: Desktop (Windows, Linux, macOS)

## Projektstruktur
```
res://
├── scenes/
│   ├── characters/     # Charakterbogen-Szenen
│   ├── ui/             # Wiederverwendbare UI-Komponenten
│   └── main.tscn       # App-Einstiegspunkt
├── scripts/
│   ├── autoload/       # Singletons: GameManager, SaveSystem, AudioManager
│   ├── components/     # Wiederverwendbare Komponenten-Scripts
│   └── resources/      # CharacterData, ItemData, SpellData
├── assets/
│   ├── sprites/
│   ├── fonts/
│   └── sounds/
└── addons/
```

## Autoloads (Singletons)
- **SaveSystem** (`scripts/autoload/save_system.gd`): JSON-Speicherung in `user://saves/`
- **AudioManager** (`scripts/autoload/audio_manager.gd`): UI-Sounds, Hintergrundmusik
- **GameManager** (`scripts/autoload/game_manager.gd`): Aktueller Charakter, Charakterliste

## Resource-Typen
- **CharacterData** (`scripts/resources/character_data.gd`): Alle D&D-Charakter-Daten
- **ItemData** (`scripts/resources/item_data.gd`): Ausrüstungsgegenstände
- **SpellData** (`scripts/resources/spell_data.gd`): Zaubersprüche

## Wichtige Konventionen
- **Typ-Annotierungen immer verwenden** (z.B. `var speed: float = 200.0`)
- **Signals** für Kommunikation zwischen Nodes (nicht direkte Referenzen)
- `await` statt `yield` (Godot 4!)
- `signal.connect(callable)` statt `.connect("name", obj, "method")`
- `@export` statt `export var`
- Physik in `_physics_process()`, Logik in `_process()`

## Was Claude NICHT tun soll
- Keine Godot-3-Syntax (KinematicBody, Spatial, `.connect(name, obj, method)`, `yield()`)
- Kein VisualScript, kein C#
- Keine externen Bibliotheken außer Godot-Addons
- WICHTIG: Godot 4.3, KEIN Godot 3!

## Häufig verwendete Nodes
- UI: CanvasLayer > Control > VBoxContainer/HBoxContainer/GridContainer
- Eingaben: LineEdit, SpinBox, OptionButton, CheckBox, TextEdit
- Layout: MarginContainer, PanelContainer, TabContainer, ScrollContainer
