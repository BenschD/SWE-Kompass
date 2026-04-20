# IEEE 830 SPEZIFIKATION - SWE-Kompass Java-Komponente

**Dokumentversion:** 1.0  
**Datum:** 2026-04-18  
**Gültig für:** Prof. Dr. Bohl / DHBW Stuttgart  
**Status:** FINAL

---

## INHALTSVERZEICHNIS

1. [Einführung](#1-einführung)
2. [Allgemeine Beschreibung](#2-allgemeine-beschreibung)
3. [Spezifische Anforderungen](#3-spezifische-anforderungen)
4. [Architektur und Design](#4-architektur-und-design)
5. [Datenmodelle](#5-datenmodelle)
6. [Schnittstellen (API)](#6-schnittstellen-api)
7. [Algorithmen und Verfahren](#7-algorithmen-und-verfahren)
8. [Qualitätsanforderungen](#8-qualitätsanforderungen)
9. [Testbarkeitsanforderungen](#9-testbarkeitsanforderungen)

---

## 1. EINFÜHRUNG

### 1.1 Zweck
Diese Spezifikation beschreibt die technischen Anforderungen für die Java-Komponente "SWE-Kompass" zur Erfassung und Verarbeitung von Peilungsdaten mit GPS-Tracking. Das Dokument richtet sich an Implementierer und umfasst alle notwendigen Details zur Umsetzung.

### 1.2 Gültigkeitsbereich
- **Komponente:** SWE-Kompass Java-Module
- **Zielplattform:** Java 11+
- **Betriebssysteme:** Windows, Linux, macOS (plattformunabhängig)
- **Integration:** Beliebige Java-Applikationen ohne GUI-Framework-Abhängigkeit

### 1.3 Definitionen und Abkürzungen

| Abkürzung | Bedeutung |
|-----------|-----------|
| **API** | Application Programming Interface |
| **GPS** | Global Positioning System |
| **GPX** | GPS Exchange Format |
| **GNSS** | Global Navigation Satellite System |
| **W3W** | What3Words |
| **DOP** | Dilution of Precision |
| **UML** | Unified Modeling Language |
| **SOLID** | Design-Prinzipien (Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion) |
| **AOP** | Aspect-Oriented Programming |
| **DI** | Dependency Injection |

---

## 2. ALLGEMEINE BESCHREIBUNG

### 2.1 Produktübersicht

Die SWE-Kompass-Komponente ist ein **Library-Modul** (nicht eine Applikation) mit folgenden Kernfunktionalitäten:

```
┌────────────────────────────────────────┐
│    Externe Applikation (mit GUI)       │
└────────────┬─────────────────────────┘
             │ nutzt
             v
┌────────────────────────────────────────┐
│   SWE-Kompass Java-Komponente          │
│  ┌──────────────────────────────────┐  │
│  │ • Bearing Service (Peilung)      │  │
│  │ • GPS Track Recorder             │  │
│  │ • GPX Exporter                   │  │
│  │ • W3W Integration                │  │
│  │ • Optimization Engine            │  │
│  └──────────────────────────────────┘  │
└────────────┬─────────────────────────┘
             │ nutzt externe Services
             v
   ┌─────────────────────────────────┐
   │ • GPS Provider (Mock/Real)      │
   │ • Magnetometer (Mock/Real)      │
   │ • W3W API (Optional)            │
   │ • Filesystem                    │
   └─────────────────────────────────┘
```

### 2.2 Komponenten-Abgrenzung

**Was die Komponente MACHT:**
- ✅ Peilungs-Richtung speichern und aktualisieren
- ✅ GPS-Punkte aufzeichnen und validieren
- ✅ Optimierung redundanter Punkte
- ✅ GPX-Format-Export
- ✅ W3W-Ortsbestimmung (optional)

**Was die Komponente NICHT MACHT:**
- ❌ Navigation / Wegfindung
- ❌ Echtzeit-Kartendarstellung
- ❌ Benutzer-Interface
- ❌ Ständige Hintergrund-Überwachung (On-Demand)

---

## 3. SPEZIFISCHE ANFORDERUNGEN

### 3.1 Funktionale Anforderungen (detailliert)

#### 3.1.1 Peilungs-Initialisierung

**Signatur:**
```java
BearingSession initiateBearing(Position initialPosition, double azimuth)
```

**Parameter:**
- `initialPosition`: Position mit Latitude [-90.0, 90.0], Longitude [-180.0, 180.0], Accuracy [0, ∞)
- `azimuth`: Richtung in Dezimalgrad [0.0, 360.0)

**Validierung:**
- Latitude ∈ [-90.0, 90.0] ✓
- Longitude ∈ [-180.0, 180.0] ✓
- Accuracy >= 0 ✓
- Azimuth ∈ [0.0, 360.0) ✓

**Rückgabe:**
```java
BearingSession {
    sessionId: UUID                 // Eindeutige Session-ID
    startTime: Instant              // Initialisierungszeit (UTC)
    initialPosition: Position       // Kopie der Initialisierungs-Position
    status: BearingStatus           // ACTIVE
}
```

**Fehlerbehandlung:**
- Bei ungültiger Position → `BearingException` mit sprechender Nachricht
- Bei Null-Eingabe → `NullPointerException` (oder Optional-Pattern)

---

#### 3.1.2 Peilungs-Update

**Signatur:**
```java
UpdateResult updateBearing(BearingSession session, Position currentPosition, double newAzimuth)
```

**Verarbeitung:**
1. Validierung der aktuellen Position (wie oben)
2. Validierung des neuen Azimuth [0.0, 360.0)
3. Berechnung der Richtungsänderung (Δazimuth)
4. Speicherung des Datenpunktes im internen Track
5. Update des Session-Zustandsmodells

**Rückgabe:**
```java
UpdateResult {
    success: boolean
    currentAzimuth: double
    compassDirection: String        // "N", "NE", "E", etc.
    pointsRecorded: int            // Anzahl der Punkte im Track
    lastUpdateTime: Instant
}
```

**Azimuth-zu-Kompass-Konvertierung:**
```
0° - 22.5°   → "N" (Nord)
22.5° - 67.5° → "NE" (Nordost)
67.5° - 112.5° → "E" (Ost)
112.5° - 157.5° → "SE" (Südost)
157.5° - 202.5° → "S" (Süd)
202.5° - 247.5° → "SW" (Südwest)
247.5° - 292.5° → "W" (West)
292.5° - 337.5° → "NW" (Nordwest)
337.5° - 360°  → "N" (Nord)
```

---

#### 3.1.3 GPS-Punkt-Speicherung

**Signatur:**
```java
void recordGPSPoint(BearingSession session, GPSPoint point)
```

**Datenstruktur GPSPoint:**
```java
record GPSPoint(
    double latitude,
    double longitude,
    double accuracy,           // Meter
    double? elevation,         // Optional, Meter
    double? speed,            // Optional, m/s
    Instant timestamp
)
```

**Speicherort:** Interner LinkedList (oder ähnliche Struktur) der Session

**Validierungsregeln:**
1. Gültige Koordinaten (s.o.)
2. Accuracy >= 0
3. Ignoration bei Accuracy > 100m (konfigurierbar)
4. Prüfung auf doppelte/sehr ähnliche Punkte (< 1m Abstand)

---

#### 3.1.4 Track-Optimierung

**Signatur (beide Algorithmen):**

```java
// Punkt-basierte Optimierung
OptimizedTrack optimizeByPointCount(BearingSession session, int interval)

// Distanz-basierte Optimierung
OptimizedTrack optimizeByDistance(BearingSession session, double distanceMeters)

// Mit Gerade-Optimierung
OptimizedTrack optimizeWithLineSimplification(
    OptimizedTrack previousResult
)
```

**Algorithmus: POINT_BASED**
```
Input: track (Liste von Punkten), interval N
Output: optimized_track (reduzierte Liste)

optimized = []
for i in range(0, len(track), N):
    optimized.append(track[i])
    
// Sicherstelle, dass letzter Punkt enthalten ist
if len(track) % N != 0:
    optimized.append(track[-1])
    
return optimized
```

**Algorithmus: DISTANCE_BASED**
```
Input: track (Liste mit GPS-Punkten), min_distance_m X
Output: optimized_track

optimized = [track[0]]  // Erster Punkt immer
last_kept = track[0]

for point in track[1:]:
    distance = haversine(last_kept, point)
    if distance >= X:
        optimized.append(point)
        last_kept = point
        
// Letzter Punkt immer
if optimized[-1] != track[-1]:
    optimized.append(track[-1])
    
return optimized
```

**Haversine-Formel (Großkreis-Distanz):**
```
R = 6371000 (Erdradius in Metern)
Δlat = (lat2 - lat1) * π / 180
Δlon = (lon2 - lon1) * π / 180
a = sin²(Δlat/2) + cos(lat1*π/180) * cos(lat2*π/180) * sin²(Δlon/2)
c = 2 * asin(√a)
distance = R * c
```

**Algorithmus: LINE_SIMPLIFICATION (Gerade-Optimierung)**
```
Input: optimized_track (Punkte)
Output: further_optimized_track

result = []
i = 0

while i < len(track):
    if i + 2 < len(track):
        // Prüfe ob nächste 3+ Punkte kollinear sind
        line_points = [track[i]]
        j = i + 1
        
        while j < len(track):
            distance_to_line = pointToLineDistance(
                track[j],
                track[i],
                track[j-1]  // oder letzter Punkt der Line
            )
            
            if distance_to_line < 5.0:  // 5m Toleranz
                line_points.append(track[j])
                j += 1
            else:
                break
        
        if len(line_points) >= 3:
            // Gerade erkannt: nur Start + Ende behalten
            result.append(line_points[0])
            result.append(line_points[-1])
            i = j
        else:
            result.append(track[i])
            i += 1
    else:
        result.append(track[i])
        i += 1

return result
```

**Rückgabe:**
```java
record OptimizedTrack(
    List<GPSPoint> points,
    int originalCount,
    int optimizedCount,
    double reductionPercent,
    OptimizationStats stats
)
```

---

#### 3.1.5 Peilung abschließen

**Signatur:**
```java
BearingResult completeBearing(BearingSession session)
BearingResult abortBearing(BearingSession session)  // Variante für Abbruch
```

**Verarbeitung:**
1. Markiere Session-Status als COMPLETED/ABORTED
2. Finalisiere den GPS-Track (kein weiterer Zugriff)
3. Berechne Summary-Statistiken
4. Optional: Wende ausstehende Optimierung an

**Rückgabe:**
```java
record BearingResult(
    UUID sessionId,
    Instant startTime,
    Instant endTime,
    double finalAzimuth,
    String compassDirection,
    List<GPSPoint> gpxTrack,           // Optimierter Track
    int totalPointsRecorded,
    int totalPointsOptimized,
    double totalDistanceMeters,
    BearingStatus status,              // COMPLETED oder ABORTED
    Map<String, Object> metadata       // Optional: Name, Beschreibung
)
```

**Spezialfall ABORT:**
- Track wird **nicht automatisch** auf Datei gespeichert
- Entwickler kann Daten in-Memory abfragen und optional selbst speichern
- Beispiel-Use-Case: "Nutzer bricht ab → App fragt 'Daten speichern?'"

---

#### 3.1.6 GPX-Export

**Signatur:**
```java
String toBearingResultGPXString(BearingResult result)
void saveBearingResultGPXToFile(BearingResult result, Path filePath)
```

**GPX-Format (XML nach GPX 1.1 Standard):**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" 
     creator="SWE-Kompass Component"
     xmlns="http://www.topografix.com/GPX/1/1"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://www.topografix.com/GPX/1/1 
                         http://www.topografix.com/GPX/1/1/gpx.xsd">
  
  <metadata>
    <name>Bearing Track [UUID]</name>
    <desc>Peilungs-Track erfasst von SWE-Kompass</desc>
    <time>2026-04-18T10:30:45Z</time>
  </metadata>
  
  <trk>
    <name>Track 1</name>
    <trkseg>
      <trkpt lat="48.7758" lon="9.1829">
        <ele>520.5</ele>
        <time>2026-04-18T10:30:50Z</time>
        <extensions>
          <speed>1.5</speed>
          <accuracy>5.2</accuracy>
        </extensions>
      </trkpt>
      <!-- weitere Punkte -->
    </trkseg>
  </trk>
</gpx>
```

**Validierung vor Speicherung:**
- XML Well-formedness prüfen
- Erforderliche GPX-Tags vorhanden
- Koordinaten plausibel
- Dateipath prüfbar (Schreibberechtigung)

---

#### 3.1.7 What3Words (W3W) Integration

**Signatur:**
```java
W3WLocation resolvePosition(Position position, String apiKey)
W3WLocation resolvePosition(double latitude, double longitude, String apiKey)
```

**Interner Ablauf:**
1. Prüfe lokalen W3W-Cache
2. Falls nicht im Cache: REST-Call zu W3W-API
   - Endpoint: `https://api.what3words.com/v3/convert-to-3wa`
   - Parameter: `coordinates`, `apiKey`, `language` (optional)
3. Parse Antwort-JSON
4. Caching für weitere Anfragen

**Rückgabe:**
```java
record W3WLocation(
    String words,              // z.B. "mango.löffel.rot"
    double latitude,           // Validiert
    double longitude,          // Validiert
    String country,            // Ländercode, z.B. "de"
    boolean isValid
)
```

**Fehlerbehandlung bei API-Ausfall:**
- Graceful Degradation: Rückgabe mit `isValid = false`
- Kein Exception für optionale Funktionalität
- Logging des Fehlers
- Fallback zu Koordinaten-Darstellung

**Caching-Strategie:**
- LRU-Cache mit max. 1000 Einträgen
- TTL: 24 Stunden
- Größe: ca. 1-2 KB pro Eintrag

---

### 3.2 Nicht-funktionale Anforderungen

#### 3.2.1 Performance (NF001)

| Metrik | Ziel | Messmethode |
|--------|------|-----------|
| Peilungs-Update | < 100 ms | JMH Benchmark |
| GPS-Punkt speichern | < 50 ms | JUnit Perf-Test |
| Track-Optimierung (10.000 Pkte) | < 5 s | Benchmark |
| Speicherverbrauch pro 1.000 Punkte | < 100 KB | Profiling |
| W3W-Request (mit Cache) | < 500 ms | Integration-Test |

#### 3.2.2 Zuverlässigkeit (NF002)

- **Verfügbarkeit:** 99.9% (keine unkontrollierten Crashes)
- **Datensicherheit:** Keine Datenverluste bei ungültigen Eingaben
- **Fehlertoleranz:** Graceful Degradation bei W3W-Ausfällen
- **Code-Coverage:** >= 85% Unit-Tests (Ziel: 90%+)

#### 3.2.3 Sicherheit (NF003)

- Keine Speicherung von Positionsdaten ohne explizite Anforderung
- GPX-Dateien nur bei Nutzer-Zustimmung speichern
- W3W-API-Key nicht in Code hardcodieren
- Validierung aller externen Eingaben

#### 3.2.4 Wartbarkeit (NF004)

- **Architektur:** Clean Code, SOLID-Prinzipien
- **Dokumentation:** JavaDoc für alle öffentlichen APIs
- **Testbarkeit:** 100% Unit-testbar ohne GUI
- **Erweiterbarkeit:** Design Patterns für Zukünftige Features

---

## 4. ARCHITEKTUR UND DESIGN

### 4.1 Schichtenmodell (Layered Architecture)

```
┌─────────────────────────────────────┐
│   API Layer                         │
│  (Public Interfaces & Facades)      │
├─────────────────────────────────────┤
│   Business Logic Layer              │
│  (Bearing, Track, Optimization)     │
├─────────────────────────────────────┤
│   Data Layer                        │
│  (GPS Repository, Cache)            │
├─────────────────────────────────────┤
│   Integration Layer                 │
│  (W3W API, GPX Writer, Validators)  │
├─────────────────────────────────────┤
│   Infrastructure                    │
│  (Logging, Configuration, Utils)    │
└─────────────────────────────────────┘
```

### 4.2 Klassenkern-Struktur

```
com.swe.kompass
├── api
│   ├── BearingComponent (Interface - Facade)
│   ├── Position (Record/Class)
│   ├── BearingSession (Record/Class)
│   ├── BearingResult (Record/Class)
│   ├── GPSPoint (Record/Class)
│   └── exceptions (Package)
│
├── service
│   ├── BearingService (Implementierung)
│   ├── GPXExportService (Implementierung)
│   ├── TrackOptimizationService (Implementierung)
│   └── W3WIntegrationService (Implementierung)
│
├── domain
│   ├── Azimuth (Value Object)
│   ├── GPSTrack (Entity)
│   ├── OptimizedTrack (Value Object)
│   └── enums/
│       ├── BearingStatus
│       ├── OptimizationMode
│       └── CompassDirection
│
├── repository
│   ├── BearingSessionRepository (Interface)
│   ├── InMemoryBearingRepository (Implementierung)
│   └── GPXFileRepository (Implementierung)
│
├── validator
│   ├── PositionValidator
│   ├── AzimuthValidator
│   ├── GPXValidator
│   └── CoordinateValidator
│
├── algorithm
│   ├── TrackOptimizer
│   ├── LineSimplificationAlgorithm
│   ├── HaversineCalculator
│   └── CompassConverter
│
├── integration
│   ├── W3WClient (Interface)
│   ├── HttpW3WClientImpl (REST-Implementierung)
│   ├── MockW3WClient (für Tests)
│   ├── GPXWriter
│   └── cache/
│       └── W3WCacheProvider
│
├── config
│   ├── BearingComponentConfig (Configuration)
│   ├── DependencyInjectionFactory
│   └── constants/
│       ├── GPXConstants
│       └── GeoConstants
│
├── logging
│   ├── BearingLogger (Wrapper um SLF4J)
│   └── PerformanceMonitor
│
└── test (nur in Test-Quellen!)
    ├── fixture/
    │   ├── PositionFixture
    │   └── GPSPointFixture
    ├── integration/
    └── unit/
```

### 4.3 Design-Muster

| Pattern | Anwendung | Grund |
|---------|-----------|-------|
| **Facade** | `BearingComponent` Interface | Vereinfachte externe API |
| **Factory** | `DependencyInjectionFactory` | Objekt-Erstellung, DI |
| **Observer** | `BearingSessionListener` (optional) | Event-basierte Updates |
| **Strategy** | `TrackOptimizationService` mit Modi | Auswechselbare Algorithmen |
| **Repository** | `BearingSessionRepository` | Data Access Abstraction |
| **Value Object** | `Azimuth`, `GPSPoint` | Immutable, semantische Werte |
| **Entity** | `GPSTrack`, `BearingSession` | Mutable Aggregates mit Identität |
| **Adapter** | `W3WClient` Interface + Implementierungen | Externe API-Integration |
| **Cache** | `W3WCacheProvider` | Performance-Optimierung |

### 4.4 SOLID-Prinzipien

- **S:** Single Responsibility → Jede Klasse hat eine Verantwortung (z.B. nur Validierung)
- **O:** Open/Closed → `TrackOptimizer` für neue Modi erweiterbar
- **L:** Liskov Substitution → Interfaces statt Konkrete Klassen, wo möglich
- **I:** Interface Segregation → Kleine, spezialisierte Interfaces
- **D:** Dependency Inversion → DI-Factory, nicht neue-Keyword überall

---

## 5. DATENMODELLE

### 5.1 UML-Klassendiagramm (Kernklassen)

```
┌────────────────────────────────────────────────────────────┐
│                    BearingComponent                         │
│                     (Interface)                             │
├────────────────────────────────────────────────────────────┤
│ + initiateBearing(Position, double): BearingSession        │
│ + updateBearing(Session, Position, double): UpdateResult   │
│ + completeBearing(Session): BearingResult                  │
│ + exportToGPX(BearingResult): String                       │
│ + saveGPXToFile(BearingResult, Path): void                 │
└────────────────────────────────────────────────────────────┘
                             △
                             │ implements
                             │
┌────────────────────────────────────────────────────────────┐
│                  BearingServiceImpl                          │
├────────────────────────────────────────────────────────────┤
│ - sessionRepository: BearingSessionRepository              │
│ - gpxExporter: GPXExportService                           │
│ - optimizer: TrackOptimizationService                     │
│ - validator: PositionValidator                            │
│ - logger: BearingLogger                                    │
├────────────────────────────────────────────────────────────┤
│ + initiateBearing(Position, double): BearingSession       │
│ + updateBearing(Session, Position, double): UpdateResult  │
│ + completeBearing(Session): BearingResult                 │
│ + exportToGPX(BearingResult): String                      │
│ + saveGPXToFile(BearingResult, Path): void                │
└────────────────────────────────────────────────────────────┘
```

### 5.2 Entity-Relationship Diagramm

```
BearingSession
├── sessionId (UUID)
├── startTime (Instant)
├── currentPosition (Position)
├── currentAzimuth (double)
├── status (BearingStatus)
└── gpxTrack (GPSTrack)

GPSTrack
├── trackId (UUID)
├── points (List<GPSPoint>)
├── createdAt (Instant)
└── optimizationMode (OptimizationMode)

GPSPoint
├── latitude (double)
├── longitude (double)
├── accuracy (double)
├── elevation (Optional<Double>)
├── speed (Optional<Double>)
├── timestamp (Instant)

BearingResult
├── sessionId (UUID)
├── startTime (Instant)
├── endTime (Instant)
├── finalAzimuth (double)
├── gpxTrack (List<GPSPoint>)
├── totalDistanceMeters (double)
└── status (BearingStatus)
```

### 5.3 Enumerations

```java
enum BearingStatus {
    INITIATED,    // Gerade erstellt
    ACTIVE,       // Daten werden erfasst
    COMPLETED,    // Regulär beendet
    ABORTED       // Vorzeitig abgebrochen
}

enum OptimizationMode {
    POINT_BASED,      // Jeder N-te Punkt
    DISTANCE_BASED,   // Alle X Meter
    LINE_SIMPLIFIED   // Mit Gerade-Optimierung
}

enum CompassDirection {
    N("Nord", 0),
    NE("Nordost", 45),
    E("Ost", 90),
    SE("Südost", 135),
    S("Süd", 180),
    SW("Südwest", 225),
    W("West", 270),
    NW("Nordwest", 315)
}
```

---

## 6. SCHNITTSTELLEN (API)

### 6.1 Public API (Hauptschnittstelle für externe Nutzer)

```java
package com.swe.kompass.api;

/**
 * Hauptschnittstelle für die SWE-Kompass-Komponente.
 * Ermöglicht die Erfassung von Peilungen mit GPS-Tracking.
 * 
 * Diese Komponente ist Thread-sicher über Dependency Injection zu nutzen.
 * Wird konfiguriert über {@link BearingComponentConfig}.
 */
public interface BearingComponent {
    
    /**
     * Initiiert eine neue Peilung.
     * 
     * @param initialPosition Die initiale GPS-Position (nicht null)
     * @param azimuth Die initiale Richtung in Grad [0.0, 360.0)
     * @return Neue BearingSession mit eindeutiger ID
     * @throws BearingException Bei ungültigen Parametern
     */
    BearingSession initiateBearing(Position initialPosition, double azimuth);
    
    /**
     * Aktualisiert eine laufende Peilung mit neuen Sensordaten.
     * Speichert automatisch den Datenpunkt im GPS-Track.
     * 
     * @param session Die aktive Peilungs-Session
     * @param currentPosition Die aktuelle GPS-Position
     * @param newAzimuth Die neue Peilungsrichtung in Grad [0.0, 360.0)
     * @return Aktualisierte Peilungs-Informationen
     * @throws BearingException Bei ungültigen Daten oder Session-Fehler
     */
    UpdateResult updateBearing(BearingSession session, 
                              Position currentPosition, 
                              double newAzimuth);
    
    /**
     * Beendet eine Peilung regulär und kompiliert die Ergebnisse.
     * 
     * @param session Die zu beendende Session
     * @return Finalisierte Peilungs-Ergebnisse mit optimiertem Track
     * @throws BearingException Bei Session-Fehler
     */
    BearingResult completeBearing(BearingSession session);
    
    /**
     * Bricht eine Peilung ab, ohne die Daten zu speichern.
     * Daten bleiben in-memory verfügbar.
     * 
     * @param session Die abzubrechende Session
     * @return Ergebnis mit Status ABORTED
     * @throws BearingException Bei Session-Fehler
     */
    BearingResult abortBearing(BearingSession session);
    
    /**
     * Exportiert ein Peilungs-Ergebnis als GPX-XML-String.
     * 
     * @param result Das Peilungs-Ergebnis
     * @return Valid GPX 1.1 XML als String
     * @throws GPXException Bei Export-Fehler
     */
    String exportToGPXString(BearingResult result);
    
    /**
     * Speichert ein Peilungs-Ergebnis als GPX-Datei auf dem Dateisystem.
     * 
     * @param result Das Peilungs-Ergebnis
     * @param filePath Zieldatei-Pfad
     * @throws GPXException Bei Fehler
     * @throws IOException Bei Dateisystem-Fehler
     */
    void saveGPXToFile(BearingResult result, java.nio.file.Path filePath);
    
    /**
     * Optimiert den GPS-Track eines Ergebnisses.
     * 
     * @param result Das Ergebnis mit Original-Track
     * @param mode Optimierungs-Modus (POINT_BASED oder DISTANCE_BASED)
     * @param value Wert (N für Punkte-Intervall, oder Meter für Distanz)
     * @return Ergebnis mit optimiertem Track
     */
    BearingResult optimizeTrack(BearingResult result, 
                                OptimizationMode mode, 
                                double value);
    
    /**
     * Löst eine GPS-Position zu einer What3Words-Adresse auf (optional).
     * Bei API-Fehler wird graceful degradation durchgeführt.
     * 
     * @param position Die zu aufzulösende Position
     * @return What3Words-Information (isValid = false bei Fehler)
     */
    W3WLocation resolvePosition(Position position);
}
```

### 6.2 Record-Definitionen (Datenstrukturen)

```java
// Position mit Koordinaten und Genauigkeit
public record Position(
    double latitude,           // [-90.0, 90.0]
    double longitude,          // [-180.0, 180.0]
    double accuracy,           // >= 0 Meter
    java.util.Optional<Double> elevation  // Optional Höhe
) {
    public static final double MAX_ACCURACY = 100.0;  // Ignorier-Schwelle
    
    public Position {
        if (latitude < -90.0 || latitude > 90.0) {
            throw new IllegalArgumentException("Ungültige Latitude");
        }
        if (longitude < -180.0 || longitude > 180.0) {
            throw new IllegalArgumentException("Ungültige Longitude");
        }
        if (accuracy < 0) {
            throw new IllegalArgumentException("Accuracy darf nicht negativ sein");
        }
    }
}

// GPS-Datenpunkt
public record GPSPoint(
    double latitude,
    double longitude,
    double accuracy,
    java.util.Optional<Double> elevation,
    java.util.Optional<Double> speed,
    java.time.Instant timestamp
) {
    // Validierung analog Position...
}

// Peilungs-Session (Identität für eine Peilung)
public record BearingSession(
    java.util.UUID sessionId,
    java.time.Instant startTime,
    Position initialPosition,
    double initialAzimuth,
    BearingStatus status
) {}

// Update-Ergebnis nach Peilungs-Aktualisierung
public record UpdateResult(
    boolean success,
    double currentAzimuth,
    String compassDirection,  // "N", "NE", etc.
    int pointsRecorded,
    java.time.Instant lastUpdateTime
) {}

// Finales Peilungs-Ergebnis
public record BearingResult(
    java.util.UUID sessionId,
    java.time.Instant startTime,
    java.time.Instant endTime,
    double finalAzimuth,
    String compassDirection,
    java.util.List<GPSPoint> optimizedTrack,
    int totalPointsRecorded,
    int totalPointsOptimized,
    double totalDistanceMeters,
    BearingStatus status,
    java.util.Map<String, Object> metadata
) {}

// What3Words-Auflösung
public record W3WLocation(
    String words,              // "mango.löffel.rot"
    double latitude,
    double longitude,
    String countryCode,        // "de"
    boolean isValid
) {}
```

---

## 7. ALGORITHMEN UND VERFAHREN

### 7.1 Sequenzdiagramm: Normale Peilung

```
Actor: External App
    |
    +---> initiateBearing(position, azimuth)
    |         |
    |         v BearingServiceImpl
    |         | validate(position)
    |         | create BearingSession
    |         | init GPXTrack
    |         v
    |     <-- BearingSession
    |
    +---> updateBearing(session, pos1, azimuth1)
    |         |
    |         v validate(pos1)
    |         | record GPSPoint(pos1)
    |         v
    |     <-- UpdateResult
    |
    +---> updateBearing(session, pos2, azimuth2)
    |         |
    |         v record GPSPoint(pos2)
    |         v
    |     <-- UpdateResult
    |
    +---> completeBearing(session)
    |         |
    |         v optimize(track)
    |         | calculate stats
    |         | finalize
    |         v
    |     <-- BearingResult
    |
    +---> exportToGPXString(result)
    |         |
    |         v GPXExportService.toXML()
    |         | format points
    |         | validate XML
    |         v
    |     <-- GPX-String
    |
    v
```

### 7.2 Pseudocode: Punkt-basierte Optimierung

```pseudocode
function optimizePointBased(track: List<GPSPoint>, interval: int) -> List<GPSPoint>:
    if interval <= 0:
        throw InvalidParameterException("Interval muss > 0 sein")
    
    if track.isEmpty():
        return emptyList()
    
    optimized = []
    
    // Alle Punkte mit Interval abtasten
    for i in range(0, track.length(), interval):
        optimized.add(track[i])
    
    // Sicherstelle, dass letzter Punkt enthalten ist
    if track.length() % interval != 0:
        optimized.add(track[track.length() - 1])
    
    return optimized
end function
```

### 7.3 Pseudocode: Distanz-basierte Optimierung

```pseudocode
function optimizeDistanceBased(track: List<GPSPoint>, minDistanceM: double) -> List<GPSPoint>:
    if minDistanceM <= 0:
        throw InvalidParameterException("Distanz muss > 0 sein")
    
    if track.isEmpty():
        return emptyList()
    
    optimized = [track[0]]  // Erster Punkt immer
    lastKept = track[0]
    
    for point in track[1:]:
        distance = haversineDistance(lastKept, point)
        
        if distance >= minDistanceM:
            optimized.add(point)
            lastKept = point
    
    // Letzter Punkt immer, falls nicht schon enthalten
    if optimized.last() != track.last():
        optimized.add(track.last())
    
    return optimized
end function

function haversineDistance(p1: GPSPoint, p2: GPSPoint) -> double:
    R = 6371000  // Erdradius in Metern
    
    lat1_rad = toRadians(p1.latitude)
    lat2_rad = toRadians(p2.latitude)
    delta_lat = toRadians(p2.latitude - p1.latitude)
    delta_lon = toRadians(p2.longitude - p1.longitude)
    
    a = sin²(delta_lat / 2) + cos(lat1_rad) * cos(lat2_rad) * sin²(delta_lon / 2)
    c = 2 * atan2(√a, √(1-a))
    
    return R * c
end function
```

### 7.4 Pseudocode: Gerade-Optimierung

```pseudocode
function simplifyLines(track: List<GPSPoint>, tolerance: double = 5.0) -> List<GPSPoint>:
    if track.length() < 3:
        return track  // Nicht genug Punkte für Gerade
    
    result = []
    i = 0
    
    while i < track.length():
        if i + 2 < track.length():
            // Versuche, eine Linie zu erkennen
            linePoints = [track[i]]
            j = i + 1
            
            while j < track.length():
                distToLine = pointToLineDistance(
                    track[j],
                    track[i],
                    track[j-1]
                )
                
                if distToLine <= tolerance:
                    linePoints.add(track[j])
                    j = j + 1
                else:
                    break
            
            if linePoints.length() >= 3:
                // Gerade erkannt: nur Start + Ende behalten
                result.add(linePoints[0])
                result.add(linePoints[-1])
                i = j
            else:
                result.add(track[i])
                i = i + 1
        else:
            result.add(track[i])
            i = i + 1
    
    return result
end function

function pointToLineDistance(point, lineStart, lineEnd) -> double:
    // Punkt-zu-Linie-Distanz (2D-Projektion)
    // Vereinfacht: verwendet Euclidean Distance
    // In vollständiger Implementierung: Großkreis-Distanz
    
    x0 = point.latitude
    y0 = point.longitude
    x1 = lineStart.latitude
    y1 = lineStart.longitude
    x2 = lineEnd.latitude
    y2 = lineEnd.longitude
    
    numerator = |((y2-y1)*x0 - (x2-x1)*y0 + x2*y1 - y2*x1)|
    denominator = √((y2-y1)² + (x2-x1)²)
    
    if denominator == 0:
        return distance(point, lineStart)
    
    return numerator / denominator
end function
```

---

## 8. QUALITÄTSANFORDERUNGEN

### 8.1 Code-Qualität

- **Style:** Java Code Conventions (Oracle)
- **Tool:** Checkstyle / SpotBugs für automatische Prüfung
- **Dokumentation:** JavaDoc für alle public APIs
- **Komplexität:** Max. zyklomatische Komplexität = 10 pro Methode

### 8.2 Sicherheit

- Keine Null-Pointer-Exceptions durch Defensive Programmierung
- Input-Validierung an allen Public-Methoden-Grenzen
- Keine Speicherung sensitiver Daten (z.B. in Strings)
- API-Keys extern konfigurieren, nie hardcoden

### 8.3 Skalierbarkeit

- Track mit bis zu 100.000 Punkten speicherbar
- Speicher-Footprint: < 1 MB für 10.000 Punkte
- Batch-Optimierung parallelisierbar (Future Enhancement)

---

## 9. TESTBARKEITSANFORDERUNGEN

### 9.1 Unit-Testing

**Framework:** JUnit 5  
**Coverage:** >= 85% Ziel (90%+)  
**Assertion-Library:** AssertJ (bessere Lesbarkeit)

**Test-Struktur:**
```
src/test/java/com/swe/kompass
├── api/
│   └── BearingComponentTest
├── service/
│   ├── BearingServiceTest
│   ├── GPXExportServiceTest
│   ├── TrackOptimizationServiceTest
│   └── W3WIntegrationServiceTest
├── validator/
│   ├── PositionValidatorTest
│   ├── AzimuthValidatorTest
│   └── CoordinateValidatorTest
├── algorithm/
│   ├── TrackOptimizerTest
│   ├── LineSimplificationAlgorithmTest
│   ├── HaversineCalculatorTest
│   └── CompassConverterTest
├── integration/
│   ├── W3WClientTest (mit Mock-API)
│   └── GPXWriterTest
└── fixture/
    ├── PositionFixture
    └── GPSPointFixture
```

**Test-Muster (beispielhafte Unit-Test):**
```java
@DisplayName("BearingService Peilungs-Tests")
class BearingServiceTest {
    
    private BearingService service;
    private PositionValidator positionValidator;
    
    @BeforeEach
    void setUp() {
        positionValidator = new PositionValidator();
        service = new BearingService(positionValidator);
    }
    
    @Test
    @DisplayName("Initialisierung mit gültiger Position")
    void testInitiateBearing_ValidInput() {
        // Arrange
        Position pos = new Position(48.7758, 9.1829, 5.0, Optional.empty());
        double azimuth = 45.0;
        
        // Act
        BearingSession session = service.initiateBearing(pos, azimuth);
        
        // Assert
        assertThat(session)
            .isNotNull()
            .extracting(BearingSession::status)
            .isEqualTo(BearingStatus.ACTIVE);
        
        assertThat(session.sessionId()).isNotNull();
        assertThat(session.startTime()).isNotNull();
    }
    
    @Test
    @DisplayName("Initialisierung mit ungültiger Latitude sollte Exception werfen")
    void testInitiateBearing_InvalidLatitude() {
        // Arrange
        Position pos = new Position(91.0, 9.1829, 5.0, Optional.empty());
        
        // Act & Assert
        assertThatThrownBy(() -> service.initiateBearing(pos, 45.0))
            .isInstanceOf(BearingException.class)
            .hasMessageContaining("Latitude");
    }
}
```

### 9.2 Integrationstests

**Szenario 1: Komplette Peilung**
```java
@Test
void testCompleteBeringScenario() {
    // Initiate
    BearingSession session = service.initiateBearing(startPos, 0.0);
    
    // Update mehrfach
    service.updateBearing(session, pos1, 45.0);
    service.updateBearing(session, pos2, 90.0);
    service.updateBearing(session, pos3, 180.0);
    
    // Complete
    BearingResult result = service.completeBearing(session);
    
    // Assertions
    assert result.status() == BearingStatus.COMPLETED;
    assert result.optimizedTrack().size() > 0;
    assert result.totalDistanceMeters() > 0;
}
```

**Szenario 2: Abbruch mit Daten-Rückgabe**
```java
@Test
void testAbortBearing_DataAvailable() {
    // Initiate & Update
    BearingSession session = service.initiateBearing(startPos, 0.0);
    service.updateBearing(session, pos1, 45.0);
    service.updateBearing(session, pos2, 90.0);
    
    // Abort
    BearingResult result = service.abortBearing(session);
    
    // Assertions
    assert result.status() == BearingStatus.ABORTED;
    assert result.optimizedTrack().size() == 2;  // Zwei Punkte erfasst
    
    // Datenspeicherung muss noch von der App erfolgen
    // (Component speichert nicht automatisch)
}
```

**Szenario 3: GPX-Export und -Speicherung**
```java
@Test
void testGPXExport_ValidFile() {
    BearingResult result = createSampleBearingResult();
    
    // Export als String
    String gpxString = service.exportToGPXString(result);
    assert gpxString.contains("<?xml");
    assert gpxString.contains("<gpx");
    assert gpxString.contains("<trkpt");
    
    // Export als Datei
    Path tmpFile = Files.createTempFile("test_", ".gpx");
    service.saveGPXToFile(result, tmpFile);
    
    // Datei-Validierung
    String content = Files.readString(tmpFile);
    assert content.contains("<gpx");
    Files.deleteIfExists(tmpFile);
}
```

### 9.3 Performance-Tests (JMH Benchmarks)

```java
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MILLISECONDS)
@Fork(1)
@Warmup(iterations = 3)
@Measurement(iterations = 5)
public class BearingServiceBenchmarks {
    
    @Benchmark
    public UpdateResult benchmarkUpdate(BearingServiceState state) {
        return state.service.updateBearing(
            state.session,
            new Position(48.776, 9.183, 5.0, Optional.empty()),
            Math.random() * 360
        );
    }
    
    @Benchmark
    public OptimizedTrack benchmarkOptimization(OptimizationState state) {
        return state.optimizer.optimizeByDistance(state.track, 50.0);
    }
}
```

### 9.4 Mock-Objekte und Test-Doubles

```java
// Mock W3W-Client für Tests
class MockW3WClient implements W3WClient {
    @Override
    public W3WLocation resolve(Position position, String apiKey) {
        // Deterministische Test-Antworten
        return new W3WLocation(
            "test.mock.location",
            position.latitude(),
            position.longitude(),
            "de",
            true
        );
    }
}

// Test-Fixtures für häufig verwendete Objekte
class PositionFixture {
    public static Position validStuttgart() {
        return new Position(48.7758, 9.1829, 5.0, Optional.of(500.0));
    }
    
    public static Position validMunich() {
        return new Position(48.1351, 11.5820, 5.0, Optional.empty());
    }
}
```

---

## FAZIT

Diese IEEE 830 Spezifikation beschreibt die vollständige technische Anforderung für die SWE-Kompass Java-Komponente. Die Implementierung muss sich streng an diese Vorgaben halten, insbesondere:

✓ Alle definierten APIs implementieren  
✓ Validierung und Fehlerbehandlung beachten  
✓ Design-Muster und SOLID-Prinzipien einhalten  
✓ Unit-Tests mit >= 85% Coverage schreiben  
✓ Keine UI, vollständig testbar  
✓ W3W optional, aber integrierbar  
✓ Systemneutrale Java-Implementierung (Java 11+)

---

**IEEE 830 Spezifikation v1.0** | Für Prof. Dr. Bohl | Verbindlich für Implementierung
