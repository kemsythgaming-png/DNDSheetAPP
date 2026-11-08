# CLAUDE.md — D&D 5e Charakter-App

> Diese Datei beschreibt den aktuellen Stand, die Architektur und die geplanten Features der D&D 5e Charakter-App.
> Claude Code liest diese Datei automatisch beim Start und kennt so den vollständigen Projektkontext.

---

## Projektübersicht

**Was ist das?**
Eine mobile-first Web-App (React/JSX) für D&D 5e Charakterverwaltung.
Ziel: Komplett auf dem Handy bedienbar — vom Erstellen eines Charakters bis zum
Spielen in der Taverne mit der Gruppe.

**Tech-Stack**
- Framework: React (JSX, Hooks)
- Styling: Inline-Styles (kein CSS-Framework)
- Datenhaltung: localStorage (Browser-lokal, kein Backend)
- Sprache: Deutsch (UI), Englisch/Deutsch gemischt bei D&D-Begriffen
- Zielgerät: Mobile (max-width 400px), läuft auch im Browser

**Hauptdatei**
`dnd-app-v2.jsx` — die gesamte App in einer einzigen Datei

---

## Aktueller Stand — Was bereits funktioniert

### 1. Hauptmenü & Slot-System
- 5 Charakter-Slots sichtbar
- 3 kostenlos, 2 gesperrt (Pro-Slots, aktuell nur Dummy)
- Belegte Slots zeigen: Charaktername, Klasse-Icon, Rasse, aktuelle Stufe
- Leere Slots starten den Charakter-Ersteller
- Alle Daten in localStorage gespeichert (Key-Schema: `dnd5e_v3_slot_0` bis `_4`)
- Kein Account, kein Backend nötig

---

### 2. Charakter-Ersteller (7 Schritte, mit Vor/Zurück-Navigation)

**Schritt 1 — Klasse wählen**
- Alle 12 D&D-5e-Klassen: Barbar, Barde, Kleriker, Druide, Kämpfer, Mönch,
  Paladin, Waldläufer, Schurke, Magier, Hexenmeister, Zauberer
- Info-Button: aufklappbare Details pro Klasse
  - Trefferwürfel (W6–W12)
  - Primärattribute
  - Rüstungs- und Waffenübungen
  - Alle Level-Fähigkeiten (Lv1–20) zweisprachig (Deutsch / Englisch)
  - Subklassen-Vorschau mit Beschreibung

**Schritt 2 — Rasse wählen**
- 9 Rassen: Mensch, Elf, Zwerg, Halbling, Halbelf, Halbork, Tiefling,
  Drachenkind, Gnom
- Unterrassen auswählbar (z.B. Hochelf/Waldelfe/Drow, Hügel-/Bergzwerg)
- Rassenmerkmale und Attribut-Boni werden live angezeigt

**Schritt 3 — Hintergrund wählen**
- 10 Hintergründe: Soldat, Krimineller, Akolyth, Adliger, Weiser,
  Held des Volkes, Entertainer, Ausreißer, Einsiedler, Gildenkaufmann
- Jeder Hintergrund gibt (PHB 2024): +2/+1 auf spezifische Attribute,
  2 Fertigkeiten, Hintergrundmerkmal, Startausrüstung

**Schritt 4 — Attribute verteilen**
- Punkt-Kauf-System (27 Punkte, Standard D&D 5e)
- Wertebereich: 8–15 (vor Boni)
- Rassenbonus + Hintergrundbonus live addiert und angezeigt
- Kosten pro Schritt sichtbar (8–13: je 1 Punkt, 14: +2 extra, 15: +3 extra)

**Schritt 5 — Fertigkeiten wählen**
- Nur klassenspezifische Fertigkeiten auswählbar
- Klassenlimit wird durchgesetzt (Schurke: 4, Barde/Waldläufer: 3, Rest: 2)
- Bonus live aus Attributen berechnet
- Hintergrunds-Fertigkeiten separat als automatisch grün angezeigt

**Schritt 6 — Gesinnung wählen**
- Alle 9 Gesinnungen mit Kurzbeschreibung

**Schritt 7 — Name & Abschluss**
- Namenseingabe: stabile Implementierung als top-level Komponente
  `NameInputStep` (außerhalb von App() um React-Remount-Bug zu vermeiden)
