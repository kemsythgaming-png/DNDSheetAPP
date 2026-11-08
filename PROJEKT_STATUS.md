# DNDSheetAPP — Vollständige Projektdokumentation

> Letzte Aktualisierung: 2026-06-02
> Datei: `D:\Programmierung\Godot\DNDSheetAPP\PROJEKT_STATUS.md`

---

## 1. Projektübersicht

**React/Vite Web-Prototyp** einer D&D 5e Charakterbogen-Applikation.
Mobile-first (max 420px), läuft komplett im Browser ohne Backend, Daten in localStorage.

| Eigenschaft | Wert |
|---|---|
| Haupt-Datei | `dnd-app-v2.jsx` (~15.200 Zeilen) |
| Framework | React 18 + Vite 6 |
| Sprache | JavaScript (JSX) — kein TypeScript |
| Styling | Inline-Styles (kein CSS-Framework) |
| Dev-Server | `npm run dev` → http://localhost:3000 |
| Single-File-Build | `npm run build:single` → `dist-single/index.html` (~41 MB, alles inline) |
| Launch-Config | `.claude/launch.json` (name: `dnd-app-v2`) |

---

## 2. Dateistruktur

```
D:\Programmierung\Godot\DNDSheetAPP\
├── dnd-app-v2.jsx          ← HAUPT-DATEI (alles in einer Datei)
├── main.jsx                ← React-Entry (rendert App)
├── index.html              ← HTML-Shell
├── vite.config.js          ← Vite-Config (inkl. vite-plugin-singlefile)
├── package.json
├── PROJEKT_STATUS.md       ← Diese Datei
│
├── public/                 ← Statische Assets (direkt per URL erreichbar)
│   ├── Barbar.png          ← Auch als avatar="/Barbar.png" nutzbar
│   ├── barde.png
│   ├── Kleriker.png
│   ├── Druide.png
│   ├── Kämpfer.png
│   ├── Mönsch.png
│   ├── Schurke.png
│   ├── Magier.png
│   ├── Zauberer.png
│   ├── Waldläufer.png
│   ├── Paladin.png
│   ├── hexenmeister.png
│   ├── Halbling.png
│   ├── HalbElfe.png
│   ├── halborc.png
│   ├── Tiefling.png
│   ├── Drachengeborener.png
│   ├── Roboter.png
│   ├── Gnom.png
│   ├── Arakocra.png
│   ├── Genasi.png
│   ├── Tabaxi.png
│   ├── Goliath.png
│   ├── Asaimar.png
│   ├── Kenku.png
│   ├── Eidechsenmensch.png
│   ├── Triton.png
│   ├── tavern.png
│   ├── arkane_bg.png
│   ├── kampf_bg.png
│   └── Kachel.png
│
├── src/assets/             ← Von Vite importierte Assets (werden gehasht/gebundelt)
│   ├── (alle oben genannten PNGs — Kopien von public/)
│   ├── hauptmenue.png
│   └── charakter.png       ← Wizard-Hintergrundbild
│
└── dist-single/
    └── index.html          ← Single-File-Build für WhatsApp/Mobile-Test
```

---

## 3. npm Scripts

```json
"dev":          "vite"                                          → localhost:3000
"dev2":         "vite --port 3001"                              → localhost:3001
"build":        "vite build"                                    → dist/
"build:single": "vite build --mode single --outDir dist-single" → alles in 1 HTML
"preview":      "vite preview"
"party":        "node party-server.js"                          → Multiplayer-Server
```

---

## 4. App-Struktur / Screens

```
App
├── SlotScreen              ← Charakter-Auswahl (Start)
├── CreatorScreen           ← 7-Schritte-Wizard (Char erstellen)
├── SheetScreen             ← Charakterbogen (Haupt-UI)
├── ArkaneChroniclesScreen  ← Kampftracker / Encounter-Manager
├── TaverneScreen           ← Gold-Shop / Slot freischalten
├── ShopScreen              ← Taler-Shop
├── SettingsScreen          ← Einstellungen
├── SupportScreen           ← Support-Info
├── ImpressumScreen         ← Impressum
└── WikiScreen              ← Regeln & Monster-Wiki
```

