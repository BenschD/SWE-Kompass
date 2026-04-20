# ANFORDERUNGSANALYSE - SWE-Kompass Java-Komponente

## 1. EINLEITUNG

### 1.1 Hintergrund
Basierend auf der Analyse der iOS-App "Kompass Professional" (https://apps.apple.com/de/app/kompass-professional/id1289069674) soll eine Java-Komponente zur Erfassung von Peilungsdaten mit GPS-Tracking entwickelt werden.

### 1.2 Ziele
- Erfassung von Peilungsrichtungen (Peilungen)
- Aufzeichnung von GPS-Tracks während der Peilung
- Export der Tracks im GPX-Format
- Vollständige Testbarkeit ohne graphische Benutzeroberfläche
- Integration in beliebige Java-Applikationen

### 1.3 Umfang
Die Anforderungsanalyse behandelt die Funktionalitäten der Kompass-App zur **Peilung** (Richtungsmessung), nicht zur Navigation.

---

## 2. ANFORDERUNGSERMITTLUNG (SOFIST-REGELN)

### 2.1 Struktur der Anforderungen

Alle Anforderungen folgen den **SOFIST-Regeln** für präzise, unverzweideutige Formulierung:

#### Regel 1: SPEZIFIK (Konkretheit)
- Anforderungen beschreiben **konkrete Funktionalitäten**, nicht abstrakte Ziele
- Messbare Kriterien statt vager Aussagen

#### Regel 2: OBSERVIERBAR/OBJEKTIVIERBAR
- Anforderungen sind **überprüfbar und testbar**
- Klare Erfolgskriterien definiert

#### Regel 3: FÄHIGKEITEN/FUNKTIONALITÄT
- Anforderungen beschreiben **Was die Komponente tut**, nicht wie

#### Regel 4: INDIVIDUELL
- Keine redundanten oder widersprechenden Anforderungen
- Jede Anforderung steht isoliert

#### Regel 5: REALISIERBAR
- Anforderungen sind **mit verfügbaren Mitteln umsetzbar**
- Technisch und zeitlich machbar

#### Regel 6: TESTBAR
- Jede Anforderung muss **ohne GUI testbar** sein
- Klare Akzeptanzkriterien

---

## 3. OBJEKT-ORIENTIERTE ANFORDERUNGSANALYSE

### 3.1 Aktivitätsdiagramm: Peilungs-Prozess

```
START
  |
  v
[Peilung initialisieren]
  | (Position, Höhe, Sensor-Daten)
  v
[GPS-Track starten]
  |
  +---> [Aktuelle Peilung erfassen] <-----+
  |     (Azimuth, Elevation, Beschleunigung) |
  |                                          |
  +---> [GPS-Punkt aufzeichnen] <-----------+
  |     (Koordinaten, Zeitstempel, Genauigkeit) |
  |                                          |
  +---> [Punkt optimieren?] -------->+
        (Gerade/Kurven-Optimierung)  |
                                     |
        [Position aktualisieren] <---+
        |
        v
   [Peilung beendet?]
        | JA
        v
   [GPS-Track kompilieren]
   (Format: GPX Standard)
        |
        v
   [Rückgabe:]
   - Aktuelle Peilung
   - GPS-Track (In-Memory)
   - Status
        |
        v
   [Export möglich?]
        | JA
        v
   [Datei speichern (Optional)]
        |
        v
   ENDE
```

### 3.2 Kontextabgrenzung

```
┌─────────────────────────────────────┐
│   Externe Systeme / Schnittstellen  │
├─────────────────────────────────────┤
│  - GPS/GNSS (Position)              │
│  - Kompass/Magnetometer (Azimuth)   │
│  - Höhenmesser (Elevation)          │
│  - Accelerometer (Bewegungsdaten)   │
│  - W3W API (What3Words)             │
│  - Dateisystem (GPX Export)         │
└──────────────┬──────────────────────┘
               │
        ┌──────v──────┐
        │  Komponente │
        │  (Java)     │
        └──────┬──────┘
               │
        ┌──────v──────────────────┐
        │  Externe Applikation    │
        │  (nutzt Komponente)     │
        └─────────────────────────┘
```

### 3.3 Stakeholder-Anforderungen

| Stakeholder | Anforderung | Priorität |
|------------|-------------|-----------|
| Benutzer | Peilung erfassen, GPS-Track aufzeichnen | MUST |
| Benutzer | Konfigurierbare Optimierung (jeder N. Punkt / alle X Meter) | MUST |
| Benutzer | GPX-Export und Speicherung | MUST |
| Entwickler | Komponente ohne UI testbar | MUST |
| Entwickler | Integration in beliebige Java-App | MUST |
| Integrator | W3W-Integration möglich | SHOULD |
| Integrator | Abbruch mit Daten-Rückgabe (ohne Speicherung) | SHOULD |
| Betreiber | Systemneutrale Implementierung | MUST |

---

## 4. FUNKTIONALE ANFORDERUNGEN

### 4.1 F001: Peilung initialisieren

**Beschreibung:** Die Komponente akzeptiert initiale Positionsdaten und Sensordaten zur Initialisierung einer Peilung.

**Eingaben:**
- GPS-Koordinaten (Breitengrad, Längengrad mit Genauigkeit)
- Höhe über Meeresspiegel (Meter)
- Initialer Azimuth/Kompass-Richtung (Grad, 0-360)
- Elevation/Neigungswinkel (optional, Grad)

**Verarbeitung:**
- Validierung aller Eingabedaten auf Plausibilität
- Initialisierung des internen Zustandsmodells
- Start des GPS-Tracking-Kanals

**Ausgaben:**
- Peilungs-Instanz mit eindeutiger Session-ID
- Initialisierungsstatus (SUCCESS/ERROR)
- Fehlertext bei Validierungsfehlern

**SOFIST-Kriterien:** ✓ Spezifik (konkrete Eingaben), ✓ Objektiv (validierbar), ✓ Testbar (Unit-Test)

---

### 4.2 F002: Peilung aktualisieren (kontinuierlich)

**Beschreibung:** Die Komponente aktualisiert laufend die Peilungsinformationen basierend auf aktuellen Sensordaten.

**Eingaben:**
- Aktuelle GPS-Koordinaten
- Aktueller Azimuth (Kompass-Richtung)
- Elevation (optional)
- Zeitstempel (optional, sonst aktuell)

**Verarbeitung:**
- Validierung der neuen Daten
- Berechnung der Richtungsänderung
- Aktualisierung der Peilungs-Richtung (Pfeil-Richtung)
- Speicherung des Datenpunktes im GPS-Track (vor Optimierung)

**Ausgaben:**
- Aktualisierte Peilungs-Azimuth (Grad, 0-360)
- Richtungsindikator (Kompass-Richtung: N, NE, E, etc.)
- Aktualisierungsstatus

**SOFIST-Kriterien:** ✓ Realisierbar (kontinuierliches Update), ✓ Testbar (Mock-Sensoren)

---

### 4.3 F003: GPS-Track aufzeichnen

**Beschreibung:** Während einer Peilung werden GPS-Datenpunkte automatisch in einem Track aufgezeichnet.

**Eingaben:**
- GPS-Koordinaten
- Zeitstempel
- Höhe
- Genauigkeit (DOP-Wert)
- Geschwindigkeit (optional)

**Verarbeitung:**
- Speicherung des Datenpunktes im internen Track-Buffer
- Anwendung von Plausibilitätsprüfungen
  - Ablehnung ungültiger Koordinaten (außerhalb [-90,90] Breite, [-180,180] Länge)
  - Ignorieren stark abweichender Punkte (z.B. Genauigkeit > 100m)
- Laufende Speicherung (In-Memory)

**Ausgaben:**
- Bestätigung der Speicherung (true/false)
- Anzahl bislang aufgezeichneter Punkte
- Speicher-Status

**SOFIST-Kriterien:** ✓ Observierbar (Punkt-Zähler), ✓ Individuell (unabhängig von F004)

---

### 4.4 F004: GPS-Track optimieren

**Beschreibung:** Redundante Punkte werden entfernt, um die Dateigröße zu optimieren, ohne die Track-Qualität zu beeinträchtigen.

**Eingaben:**
- Optimierungs-Modus: "POINT_BASED" oder "DISTANCE_BASED"
- Bei POINT_BASED: N (jeder N-te Punkt wird beibehalten)
- Bei DISTANCE_BASED: X (nur Punkte mit min. Abstand X Meter)
- Optional: Gerade-Optimierung aktivieren (boolean)

**Verarbeitung:**

**Modus POINT_BASED:**
- Behalte jeden N-ten Punkt des gesamten Tracks
- Beispiel: N=10 → Punkte 0, 10, 20, 30, ... beibehalten
- Anfang und Ende immer beibehalten

**Modus DISTANCE_BASED:**
- Iteriere durch Punkte
- Berechne Haversine-Distanz zwischen aufeinanderfolgenden Punkten
- Behalte Punkt nur wenn Distanz >= X Meter zur letzten akzeptierten Punkt
- Anfang und Ende immer beibehalten

**Gerade-Optimierung (optional, beide Modi):**
- Erkenne Geradensequenzen (3+ Punkte in einer Linie, Abweichung < 5m)
- Reduziere auf Start- und Endpunkt der Geraden
- Anwendbar auf aufgezeichnete Punkte NACH normaler Optimierung
- Beispiel: 100 Punkte in einer Linie → 2 Punkte

**Ausgaben:**
- Optimierter GPS-Track
- Statistik: Original-Punktzahl, optimierte Punktzahl, Reduktion %
- Validierungsstatus

**SOFIST-Kriterien:** ✓ Fähigkeiten (Was wird optimiert), ✓ Realisierbar, ✓ Testbar (Mock-Daten)

---

### 4.5 F005: Peilung beenden

**Beschreibung:** Die Komponente beendet eine Peilung und vergibt die aufgezeichneten Daten.

**Eingaben:**
- Peilungs-Session-ID
- Optional: Abbruch-Flag (bei vorzeitigem Abbruch)

**Verarbeitung:**
- Finalisierung des GPS-Tracks
- Anwendung aller ausstehenden Optimierungen (falls nicht bereits angewendet)
- Erstellung der Peilungs-Zusammenfassung
- Zustand auf "COMPLETED" oder "ABORTED" setzen

**Ausgaben:**
- Finalisierte Peilungs-Daten:
  - Finale Richtung (Azimuth)
  - Kompass-Richtung (N/NE/E/SE/...)
  - GPS-Track (optimiert)
  - Zeitstempel Start/Ende
  - Statistiken (Anzahl Punkte, Distanz, etc.)
- Status (SUCCESS/ERROR)

**Spezialfall ABBRUCH:**
- Datenpunkte werden intern gehalten
- Rückgabe ermöglicht, aber KEIN Dateispeicherung
- Entwickler können Daten in-Memory verarbeiten

**SOFIST-Kriterien:** ✓ Spezifik (klarer Abbruch-Pfad), ✓ Testbar

---

### 4.6 F006: GPX-Export durchführen

**Beschreibung:** Der erfasste GPS-Track wird in das GPX-Format exportiert (als String oder Datei).

**Eingaben:**
- Peilungs-Session-Daten (mit optimiertem Track)
- Exportformat: "STRING" oder "FILE"
- Dateipath (bei "FILE")
- Optionale Metadaten (Name, Beschreibung)

**Verarbeitung:**
- Konvertierung des GPS-Tracks in GPX-XML-Format
- GPX-Header mit Metainformationen
- Track-Segmente mit Wegpunkten (trkpt)
  - Latitude, Longitude
  - Elevation (wenn verfügbar)
  - Zeitstempel (ISO 8601: YYYY-MM-DDTHH:MM:SSZ)
  - Nach GPX 1.1 Standard
- Validierung des XML gegen GPX-Schema (Basic-Check)
- Bei "FILE": Speicherung mit UTF-8 Encoding

**Ausgaben:**
- GPX-String (bei STRING)
- Dateipfad (bei FILE)
- Speicher-/Konvertierungsstatus
- Fehler-Details bei Fehlschlag

**SOFIST-Kriterien:** ✓ Realisierbar (Standard-Format), ✓ Testbar (Datei-Vergleich)

---

### 4.7 F007: What3Words (W3W) Integration

**Beschreibung:** Optionale Integration von What3Words zur Ortsbestimmung.

**Eingaben:**
- GPS-Koordinaten
- W3W-API-Key (extern konfigurierbar)
- Optional: Sprache (z.B. "de" für Deutsch)

**Verarbeitung:**
- Koordinaten zu W3W-Adresse konvertieren (via REST-API)
- Caching von Anfragen zur Performance-Optimierung
- Fehlerbehandlung bei API-Ausfällen (graceful degradation)

**Ausgaben:**
- W3W-Adresse (z.B. "///mango.löffel.rot")
- Länderkürzel
- Koordinatenvalidität
- Status (OK/ERROR)

**SOFIST-Kriterien:** ✓ Fähigkeiten (optionale Integration), ✓ Testbar (Mock-API)

---

## 5. NICHT-FUNKTIONALE ANFORDERUNGEN

### 5.1 Performance (NF001)

**Anforderung:** Peilungs-Updates mit minimaler Latenz
- Response-Zeit für Peilungs-Update: < 100 ms
- GPS-Track-Speicherung: < 50 ms pro Punkt
- Optimierung für 10.000 Punkte: < 5 Sekunden
- Speicherverbrauch: max. 100 KB pro 1.000 GPS-Punkte

**Messung:** Durch Benchmark-Tests, profiling mit JProfiler

---

### 5.2 Zuverlässigkeit (NF002)

**Anforderung:** Hohe Verfügbarkeit und Fehlertoleranz
- Keine Datenverluste bei ungültigen Eingaben (Validierung statt Exception)
- Graceful Degradation bei W3W-API-Fehlern
- Recovery von korrupten Zwischendaten
- Testbarkeit: >85% Code-Coverage (Ziel: >90%)

---

### 5.3 Usability (NF003)

**Anforderung:** Benutzerfreundliche Konfiguration
- Einfache API für Konfiguration von Optimierungs-Parametern
- Aussagekräftige Fehlermeldungen
- Konsistente Datentypen (Grad statt Radiant, etc.)

---

### 5.4 Kompatibilität (NF004)

**Anforderung:** System- und plattformunabhängigkeit
- Java 11+ Kompatibilität (kein Platform-spezifischer Code)
- Unabhängig vom Betriebssystem (Windows, Linux, macOS)
- Keine Abhängigkeiten zu GUI-Frameworks
- Externe Abhängigkeiten: nur Standard-Libs (JSON, XML)

---

### 5.5 Wartbarkeit (NF005)

**Anforderung:** Code-Qualität und Dokumentation
- SWE-Regeln einhalten: SOLID, Design Patterns, klare Architektur
- Inline-Dokumentation nach JavaDoc-Standard
- Unit-Tests für alle kritischen Komponenten
- Konfigurierbare Logging-Level

---

## 6. EINGABE-/AUSGABE-SPEZIFIKATION

### 6.1 Datentypen

```
Position:
  - Latitude: double [-90.0, 90.0]
  - Longitude: double [-180.0, 180.0]
  - Accuracy: double [0.0, ∞) Meter

Azimuth (Kompass-Richtung):
  - Wert: double [0.0, 360.0) Grad
  - 0° = Norden, 90° = Osten, 180° = Süden, 270° = Westen
  - Konvertierung zu Kompass: N, NE, E, SE, S, SW, W, NW

Elevation (Höhe):
  - Wert: double [beliebig] Meter über Meeresspiegel

Zeitstempel:
  - Format: ISO 8601 (YYYY-MM-DDTHH:MM:SSZ)
  - Intern: System.currentTimeMillis() oder Instant.now()

GPS-Punkt:
  - Latitude, Longitude, Elevation (optional)
  - Accuracy (optional)
  - Zeitstempel
  - Speed (optional, m/s)

Optimierungs-Parameter:
  - Modus: Enum {POINT_BASED, DISTANCE_BASED}
  - Wert: int (N-Punkte) oder double (X Meter)
  - Gerade-Optimierung: boolean
```

---

## 7. FEHLERBEHANDLUNG

| Fehler | Verhalten | Rückgabe |
|--------|-----------|----------|
| Ungültige Koordinaten (Lat > 90) | Ignorieren/Warnen | false, error-code |
| Negative Genauigkeit | Validierung fehlschlag | exception mit Nachricht |
| W3W-API nicht erreichbar | Graceful degradation | null mit Status |
| Dateispeicherung fehlgeschlagen | Exception + Logging | error-status |
| Ungültige Optimierungs-Parameter | Fallback zu Defaults | Warnung + Standard-Modus |

---

## 8. INTEGRATIONSVORGABEN

### 8.1 Schnittstellen-Sicht

```java
// Externe Applikation nutzt Komponente:
public interface BearingComponent {
    // Peilung starten
    BearingSession initiateBearing(Position initialPos, double azimuth);
    
    // Peilung aktualisieren
    void updateBearing(BearingSession session, Position current, double newAzimuth);
    
    // Peilung beenden
    BearingResult completeBearing(BearingSession session);
    
    // GPX exportieren
    String exportToGPX(BearingResult result);
    void saveGPXToFile(BearingResult result, Path filePath);
}
```

### 8.2 Externe Abhängigkeiten

- **GPS-Daten:** Provider-unabhängig (Mock-implementierbar)
- **Magnetometer-Daten:** Provider-unabhängig
- **W3W-API:** Optional, über Dependency Injection
- **Dateisystem:** Standard Java NIO

---

## 9. CONSTRAINTS UND RAHMENBEDINGUNGEN

1. **Sprachliche Vereinbarungen:**
   - Interne Winkeldarstellung: Dezimalgrad (0-360)
   - Export: ISO 8601 für Zeitstempel
   - Dokumentation und Code-Kommentare: Deutsch (Anforderungsanalyse) / Englisch (Code)

2. **Datenschutz & Sicherheit:**
   - Keine Speicherung von Positionsdaten ohne Nutzer-Zustimmung
   - Lokale GPX-Speicherung nur auf explizite Anforderung
   - Keine Transmission von Daten über Netzwerk (lokal)

3. **Technische Constraints:**
   - Keine externe Abhängigkeit zu Google, Apple Maps etc.
   - Optional W3W-Integration über externe API
   - Keine Echtzeit-Navigation

---

## 10. ABNAHMEKRITERIEN

| Kriterium | Akzeptanz |
|-----------|-----------|
| Alle MUST-Anforderungen implementiert | ja/nein |
| Code-Coverage >= 85% | ja/nein |
| Alle Unit-Tests bestanden | ja/nein |
| Integrationstests für E2E-Szenarien | ja/nein |
| Spezifikation mit implementiertem Code übereinstimmend | ja/nein |
| W3W optional, aber integrierbar | ja/nein |
| GPX-Datei valid nach Standard | ja/nein |
| Komponente in Test-Applikation erfolgreich integriert | ja/nein |

---

## 11. GLOSSAR

| Begriff | Definition |
|---------|-----------|
| **Peilung** | Richtungsmessung zu einem Ziel; wird durch Azimuth (Grad) dargestellt; nicht navigierend |
| **Azimuth** | Kompass-Richtung in Dezimalgrad (0-360) von Norden im Uhrzeigersinn |
| **GPS-Track** | Sequenz von aufgezeichneten GPS-Datenpunkten mit Zeit und Koordinaten |
| **GPX** | GPS Exchange Format; XML-basiertes Standard-Format für Geodaten |
| **What3Words (W3W)** | System zur Identifikation geografischer Lokationen durch 3-Wort-Adressen |
| **Elevation** | Höhe über Meeresspiegel in Metern |
| **DOP** | Dilution of Precision; Maß für GPS-Genauigkeit |
| **Haversine** | Formel zur Berechnung von Großkreis-Distanzen zwischen zwei Punkten |
| **Gerade-Optimierung** | Reduktion kollinearer Punkte auf Start- und Endpunkt |

---

## 12. ÄNDERUNGSVERLAUF

| Datum | Version | Änderung | Autor |
|-------|---------|----------|-------|
| 2026-04-18 | 1.0 | Initial Release | SWE-Kompass Team |

---

**Anforderungsanalyse v1.0** | Für Prof. Dr. Bohl | Systemneutrale Spezifikation