- Live-Validierung: min. 2 Zeichen, Fertig-Knopf aktiviert sich sofort
- Vollständige Zusammenfassung: alle Attribute mit Boni, Klasse, Rasse, BG, Fertigkeiten

---

### 3. Charakter-Sheet (8 Tabs)

**Kern-Tab**
- Charakter-Übersicht (Name, Klasse-Icon, Rasse, Stufe, Hintergrund, Gesinnung)
- Alle 6 Attribute mit Modifikatoren (inkl. Rassen- + Hintergrundbonus)
- HP-Tracker: Schaden/Heilungs-Buttons + Eingabefeld für Betrag
- HP-Balken mit Farbwechsel (grün >60%, orange >30%, rot ≤30%)
- Todesrettungswürfe: 3 Erfolge + 3 Misserfolge, antippbar
- Proficienzbonus, Initiative, Passive Wahrnehmung
- Inspirations-Button (toggelt, wird gespeichert)

**Kampf-Tab**
- Rüstungsklasse (automatisch nach Klasse: Barbar=10+GES+KON, Mönch=10+GES+WEI,
  Kämpfer/Paladin=16, Kleriker=15, Waldläufer=14, Rest=10+GES)
- Initiative (GES-Mod) und Bewegung in ft + Meter
- Alle 6 Rettungswürfe mit klassenspezifischer Profi-Markierung
- Rüstungs- und Waffenübungen der gewählten Klasse

**Skills-Tab**
- Alle 18 Fertigkeiten mit berechnetem Bonus
- Geübte Fertigkeiten farblich hervorgehoben (Klassenfarbe)
- Klassen- + Hintergrunds-Fertigkeiten zusammengeführt

**Merkmale-Tab**
- Klassenmerkmale: alle Features bis zur aktuellen Stufe, zweisprachig
- Nächste Fähigkeiten (kommende Stufe) als Vorschau
- Rassenmerkmale + Unterrassen-Details
- Hintergrundmerkmal mit Volltext

**Zauber-Tab**
- Zauberwirker-Werte: Fähigkeit, RW-SG (8+Prof+Mod), Angriffsbonus
- Klassengefilterte Zauberliste nach Grad (Cantrips, 1. Grad, 2. Grad...)
- Slot-Anzahl je nach Stufe automatisch berechnet
- Nicht-Zauberwirker: sinnvolle Meldung statt leerem Tab

**Inventar-Tab**
- Währung: GM, SM, KM, EM, PM — editierbare Felder, Gesamtwert in GM
- Eigene Gegenstände: Name + optionaler Schaden + Gewicht
- Waffen-Datenbank: 40+ SRD-Waffen mit DMG, Gewicht (lb), Kosten, Eigenschaften
- Gesamtgewicht-Anzeige (wird rot bei >150 lb)
- Pro Item: Menge +/−, abhaken (durchgestrichen), löschen
- Alles gespeichert in localStorage

**Notizen-Tab**
- 8 separate Textfelder (auto-save):
  Charakterbeschreibung, Persönlichkeit, Ideale, Bindungen, Makel,
  Hintergrundgeschichte, Verbündete & Organisationen, Sonstiges

**Hilfe-Tab**
- Entfernungen ft ↔ Meter (aufklappbar)
- Kampfbegriffe erklärt
- Alle Zustände (Conditions) erklärt
- Schlüsselbegriffe (Resistenz, Immunität, Rast...)
- Attribut-Modifikatoren-Tabelle
- Rüstungsklasse-Berechnung nach Typ

---

### 4. Level-Up System (interaktiv, 4 Phasen)

Aufruf: Button "Lv X ↑" oben rechts im Sheet.
Ist als top-level Komponente `LevelUpModal` außerhalb von App() implementiert.

**Phase 1 — HP würfeln**
- Würfel-Emoji animiert sich (dreht, zeigt zufällige Zahlen)
- Klassenspezifischer Würfel (W6=Magier/Zauberer, W8=Barde/Kleriker/etc.,
  W10=Kämpfer/Paladin/Waldläufer, W12=Barbar)
- Wahl: Würfeln (zufällig) ODER Durchschnitt (Ceil(HD/2)+1)
- Beides zeigt: Ergebnis + KON-Mod = finale TP
- Neue Fähigkeiten der Stufe angezeigt (aus `lvUpFeats` Data)
- Detaillierte Feature-Beschreibungen aus `features` Array

