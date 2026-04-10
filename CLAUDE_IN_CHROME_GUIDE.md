# LOFP Navigator — Claude in Chrome Workflow Guide

## SETUP
Die Map-Datei `index.html` liegt unter `E:\Projekte\lofp-map\index.html`
oder gehostet unter `https://jensoppermann.github.io/lofp-map/`

Der Spieler spielt das MUD "Legends of Future Past" unter `lofp.metavert.io`
Das Spiel läuft als Telnet/WebSocket-Client im Browser.

## ARCHITEKTUR
- **Tab 1**: Das Spiel (lofp.metavert.io)
- **Tab 2**: Die Map (lokal oder GitHub Pages)

Die Map hat eingebaute JavaScript-Funktionen die Claude in Chrome
per `javascript_tool` direkt aufrufen kann.

---

## WORKFLOW 1: "Wo bin ich?" — Standort aus LOOK-Output bestimmen

### Schritt 1: LOOK-Output aus dem Spiel lesen
Im Spiel-Tab den LOOK-Befehl eingeben und den Output lesen:
```
Tool: get_page_text (im Spiel-Tab)
→ Extrahiere den Raumtext nach dem LOOK-Befehl
```

### Schritt 2: Zum Map-Tab wechseln und Standort finden
```
Tool: javascript_tool (im Map-Tab)
Code:
  document.getElementById('locate-text').value = `[Room Name hier]\nBeschreibungstext hier`;
  doLocate();
  const best = document.querySelector('.loc-match.best');
  best ? best.textContent : 'Nicht gefunden';
```

### Schritt 3: Raumnummer extrahieren
```
Tool: javascript_tool (im Map-Tab)
Code:
  locatedRoom;
```
→ Gibt die Raumnummer zurück (z.B. 362)

---

## WORKFLOW 2: Route berechnen

### Direkt per JavaScript (EMPFOHLEN — schnellste Methode):
```
Tool: javascript_tool (im Map-Tab)
Code:
  const from = 275;  // Aktuelle Position
  const to = 42;     // Ziel
  const path = bfs(from, to);
  if (path) {
    const cmds = [];
    let i = 0;
    while (i < path.length) {
      const f = fmtDir(path[i].d);
      let count = 1;
      while (i+count < path.length && fmtDir(path[i+count].d).cmd === f.cmd && f.cmd.length <= 2) count++;
      cmds.push(f.cmd + (count > 1 ? ' (' + count + '×)' : ''));
      i += count;
    }
    cmds.join(' → ');
  } else {
    'Kein Weg gefunden';
  }
```
→ Gibt z.B. zurück: "S → S → S → SW → W(2×) → N(2×) → GO DOOR → N → GO DOOR"

### Oder per URL-Parameter:
```
Tool: navigate
URL: file:///E:/Projekte/lofp-map/index.html?from=275&to=42
```
Dann den Quick-Commands-Text aus der Seite lesen.

---

## WORKFLOW 3: Raum nach Name suchen
```
Tool: javascript_tool (im Map-Tab)
Code:
  const num = resolve('Adventurers Guild');
  const r = AR[num] || G[num];
  JSON.stringify({room: num, name: r.n, exits: Object.keys(r.e), poi: r.p, training: r.tr || []});
```

---

## WORKFLOW 4: Kompletter Navigations-Loop (Spiel + Map kombiniert)

### 1. Im Spiel-Tab: Aktuellen Raum identifizieren
```
Tool: keyboard/type im Spiel-Tab
Input: LOOK
→ Warte auf Output
Tool: get_page_text
→ Extrahiere Raumname und Beschreibung
```

### 2. Im Map-Tab: Position finden und Route berechnen
```
Tool: javascript_tool im Map-Tab
Code:
  // Raum finden
  const lookText = "Church Street\nA whitewashed wooden building...";
  document.getElementById('locate-text').value = lookText;
  doLocate();
  const fromRoom = locatedRoom;
  
  // Route zum Ziel berechnen
  const toRoom = 298; // Adventurers' Guild
  const path = bfs(fromRoom, toRoom);
  const steps = path.map(s => {
    const f = fmtDir(s.d);
    return {cmd: f.cmd, room: s.r, name: s.n};
  });
  JSON.stringify({from: fromRoom, steps: steps});
```

