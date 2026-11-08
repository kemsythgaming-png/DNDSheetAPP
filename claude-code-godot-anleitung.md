# Claude Code in Godot 4 — Vollständige Anleitung

> **Stand:** Mai 2026 · Godot 4.x · Claude Code (Sonnet 4.6)

---

## Inhaltsverzeichnis

1. [Was ist Claude Code?](#1-was-ist-claude-code)
2. [Voraussetzungen & Installation](#2-voraussetzungen--installation)
3. [Grundlegendes Setup](#3-grundlegendes-setup)
4. [Godot MCP — Claude steuert den Editor](#4-godot-mcp--claude-steuert-den-editor)
5. [Skills & Plugins für Godot](#5-skills--plugins-für-godot)
6. [Der optimale Workflow](#6-der-optimale-workflow)
7. [Prompt-Engineering für GDScript](#7-prompt-engineering-für-gdscript)
8. [Häufige Aufgaben mit Claude Code](#8-häufige-aufgaben-mit-claude-code)
9. [GDScript Best Practices die Claude kennt](#9-gdscript-best-practices-die-claude-kennt)
10. [Fehlerbehebung & Grenzen](#10-fehlerbehebung--grenzen)
11. [Nützliche Ressourcen](#11-nützliche-ressourcen)

---

## 1. Was ist Claude Code?

Claude Code ist ein **KI-gestütztes Kommandozeilen-Tool** von Anthropic, das direkt in deinem Terminal oder deiner IDE läuft. Anders als das Chat-Interface kann Claude Code:

- Dateien lesen, schreiben und bearbeiten
- Bash-Befehle ausführen
- Dein gesamtes Projektverzeichnis analysieren
- Mehrere Dateien gleichzeitig refaktorieren
- Mit externen Tools über **MCP (Model Context Protocol)** kommunizieren — auch direkt mit dem Godot-Editor

**Warum Claude Code für Godot?**
Claude Sonnet 4.6 wurde mit Daten bis Juli 2025 trainiert und kennt daher Godot 4.x APIs (CharacterBody2D/3D, Signals, `@export`, `await`, den neuen MultiplayerAPI usw.) deutlich besser als ältere Modelle, die noch Godot-3-Syntax produzieren.

---

## 2. Voraussetzungen & Installation

### Benötigte Software

| Software | Version | Link |
|---|---|---|
| Godot Engine | 4.2 oder höher | godotengine.org |
| Node.js | 18 oder höher | nodejs.org |
| Claude Code | aktuell | über npm |
| Python | 3.10+ (optional, für MCP) | python.org |

### Claude Code installieren

```bash
# Installation über npm (global)
npm install -g @anthropic-ai/claude-code

# Überprüfen
claude --version

# Anmelden (Anthropic-Account erforderlich)
claude login
```

### Pläne & Kosten (Stand Mai 2026)

- **Claude Pro** (~20 $/Monat): Enthält ein monatliches Claude-Code-Kontingent — gut für moderaten Einsatz
- **Pay-as-you-go** (API): Für intensive Nutzung, Abrechnung nach Token
- Für ein mittleres Godot-Projekt (RTS, RPG etc.) liegen die Kosten erfahrungsgemäß bei 5–30 $ pro Monat

---

## 3. Grundlegendes Setup

### Godot-Projekt vorbereiten

Erstelle eine `CLAUDE.md`-Datei im **Stammverzeichnis** deines Godot-Projekts. Diese Datei liest Claude Code bei jedem Start automatisch und kennt so sofort deinen Projektkontext.

```markdown
# CLAUDE.md — Mein Godot-Projekt

## Projektübersicht
- Genre: 2D Top-Down RPG
- Godot-Version: 4.3
- Sprache: GDScript (kein C#)
- Plattform: Desktop (Windows, Linux, macOS)

## Projektstruktur
```
res://
├── scenes/
│   ├── player/
│   ├── enemies/
│   ├── ui/
│   └── world/
├── scripts/
│   ├── autoload/      # Singletons (GameManager, AudioManager)
│   ├── components/    # Wiederverwendbare Komponenten
│   └── resources/     # Resource-Typen
├── assets/
│   ├── sprites/
│   ├── sounds/
│   └── fonts/
└── addons/
```

## Wichtige Konventionen
- **Typ-Annotierungen immer verwenden** (z.B. `var speed: float = 200.0`)
- **Signals** für Kommunikation zwischen Nodes (nicht direkte Referenzen)
- **Autoloads**: GameManager, AudioManager, SaveSystem
- CharacterBody2D für den Spieler, nicht KinematicBody (Godot 3!)
- Physik in `_physics_process()`, Logik in `_process()`

## Häufig verwendete Nodes
- Spieler: CharacterBody2D + CollisionShape2D + AnimatedSprite2D
- Gegner: CharacterBody2D mit NavigationAgent2D
- UI: CanvasLayer > Control

## Was Claude NICHT tun soll
- Keine Godot-3-Syntax (KinematicBody, Spatial, .connect(name, obj, method))
- Kein VisualScript
- Keine externen Abhängigkeiten außer Godot-Addons
```

### Claude Code starten

```bash
# Im Godot-Projektverzeichnis:
cd /pfad/zu/meinem/godot-projekt
claude

# Oder direkt mit einer Aufgabe:
claude "Erstelle ein PlayerController-Script für CharacterBody2D mit Bewegung und Sprung"
```

---

## 4. Godot MCP — Claude steuert den Editor

Das **Godot MCP** (Model Context Protocol Server) ist das mächtigste Feature: Claude Code kann damit direkt mit dem laufenden Godot-Editor kommunizieren — Szenen öffnen, Scripts ausführen, den Debugger auslesen.

### Installation: godot-mcp

```bash
# MCP-Server installieren
npm install -g godot-mcp

# Alternativ direkt aus GitHub:
git clone https://github.com/Coding-Solo/godot-mcp
cd godot-mcp
npm install
npm run build
```

### Claude Code mit Godot MCP verbinden

Bearbeite `~/.claude/claude_desktop_config.json` (oder die entsprechende Config für Claude Code):

```json
{
  "mcpServers": {
    "godot": {
      "command": "node",
      "args": ["/pfad/zu/godot-mcp/build/index.js"],
      "env": {
        "GODOT_PATH": "/usr/bin/godot4",
        "PROJECT_PATH": "/pfad/zu/deinem/godot-projekt"
      }
    }
  }
}
```

**Windows-Beispiel:**
```json
{
  "mcpServers": {
    "godot": {
      "command": "node",
      "args": ["C:/Tools/godot-mcp/build/index.js"],
      "env": {
        "GODOT_PATH": "C:/Program Files/Godot/Godot_v4.3.exe",
        "PROJECT_PATH": "C:/Users/User/Projekte/MeinSpiel"
      }
    }
  }
}
```

### Was Claude mit Godot MCP kann

| Fähigkeit | Beschreibung |
|---|---|
| Editor starten | Godot automatisch öffnen |
| Projekt ausführen | Spiel starten und Ausgabe lesen |
| Debug-Output | Fehler und `print()`-Ausgaben abrufen |
| Szenen laden | Bestimmte `.tscn`-Dateien öffnen |
| Scripts editieren | `.gd`-Dateien direkt schreiben |

**Beispiel-Prompts mit MCP:**
```
"Starte das Projekt und lies den Debug-Output. 
 Behebe dann den Fehler in player.gd."

"Öffne die Szene scenes/world/level_01.tscn 
 und füge einen NavigationRegion2D hinzu."
```

---

## 5. Skills & Plugins für Godot

Skills sind **Wissenspakete** die Claude Code lädt um spezialisierter zu arbeiten. Für Godot gibt es mehrere ausgezeichnete.

### Option A: GodotPrompter (empfohlen)

45 domänenspezifische Skills für Godot 4.x.

```bash
# Repository klonen
git clone https://github.com/jame581/GodotPrompter
cd GodotPrompter

# In Claude Code einbinden
claude --plugin-dir ./GodotPrompter
```

**Enthaltene Skills (Auswahl):**

| Skill | Anwendungsfall |
|---|---|
| `player-controller` | CharacterBody2D Bewegung mit Coyote-Time, Jump-Buffering |
| `state-machine` | Saubere FSM-Implementierung |
| `ai-navigation` | NavigationAgent2D, Pathfinding |
| `inventory-system` | Item-Resources, Slots, Drag & Drop |
| `save-system` | JSON/Binary Speichersystem |
| `multiplayer` | MultiplayerAPI, RPC, Synchronizer |
| `shader` | GLSL-Shader für Godot |
| `ui-system` | Control-Nodes, Themes, Responsive UI |
| `audio` | AudioStreamPlayer, Bus-System |
| `procedural-gen` | Noise, Dungeon-Generierung |

**Beispiel:**
```
"Lade den player-controller Skill und erstelle einen 
 Platformer-Spieler mit Coyote-Time und Jump-Buffering 
 für CharacterBody2D."
```

### Option B: godot-claude-skills

```bash
git clone https://github.com/alexmeckes/godot-claude-skills
claude --plugin-dir ./godot-claude-skills
```

Fokus auf: GDScript-Patterns, Live-Editing, Shader-Authoring, Scene-Design.

### Option C: Godot Skills Plugin (Claude Code Marketplace)

In Claude Code direkt installierbar:

```
# In Claude Code:
/plugin marketplace add randroids-dojo/godot-skills

# Oder über die Skills-Oberfläche:
Customize > Skills > "godot" suchen > aktivieren
```

Enthält GdUnit4-Integration für automatisches Testen.

---

## 6. Der optimale Workflow

### Täglicher Entwicklungsablauf

```
1. Terminal öffnen → Projektverzeichnis
2. claude starten
3. Aufgabe beschreiben
4. Code reviewen
5. In Godot testen
6. Feedback geben → Claude korrigiert
```

### Empfohlene Projektstruktur für Claude Code

```
mein-spiel/
├── CLAUDE.md              ← Projektkontext (immer!)
├── .claude/
│   └── settings.json      ← Claude-Code-Einstellungen
├── project.godot
├── scenes/
├── scripts/
├── assets/
└── docs/
    ├── game-design.md     ← GDD (Claude liest mit!)
    └── architecture.md    ← Technische Entscheidungen
```

### Iterativer Arbeitsrhythmus

**Schritt 1: Kontext geben**
```
"Lies CLAUDE.md und docs/architecture.md. 
 Wir arbeiten heute am Inventar-System."
```

**Schritt 2: Implementierung anfragen**
```
"Erstelle ein Inventar-System mit:
- Resource-basierte Items (ItemData.gd)
- InventoryComponent.gd als Node-Komponente  
- Signal item_added(item: ItemData, slot: int)
- Signal item_removed(item: ItemData, slot: int)
- Maximale Slot-Anzahl als @export
- Typ-Annotierungen überall"
```

**Schritt 3: Integration testen**
```
"Das Inventar funktioniert, aber beim Droppen 
 eines Items gibt es: ERROR: Invalid get index 'slot_index' 
 on base 'Nil'. Hier ist der Stack-Trace: [...]"
```

**Schritt 4: Refaktorierung**
```
"Das Inventar-Script ist zu lang (300 Zeilen). 
 Teile es auf in: InventoryComponent.gd (Logik), 
 InventoryUI.gd (Darstellung), ItemSlot.gd (Slot-Node)"
```

---

## 7. Prompt-Engineering für GDScript

### Die goldene Regel: Spezifisch statt vage

❌ **Schlecht:**
```
"Mach einen Spieler der sich bewegt"
```

✅ **Gut:**
```
"Erstelle player.gd für einen CharacterBody2D in Godot 4.3.
 Anforderungen:
 - 2D Top-Down (keine Schwerkraft)
 - WASD + Pfeiltasten Bewegung
 - Geschwindigkeit: 200px/s (als @export)
 - Dash-Fähigkeit: Leertaste, 3x Grundgeschwindigkeit, 0.2s, 
   Cooldown 1.5s
 - Signal 'dashed' senden wenn Dash ausgeführt wird
 - Alle Variablen mit Typ-Annotierungen
 - Kommentare auf Deutsch"
```

### Kontext-Vorlagen

**Vorlage 1: Neues System**
```
Ich entwickle [SPIELTYP] in Godot 4.3 mit GDScript.
Ich brauche [SYSTEM-NAME] mit folgenden Features:
- [Feature 1]
- [Feature 2]
Vorhandene Autoloads: [GameManager, AudioManager, ...]
Bitte nutze Signals statt direkter Node-Referenzen wo möglich.
```

**Vorlage 2: Bug-Report**
```
Godot-Version: 4.3
Fehlermeldung: [EXAKTER FEHLER]
Stack-Trace: [STACK-TRACE]
Betroffene Datei: [DATEINAME.gd]

Hier ist der relevante Code:
[CODE-SNIPPET]

Das Problem tritt auf wenn: [BEDINGUNG]
```

**Vorlage 3: Code-Review**
```
Bitte reviewe diesen GDScript-Code auf:
1. Performance-Probleme (besonders in _process/_physics_process)
2. Godot-4-Best-Practices (Signals, Typ-Annotierungen, @export)
3. Mögliche Null-Referenz-Fehler
4. Fehlende Bereinigung (_exit_tree, disconnect)

[CODE]
```

**Vorlage 4: Refaktorierung**
```
Diese Klasse macht zu viel (God-Object-Problem):
[CODE]

Teile sie auf in sinnvolle Komponenten nach dem 
Prinzip "Composition over Inheritance" in Godot.
Erkläre warum du die Aufteilung so wählst.
```

### GDScript-spezifische Hinweise im Prompt

Füge diese Sätze ein um Godot-3-Fehler zu vermeiden:

```
- "Godot 4, kein Godot 3"
- "CharacterBody2D/3D (nicht KinematicBody)"
- "Node3D (nicht Spatial)"  
- "signal.connect(callable) (nicht .connect(name, obj, method))"
- "await signal (nicht yield)"
- "@export statt export var"
- "is_on_floor() für CharacterBody2D"
```

---

## 8. Häufige Aufgaben mit Claude Code

### 8.1 Spielerbewegung (CharacterBody2D)

```
"Erstelle player_controller.gd für CharacterBody2D:
- 8-Richtungs-Bewegung mit Normalisierung
- Beschleunigung und Reibung (nicht sofortiger Stop)
- @export für: speed, acceleration, friction
- _physics_process für Physik
- AnimatedSprite2D-Animationen basierend auf Richtung
- Godot 4.3, Typ-Annotierungen, deutsche Kommentare"
```

### 8.2 Gegner KI mit Navigation

```
"Erstelle enemy_ai.gd für einen CharacterBody2D-Gegner:
- NavigationAgent2D für Pathfinding
- 3 Zustände: Patrol, Chase, Attack (State Machine)
- Patrol: zufällige Punkte in @export NodePath-Array
- Chase: wenn Spieler in @export detection_range: float
- Attack: wenn in @export attack_range: float
- Signals: state_changed(old, new), player_detected, player_lost
- Godot 4.3"
```

### 8.3 Save-System

```
"Erstelle ein Save-System als Autoload (save_system.gd):
- Speichert Dictionary in JSON unter user://save.json
- Methoden: save_game(data: Dictionary), 
             load_game() -> Dictionary,
             has_save() -> bool,
             delete_save()
- Signal save_completed, load_completed
- Error-Handling für korrupte Dateien
- Godot 4.3"
```

### 8.4 Audio-Manager

```
"Erstelle audio_manager.gd als Autoload:
- Pools für Sound-Effekte (mehrere gleichzeitig)
- play_sfx(sound: AudioStream) -> void
- play_music(music: AudioStream, crossfade: float = 1.0)
- stop_music(fadeout: float = 1.0)
- set_sfx_volume(volume_db: float)
- set_music_volume(volume_db: float)
- Nutzt AudioStreamPlayer-Nodes im Autoload selbst
- Godot 4.3, vollständige Typ-Annotierungen"
```

### 8.5 Shader erstellen

```
"Erstelle einen Godot-4-CanvasItem-Shader der:
- Einen Pixelate-Effekt erzeugt
- Einen @export uniform pixel_size: float = 4.0 hat
- Auf ein Sprite2D anwendbar ist
Erkläre jeden Teil des GLSL-Codes."
```

### 8.6 Szenen-Datei (.tscn) generieren

```
"Erstelle eine vollständige .tscn-Datei für eine 
 Plattformer-Level-Szene mit:
- Node2D als Root (heißt 'Level')
- TileMapLayer für Boden und Plattformen
- Marker2D namens 'PlayerSpawn'
- Camera2D mit Limits
- CanvasLayer für HUD (leer)
Godot 4.3 Format."
```

### 8.7 Automatisches Testing mit GdUnit4

```
"Erstelle GdUnit4-Tests für inventory_component.gd:
- Test: item kann hinzugefügt werden
- Test: volles Inventar wirft Signal inventory_full
- Test: item_removed Signal wird korrekt gesendet
- Test: Speichern und Laden behält Items
Nutze GdUnit4-Syntax für Godot 4."
```

---

## 9. GDScript Best Practices die Claude kennt

Stelle sicher dass Claude diese Standards in deinem Projekt anwendet:

### Typ-Annotierungen (immer!)

```gdscript
# ❌ Schlecht
var speed = 200
var health = 100
func take_damage(amount):
    health -= amount

# ✅ Gut  
var speed: float = 200.0
var health: int = 100
func take_damage(amount: int) -> void:
    health -= amount
```

### Signals richtig definieren

```gdscript
# Godot 4 Syntax
signal health_changed(new_health: int, old_health: int)
signal player_died
signal item_collected(item: ItemData)

# Verbinden (Godot 4!)
other_node.some_signal.connect(_on_some_signal)
# NICHT: .connect("some_signal", self, "_on_some_signal")
```

### @export für Inspector-Werte

```gdscript
@export var speed: float = 200.0
@export var jump_force: float = 400.0
@export_range(0.0, 100.0) var health: float = 100.0
@export_group("Combat")
@export var attack_damage: int = 10
@export var attack_cooldown: float = 0.5
```

### Autoload (Singletons)

```gdscript
# In project.godot eingetragen unter AutoLoad
# Zugriff überall:
GameManager.current_level = 2
AudioManager.play_sfx(hit_sound)
SaveSystem.save_game(save_data)
```

### await für asynchrone Operationen

```gdscript
# Warten auf Signal
await animation_player.animation_finished

# Warten auf Timer
await get_tree().create_timer(1.5).timeout

# Warten auf nächsten Frame
await get_tree().process_frame

# NICHT mehr: yield()
```

### Ressourcen-Typen

```gdscript
# Eigene Resource-Klasse
class_name ItemData
extends Resource

@export var item_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var value: int = 0
@export var stackable: bool = true
@export var max_stack: int = 99
```

---

## 10. Fehlerbehebung & Grenzen

### Häufige Probleme

**Problem: Claude produziert Godot-3-Syntax**

Lösung: Füge in CLAUDE.md und jeden Prompt ein:
```
WICHTIG: Godot 4.3, KEIN Godot 3.
Verwende CharacterBody2D (nicht KinematicBody),
Node3D (nicht Spatial), signal.connect(callable),
await (nicht yield), @export (nicht export var).
```

**Problem: Generierter Code kompiliert nicht**

Lösung: Kopiere den genauen Fehlertext und gib ihn Claude:
```
"Dieser Code erzeugt folgenden Fehler beim Kompilieren:
[FEHLER]
Hier ist der Code: [CODE]
Bitte korrigiere den Fehler."
```

**Problem: Code funktioniert aber ist langsam**

Lösung:
```
"Dieser Code läuft in _process() bei 60 FPS und verursacht
Performance-Probleme. Optimiere ihn:
- Vermeide Berechnungen die nur bei Änderungen nötig sind
- Nutze _physics_process statt _process für Physik
- Caching für teure Operationen
[CODE]"
```

**Problem: Claude versteht die Szenenstruktur nicht**

Lösung: Beschreibe den Szenengraphen explizit:
```
"Mein Szenengraph:
Player (CharacterBody2D)
├── CollisionShape2D
├── AnimatedSprite2D
├── HealthComponent (Node)
└── WeaponSlot (Node2D)
    └── Sword (Node2D)

Erstelle ein Script für HealthComponent.gd das..."
```

### Grenzen von Claude Code

| Limitation | Workaround |
|---|---|
| Versteht keine Bilder/Screenshots | Szenengraph als Text beschreiben |
| Kann Godot-Editor nicht direkt sehen | godot-mcp installieren |
| Kontextfenster hat Grenzen | CLAUDE.md kurz halten, Teilaufgaben stellen |
| Manche neue Godot-APIs noch unbekannt | Offizielle Doku-Snippet mitschicken |
| Generiert keine Binäres/Assets | Nur Code und .tscn-Dateien |

### Wenn Claude falsch liegt

```
"Die Methode move_toward() existiert nicht in diesem Kontext.
In Godot 4 heißt sie Vector2.move_toward(target, delta).
Korrigiere das im Code."
```

```
"Das Signal 'body_entered' eines Area2D in Godot 4 liefert 
einen Node2D, nicht ein PhysicsBody2D. Passe den Code an."
```

---

## 11. Nützliche Ressourcen

### Tools & Repositories

| Name | URL | Zweck |
|---|---|---|
| godot-mcp | github.com/Coding-Solo/godot-mcp | Editor-Integration |
| GodotPrompter | github.com/jame581/GodotPrompter | 45 Godot-Skills |
| godot-claude-skills | github.com/alexmeckes/godot-claude-skills | Skills + Live-Edit |
| Godot-Claude-Skills | github.com/Randroids-Dojo/Godot-Claude-Skills | Basis-Skills |
| GdUnit4 | github.com/MikeSchulze/gdUnit4 | Testing-Framework |
| PlayGodot | pypi.org/project/playgodot | E2E-Test-Automation |

### Dokumentation

| Ressource | URL |
|---|---|
| Claude Code Docs | docs.anthropic.com/claude-code |
| Godot 4 Docs | docs.godotengine.org |
| GDScript Referenz | docs.godotengine.org/en/stable/tutorials/scripting/gdscript |
| MCP Protokoll | modelcontextprotocol.io |

### Beispiel-Prompts Sammlung

**Quick-Reference:**
```bash
# Spielerbewegung
claude "CharacterBody2D 2D Top-Down Movement mit WASD, @export speed, Godot 4.3 GDScript"

# State Machine  
claude "State Machine GDScript für Gegner: Idle, Patrol, Chase, Attack. Signals für Übergänge."

# Save System
claude "Autoload SaveSystem.gd: save/load Dictionary als JSON in user://, Error-Handling, Godot 4"

# Shader
claude "Godot 4 CanvasItem Shader: Outline-Effekt, @export outline_color und outline_width"

# Unit Tests
claude "GdUnit4 Tests für PlayerController.gd: Bewegung, Kollision, Signal-Tests"
```

---

## Schnellstart-Checkliste

- [ ] Claude Code installiert (`npm install -g @anthropic-ai/claude-code`)
- [ ] `claude login` ausgeführt
- [ ] `CLAUDE.md` im Projektroot erstellt
- [ ] Godot-Version in CLAUDE.md vermerkt
- [ ] Projektstruktur beschrieben
- [ ] GDScript-Konventionen festgelegt
- [ ] Optional: godot-mcp installiert und konfiguriert
- [ ] Optional: GodotPrompter-Skills geladen
- [ ] Erstes `claude`-Kommando im Projektverzeichnis ausgeführt

---

*Erstellt mit Claude Sonnet 4.6 · Mai 2026*
*Godot ist ein Open-Source-Projekt unter der MIT-Lizenz: godotengine.org*