**Phase 2 — Subklasse wählen** (nur wenn nextLv === clsObj.subLv)
- Alle Subklassen der Klasse auswählbar
- Vollständige Beschreibung pro Subklasse
- Weiter-Button gesperrt bis Auswahl getroffen

**Phase 3 — Zauber-Auswahl** (nur Zauberwirker-Klassen)
- Klassengefilterte Zauberliste aus `clsObj.spells`
- Suche + Grade-Filter
- Mehrere Zauber wählbar, werden in `learnedSpells` Array gespeichert

**Phase 4 — Attributssteigerung** (nur Lv 4, 8, 12, 16, 19)
- +/− Buttons pro Attribut
- Maximum 20 pro Attribut durchgesetzt
- Maximal 2 Punkte total verteilbar
- Modifikatoren live aktualisiert

**Abschluss — Bestätigungs-Zusammenfassung**
- Zeigt: neue Stufe, +HP, Attribut-Änderungen, Subklasse, neue Zauber
- Bestätigen speichert alles in localStorage

---

## Datenstruktur (localStorage)

```js
// Gespeichertes Charakter-Objekt (Beispiel)
{
  cls: "wizard",           // Klassen-ID
  race: "elf",             // Rassen-ID
  sub: "high",             // Unterrassen-ID
  bg: "sage",              // Hintergrunds-ID
  stats: {                 // Basis-Stats VOR Boni (Punkt-Kauf)
    STÄ: 8, GES: 14, KON: 14,
    INT: 18, WEI: 12, CHA: 10
  },
  finalStats: {            // Stats MIT allen Boni (Race + BG)
    STÄ: 9, GES: 16, KON: 14,
    INT: 20, WEI: 13, CHA: 10
  },
  skills: ["Arkane Kunde","Geschichte"],  // Klassen-Fertigkeiten
  align: "cg",             // Gesinnungs-ID
  name: "Aldric Fernholz",
  lv: 5,                   // Aktuelle Stufe
  hp: { cur: 28, max: 35 },
  inspiration: false,
  learnedSpells: ["Fireball / Feuerball", "Shield / Schild"],
  chosenSubclass: "evocation",
  chosenSubclassName: "Evokation",
  chosenSubclassDesc: "...",
  hpAddThisLevel: 6,
  // Inventar
  inventar: [
    { id: 1234567890, name: "Zauberstab", dmg: "—", weight: 1, qty: 1, checked: false }
  ],
  gold: { gm: 145, sm: 32, km: 8, em: 0, pm: 0 },
  // Notizen
  notizenCharakter: "Großgewachsener Hochelf...",
  notizenBackstory: "Sucht das schwarze Buch...",
  // ... weitere Notizen-Felder
  slotIdx: 0               // Wird beim Öffnen hinzugefügt, nicht gespeichert
}
```

---

## Wichtige Implementierungs-Details

### Name-Input Bug (gelöst)
**Problem:** React remounted den Input bei jedem Keystroke → Focus-Verlust.
**Ursache:** Komponenten die *innerhalb* von App() oder CreatorScreen() definiert
sind, werden bei jedem Re-render als neue Funktion-Instanz erstellt →
React erkennt sie als neue Komponente → Unmount + Remount.
**Lösung:** `NameInputStep` als **top-level Funktion außerhalb von App()** definiert.
useState für localName im Input selbst. onNameChange-Callback aktualisiert
`char.name` in App (für canNext()), aber die Komponente bleibt stabil.

### LevelUpModal (top-level)
Gleiche Lösung: `LevelUpModal` außerhalb von App() damit es nicht
bei jedem App-Re-render neu gemounted wird.

### Klassenfarben
Jede Klasse hat eine Akzentfarbe die durch die gesamte UI verwendet wird:
```js
const COL = {
  barbarian:"#c0392b", bard:"#8e44ad", cleric:"#c99a2e",
  druid:"#27ae60",     fighter:"#2980b9", monk:"#16a085",
  paladin:"#d4ac0d",   ranger:"#1e8449", rogue:"#7d3c98",
  sorcerer:"#2471a3",  warlock:"#6c3483", wizard:"#1a5276"
}
```

### canNext()-Logik (Creator)
```js
step 0: !!char.cls
step 1: !!char.race && (keine Unterrassen || !!char.sub)
step 2: !!char.bg
step 3: ptsLeft === 0  (alle 27 Punkte verteilt)
step 4: char.skills.length === cls.skillCount
step 5: !!char.align
step 6: char.name.trim().length >= 2
```

