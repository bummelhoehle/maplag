# MapLag — Hide & Seek Map

Created with Claude AI.

## Projektübersicht
Single-page HTML/JS App für das JetLag Hide & Seek Spiel. Eine Karte auf der Zonen eingezeichnet werden, die den möglichen Aufenthaltsort des Hiders eingrenzen.

**Live:** https://bummelhoehle.github.io/maplag  
**Repo:** https://github.com/bummelhoehle/maplag.git  
**Hauptdatei:** `index.html` (alles in einer Datei — kein Build-System)

---

## Tech Stack
- **Leaflet 1.9.4** — Karte (OpenStreetMap Tiles)
- **Turf.js 6** — Geometrie (invertierte Kreise für Hit-Zonen)
- **Photon (komoot)** — Geocoding/Suche
- **OpenRailwayMap** — Transit-Layer
- Kein Framework, kein Build-Step, eine HTML-Datei

---

## Architektur

### Zonen-System
Zonen haben zwei Typen:
- **Miss** (`layer._isMiss = true`) — roter Kreis/Polygon, Hider ist NICHT hier
- **Hit** (`layer._isInverted = true`) — invertierter Kreis (Welt minus Kreis), Hider ist NÄHER als dieser Radius
- Kein Union-Code — jede Zone wird direkt mit eigenem Style gerendert

### Haupt-State
```js
const st = {
  mode: 'none' | 'free' | 'circ',
  zones: [{id, lbl, type, layer}],
  // ...
}
```

### Wichtige Funktionen
- `addZone(mkLayer, defaultLabel)` — async, öffnet Label-Modal, fügt Zone hinzu
- `delZone(id)` — entfernt Zone
- `invertedCircleLayer(lat, lng, radiusM, style)` — Hit-Zone via turf.difference
- `drawRadar(hit)` — Radar Hit/Miss zeichnen
- `measDraw(closer)` — Measuring Hit/Miss zeichnen
- `haversine(lat1, lng1, lat2, lng2)` — Distanz in Metern
- `startLocation()` — GPS watchPosition, setzt `locationMarker`

---

## UI-Struktur

### Desktop
```
[Toolbar oben]
[Map] [Sidebar mit Zonenliste]
[Statusbar unten]
```

### Mobile (≤700px)
```
[Map]
[Statusbar]
[Search Bar]
[Toolbar unten — Grid 5 Spalten]
```

### Toolbar-Buttons
- **Draw** (`data-mode="free"`) — Freihand, ergibt Miss-Zone
- **Radar** (`data-mode="circ"`) → öffnet Radar Sheet (Hit/Miss)
- **Thermo** — Thermometer Bottom Sheet
- **Measure** — Measuring Float Panel (links unten)
- **Locate** — Zentriert Karte auf GPS
- **Zones** — Zone-Liste Bottom Sheet
- **Save/Load** — JSON Export/Import
- **Clear** — Alle Zonen löschen

### Leaflet Controls (links oben)
- Zoom +/−
- **km/mi** — Einheitenumschalter
- **🚌** — Transit Layer Toggle

---

## Bottom Sheets
Alle Panels sind `.bottom-sheet` mit `.bottom-sheet.open`:
- `#radar-sheet` — Radar Hit/Miss mit Radius-Input
- `#thermo-panel` — Thermometer (GPS Start/Stop + Wärmer/Kälter)
- `#zone-panel` — Zonenliste
- `#label-modal` — Name einer Zone eingeben
- `#confirm-modal` — Bestätigung zum Löschen

### Measuring Panel
**Kein** Bottom Sheet — `#meas-sheet` ist ein `position:fixed` Float-Panel unten links.  
Nutzt die **Haupt-Suchleiste** (🔍) für Ortsauswahl — wenn Measuring aktiv, ruft Suchergebnis-Klick `measSelectFromSearch(lat, lng, name)` auf.

---

## CSS Design-System

```css
:root {
  --bg: #0a0e13;        /* Hintergrund */
  --bg1: #111820;       /* Toolbar/Sidebar */
  --bg2: #182030;       /* Sheets */
  --bg3: #1e2a3a;       /* Hover-States */
  --border: #1e2d40;
  --border2: #263852;
  --text1: #eaf0f8;
  --text2: #6b8aaa;     /* Sekundär */
  --text3: #3d566e;     /* Hints */
  --red: #e05252;       /* Miss-Zonen */
  --green: #3fbf6e;     /* Hit-Buttons */
  --gold: #e8b84b;      /* Akzent/Logo */
}
```

### Button-Klassen
- `.tb-btn` — Toolbar-Button
- `.tb-btn.active` — Aktiver Modus (gold)
- `.tb-btn.danger` — Rot (Clear)
- `.sh-btn` — Sheet-Button (groß, mit Border)
- `.sh-btn.hit` — Grün
- `.sh-btn.miss` — Rot
- `.sh-btn.ghost` — Transparent

---

## Bekannte Eigenheiten / Gotchas

1. **Safari iOS** — `disabled`-Attribut auf Buttons blockiert Touch-Events → nie `disabled` verwenden, nur `opacity` + State-Check
2. **Leaflet touchstart** — blockiert Sheet-Interaktionen → Check `document.querySelector('.bottom-sheet.open')` am Anfang der Handler
3. **Dynamische Leaflet Controls** — `getElementById('btn-opnv')` funktioniert erst nach `addTo(map)` → `querySelector` oder Event-Delegation nutzen
4. **addZone** — erstellt erst einen Test-Layer (`mkLayer({})`) um `_isMiss`/`_isInverted` zu lesen, dann `map.removeLayer(testLayer)`, dann echten Layer erstellen
5. **Kein Union-Code** — turf.union wurde entfernt weil es mit invertierten Zonen nicht funktioniert hat. Jede Zone wird direkt gerendert.

---

## Datei-Struktur
```
index.html          — Komplette App (CSS + HTML + JS in einer Datei)
CLAUDE.md           — Diese Datei
```

---

## Häufige Aufgaben

**Neue Zone-Art hinzufügen:**
```js
await addZone(s => {
  const l = L.circle([lat, lng], {radius, ...s, color:'#f85149', fillColor:'#f85149'});
  l._isMiss = true; // oder _isInverted = true
  return l;
}, 'Label');
```

**Sheet öffnen/schließen:**
```js
document.getElementById('mein-sheet').classList.add('open');
document.getElementById('mein-sheet').classList.remove('open');
```

**GPS-Standort nutzen:**
```js
if (locationMarker) {
  const ll = locationMarker.getLatLng();
  // ll.lat, ll.lng
}
```