---

## 5. Tabs im Charakterbogen (SheetScreen)

```
Kern | Kampf | Skills | Merkmale | Zauber | Inventar | Währung | Notizen | Hilfe
```

| Tab | Funktion |
|---|---|
| **Kern** | Portrait, Basiswerte, Attribute, Skills-Übersicht, Hintergrund-Zauber-Karte, Aktivitäten, Todeswürfe |
| **Kampf** | Initiative, AC, HP, Waffen, Zauber-Angriffe, Kampf-Tracker |
| **Skills** | Alle Fertigkeiten mit Bonus, Profizienzen, Expertise |
| **Merkmale** | Rasse, Klasse, Hintergrund, Sprachen, Ausrüstung, Subklasse |
| **Zauber** | Zaubertricks + Zauber (gelernte + Hintergrund-Zauber), Slots, DC, Angriff |
| **Inventar** | Gegenstände, Gewicht, Rüstung |
| **Währung** | Gold, Silber, Kupfer, Elektrum, Platin |
| **Notizen** | Freitext |
| **Hilfe** | Regeln, Hinweise |

---

## 6. Charakter-Erstellen Wizard (CreatorScreen)

**7 Pflicht-Schritte** + optionale Schritte je nach Klasse/Rasse:

| Schritt | Name | Inhalt |
|---|---|---|
| 1 | Klasse | 12 Klassen mit Vollbild-Bild, zentriertem Text, Accordion (Features, Subklassen) |
| 2 | Rasse | 20+ Rassen, viele mit Vollbild-Bild, Unterrassen |
| 3 | Hintergrund | Alle PHB-Hintergründe inkl. Magic-Initiate-Feat |
| 4 | Attribute | Point-Buy oder Würfeln |
| 5 | Fertigkeiten | Klassenspezifische Fertigkeitsauswahl |
| 6 | Zaubertricks | Nur wenn Klasse Cantrips hat; ausklappbar mit Kampf-Details |
| 7 | Name | Charaktername eingeben |

**Optionale Schritte** (werden automatisch eingeschoben):
- `Waffenwahl` — Roboter-Klasse Battle-Sub: 4 Waffen wählen
- `BG-Magie` — Akolyth/Magic-Initiate-Hintergrund: 2 Cantrips + 1 Spell
- `Zauber` — Zauberwirker: 2 Startzauber wählen

**Wizard-Container:** `height: 100dvh` (korrekte Darstellung auf Handy mit Browser-Leiste)
**Footer:** `padding-bottom: env(safe-area-inset-bottom)` für iPhone Home-Bar

---

## 7. Klassen (12)

| ID | Name | Icon | HD | Primary | Caster |
|---|---|---|---|---|---|
| barbarian | Barbar | ⚔️ | W12 | STÄ/KON | ✗ |
| bard | Barde | 🎵 | W8 | CHA | ✓ |
| cleric | Kleriker | ✝️ | W8 | WEI | ✓ |
| druid | Druide | 🌿 | W8 | WEI | ✓ |
| fighter | Kämpfer | 🛡️ | W10 | STÄ/GES | ✗ |
| monk | Mönch | 👊 | W8 | GES/WEI | ✗ |
| paladin | Paladin | ⚜️ | W10 | STÄ/CHA | ✓ (halb) |
| ranger | Waldläufer | 🏹 | W10 | GES/WEI | ✓ (halb) |
| rogue | Schurke | 🗡️ | W8 | GES | ✗ |
| sorcerer | Zauberer | ✨ | W6 | CHA | ✓ |
| warlock | Hexenmeister | 👁️ | W8 | CHA | ✓ |
| wizard | Magier | 📚 | W6 | INT | ✓ |

---

## 8. Rassen (23)

