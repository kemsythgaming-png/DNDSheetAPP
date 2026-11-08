# DNDSheetAPP – Game Design Dokument

## Überblick
DNDSheetAPP ist eine Godot-4-basierte Desktop-Applikation zur Verwaltung
von D&D-5e-Charakterbögen. Ziel ist es, den physischen Charakterbogen
vollständig digital und komfortabel abzubilden.

## Kernfunktionen

### Charakterverwaltung
- Mehrere Charaktere erstellen, bearbeiten, löschen
- Übersichtsliste aller gespeicherter Charaktere

### Charakterbogen-Ansicht
- Alle D&D-5e-Attribute (STR, DEX, CON, INT, WIS, CHA) mit Modifikatoren
- Fertigkeiten mit Proficienz-Markierung
- HP-Tracker (aktuell / maximal / temporär)
- Rüstungsklasse, Initiative, Bewegungsrate
- Rettungswürfe
- Angriffe & Zauber

### Inventar
- Ausrüstungsgegenstände mit ItemData-Resources
- Gewichtsberechnung
- Münzen (KM, SM, EM, GM, PM)

### Zauberbuch
- Zaubersprüche mit SpellData-Resources
- Zauberslots nach Klasse und Level
- Konzentrations-Markierung

### Notizen
- Freies Textfeld für Hintergrundgeschichte
- Features & Eigenschaften
- Allgemeine Notizen

## Technische Anforderungen
- Godot 4.3, GDScript
- Lokale Speicherung: `user://saves/characters.json`
- Kein Netzwerk, kein Online-Dienst
- Zielplattform: Desktop (Windows, Linux, macOS)