### finalStats()-Funktion
Berechnet Stats mit allen Boni:
```js
function finalStats(char) {
  // Basis-Stats + Rassenbonus + Unterrassenbonus + Hintergrundbonus
}
```
Wird beim Speichern einmalig berechnet und als `finalStats` gespeichert.
Im Sheet immer `sheet.finalStats` verwenden, nie `sheet.stats`.

---

## Offene Punkte / Bekannte Probleme

- [ ] Zauber-Auswahl im Level-Up zeigt nur Zauber aus `clsObj.spells` (begrenzte Liste)
      → Volle SPELL_DB ist definiert aber noch nicht im Level-Up-Modal verknüpft
- [ ] PDF-Export Button existiert, zeigt aber nur einen Alert
      → Grundgerüst für ReportLab PDF-Generator in Python vorhanden (aldric_fernholz_dnd.pdf)
- [ ] Pro-Slots sind rein visuell gesperrt, kein echtes Payment-System
- [ ] Notizen-Tab speichert nicht in Echtzeit bei allen Feldern (nur erstes Feld)
- [ ] Inventar-Gewicht: kein Encumbrance-System (nur Anzeige, keine Auswirkung)

---

## Geplante Features (Theorie, noch nicht implementiert)

### 🍺 Taverne / Party-System
- Party-Raum erstellen mit Einladecode
- Andere Spieler können mit Code beitreten
- Alle Charaktere sitzen visuell in einer Taverne (Pixel-Art oder illustriert)
- Charakter-Avatar je nach Rasse unterschiedlich dargestellt
- In-Character-Chat (als Figur schreiben, nicht als Spieler)
- Gemeinsamer Initiative-Tracker für den DM
- Session-Notizen die alle sehen

### ⚔️ Idle-Game / Solo-Abenteuer
- Charakter geht auf automatische Solo-Missionen wenn App nicht aktiv ist
- Passive Ressourcen sammeln: Gold, XP, Items
- Zufallsereignisse basierend auf Klasse und Stats
  (Magier findet Zauberbuch-Seiten, Schurke stiehlt Gold, Paladin hilft NPCs)
- Push-Notifications: "Dein Waldläufer hat einen seltenen Bogen gefunden!"
- Belohnungen fließen optional ins echte Character Sheet zurück
- Offline-Progress-Berechnung (Stunden × Rate)
- Prestige-System: Legendäre Errungenschaften je Klasse

### 🖨️ PDF-Export (Charakterbogen)
- Druckbarer 3-seitiger Charakterbogen
- Seite 1: Hauptblatt (Attribute, Kampfwerte, Fertigkeiten, Merkmale)
- Seite 2: Hintergrund & Persönlichkeit
- Seite 3: Zauberbogen (nur für Zauberwirker)
- Python/ReportLab Backend bereits als Proof-of-Concept vorhanden
- Alternative: Browser-Print mit CSS @media print

### 📱 Native App
- Aktuell: Web-App / React Artifact
- Ziel: React Native (iOS + Android aus einer Codebase)
- Lokale Datenhaltung bleibt (AsyncStorage statt localStorage)

---

## Konventionen für neue Features

- Alle neuen Komponenten die State halten: **außerhalb von App()** definieren
- Neue Tabs im Sheet: in `SHEET_TABS`-Array eintragen
- Neue Klassen-Daten: in `CLASSES`-Array (gleiche Struktur wie bestehende)
- Neue Rassen-Daten: in `RACES`-Array
- Alles in Deutsch, D&D-Begriffe zweisprachig (Deutsch / Englisch)
- Inline-Styles überall (kein CSS, keine Klassen)
- Mobile-First: maxWidth 400px, Touch-freundliche Buttons (min. 44px Höhe)
- localStorage-Keys immer mit `dnd5e_v3_` prefixen

---

## Datei-Übersicht

```
/
├── CLAUDE.md                        ← Diese Datei
├── dnd-app-v2.jsx                   ← Haupt-App (gesamte Logik)
└── claude-code-godot-anleitung.md   ← Godot-Anleitung (separates Projekt)
```

---

*Letzte Aktualisierung: Mai 2026*
*Stack: React JSX · localStorage · Mobile-First · D&D 5e SRD*