| ID | Name | Bild | Unterrassen |
|---|---|---|---|
| human | Mensch | — | — |
| elf | Elf | — | Hochelf, Waldelfe, Drow |
| dwarf | Zwerg | — | Hügelzwerg, Bergzwerg |
| halfling | Halbling | ✅ Halbling.png | Leichtfuß, Stämmig |
| halfelf | Halbelf | ✅ HalbElfe.png | — |
| halforc | Halbork | ✅ halborc.png | — |
| tiefling | Tiefling | ✅ Tiefling.png | — |
| dragonborn | Drachengeborener | ✅ Drachengeborener.png | Schwarz/Blau/Rot/Grün/Weiß/etc. |
| robot | Roboter | ✅ Roboter.png | Kampf/Unterstützung/Infiltration |
| gnome | Gnom | ✅ Gnom.png | Waldgnom, Felsgnom |
| aarakocra | Aarakocra | ✅ Arakocra.png | — |
| genasi | Genasi | ✅ Genasi.png | Feuer/Wasser/Luft/Erde |
| goliath | Goliath | ✅ Goliath.png | — |
| tabaxi | Tabaxi | ✅ Tabaxi.png | — |
| aasimar | Aasimar | ✅ Asaimar.png | Protector/Scourge/Fallen |
| kenku | Kenku | ✅ Kenku.png | — |
| lizardfolk | Eidechsenmensch | ✅ Eidechsenmensch.png | — |
| triton | Triton | ✅ Triton.png | — |
| firbolg | Firbolg | — | — |
| goblin | Goblin | — | — |
| hobgoblin | Hobgoblin | — | — |
| orc | Vollblut-Ork | — | — |
| kobold | Kobold | — | — |

---

## 9. Hintergründe

PHB-Standard + Magic-Initiate-Varianten:
`Akolyth, Krimineller, Volksheld, Adliger, Weiser, Soldat, Unterhaltungskünstler, Handwerker, Einsiedler, Matrose, Fremdling, Zunftmitglied`

**Magic-Initiate-Feat-Hintergründe:**
- `magicInitCleric` → 2 Kleriker-Cantrips + 1 Kleriker-Spell Grad 1 (WEI)
- `magicInitDruid` → 2 Druiden-Cantrips + 1 Druiden-Spell Grad 1 (WEI)
- `magicInitWizard` → 2 Magier-Cantrips + 1 Magier-Spell Grad 1 (INT)

Diese Zauber erscheinen im **Zauber-Tab** (Sektion "Hintergrund-Zauber · 1× Täglich") und im **Kern-Tab** (Karte "✨ Hintergrund-Zauber"), auch für Nicht-Zauberwirker (z.B. Barbar mit Akolyth).

---

## 10. Bild-System

### Klassen-Bilder (CLASS_IMAGES)
```js
// ~Zeile 2576, vor StepClass
const CLASS_IMAGES = {
  barbarian: imgBarbar,    bard: imgBarde,
  cleric:    imgKleriker,  druid: imgDruide,
  fighter:   imgKaempfer,  monk: imgMoench,
  rogue:     imgSchurke,   wizard: imgMagier,
  sorcerer:  imgZauberer,  ranger: imgWaldlaeufer,
  paladin:   imgPaladin,   warlock: imgHexenmeister,
};
```

### Rassen-Bilder (RACE_IMAGES)
```js
// ~Zeile 2867, vor StepRace
const RACE_IMAGES = {
  halfling:   imgHalbling,      halfelf:    imgHalbElf,
  halforc:    imgHalborc,       tiefling:   imgTiefling,
  dragonborn: imgDrachengeborener, robot:   imgRoboter,
  gnome:      imgGnom,          aarakocra:  imgAarakocra,
  genasi:     imgGenasi,        tabaxi:     imgTabaxi,
  goliath:    imgGoliath,       aasimar:    imgAasimar,
  kenku:      imgKenku,         lizardfolk: imgLizardfolk,
  triton:     imgTriton,
};
```