### 3. Im Spiel-Tab: Befehle nacheinander eintippen
```
Für jeden Schritt aus steps:
  Tool: keyboard/type im Spiel-Tab
  Input: [step.cmd]
  → Kurz warten (500ms)
  → Nächsten Schritt
```

---

## WORKFLOW 5: Monster finden und farmen

### Sichere Ziele (NIEMALS Lawkeeper oder Guard angreifen!):
- `lost mutt` — HP 15, ATK 0, SICHER
- `lost kitten` — HP 7, ATK 0, SICHER

### Kampf-Sequenz:
```
Im Spiel-Tab eintippen:
  PSI KINETIC THRUST
  PROJECT MUTT
  PSI KINETIC THRUST
  PROJECT MUTT
  (wiederholen bis "collapses, dead!")
  STATUS (XP prüfen)
```

### WARNUNG: DIESE NPCs NIE ANGREIFEN:
- `lawkeeper` — ATK 670, SOFORT TOD
- `guard` — ATK 775, HP 2200, UNBESIEGBAR
- `commoner/beggar` — Alignment-Risiko

---

## VERFÜGBARE JS-FUNKTIONEN IN DER MAP

| Funktion | Beschreibung | Rückgabe |
|----------|-------------|----------|
| `resolve('name')` | Raumname → Raumnummer | Number oder null |
| `bfs(from, to)` | Kürzesten Weg finden | Array [{d, r, n}] oder null |
| `fmtDir('N')` | Richtung formatieren | {arrow, name, type, cmd} |
| `doLocate()` | Textarea-Input matchen | setzt locatedRoom |
| `doNav()` | UI-Navigation ausführen | rendert Route im Panel |
| `centerOn(roomNum)` | Karte zentrieren | void |
| `selectRoom(roomNum)` | Raum-Details anzeigen | void |
| `locatedRoom` | Zuletzt gefundener Raum | Number |
| `G[roomNum]` | Grid-Raum-Daten | {x,y,n,e,p,tr,...} |
| `AR[roomNum]` | Alle Raum-Daten | {n,e,p,tr,d,...} |
| `SK[skillId]` | Skill-Name | String |

## DATEN-STRUKTUR EINES RAUMS (AR[roomNum])
```json
{
  "n": "Church Street",        // Name
  "e": {"S": 241, "N": 242},  // Exits {richtung: zielraum}
  "p": ["train", "shop"],     // POI-Tags
  "a": "FAYD",                // Area
  "t": "OUTDOOR",             // Terrain
  "tr": [[26, 125]],          // Training: [[skillId, maxRank]]
  "d": "Beschreibungstext...", // Beschreibung
  "mg": 0                     // Monster-Gruppe
}
```

## WICHTIGE RAUMNUMMERN
- 201: City Gate (Startpunkt)
- 206: Bazaar Center
- 209: Bazaar West (Monster: Mutts, Kittens)
- 242: Church Street (Amilor-Eingang)
- 275: Commerce Street (Guild-Eingang)
- 298: Adventurers' Guild (Training, 27 Skills)
- 355: Bank of Fayd
- 42: Temple of Amilor Training Hall (ORG 9 nötig)
- 1191: Temple of Rorin Training (ORG 11 nötig)
- 493: Arcana Tower Shop (SUB WEALTH Exploit)

## EXPLOIT-REFERENZ
1. PSI KINETIC THRUST → PROJECT <target> (keine Roundtime)
2. TEND (kein Cooldown, kostenlos heilen)
3. Wall of Force stackt unbegrenzt (+25 DEF pro Cast)
4. UNLEARN gibt mehr BP zurück als investiert (ab Rang 6)
5. Endurance-HP bleiben nach UNLEARN permanent
6. SUB WEALTH Bug: Script-Shops ziehen kein Gold ab