### Karten-Design (wenn Bild vorhanden)
```jsx
// Karte
style={{ padding:0, border:`2px solid ${isSelected ? acc : 'transparent'}`,
  borderRadius:12, boxShadow: isSelected ? `0 0 12px ${acc}66` : 'none',
  overflow:'hidden', position:'relative', height: IMAGE ? 100 : undefined }}

// Vollbild-Bild (inset:-2 damit es bis zur Border-Kante geht)
<img style={{ position:'absolute', inset:-2,
  width:'calc(100% + 4px)', height:'calc(100% + 4px)',
  objectFit:'cover', objectPosition:'right top' }}/>

// Dunkles Gradient-Overlay
<div style={{ position:'absolute', inset:0,
  background:'linear-gradient(to right, #0a0a18dd 0%, #0a0a1877 45%, transparent 100%)' }}/>

// Text: zentriert, kein Emoji
<div style={{ position:'relative', zIndex:1, height:'100%',
  display:'flex', alignItems:'center', justifyContent:'center', textAlign:'center' }}>
  <div>
    <div style={{fontWeight:700, fontSize:16}}>{name}</div>
    <div style={{fontSize:11, color:MUTED}}>{stats}</div>
  </div>
</div>
```

### Neues Bild hinzufügen
```
1. PNG in public/ ablegen
2. cp public/Name.png src/assets/Name.png
3. import imgName from './src/assets/Name.png'  (oben in dnd-app-v2.jsx, ~Zeile 7–40)
4. CLASS_IMAGES[klassenId] = imgName
   RACE_IMAGES[rassenId]   = imgName
```

---

## 11. Charakter-Avatar

- Feld `sheet.avatar` (String, URL) → wird in localStorage gespeichert
- **Slot-Karte**: 40×40px Thumbnail, `objectPosition: 'top'`, farbiger Border je Klasse
- **Kern-Tab**: Volle Breite (max 180px hoch), `objectPosition: 'center top'`
- Beispiel: `sheet.avatar = '/Barbar.png'` (aus `public/` → kein Import nötig)

---

## 12. Zauber-System

### Zaubertricks (Cantrips)
- `CLASS_CANTRIPS` Map: Cantrip-Pool je Klasse (~Zeile 5628)
- `CANTRIP_COUNT`: `{bard:2, cleric:3, druid:2, sorcerer:4, warlock:2, wizard:3}`
- Im Wizard (StepCantrips): ausklappbar mit **Aktions-Badge + Schaden-Badge + Stat-Block**
- Im Spielbogen: `sheet.learnedCantrips` (Array von Spellnamen)

### Zauber
- `sheet.learnedSpells` (Array von Spellnamen)
- Im Wizard (StepSpells): ausklappbar mit Beschreibung
- Im Zauber-Tab: **SpellCard** mit Reichweite, Schaden, Aktion, Skalierung

### SPELL_COMBAT_DATA (~Zeile 5657)
```js
'Fire Bolt / Feuerpfeil': {
  range:'120ft', dmg:'1W10', type:'Feuer',
  roll:'Angriff', act:'A',
  note:'Lv5:2W10 · Lv11:3W10 · Lv17:4W10'
}
```
Felder: `range`, `dmg`, `type`, `roll` (`'Angriff'` oder Rettungswurf-Attribut), `act` (`'A'`/`'BA'`/`'R'`/`'Rit.'`), `higher`, `note`

### ACT_STYLE_MAP (~Zeile 1065, global)
```js
const ACT_STYLE_MAP = {
  'A':    { label:'Aktion',       bg:'#0d1f35', col:'#5db3f5' },
  'BA':   { label:'Bonus-Aktion', bg:'#2a1400', col:'#f5a623' },
  'R':    { label:'Reaktion',     bg:'#1f0d2a', col:'#c084fc' },
  'Rit.': { label:'Ritual',       bg:'#0d2a1a', col:'#2ecc71' },
  '1Min': { label:'1 Minute',     bg:'#1a1a1a', col:'#888'    },
};
```

### Hintergrund-Zauber (Magic Initiate)
- `sheet.bgCantrips` / `sheet.bgSpells` (Arrays)
- Ability-Zuordnung: `BG_ABILITY_MAP = { magicInitCleric:'WEI', magicInitDruid:'WEI', magicInitWizard:'INT' }`
- Angezeigt in **Zauber-Tab** (eigene Sektionen) + **Kern-Tab** (Karte "✨ Hintergrund-Zauber")
- Deduplizierung: bgCantrips werden aus learnedCantrips rausgefiltert

---

## 13. localStorage Struktur

| Key | Inhalt |
|---|---|
| `dnd5e_v3_slot_0` | Charakter-Slot 0 (JSON) |
| `dnd5e_v3_slot_1` | Charakter-Slot 1 (JSON) |
| `dnd5e_v3_slot_2` | Charakter-Slot 2 (JSON) |
| `dnd5e_unlocked_slots` | Array mit freigeschalteten Slot-Indizes |
| `dnd5e_taverne_gold` | Gold-Münzen (Taverne) |
| `dnd5e_shop_taler` | Taler (Shop) |

### Charakter-Objekt (sheet) — wichtige Felder
```js
{
  name: 'klo',
  cls:  'barbarian',
  race: 'halfling',
  sub:  'lightfoot',
  bg:   'acolyte',
  lv:   1,
  avatar: '/Barbar.png',
  alignment: 'neutral_good',

  // Attribute (Basis-Werte ohne Boni)
  STÄ:10, GES:14, KON:13, INT:8, WEI:12, CHA:10,

  // Kampf
  hp:12, hpMax:12, hpTemp:0,
  deathSaves: { s:0, f:0 },

  // Zauber
  learnedCantrips: ['Fire Bolt / Feuerpfeil'],
  learnedSpells:   ['Magic Missile / Magisches Geschoss'],
  bgCantrips:      ['Sacred Flame / Heilige Flamme'],
  bgSpells:        ['Bless / Segen'],
  spellSlots:     {1:2, 2:0, 3:0, 4:0, 5:0},
  spellSlotsUsed: {1:0, 2:0, 3:0, 4:0, 5:0},

  // Inventar
  inventory: [{name:'Schwert', qty:1, weight:3, notes:''}],
  currency:  {gp:10, sp:5, cp:0, ep:0, pp:0},

  // Fertigkeiten
  proficiencies: ['Athletics', 'Perception'],
  expertise:     [],

  // Sonstiges
  notes: '',
  features: [],
}
```

---

## 14. Farben-System

```js
// Klassen-Farben (COL map, ~Zeile 1230)
barbarian:'#e74c3c', bard:'#9b59b6',    cleric:'#f1c40f',
druid:'#27ae60',     fighter:'#e67e22', monk:'#1abc9c',
paladin:'#d4af37',   ranger:'#2ecc71',  rogue:'#95a5a6',
sorcerer:'#e91e63',  warlock:'#6c3483', wizard:'#2980b9'

// Globale UI-Farben
BG    = '#0a0a18'   // Haupt-Hintergrund (sehr dunkelblau)
BG2   = '#0f0f20'   // Sekundär-Hintergrund
CARD  = '#12122a'   // Karten-Hintergrund
TXT   = '#e8e8f0'   // Haupt-Text
MUTED = '#6a6a8a'   // Gedämpfter Text
```

---

## 15. Löschen-System (SlotScreen)

**Multi-Select mit Bestätigungsdialog:**
1. "🗑️ Charakter löschen" → `deleteMode = true`
2. Beliebig viele Charaktere antippen → werden in `toDelete[]` (Array) gesammelt
3. Statuszeile zeigt: `„Name1", „Name2" markiert`
4. "X Charaktere löschen" klicken → **Bestätigungsdialog** öffnet sich
5. Dialog: zeigt Namen + "✓ Ja, löschen" / "✕ Abbrechen"

---

## 16. Weitere Screens

### ArkaneChroniclesScreen
- Encounter-Manager: Kreaturen hinzufügen, Initiative würfeln, Reihenfolge
- HP-Tracking pro Kreatur, Zustandseffekte
- Monster-Datenbank mit ~100 Einträgen (CR, HP, AC, Aktionen)

### TaverneScreen
- Gold-Shop: Slot 4 für 100 GM, Slot 5 für 150 GM freischalten
- Tavern-Atmosphäre mit Hintergrundbild

### WikiScreen
- D&D 5e Regelreferenz
- Monster-Lexikon, Zauber-Datenbank (~200 Einträge), Feats-Wiki

### SettingsScreen
- Akzentfarbe ändern, alle App-Daten zurücksetzen

---

## 17. Wichtige Hilfsfunktionen

| Funktion | Beschreibung | ca. Zeile |
|---|---|---|
| `finalStats(sheet)` | Attribute + Rassen-Boni + Klassen-Boni berechnen | ~1100 |
| `mod(val)` | Attribut-Modifikator: `Math.floor((val-10)/2)` | ~1050 |
| `profBonus(lv)` | Übungsbonus je Level: 1→+2, 5→+3, 9→+4 etc. | ~1055 |
| `calcAC(sheet)` | Rüstungsklasse nach Klasse/Rüstung berechnen | ~1140 |
| `mToFt(str)` | Meter in Feet umrechnen: "18m" → "60ft" | ~1100 |
| `fmt(n)` | Modifier formatieren: "+3", "-1" | ~1050 |
| `loadSlot(i)` | localStorage Slot laden | ~1221 |
| `saveSlot(i,d)` | localStorage Slot speichern | ~1222 |
| `clearSlot(i)` | localStorage Slot löschen | ~1223 |

---

## 18. Vite-Konfiguration

```js
// vite.config.js
import { viteSingleFile } from 'vite-plugin-singlefile'

export default defineConfig(({ mode }) => ({
  plugins: [
    react(),
    ...(mode === 'single' ? [viteSingleFile()] : []),
  ],
  server: { port: 3000, open: false },
  build: {
    ...(mode === 'single' && {
      assetsInlineLimit: 100_000_000,
      cssCodeSplit: false,
    }),
  },
}))
```

---

## 19. Bekannte Eigenheiten & Technische Details

- `100dvh` statt `100vh` im Wizard → korrekte Darstellung auf iOS/Android (Browser-Leiste)
- `inset:-2px` bei Karten-Bildern → Bild überdeckt auch den Border-Bereich
- `SPELL_COMBAT_DATA` und `ACT_STYLE_MAP` sind **global** (außerhalb aller Funktionen)
- Charakterdaten werden per `useEffect` bei jeder Änderung **auto-gespeichert**
- Der Wizard hat optionale Schritte — `STEPS`-Array wird dynamisch zusammengebaut
- Klassen- und Rassen-Karten **ohne** Bild zeigen weiterhin Emoji + normales Layout
- Selektion wird durch `border: 2px solid acc` + `boxShadow: 0 0 12px acc66` angezeigt (kein Layout-Shift)

---

## 20. Neuen Chat starten — Checkliste

Beim Öffnen eines neuen Chats diese Datei vorlegen:
> "Hier ist die Projektdokumentation (`PROJEKT_STATUS.md`). Bitte lies sie und mache weiter mit [Aufgabe]."

**Wichtig zu wissen:**
- **Alles ist in `dnd-app-v2.jsx`** — eine einzige große Datei (~15.200 Zeilen)
- Dev-Server starten: `npm run dev` im Projektordner `D:\Programmierung\Godot\DNDSheetAPP\`
- Preview-Tool: Launch-Config `dnd-app-v2` (port 3000)
- Neue Bilder: erst in `public/`, dann in `src/assets/` kopieren, dann importieren + in Map eintragen
- Kein TypeScript, kein CSS-Framework, alles Inline-Styles
