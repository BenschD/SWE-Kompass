# JAVA-Peilungs-Komponente: Vollständige Projektdokumentation
## Projektübersicht und Zielsetzung

**Projekttitel:** JAVA-Peilungs-Komponente mit GPS-Track-Aufzeichnung  
**Basis:** iOS Kompass Professional App  
**Ziel:** Überführung der Peilungs-Funktionalitäten in eine UI-unabhängige JAVA-Komponente

---

## 1. PROJEKTABLAUFPLAN

### Phase 1: Anforderungsanalyse und Klärung (Woche 1-2)
- ✅ Klärung offener Fragen
- ✅ Analyse der iOS Kompass App
- ✅ Stakeholder-Identifikation
- ✅ Dokumentation der Ist-Anforderungen

### Phase 2: Spezifikation (Woche 2-4)
- ✅ Erstellung der Anforderungsspezifikation nach IEEE 830
- ✅ UML-Modellierung (Use Cases, Klassendiagramme, Sequenzdiagramme)
- ✅ Schnittstellendefinition
- ✅ Datenmodellierung

### Phase 3: Grobentwurf (Woche 4-5)
- ✅ Architekturmuster-Definition
- ✅ Komponentendesign
- ✅ Schichtenarchitektur
- ✅ Festlegung der Entwurfsmuster

### Phase 4: Feinentwurf (Woche 5-6)
- ✅ Detaillierte Klassenmodellierung
- ✅ Algorithmen-Design
- ✅ Exception-Handling-Konzept
- ✅ Logging-Strategie

### Phase 5: Implementierung (Woche 6-9)
- ✅ Modulweise Implementierung
- ✅ Unit-Tests parallel
- ✅ Code Reviews
- ✅ Refactoring

### Phase 6: Test und Qualitätssicherung (Woche 9-10)
- ✅ Integrationstests
- ✅ Systemtests
- ✅ Performance-Tests
- ✅ Dokumentation finalisieren

---

## 2. KLÄRUNG DER VORBEREITUNGSFRAGEN

### 2.1 Was genau ist mit "Peilung" gemeint?

**Definition:** Eine Peilung bezeichnet die Bestimmung der Richtung (Azimut/Kurswinkel) von einem Standpunkt zu einem Zielpunkt. Im Kontext der Kompass-App:

1. **Richtungspeilung:** Bestimmung des Azimuts (0°-360°) vom aktuellen Standort zum Zielpunkt
2. **Distanzberechnung:** Berechnung der Entfernung zwischen Start- und Zielpunkt
3. **Tracking während Bewegung:** Kontinuierliche Aktualisierung der Peilung während der Bewegung
4. **Speicherung des Pfades:** Aufzeichnung aller GPS-Punkte während der Peilung

**Funktionale Anforderungen:**
- Berechnung des Azimuts (magnetisch und geografisch)
- Berechnung der Großkreis-Distanz (Haversine-Formel)
- Kurskorrektur bei Bewegung
- Abweichungsberechnung vom Zielpunkt

### 2.2 Welcher GPX-Standard soll verwendet werden?

**Entscheidung:** GPX 1.1 (Topografix)

**Begründung:**
- Weit verbreiteter Standard
- Unterstützung durch alle gängigen GPS-Anwendungen
- XML-basiert, einfach zu parsen und generieren
- Umfassende Unterstützung für Tracks, Waypoints und Metadaten

**Schema-URL:** http://www.topografix.com/GPX/1/1

### 2.3 Welche Daten sollen aufgezeichnet werden?

**Pflichtdaten pro Trackpoint:**
- **Koordinaten:** Latitude, Longitude (WGS84)
- **Zeitstempel:** ISO 8601 Format (UTC)
- **Höhe:** Elevation in Metern

**Optionale Daten:**
- **Genauigkeit:** HDOP (Horizontal Dilution of Precision)
- **Geschwindigkeit:** Speed in m/s
- **Kurs:** Course (0-360°)
- **Anzahl Satelliten:** Number of satellites

**Metadaten (Track-Level):**
- Peilungs-Start-Zeit
- Peilungs-Ende-Zeit
- Start-Koordinaten
- Ziel-Koordinaten
- Gesamtdistanz

### 2.4 Zeitintervall für GPS-Aufzeichnung

**Standard-Intervall:** 2 Sekunden (0.5 Hz)

**Konfigurierbare Optionen:**
- **Eco-Modus:** 5 Sekunden (0.2 Hz) - Batterieschonend
- **Standard:** 2 Sekunden (0.5 Hz) - Ausgewogen
- **Präzise:** 1 Sekunde (1 Hz) - Hohe Genauigkeit
- **Ultra-Präzise:** 0.5 Sekunden (2 Hz) - Sehr hohe Genauigkeit

**Adaptive Aufzeichnung:**
- Bei Stillstand: Reduzierung auf 10 Sekunden
- Bei hoher Geschwindigkeit: Erhöhung auf 0.5 Sekunden

### 2.5 Anforderungen an die Genauigkeit

**GPS-Genauigkeit:**
- **Mindestanforderung:** ±10 Meter horizontal
- **Empfohlen:** ±5 Meter horizontal
- **Höhengenauigkeit:** ±15 Meter

**Azimut-Berechnung:**
- **Genauigkeit:** ±1° bei Distanzen > 10m
- **Magnetische Deklination:** Automatische Korrektur basierend auf Position

**Distanzberechnung:**
- **Genauigkeit:** ±0.1% (Haversine-Formel)

**Qualitätskriterien:**
- Verwerfung von GPS-Punkten mit HDOP > 5.0
- Mindestens 4 Satelliten erforderlich
- Filtering von GPS-Spikes (Kalman-Filter)

### 2.6 Performance-Anforderungen

**Echtzeitfähigkeit:**
- Aktualisierung der Peilung: < 100ms
- GPS-Punkt-Verarbeitung: < 50ms
- Speicherung in GPX: Asynchron, max. 500ms

**Speicher:**
- Max. RAM-Verbrauch: 50 MB
- Max. Anzahl Track-Punkte im Speicher: 10.000
- Bei Überschreitung: Automatisches Flushing in Datei

**CPU:**
- Max. CPU-Last im Idle: < 5%
- Max. CPU-Last bei aktiver Peilung: < 20%

**Latenz:**
- Startzeit der Komponente: < 1 Sekunde
- Antwortzeit für Peilungsberechnung: < 50ms

### 2.7 Umgang mit ungültigen Koordinaten

**Validierungsregeln:**
1. **Latitude:** -90° ≤ lat ≤ 90°
2. **Longitude:** -180° ≤ lon ≤ 180°
3. **Elevation:** -500m ≤ ele ≤ 9000m (Mount Everest)
4. **Zeitstempel:** Nicht in der Zukunft

**Fehlerbehandlung:**
- **Ungültige Koordinaten:** Logging + Verwerfung des Datenpunkts
- **GPS-Signal verloren:** Markierung im Track (GPS Signal Lost)
- **Zu große Abweichung:** Outlier-Detection (>50m/s Geschwindigkeit)
- **Inkonsistente Zeitstempel:** Interpolation oder Verwerfung

**Strategien:**
- **Last Known Good Position:** Verwendung der letzten gültigen Position
- **Interpolation:** Bei kurzen Signalverlusten (< 10 Sekunden)
- **Gap-Markierung:** Bei längeren Ausfällen (> 10 Sekunden)

### 2.8 Speicherort der GPX-Datei

**Standard-Speicherort (Konfigurierbar):**
- **Default:** `./gps-tracks/`
- **Namenskonvention:** `bearing_YYYYMMDD_HHmmss.gpx`

**Konfigurationsmöglichkeiten:**
```java
GpxConfiguration config = new GpxConfiguration.Builder()
    .setOutputDirectory("./custom/path/")
    .setFileNamePattern("track_{date}_{time}.gpx")
    .setAutoSave(true)
    .build();
```

**Anforderungen:**
- Verzeichnis muss existieren oder wird automatisch erstellt
- Schreibrechte erforderlich
- Atomare Schreiboperationen (Temp-Datei + Rename)
- Optional: Kompression (gzip)

### 2.9 Schnittstellen zur App

**Primäre Schnittstelle: Java API**

```java
// Hauptschnittstelle
public interface BearingComponent {
    // Peilung starten
    void startBearing(GeoCoordinate target);
    
    // Aktuelle Position aktualisieren
    void updateCurrentPosition(GeoCoordinate position);
    
    // Peilung stoppen und GPX speichern
    GpxFile stopBearing();
    
    // Aktuelle Peilungsinformationen abrufen
    BearingInfo getCurrentBearing();
    
    // Event-Listener registrieren
    void addBearingListener(BearingListener listener);
}
```

**Datenklassen:**
```java
public class GeoCoordinate {
    private double latitude;
    private double longitude;
    private double elevation;
    private Instant timestamp;
    private double accuracy;
}

public class BearingInfo {
    private double azimuth;          // 0-360°
    private double distance;         // in Metern
    private double deviation;        // Abweichung vom Kurs
    private GeoCoordinate current;
    private GeoCoordinate target;
}
```

**Event-Callbacks:**
```java
public interface BearingListener {
    void onBearingUpdate(BearingInfo info);
    void onGpsPointRecorded(GeoCoordinate point);
    void onTargetReached(double finalDistance);
    void onGpsSignalLost();
    void onGpsSignalRestored();
}
```

**Export-Schnittstelle:**
- GPX-Datei als Primary Output
- Optional: JSON-Export für weitere Verarbeitung
- Optional: KML-Export für Google Earth

### 2.10 Umfang der Dokumentation

**Anforderungsanalyse:** 8-12 Seiten
- Stakeholder-Analyse (1 Seite)
- Use Cases (2-3 Seiten)
- Funktionale Anforderungen (3-4 Seiten)
- Nicht-funktionale Anforderungen (2-3 Seiten)

**Spezifikation (IEEE 830):** 25-35 Seiten
- Einführung (2-3 Seiten)
- Systemübersicht (3-4 Seiten)
- Funktionale Anforderungen (10-15 Seiten)
- Schnittstellen (5-7 Seiten)
- Nicht-funktionale Anforderungen (5-6 Seiten)

**Design-Dokumentation:** 20-25 Seiten
- Architektur (5-6 Seiten)
- UML-Diagramme (8-10 Seiten)
- Entwurfsmuster (4-5 Seiten)
- Datenmodell (3-4 Seiten)

**Implementierungsdokumentation:** 10-15 Seiten
- Modulbeschreibung (5-7 Seiten)
- Algorithmen (3-4 Seiten)
- Test-Strategie (2-4 Seiten)

**Gesamtumfang:** ~65-85 Seiten

### 2.11 Größenlimit für GPX-Dateien

**Soft-Limit:** 10.000 Track-Punkte pro GPX-Datei
**Hard-Limit:** 50.000 Track-Punkte

**Strategien bei Überschreitung:**
1. **Auto-Split:** Automatische Aufteilung in mehrere Dateien
2. **Compression:** Reduzierung redundanter Punkte (Douglas-Peucker)
3. **Warning:** Log-Eintrag bei Annäherung an Limit

**Berechnung:**
- Durchschnittliche Dateigröße: ~200-300 Bytes pro Track-Punkt
- 10.000 Punkte ≈ 2-3 MB
- 50.000 Punkte ≈ 10-15 MB

### 2.12 Modulare Architektur

**Hauptmodule:**

1. **Core Module:** `bearing-core`
   - Peilungsberechnung
   - Koordinatentransformation
   - Mathematische Funktionen

2. **GPS Tracking Module:** `gps-tracker`
   - GPS-Punkt-Aufzeichnung
   - Qualitätsfilterung
   - Track-Management

3. **GPX Export Module:** `gpx-exporter`
   - GPX-Generierung
   - Serialisierung
   - Validierung

4. **Data Model Module:** `data-model`
   - Koordinaten
   - Track-Daten
   - Konfiguration

5. **Utility Module:** `bearing-utils`
   - Kalman-Filter
   - Geodätische Berechnungen
   - Logging

**Abhängigkeiten:**
```
bearing-core → data-model, bearing-utils
gps-tracker → data-model, bearing-utils
gpx-exporter → data-model
```

### 2.13 Test-Strategie

**Ja, jedes Modul erhält eigene Tests:**

**Unit-Tests (pro Modul):**
- `BearingCoreTest` → Peilungsberechnungen
- `GpsTrackerTest` → GPS-Aufzeichnung
- `GpxExporterTest` → GPX-Generierung
- `CoordinateTest` → Datenmodell-Validierung
- `GeoUtilsTest` → Mathematische Funktionen

**Integration-Tests:**
- `BearingComponentIntegrationTest` → End-to-End
- `GpxExportIntegrationTest` → Vollständiger Export

**Test-Coverage-Ziel:** ≥ 80%

**Test-Framework:** JUnit 5 + Mockito

### 2.14 Abbruchverhalten

**Szenario: Nutzer bricht Peilung ab**

**Verhalten:**
1. **Sofortiges Stoppen** der GPS-Aufzeichnung
2. **Speicherung** des bisherigen Tracks als GPX
3. **Metadaten-Markierung:** `<status>ABORTED</status>`
4. **Event-Notification:** `onBearingAborted(BearingInfo lastInfo)`

**Datensicherung:**
- Alle bisher aufgezeichneten Punkte werden gespeichert
- Dateiname-Suffix: `_aborted`
- Beispiel: `bearing_20260416_143022_aborted.gpx`

**Cleanup:**
- Freigabe von Ressourcen
- Logging des Abbruchs
- Reset des internen States

### 2.15 API-Verwendung

**Empfohlene APIs/Libraries:**

1. **What3Words (Optional):**
   - Für benutzerfreundliche Ziel-Eingabe
   - Integration über what3words Java API
   - Nicht verpflichtend

2. **Geodätische Berechnungen:**
   - GeographicLib (für präzise Berechnungen)
   - Apache Commons Math (Kalman-Filter)

3. **XML-Verarbeitung (GPX):**
   - JAXB für XML-Binding
   - Standard Java XML APIs

4. **Logging:**
   - SLF4J + Logback

5. **Testing:**
   - JUnit 5
   - Mockito
   - AssertJ

**Keine externen GPS-APIs:**
- GPS-Daten werden durch die integrierende Anwendung geliefert
- Keine direkte Hardware-Anbindung

### 2.16 Optimierungen für Note 1+

**Performance-Optimierungen:**
1. **Kalman-Filter** für GPS-Glättung
2. **Douglas-Peucker-Algorithmus** für Track-Vereinfachung
3. **Async I/O** für GPX-Speicherung
4. **Memory-Pooling** für Track-Punkte

**Erweiterte Features:**
1. **Multi-Target-Peilung:** Mehrere Ziele gleichzeitig
2. **Geo-Fencing:** Benachrichtigung bei Erreichen eines Radius
3. **Route-Prediction:** Voraussage des Ankunftszeitpunkts
4. **Höhenprofil-Analyse:** Steigung/Gefälle-Berechnung
5. **Export-Formate:** KML, GeoJSON zusätzlich zu GPX
6. **Track-Statistiken:** Durchschnittsgeschwindigkeit, max. Geschwindigkeit, Gesamtdistanz
7. **Waypoint-Management:** Zwischenziele setzen
8. **Offline-Karten-Integration:** Vorbereitung für Tile-Download

**Design-Patterns (zusätzlich):**
1. **Strategy Pattern** für verschiedene Distanzberechnungen
2. **Factory Pattern** für GPS-Filter-Erstellung
3. **Builder Pattern** für komplexe Konfigurationen
4. **Composite Pattern** für Multi-Track-Verwaltung
5. **Chain of Responsibility** für GPS-Validierung

**Code Quality:**
1. **Clean Code Principles** durchgängig
2. **SOLID Principles** angewendet
3. **JavaDoc** vollständig
4. **Checkstyle/PMD** erfüllt
5. **Code Coverage** > 90%

---

## 3. ANFORDERUNGSANALYSE

### 3.1 Stakeholder-Analyse

**Primäre Stakeholder:**
1. **Entwickler:** Integration in bestehende Anwendungen
2. **Endnutzer:** Indirekt über integrierende Apps
3. **Projekt-Betreuer (Herr Bohl):** Bewertung

**Sekundäre Stakeholder:**
1. **Wartungsteam:** Zukünftige Pflege
2. **Qualitätssicherung:** Testing

### 3.2 Use Cases

#### UC-01: Peilung starten
**Akteur:** Integrierende Anwendung  
**Vorbedingung:** Komponente initialisiert, Zielkoordinate vorhanden  
**Nachbedingung:** Peilung aktiv, GPS-Aufzeichnung läuft  
**Hauptszenario:**
1. Anwendung ruft `startBearing(target)` auf
2. System validiert Zielkoordinate
3. System initialisiert GPS-Tracker
4. System beginnt Aufzeichnung
5. System berechnet initiale Peilung
6. System notifiziert Listener

**Alternative Szenarien:**
- A1: Ungültige Zielkoordinate → Exception werfen
- A2: Peilung bereits aktiv → Warnung, alte Peilung stoppen

#### UC-02: Position aktualisieren
**Akteur:** Integrierende Anwendung  
**Vorbedingung:** Peilung aktiv  
**Nachbedingung:** Neue Peilung berechnet, GPS-Punkt gespeichert  
**Hauptszenario:**
1. Anwendung liefert neue Position
2. System validiert Position
3. System speichert GPS-Punkt
4. System berechnet neue Peilung
5. System prüft Zielannäherung
6. System notifiziert Listener

#### UC-03: Peilung beenden
**Akteur:** Integrierende Anwendung  
**Vorbedingung:** Peilung aktiv  
**Nachbedingung:** GPX-Datei gespeichert, Ressourcen freigegeben  
**Hauptszenario:**
1. Anwendung ruft `stopBearing()` auf
2. System stoppt GPS-Aufzeichnung
3. System generiert GPX-Datei
4. System validiert GPX
5. System speichert Datei
6. System gibt Ressourcen frei
7. System gibt GPX-Objekt zurück

#### UC-04: Peilung abbrechen
**Akteur:** Integrierende Anwendung  
**Vorbedingung:** Peilung aktiv  
**Nachbedingung:** Teiltrack gespeichert, Status = ABORTED  
**Hauptszenario:**
1. Anwendung ruft `abortBearing()` auf
2. System markiert Status als ABORTED
3. System generiert GPX mit Abbruch-Marker
4. System speichert Datei mit "_aborted" Suffix
5. System notifiziert Listener über Abbruch

### 3.3 Funktionale Anforderungen

**FA-01: Peilungsberechnung**
- Das System muss den Azimut (0-360°) vom Startpunkt zum Zielpunkt berechnen
- Das System muss die Großkreis-Distanz nach Haversine-Formel berechnen
- Das System muss die Kursabweichung kontinuierlich aktualisieren

**FA-02: GPS-Tracking**
- Das System muss GPS-Punkte mit konfigurierbarem Intervall aufzeichnen
- Das System muss ungültige GPS-Punkte filtern (HDOP > 5.0)
- Das System muss GPS-Spikes erkennen und entfernen

**FA-03: GPX-Export**
- Das System muss GPX 1.1 Standard einhalten
- Das System muss Tracks mit Metadaten speichern
- Das System muss GPX-Dateien validieren

**FA-04: Konfiguration**
- Das System muss Tracking-Intervall konfigurierbar machen
- Das System muss Ausgabeverzeichnis konfigurierbar machen
- Das System muss Genauigkeitsanforderungen konfigurierbar machen

**FA-05: Event-System**
- Das System muss Events bei Peilungsupdates auslösen
- Das System muss Events bei GPS-Signal-Verlust auslösen
- Das System muss Events bei Zielannäherung auslösen

### 3.4 Nicht-funktionale Anforderungen

**NFA-01: Performance**
- Peilungsberechnung < 50ms
- GPS-Punkt-Verarbeitung < 100ms
- Max. RAM: 50 MB

**NFA-02: Portabilität**
- Lauffähig auf JVM 11+
- Plattformunabhängig (Windows, Linux, macOS)
- Keine nativen Abhängigkeiten

**NFA-03: Wartbarkeit**
- Modulare Architektur
- Umfassende JavaDoc
- Unit-Test-Coverage ≥ 80%

**NFA-04: Zuverlässigkeit**
- Keine Datenverluste bei Abstürzen
- Atomare Datei-Operationen
- Graceful Degradation bei GPS-Verlust

**NFA-05: Usability (für Entwickler)**
- Intuitive API
- Klare Exception-Hierarchie
- Umfangreiche Beispiele

---

## 4. SPEZIFIKATION NACH IEEE 830

### 4.1 Einführung

#### 4.1.1 Zweck
Dieses Dokument spezifiziert die Anforderungen an eine Java-Komponente zur Peilung mit GPS-Tracking. Die Komponente überführt Funktionalitäten der iOS Kompass Professional App in eine UI-unabhängige, wiederverwendbare Java-Bibliothek.

#### 4.1.2 Gültigkeitsbereich
Die Spezifikation gilt für:
- **Produktname:** JAVA Bearing Component
- **Version:** 1.0
- **Module:** bearing-core, gps-tracker, gpx-exporter, data-model, bearing-utils

#### 4.1.3 Definitionen und Abkürzungen

**Begriffe:**
- **Peilung:** Richtungsbestimmung vom aktuellen Standort zum Zielpunkt
- **Azimut:** Horizontalwinkel (0-360°) von Nord aus gemessen
- **Track:** Sequenz von GPS-Punkten
- **Waypoint:** Einzelner GPS-Punkt mit Metadaten
- **HDOP:** Horizontal Dilution of Precision (GPS-Genauigkeitsmaß)

**Abkürzungen:**
- GPX: GPS Exchange Format
- WGS84: World Geodetic System 1984
- UTC: Coordinated Universal Time
- API: Application Programming Interface

#### 4.1.4 Referenzen
- IEEE 830-1998: Recommended Practice for Software Requirements Specifications
- GPX 1.1 Schema: http://www.topografix.com/GPX/1/1
- ISO 6709: Geographic Point Location
- WGS84: NIMA TR8350.2

#### 4.1.5 Übersicht
Kapitel 2 beschreibt das Gesamtsystem und seine Umgebung.  
Kapitel 3 definiert detaillierte funktionale Anforderungen.  
Kapitel 4 spezifiziert Schnittstellen.  
Kapitel 5 behandelt nicht-funktionale Anforderungen.

### 4.2 Systemübersicht

#### 4.2.1 Produktperspektive
Die Komponente ist eine eigenständige Java-Bibliothek ohne UI. Sie wird in bestehende Anwendungen integriert und erhält GPS-Daten von der Host-Anwendung.

**Systemkontext:**
```
┌─────────────────────────────────────┐
│   Integrierende Anwendung (UI)      │
│   - GPS-Sensor-Zugriff              │
│   - Benutzereingaben                │
│   - Visualisierung                  │
└──────────────┬──────────────────────┘
               │ API Calls
               ▼
┌─────────────────────────────────────┐
│   JAVA Bearing Component            │
│   - Peilungsberechnung              │
│   - GPS-Tracking                    │
│   - GPX-Export                      │
└──────────────┬──────────────────────┘
               │ File I/O
               ▼
┌─────────────────────────────────────┐
│   Dateisystem                       │
│   - GPX-Dateien                     │
│   - Logs                            │
└─────────────────────────────────────┘
```

#### 4.2.2 Produktfunktionen
1. Berechnung von Azimut und Distanz zu Zielpunkten
2. Kontinuierliche GPS-Punkt-Aufzeichnung
3. Erzeugung von GPX 1.1-konformen Track-Dateien
4. Event-basierte Benachrichtigungen
5. Konfigurierbare Parameter

#### 4.2.3 Benutzercharakteristika
**Zielgruppe:** Java-Entwickler mit Erfahrung in:
- Java SE 11+
- GPS/Geodäsie-Grundlagen
- Event-Driven Programming

**Keine Zielgruppe:** Endanwender (nur indirekt)

#### 4.2.4 Einschränkungen
- Keine direkte Hardware-Anbindung (GPS-Receiver)
- Keine UI-Komponenten
- Keine Kartendarstellung
- Keine Netzwerkfunktionalität (außer optionale APIs)

#### 4.2.5 Annahmen und Abhängigkeiten
**Annahmen:**
- Host-Anwendung liefert valide GPS-Daten
- Schreibrechte im konfigurierten Ausgabeverzeichnis
- JVM 11+ verfügbar

**Abhängigkeiten:**
- SLF4J für Logging
- JAXB für XML-Processing
- (Optional) GeographicLib für erweiterte Berechnungen

### 4.3 Detaillierte Anforderungen

#### 4.3.1 Externe Schnittstellen

**4.3.1.1 Hauptschnittstelle: BearingComponent**

```java
/**
 * Hauptschnittstelle der Peilungs-Komponente.
 * Thread-safe für gleichzeitige Lesezugriffe.
 */
public interface BearingComponent {
    
    /**
     * Startet eine neue Peilung zum angegebenen Ziel.
     * 
     * @param target Zielkoordinate
     * @param config Konfiguration für diese Peilung
     * @throws IllegalStateException wenn bereits eine Peilung aktiv ist
     * @throws IllegalArgumentException wenn target ungültig ist
     */
    void startBearing(GeoCoordinate target, BearingConfig config);
    
    /**
     * Aktualisiert die aktuelle Position.
     * 
     * @param position Neue GPS-Position
     * @throws IllegalStateException wenn keine Peilung aktiv ist
     * @throws IllegalArgumentException wenn position ungültig ist
     */
    void updatePosition(GeoCoordinate position);
    
    /**
     * Beendet die aktive Peilung und speichert den Track.
     * 
     * @return GPX-Datei-Objekt mit gespeichertem Pfad
     * @throws IllegalStateException wenn keine Peilung aktiv ist
     * @throws IOException wenn Speicherung fehlschlägt
     */
    GpxFile stopBearing() throws IOException;
    
    /**
     * Bricht die aktive Peilung ab.
     * Track wird als "aborted" markiert und gespeichert.
     * 
     * @return GPX-Datei-Objekt mit gespeichertem Pfad
     * @throws IllegalStateException wenn keine Peilung aktiv ist
     */
    GpxFile abortBearing() throws IOException;
    
    /**
     * Liefert aktuelle Peilungsinformationen.
     * 
     * @return Snapshot der aktuellen Peilung
     * @throws IllegalStateException wenn keine Peilung aktiv ist
     */
    BearingInfo getCurrentBearing();
    
    /**
     * Prüft, ob eine Peilung aktiv ist.
     * 
     * @return true wenn aktiv, sonst false
     */
    boolean isBearingActive();
    
    /**
     * Registriert einen Event-Listener.
     * 
     * @param listener Listener für Peilungs-Events
     */
    void addListener(BearingListener listener);
    
    /**
     * Entfernt einen Event-Listener.
     * 
     * @param listener Zu entfernender Listener
     */
    void removeListener(BearingListener listener);
    
    /**
     * Gibt alle Ressourcen frei.
     * Muss am Ende der Nutzung aufgerufen werden.
     */
    void shutdown();
}
```

**4.3.1.2 Datenmodell**

```java
/**
 * Repräsentiert eine geografische Koordinate.
 * Immutable, Thread-safe.
 */
public final class GeoCoordinate {
    private final double latitude;      // -90.0 bis +90.0
    private final double longitude;     // -180.0 bis +180.0
    private final double elevation;     // Meter über NN
    private final Instant timestamp;    // UTC
    private final double accuracy;      // HDOP
    private final double speed;         // m/s (optional)
    private final double course;        // 0-360° (optional)
    
    // Builder pattern
    public static class Builder { ... }
    
    // Validierung
    public boolean isValid() { ... }
}

/**
 * Peilungsinformationen (Snapshot).
 * Immutable.
 */
public final class BearingInfo {
    private final double azimuth;           // 0-360° (geografisch Nord)
    private final double magneticAzimuth;   // 0-360° (magnetisch Nord)
    private final double distance;          // Meter
    private final double initialDistance;   // Startdistanz
    private final double deviation;         // Abweichung vom Sollkurs
    private final GeoCoordinate current;
    private final GeoCoordinate target;
    private final Instant calculatedAt;
    
    // Berechnete Felder
    public double getProgress() { ... }      // 0.0-1.0
    public double getRemainingDistance() { ... }
}

/**
 * GPX-Datei-Referenz.
 */
public final class GpxFile {
    private final Path filePath;
    private final int trackPointCount;
    private final Duration duration;
    private final double totalDistance;
    private final GpxStatus status;
    
    public enum GpxStatus {
        COMPLETED,
        ABORTED,
        ERROR
    }
}

/**
 * Konfiguration für Peilung.
 */
public final class BearingConfig {
    private final Duration trackingInterval;
    private final Path outputDirectory;
    private final String fileNamePattern;
    private final double minAccuracy;           // Max HDOP
    private final boolean enableKalmanFilter;
    private final boolean compressGpx;
    
    public static class Builder { ... }
    
    // Standard-Konfigurationen
    public static BearingConfig eco() { ... }
    public static BearingConfig standard() { ... }
    public static BearingConfig precise() { ... }
}
```

**4.3.1.3 Event-Listener**

```java
/**
 * Event-Listener für Peilungs-Updates.
 */
public interface BearingListener {
    
    /**
     * Wird bei jeder Peilungsaktualisierung aufgerufen.
     */
    default void onBearingUpdate(BearingInfo info) {}
    
    /**
     * Wird bei jedem aufgezeichneten GPS-Punkt aufgerufen.
     */
    default void onTrackPointRecorded(GeoCoordinate point) {}
    
    /**
     * Wird aufgerufen, wenn Ziel erreicht wurde (< 10m).
     */
    default void onTargetReached(BearingInfo finalInfo) {}
    
    /**
     * Wird bei GPS-Signal-Verlust aufgerufen.
     */
    default void onGpsSignalLost(Instant lostAt) {}
    
    /**
     * Wird bei GPS-Signal-Wiederherstellung aufgerufen.
     */
    default void onGpsSignalRestored(Instant restoredAt) {}
    
    /**
     * Wird bei Abbruch der Peilung aufgerufen.
     */
    default void onBearingAborted(BearingInfo lastInfo) {}
    
    /**
     * Wird bei Fehlern aufgerufen.
     */
    default void onError(BearingException exception) {}
}
```

#### 4.3.2 Funktionale Anforderungen

**FR-001: Azimut-Berechnung**
- **Beschreibung:** System berechnet den geografischen Azimut (0-360°)
- **Input:** Aktuelle Position, Zielposition
- **Output:** Azimut in Grad
- **Algorithmus:** Atan2-basiert mit Normalisierung
- **Genauigkeit:** ±1° bei Distanz > 10m
- **Performance:** < 10ms

**FR-002: Distanzberechnung**
- **Beschreibung:** Berechnung der Großkreis-Distanz
- **Algorithmus:** Haversine-Formel
- **Input:** Zwei GeoCoordinate-Objekte
- **Output:** Distanz in Metern
- **Genauigkeit:** ±0.1%
- **Performance:** < 5ms

**FR-003: GPS-Punkt-Aufzeichnung**
- **Beschreibung:** Kontinuierliche Aufzeichnung von GPS-Punkten
- **Intervall:** Konfigurierbar (0.5s - 10s)
- **Validierung:** 
  - Koordinaten im gültigen Bereich
  - HDOP < konfigurierter Wert
  - Zeitstempel nicht in Zukunft
  - Geschwindigkeit < 300 m/s (Outlier-Detection)
- **Speicherung:** In-Memory bis Flush oder Ende

**FR-004: Kalman-Filter**
- **Beschreibung:** Optionale GPS-Glättung
- **Algorithmus:** 1D-Kalman-Filter für Lat/Lon
- **Konfigurierbar:** true/false
- **Effekt:** Reduzierung von GPS-Jitter

**FR-005: GPX-Generierung**
- **Standard:** GPX 1.1
- **Struktur:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="BearingComponent">
  <metadata>
    <name>Bearing Track</name>
    <time>2026-04-16T12:00:00Z</time>
    <bounds minlat="48.0" minlon="9.0" maxlat="49.0" maxlon="10.0"/>
  </metadata>
  <trk>
    <name>Bearing to Target</name>
    <extensions>
      <bearing:target lat="48.5" lon="9.5"/>
      <bearing:status>COMPLETED</bearing:status>
    </extensions>
    <trkseg>
      <trkpt lat="48.1234" lon="9.5678">
        <ele>300.5</ele>
        <time>2026-04-16T12:00:01Z</time>
        <hdop>1.2</hdop>
      </trkpt>
      <!-- weitere Punkte -->
    </trkseg>
  </trk>
</gpx>
```

**FR-006: Track-Vereinfachung (Optional)**
- **Algorithmus:** Douglas-Peucker
- **Toleranz:** Konfigurierbar (Standard: 5m)
- **Anwendung:** Bei > 5000 Punkten automatisch
- **Effekt:** Reduzierung der Dateigröße um ~30-50%

**FR-007: Multi-Track-Support**
- **Beschreibung:** Mehrere Tracks in einer GPX-Datei
- **Use Case:** Mehrere Peilungen nacheinander
- **Implementierung:** Append-Mode für GPX

**FR-008: Zielannäherung-Detection**
- **Schwellwert:** 10 Meter
- **Event:** onTargetReached()
- **Verhalten:** Peilung läuft weiter, nur Notification

#### 4.3.3 Performance-Anforderungen

**PR-001: Berechnungs-Performance**
- Azimut-Berechnung: < 10ms
- Distanz-Berechnung: < 5ms
- GPS-Punkt-Validierung: < 5ms
- Gesamtverarbeitung pro Update: < 50ms

**PR-002: Speicher-Performance**
- Max. RAM-Verbrauch: 50 MB
- Track-Punkte im Speicher: Max. 10.000
- Auto-Flush bei 8.000 Punkten

**PR-003: I/O-Performance**
- GPX-Speicherung: Asynchron
- Max. Wartezeit: 500ms
- Atomare Schreiboperationen (Temp + Rename)

**PR-004: Thread-Safety**
- BearingComponent: Thread-safe für Lesezugriffe
- Event-Callbacks: Eigener Thread-Pool
- Max. 10 gleichzeitige Listener

#### 4.3.4 Zuverlässigkeits-Anforderungen

**RR-001: Fehlertoleranz**
- GPS-Signal-Verlust: Graceful Degradation
- I/O-Fehler: Retry mit Exponential Backoff
- Ungültige Daten: Logging + Discard

**RR-002: Datenintegrität**
- Atomare Datei-Operationen
- GPX-Validierung vor Speicherung
- Checksummen für kritische Daten

**RR-003: Recovery**
- Auto-Save bei JVM-Shutdown
- Teiltrack-Speicherung bei Crash
- Recovery-Informationen in Temp-Datei

#### 4.3.5 Wartbarkeits-Anforderungen

**MR-001: Modularität**
- Klare Modul-Trennung
- Dependency Injection
- Loose Coupling

**MR-002: Dokumentation**
- Vollständige JavaDoc (alle public APIs)
- Architektur-Dokumentation
- Beispiel-Code

**MR-003: Testbarkeit**
- Unit-Test-Coverage ≥ 80%
- Mock-freundliches Design
- Integration-Tests

**MR-004: Code-Qualität**
- Checkstyle-Konformität
- PMD-Konformität
- SonarQube Quality Gate: A

#### 4.3.6 Portabilitäts-Anforderungen

**PO-001: Plattform-Unabhängigkeit**
- JVM 11+ (LTS)
- Keine nativen Abhängigkeiten
- Lauffähig auf Windows, Linux, macOS

**PO-002: Build-System**
- Maven 3.6+
- Gradle-kompatibel

**PO-003: Deployment**
- Als JAR-Bibliothek
- Maven Central kompatibel
- Semantic Versioning

---

## 5. UML-MODELLIERUNG

### 5.1 Use-Case-Diagramm

```
                    ┌─────────────────────────┐
                    │  Integrierende App      │
                    └────────┬────────────────┘
                             │
                ┌────────────┼────────────┐
                │            │            │
                ▼            ▼            ▼
        ┌─────────────┐ ┌──────────┐ ┌─────────────┐
        │  Peilung    │ │ Position │ │  Peilung    │
        │  starten    │ │ aktual.  │ │  beenden    │
        └─────────────┘ └──────────┘ └─────────────┘
                │
                │ <<include>>
                ▼
        ┌─────────────────┐
        │ GPS Track       │
        │ aufzeichnen     │
        └─────────────────┘
                │
                │ <<include>>
                ▼
        ┌─────────────────┐
        │ GPX Datei       │
        │ speichern       │
        └─────────────────┘
```

### 5.2 Klassendiagramm (Übersicht)

```
┌─────────────────────────────────────────────────────┐
│              <<interface>>                          │
│            BearingComponent                         │
├─────────────────────────────────────────────────────┤
│ + startBearing(target, config)                      │
│ + updatePosition(position)                          │
│ + stopBearing(): GpxFile                            │
│ + getCurrentBearing(): BearingInfo                  │
│ + addListener(listener)                             │
└───────────────┬─────────────────────────────────────┘
                │
                │ implements
                ▼
┌─────────────────────────────────────────────────────┐
│         BearingComponentImpl                        │
├─────────────────────────────────────────────────────┤
│ - gpsTracker: GpsTracker                            │
│ - bearingCalculator: BearingCalculator              │
│ - gpxExporter: GpxExporter                          │
│ - eventDispatcher: EventDispatcher                  │
│ - currentTarget: GeoCoordinate                      │
│ - bearingState: BearingState                        │
├─────────────────────────────────────────────────────┤
│ + startBearing(...)                                 │
│ + updatePosition(...)                               │
│ - validateCoordinate(coord)                         │
│ - notifyListeners(event)                            │
└─────────────────────────────────────────────────────┘
                │
                │ uses
                ▼
┌─────────────────────────────────────────────────────┐
│          BearingCalculator                          │
├─────────────────────────────────────────────────────┤
│ + calculateAzimuth(from, to): double                │
│ + calculateDistance(from, to): double               │
│ + calculateDeviation(current, target, heading)      │
└─────────────────────────────────────────────────────┘
                │
                │ uses
                ▼
┌─────────────────────────────────────────────────────┐
│            GeoUtils                                 │
├─────────────────────────────────────────────────────┤
│ + haversineDistance(lat1, lon1, lat2, lon2)         │
│ + bearing(lat1, lon1, lat2, lon2)                   │
│ + normalizeAzimuth(azimuth): double                 │
└─────────────────────────────────────────────────────┘
```

### 5.3 Sequenzdiagramm: Peilung starten

```
App             BearingComponent    GpsTracker    BearingCalculator
 │                    │                 │                │
 │ startBearing()     │                 │                │
 ├───────────────────>│                 │                │
 │                    │ start()         │                │
 │                    ├────────────────>│                │
 │                    │                 │                │
 │                    │ calculate()     │                │
 │                    ├────────────────────────────────>│
 │                    │                 │     Azimuth    │
 │                    │<────────────────────────────────┤
 │                    │                 │                │
 │                    │ onBearingUpdate()               │
 │<───────────────────┤                 │                │
 │                    │                 │                │
```

### 5.4 Zustandsdiagramm: BearingState

```
        ┌─────────┐
        │  IDLE   │
        └────┬────┘
             │ startBearing()
             ▼
        ┌─────────┐
        │ ACTIVE  │◄───┐
        └────┬────┘    │
             │         │ updatePosition()
             │         │
             ├─────────┘
             │
             │ stopBearing() / abortBearing()
             ▼
        ┌─────────┐
        │ SAVING  │
        └────┬────┘
             │
             │ GPX saved
             ▼
        ┌─────────┐
        │COMPLETED│
        └─────────┘
```

### 5.5 Komponentendiagramm

```
┌──────────────────────────────────────────────────┐
│          bearing-component.jar                   │
├──────────────────────────────────────────────────┤
│  ┌────────────────┐  ┌────────────────┐          │
│  │  bearing-core  │  │  gps-tracker   │          │
│  └────────────────┘  └────────────────┘          │
│  ┌────────────────┐  ┌────────────────┐          │
│  │ gpx-exporter   │  │  data-model    │          │
│  └────────────────┘  └────────────────┘          │
│  ┌────────────────┐                              │
│  │ bearing-utils  │                              │
│  └────────────────┘                              │
└──────────────────────────────────────────────────┘
         │
         │ depends on
         ▼
┌──────────────────────────────────────────────────┐
│  External Dependencies                           │
│  - slf4j-api                                     │
│  - jaxb-api (XML processing)                     │
│  - (optional) geographiclib                      │
└──────────────────────────────────────────────────┘
```

### 5.6 Paketdiagramm

```
de.dhbw.bearing
    │
    ├── api (Public API)
    │   ├── BearingComponent
    │   ├── BearingListener
    │   └── BearingConfig
    │
    ├── core (Business Logic)
    │   ├── BearingComponentImpl
    │   ├── BearingCalculator
    │   └── BearingState
    │
    ├── tracking (GPS Tracking)
    │   ├── GpsTracker
    │   ├── TrackPointValidator
    │   └── KalmanFilter
    │
    ├── export (GPX Export)
    │   ├── GpxExporter
    │   ├── GpxGenerator
    │   └── GpxValidator
    │
    ├── model (Data Model)
    │   ├── GeoCoordinate
    │   ├── BearingInfo
    │   └── GpxFile
    │
    └── util (Utilities)
        ├── GeoUtils
        ├── MathUtils
        └── ValidationUtils
```

---

## 6. ARCHITEKTUR UND ENTWURFSMUSTER

### 6.1 Architekturmuster: Schichtenarchitektur

```
┌─────────────────────────────────────────────┐
│      Presentation Layer (außerhalb)         │
│      - UI                                   │
│      - User Input                           │
└──────────────────┬──────────────────────────┘
                   │ API Calls
┌──────────────────▼──────────────────────────┐
│      API Layer                              │
│      - BearingComponent (Facade)            │
│      - Event Listeners                      │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│      Business Logic Layer                   │
│      - BearingCalculator                    │
│      - GpsTracker                           │
│      - Validation                           │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│      Data Access Layer                      │
│      - GpxExporter                          │
│      - File I/O                             │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│      Persistence Layer                      │
│      - File System                          │
│      - GPX Files                            │
└─────────────────────────────────────────────┘
```

**Vorteile:**
- Klare Trennung der Verantwortlichkeiten
- Austauschbarkeit einzelner Schichten
- Testbarkeit durch Isolation

### 6.2 Entwurfsmuster

#### 6.2.1 Facade Pattern
**Anwendung:** BearingComponent als Facade  
**Zweck:** Vereinfachte Schnittstelle für komplexes Subsystem  
**Implementierung:**
```java
public class BearingComponentImpl implements BearingComponent {
    private final BearingCalculator calculator;
    private final GpsTracker tracker;
    private final GpxExporter exporter;
    
    // Facade versteckt Komplexität
    public void startBearing(GeoCoordinate target, BearingConfig config) {
        calculator.initialize(target);
        tracker.start(config);
        // Koordination mehrerer Subsysteme
    }
}
```

#### 6.2.2 Observer Pattern
**Anwendung:** Event-System (BearingListener)  
**Zweck:** Benachrichtigung bei Zustandsänderungen  
**Implementierung:**
```java
public class EventDispatcher {
    private final List<BearingListener> listeners = new CopyOnWriteArrayList<>();
    
    public void notifyBearingUpdate(BearingInfo info) {
        listeners.forEach(l -> l.onBearingUpdate(info));
    }
}
```

#### 6.2.3 Builder Pattern
**Anwendung:** GeoCoordinate, BearingConfig  
**Zweck:** Flexible Objekterzeugung mit vielen optionalen Parametern  
**Implementierung:**
```java
GeoCoordinate coord = new GeoCoordinate.Builder()
    .latitude(48.1234)
    .longitude(9.5678)
    .elevation(300.0)
    .timestamp(Instant.now())
    .accuracy(2.5)
    .build();
```

#### 6.2.4 Strategy Pattern
**Anwendung:** Distanzberechnung (Haversine vs. Vincenty)  
**Zweck:** Austauschbare Algorithmen  
**Implementierung:**
```java
public interface DistanceCalculationStrategy {
    double calculate(GeoCoordinate from, GeoCoordinate to);
}

public class HaversineStrategy implements DistanceCalculationStrategy { ... }
public class VincentyStrategy implements DistanceCalculationStrategy { ... }
```

#### 6.2.5 Template Method Pattern
**Anwendung:** GPX-Export-Pipeline  
**Zweck:** Fixe Ablaufstruktur mit variablen Schritten  
**Implementierung:**
```java
public abstract class AbstractGpxExporter {
    public final GpxFile export(Track track) {
        validate(track);
        String xml = generateXml(track);
        Path file = writeToFile(xml);
        return createGpxFile(file);
    }
    
    protected abstract String generateXml(Track track);
}
```

#### 6.2.6 Singleton Pattern (vorsichtig)
**Anwendung:** Logger-Konfiguration  
**Zweck:** Zentrale Instanz  
**Implementierung:** Enum-basiert
```java
public enum LoggerFactory {
    INSTANCE;
    
    public Logger getLogger(Class<?> clazz) { ... }
}
```

#### 6.2.7 Factory Pattern
**Anwendung:** Filter-Erstellung (Kalman, Median, etc.)  
**Zweck:** Objekterzeugung ohne Kenntnis der konkreten Klasse  
**Implementierung:**
```java
public class GpsFilterFactory {
    public static GpsFilter createFilter(FilterType type) {
        switch (type) {
            case KALMAN: return new KalmanFilter();
            case MEDIAN: return new MedianFilter();
            default: return new NoOpFilter();
        }
    }
}
```

#### 6.2.8 Dependency Injection
**Anwendung:** Alle Komponenten  
**Zweck:** Loose Coupling, Testbarkeit  
**Implementierung:**
```java
public class BearingComponentImpl {
    private final BearingCalculator calculator;
    private final GpsTracker tracker;
    
    // Constructor Injection
    public BearingComponentImpl(
        BearingCalculator calculator,
        GpsTracker tracker
    ) {
        this.calculator = calculator;
        this.tracker = tracker;
    }
}
```

### 6.3 SOLID Principles

**S - Single Responsibility:**
- BearingCalculator: Nur Berechnungen
- GpsTracker: Nur Tracking
- GpxExporter: Nur Export

**O - Open/Closed:**
- DistanceCalculationStrategy: Erweiterbar ohne Änderung
- GpsFilter: Neue Filter ohne Core-Änderungen

**L - Liskov Substitution:**
- Alle Strategy-Implementierungen austauschbar
- Filter-Implementierungen austauschbar

**I - Interface Segregation:**
- BearingListener: Default-Methoden, nur benötigte implementieren
- Kleine, fokussierte Interfaces

**D - Dependency Inversion:**
- Abhängigkeit von Abstraktionen (Interfaces)
- Keine direkten Abhängigkeiten von Implementierungen

---

## 7. IMPLEMENTIERUNGSRICHTLINIEN

### 7.1 Coding Standards

**Namenskonventionen:**
- Klassen: PascalCase (`BearingCalculator`)
- Methoden/Variablen: camelCase (`calculateAzimuth`)
- Konstanten: UPPER_SNAKE_CASE (`MAX_TRACK_POINTS`)
- Packages: lowercase (`de.dhbw.bearing.core`)

**Code-Organisation:**
- Max. 200 Zeilen pro Methode (Empfehlung: < 50)
- Max. 500 Zeilen pro Klasse
- Max. Verschachtelungstiefe: 4

**Kommentare:**
- JavaDoc für alle public APIs
- Inline-Kommentare für komplexe Logik
- TODO/FIXME mit Ticket-Referenz

### 7.2 Exception-Handling

**Exception-Hierarchie:**
```java
BearingException (checked)
├── InvalidCoordinateException
├── GpsSignalLostException
├── TrackingException
└── GpxExportException
    ├── GpxValidationException
    └── GpxIOException
```

**Richtlinien:**
- Checked Exceptions für recoverable Fehler
- Runtime Exceptions für Programming Errors
- Nie Exception schlucken ohne Logging
- Spezifische Exceptions werfen

### 7.3 Logging

**Log-Levels:**
- **ERROR:** Kritische Fehler (z.B. GPX-Speicherung fehlgeschlagen)
- **WARN:** Potenzielle Probleme (z.B. GPS-Genauigkeit niedrig)
- **INFO:** Wichtige Events (z.B. Peilung gestartet)
- **DEBUG:** Detaillierte Informationen
- **TRACE:** Sehr detailliert (Entwicklung)

**Logging-Strategie:**
```java
private static final Logger log = LoggerFactory.getLogger(BearingComponentImpl.class);

public void startBearing(GeoCoordinate target, BearingConfig config) {
    log.info("Starting bearing to target: {}", target);
    try {
        // ...
    } catch (Exception e) {
        log.error("Failed to start bearing", e);
        throw new BearingException("Failed to start bearing", e);
    }
}
```

### 7.4 Parallelität

**Thread-Safety:**
- BearingComponent: Thread-safe
- GeoCoordinate: Immutable
- Event-Callbacks: Thread-Pool (Executor)

**Synchronisation:**
```java
public class BearingComponentImpl {
    private final Object lock = new Object();
    
    public void updatePosition(GeoCoordinate position) {
        synchronized (lock) {
            // Critical section
        }
    }
}
```

**Thread-Pool für Events:**
```java
private final ExecutorService eventExecutor = 
    Executors.newFixedThreadPool(10);

private void notifyListeners(Consumer<BearingListener> action) {
    listeners.forEach(listener -> 
        eventExecutor.submit(() -> action.accept(listener))
    );
}
```

### 7.5 Ressourcen-Management

**Auto-Closeable:**
```java
public class BearingComponentImpl implements BearingComponent, AutoCloseable {
    @Override
    public void close() {
        shutdown();
    }
    
    @Override
    public void shutdown() {
        try {
            if (isBearingActive()) {
                stopBearing();
            }
            eventExecutor.shutdown();
            eventExecutor.awaitTermination(5, TimeUnit.SECONDS);
        } catch (Exception e) {
            log.error("Error during shutdown", e);
        }
    }
}
```

**Try-with-Resources:**
```java
try (BearingComponent component = BearingComponentFactory.create()) {
    component.startBearing(target, config);
    // Use component
} // Automatic cleanup
```

---

## 8. TEST-STRATEGIE

### 8.1 Unit-Tests

**Test-Struktur: AAA-Pattern**
```java
@Test
void calculateAzimuth_shouldReturnCorrectBearing() {
    // Arrange
    GeoCoordinate from = new GeoCoordinate.Builder()
        .latitude(48.0)
        .longitude(9.0)
        .build();
    GeoCoordinate to = new GeoCoordinate.Builder()
        .latitude(49.0)
        .longitude(10.0)
        .build();
    BearingCalculator calculator = new BearingCalculator();
    
    // Act
    double azimuth = calculator.calculateAzimuth(from, to);
    
    // Assert
    assertThat(azimuth).isBetween(0.0, 360.0);
    assertThat(azimuth).isCloseTo(44.76, within(0.1));
}
```

**Test-Coverage-Ziele:**
- bearing-core: ≥ 90%
- gps-tracker: ≥ 85%
- gpx-exporter: ≥ 80%
- data-model: ≥ 95%
- bearing-utils: ≥ 90%

**Test-Kategorien:**
```java
@Tag("unit")
class BearingCalculatorTest { ... }

@Tag("integration")
class BearingComponentIntegrationTest { ... }

@Tag("slow")
class PerformanceTest { ... }
```

### 8.2 Testfälle (Beispiele)

**Positive Tests:**
- Korrekte Azimut-Berechnung bei bekannten Koordinaten
- Korrekte Distanz-Berechnung (Haversine)
- Erfolgreiche GPX-Generierung
- Event-Benachrichtigungen werden ausgelöst

**Negative Tests:**
- Ungültige Koordinaten → Exception
- GPS-Punkte mit HDOP > Grenzwert → Verwerfung
- Ungültiger GPX-Output → Validierungs-Fehler
- Peilung starten wenn bereits aktiv → Exception

**Edge Cases:**
- Koordinaten am Nord/Südpol
- Überschreitung der Datumsgrenze
- Identische Start/Ziel-Koordinaten
- Sehr große Distanzen (> 10.000 km)
- Sehr kurze Tracks (< 2 Punkte)

**Performance-Tests:**
```java
@Test
void bearingCalculation_shouldCompleteWithin50ms() {
    // Arrange
    GeoCoordinate from = createRandomCoordinate();
    GeoCoordinate to = createRandomCoordinate();
    BearingCalculator calculator = new BearingCalculator();
    
    // Act & Assert
    assertTimeout(Duration.ofMillis(50), () -> {
        calculator.calculateAzimuth(from, to);
    });
}
```

### 8.3 Mocking-Strategie

**Mockito für Abhängigkeiten:**
```java
@Test
void startBearing_shouldInitializeTracker() {
    // Arrange
    GpsTracker tracker = mock(GpsTracker.class);
    BearingCalculator calculator = mock(BearingCalculator.class);
    BearingComponentImpl component = new BearingComponentImpl(calculator, tracker);
    
    GeoCoordinate target = createTestCoordinate();
    BearingConfig config = BearingConfig.standard();
    
    // Act
    component.startBearing(target, config);
    
    // Assert
    verify(tracker).start(config);
    verify(calculator).initialize(target);
}
```

### 8.4 Integration-Tests

**Test mit realen Komponenten:**
```java
@Test
void endToEnd_bearingWithGpxExport() throws Exception {
    // Arrange
    BearingComponent component = BearingComponentFactory.createDefault();
    GeoCoordinate target = createTestTarget();
    BearingConfig config = BearingConfig.standard();
    
    List<BearingInfo> updates = new ArrayList<>();
    component.addListener(new BearingListener() {
        @Override
        public void onBearingUpdate(BearingInfo info) {
            updates.add(info);
        }
    });
    
    // Act
    component.startBearing(target, config);
    
    // Simulate GPS updates
    for (int i = 0; i < 10; i++) {
        component.updatePosition(createTestPosition(i));
        Thread.sleep(100);
    }
    
    GpxFile gpx = component.stopBearing();
    
    // Assert
    assertThat(updates).hasSize(10);
    assertThat(gpx.getTrackPointCount()).isEqualTo(10);
    assertThat(Files.exists(gpx.getFilePath())).isTrue();
    
    // Cleanup
    Files.deleteIfExists(gpx.getFilePath());
}
```

### 8.5 Test-Daten

**Test-Koordinaten:**
```java
public class TestDataFactory {
    public static GeoCoordinate STUTTGART = new GeoCoordinate.Builder()
        .latitude(48.7758)
        .longitude(9.1829)
        .elevation(245.0)
        .build();
    
    public static GeoCoordinate MUNICH = new GeoCoordinate.Builder()
        .latitude(48.1351)
        .longitude(11.5820)
        .elevation(519.0)
        .build();
    
    // Distanz Stuttgart-München: ~192 km
    public static double STUTTGART_MUNICH_DISTANCE = 192_000.0;
}
```

---

## 9. BUILD UND DEPLOYMENT

### 9.1 Maven-Struktur

**Projekt-Layout:**
```
bearing-component/
├── pom.xml (Parent POM)
├── bearing-core/
│   ├── pom.xml
│   └── src/
├── gps-tracker/
│   ├── pom.xml
│   └── src/
├── gpx-exporter/
│   ├── pom.xml
│   └── src/
├── data-model/
│   ├── pom.xml
│   └── src/
└── bearing-utils/
    ├── pom.xml
    └── src/
```

**Parent POM (Auszug):**
```xml
<project>
    <groupId>de.dhbw</groupId>
    <artifactId>bearing-component</artifactId>
    <version>1.0.0</version>
    <packaging>pom</packaging>
    
    <modules>
        <module>bearing-core</module>
        <module>gps-tracker</module>
        <module>gpx-exporter</module>
        <module>data-model</module>
        <module>bearing-utils</module>
    </modules>
    
    <properties>
        <java.version>11</java.version>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
        <slf4j.version>1.7.36</slf4j.version>
        <junit.version>5.9.0</junit.version>
    </properties>
    
    <dependencyManagement>
        <dependencies>
            <!-- SLF4J -->
            <dependency>
                <groupId>org.slf4j</groupId>
                <artifactId>slf4j-api</artifactId>
                <version>${slf4j.version}</version>
            </dependency>
            
            <!-- JUnit 5 -->
            <dependency>
                <groupId>org.junit.jupiter</groupId>
                <artifactId>junit-jupiter</artifactId>
                <version>${junit.version}</version>
                <scope>test</scope>
            </dependency>
            
            <!-- Mockito -->
            <dependency>
                <groupId>org.mockito</groupId>
                <artifactId>mockito-core</artifactId>
                <version>4.8.0</version>
                <scope>test</scope>
            </dependency>
            
            <!-- AssertJ -->
            <dependency>
                <groupId>org.assertj</groupId>
                <artifactId>assertj-core</artifactId>
                <version>3.23.1</version>
                <scope>test</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
    
    <build>
        <plugins>
            <!-- Compiler -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.10.1</version>
            </plugin>
            
            <!-- Surefire (Tests) -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>2.22.2</version>
            </plugin>
            
            <!-- Jacoco (Coverage) -->
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.8.8</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>report</id>
                        <phase>test</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            
            <!-- Checkstyle -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-checkstyle-plugin</artifactId>
                <version>3.2.0</version>
                <configuration>
                    <configLocation>checkstyle.xml</configLocation>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

### 9.2 Build-Kommandos

```bash
# Kompilieren
mvn clean compile

# Tests ausführen
mvn test

# Integration-Tests
mvn verify

# Coverage-Report
mvn jacoco:report

# Checkstyle-Prüfung
mvn checkstyle:check

# Paketieren (ohne Tests für Abgabe)
mvn clean package -DskipTests

# Vollständiger Build
mvn clean install
```

### 9.3 Abgabe-Vorbereitung

**Struktur für Herr Bohl:**
```
abgabe/
├── source/
│   ├── bearing-component/  (komplettes Projekt)
│   │   ├── pom.xml
│   │   ├── bearing-core/
│   │   ├── gps-tracker/
│   │   └── ...
│   └── README.md (Build-Anleitung)
├── documentation/
│   ├── Anforderungsanalyse.pdf
│   ├── Spezifikation_IEEE830.pdf
│   ├── Design_Dokumentation.pdf
│   └── Implementierung_Dokumentation.pdf
└── examples/
    ├── BasicUsageExample.java
    └── AdvancedFeaturesExample.java
```

**README.md:**
```markdown
# JAVA Peilungs-Komponente - Build-Anleitung

## Voraussetzungen
- JDK 11 oder höher
- Maven 3.6+

## Build
```bash
cd bearing-component
mvn clean install
```

## Tests
```bash
mvn test
```

## Verwendung
Siehe examples/BasicUsageExample.java

## Struktur
- bearing-core: Kernfunktionalität
- gps-tracker: GPS-Aufzeichnung
- gpx-exporter: GPX-Export
- data-model: Datenmodell
- bearing-utils: Hilfsfunktionen
```

---

## 10. ERWEITERTE FEATURES (für 1+)

### 10.1 Kalman-Filter-Implementierung

**Algorithmus:**
```java
public class KalmanFilter implements GpsFilter {
    private double processNoise = 0.001;  // Q
    private double measurementNoise = 4.0; // R
    private double estimatedError = 1.0;   // P
    private double estimate;
    
    @Override
    public GeoCoordinate filter(GeoCoordinate raw) {
        // Prediction
        double predictedError = estimatedError + processNoise;
        
        // Update
        double kalmanGain = predictedError / (predictedError + measurementNoise);
        estimate = estimate + kalmanGain * (raw.getLatitude() - estimate);
        estimatedError = (1 - kalmanGain) * predictedError;
        
        return new GeoCoordinate.Builder(raw)
            .latitude(estimate)
            .build();
    }
}
```

### 10.2 Douglas-Peucker Track-Vereinfachung

**Implementierung:**
```java
public class DouglasPeuckerSimplifier {
    private final double epsilon; // Toleranz in Metern
    
    public List<GeoCoordinate> simplify(List<GeoCoordinate> points) {
        if (points.size() <= 2) return points;
        
        // Finde Punkt mit größter Distanz
        double maxDistance = 0;
        int index = 0;
        
        GeoCoordinate first = points.get(0);
        GeoCoordinate last = points.get(points.size() - 1);
        
        for (int i = 1; i < points.size() - 1; i++) {
            double distance = perpendicularDistance(points.get(i), first, last);
            if (distance > maxDistance) {
                maxDistance = distance;
                index = i;
            }
        }
        
        // Rekursiv vereinfachen
        if (maxDistance > epsilon) {
            List<GeoCoordinate> left = simplify(points.subList(0, index + 1));
            List<GeoCoordinate> right = simplify(points.subList(index, points.size()));
            
            left.addAll(right.subList(1, right.size()));
            return left;
        } else {
            return Arrays.asList(first, last);
        }
    }
}
```

### 10.3 Multi-Target-Peilung

**Erweiterung:**
```java
public interface MultiTargetBearingComponent extends BearingComponent {
    void addTarget(String id, GeoCoordinate target);
    void removeTarget(String id);
    Map<String, BearingInfo> getCurrentBearings();
    void setActiveTarget(String id);
}
```

### 10.4 Geo-Fencing

**Implementation:**
```java
public class GeoFence {
    private final GeoCoordinate center;
    private final double radius; // in Metern
    
    public boolean contains(GeoCoordinate point) {
        double distance = GeoUtils.haversineDistance(center, point);
        return distance <= radius;
    }
    
    public double getDistanceToFence(GeoCoordinate point) {
        double distance = GeoUtils.haversineDistance(center, point);
        return Math.max(0, distance - radius);
    }
}

// Event
public interface BearingListener {
    default void onFenceEntered(String fenceId) {}
    default void onFenceExited(String fenceId) {}
}
```

### 10.5 Route-Prediction

**ETA-Berechnung:**
```java
public class RoutePredictor {
    public Instant predictArrival(
        GeoCoordinate current,
        GeoCoordinate target,
        double averageSpeed
    ) {
        double remainingDistance = GeoUtils.haversineDistance(current, target);
        double timeInSeconds = remainingDistance / averageSpeed;
        return Instant.now().plusSeconds((long) timeInSeconds);
    }
    
    public double calculateAverageSpeed(List<GeoCoordinate> track) {
        if (track.size() < 2) return 0;
        
        double totalDistance = 0;
        for (int i = 1; i < track.size(); i++) {
            totalDistance += GeoUtils.haversineDistance(
                track.get(i-1), 
                track.get(i)
            );
        }
        
        Duration duration = Duration.between(
            track.get(0).getTimestamp(),
            track.get(track.size() - 1).getTimestamp()
        );
        
        return totalDistance / duration.getSeconds();
    }
}
```

### 10.6 Track-Statistiken

**Implementierung:**
```java
public class TrackStatistics {
    private final List<GeoCoordinate> track;
    
    public double getTotalDistance() {
        double total = 0;
        for (int i = 1; i < track.size(); i++) {
            total += GeoUtils.haversineDistance(track.get(i-1), track.get(i));
        }
        return total;
    }
    
    public double getMaxSpeed() {
        return track.stream()
            .mapToDouble(GeoCoordinate::getSpeed)
            .max()
            .orElse(0);
    }
    
    public double getAverageSpeed() {
        return track.stream()
            .mapToDouble(GeoCoordinate::getSpeed)
            .average()
            .orElse(0);
    }
    
    public ElevationProfile getElevationProfile() {
        double totalAscent = 0;
        double totalDescent = 0;
        
        for (int i = 1; i < track.size(); i++) {
            double diff = track.get(i).getElevation() - track.get(i-1).getElevation();
            if (diff > 0) totalAscent += diff;
            else totalDescent += Math.abs(diff);
        }
        
        return new ElevationProfile(totalAscent, totalDescent);
    }
}
```

### 10.7 KML-Export (zusätzlich zu GPX)

**Implementierung:**
```java
public class KmlExporter {
    public Path exportToKml(Track track, Path outputPath) throws IOException {
        StringBuilder kml = new StringBuilder();
        kml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        kml.append("<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n");
        kml.append("<Document>\n");
        kml.append("<name>").append(track.getName()).append("</name>\n");
        kml.append("<Placemark>\n");
        kml.append("<LineString>\n");
        kml.append("<coordinates>\n");
        
        for (GeoCoordinate point : track.getPoints()) {
            kml.append(String.format("%f,%f,%f\n", 
                point.getLongitude(), 
                point.getLatitude(), 
                point.getElevation()));
        }
        
        kml.append("</coordinates>\n");
        kml.append("</LineString>\n");
        kml.append("</Placemark>\n");
        kml.append("</Document>\n");
        kml.append("</kml>\n");
        
        Files.write(outputPath, kml.toString().getBytes(StandardCharsets.UTF_8));
        return outputPath;
    }
}
```

---

## 11. QUALITÄTSSICHERUNG

### 11.1 Code-Review-Checkliste

- [ ] Entspricht SOLID-Prinzipien
- [ ] Alle public APIs haben JavaDoc
- [ ] Exception-Handling korrekt
- [ ] Keine Code-Duplikation
- [ ] Unit-Tests vorhanden
- [ ] Thread-Safety beachtet
- [ ] Ressourcen werden freigegeben
- [ ] Logging angemessen
- [ ] Namenskonventionen eingehalten
- [ ] Performance-Anforderungen erfüllt

### 11.2 Metriken

**Code-Coverage:**
- Ziel: ≥ 80%
- Tool: JaCoCo
- Report: target/site/jacoco/index.html

**Cyclomatic Complexity:**
- Max. pro Methode: 10
- Tool: Checkstyle/PMD

**Code-Duplikation:**
- Max. Duplikation: < 5%
- Tool: PMD CPD

### 11.3 Continuous Integration

**GitHub Actions (Beispiel):**
```yaml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up JDK 11
      uses: actions/setup-java@v2
      with:
        java-version: '11'
        distribution: 'adopt'
    
    - name: Build with Maven
      run: mvn clean install
    
    - name: Run tests
      run: mvn test
    
    - name: Generate coverage report
      run: mvn jacoco:report
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v2
```

---

## 12. PROJEKTMANAGEMENT

### 12.1 Zeitplan (10 Wochen)

| Woche | Phase | Deliverables |
|-------|-------|-------------|
| 1-2 | Anforderungsanalyse | Use Cases, Stakeholder-Analyse |
| 2-4 | Spezifikation | IEEE 830 Dokument, UML-Diagramme |
| 4-5 | Grobentwurf | Architektur, Entwurfsmuster |
| 5-6 | Feinentwurf | Detaillierte Klassenmodelle |
| 6-9 | Implementierung | Lauffähiger Code, Unit-Tests |
| 9-10 | Test & QS | Integration-Tests, Dokumentation |

### 12.2 Meilensteine

**M1 (Woche 2):** Anforderungsanalyse abgeschlossen  
**M2 (Woche 4):** Spezifikation abgeschlossen  
**M3 (Woche 6):** Design abgeschlossen, Implementierung startet  
**M4 (Woche 9):** Implementierung abgeschlossen  
**M5 (Woche 10):** Projekt abgabebereit

### 12.3 Risikomanagement

| Risiko | Wahrscheinlichkeit | Impact | Mitigation |
|--------|-------------------|--------|------------|
| Zeit knapp | Hoch | Hoch | Früher Start, Puffer einplanen |
| Komplexität unterschätzt | Mittel | Hoch | Prototyping, Reviews |
| Anforderungen unklar | Mittel | Mittel | Frühe Klärung mit Betreuer |
| Technische Probleme | Niedrig | Mittel | Proof of Concepts |

---

## 13. ABGABE-CHECKLISTE

### 13.1 Dokumente

- [ ] Anforderungsanalyse (8-12 Seiten)
- [ ] Spezifikation nach IEEE 830 (25-35 Seiten)
- [ ] Design-Dokumentation (20-25 Seiten)
- [ ] Implementierungs-Dokumentation (10-15 Seiten)
- [ ] UML-Diagramme (separat oder integriert)
- [ ] Test-Dokumentation
- [ ] README mit Build-Anleitung

### 13.2 Code

- [ ] Vollständiger Source-Code
- [ ] Maven-Projekt lauffähig
- [ ] Unit-Tests (≥ 80% Coverage)
- [ ] Integration-Tests
- [ ] Beispiel-Code
- [ ] JavaDoc vollständig

### 13.3 Qualitätskriterien

- [ ] Checkstyle: Keine Violations
- [ ] PMD: Keine kritischen Issues
- [ ] JaCoCo: ≥ 80% Coverage
- [ ] Alle Tests erfolgreich
- [ ] Code kompiliert ohne Warnings

### 13.4 Themenabdeckung aus Vorlesung

- [x] Anforderungsanalyse (Sophist Regeln)
- [x] Spezifikation (IEEE 830)
- [x] UML-Modellierung (Use Cases, Klassen-, Sequenzdiagramme)
- [x] Objektorientierte Analyse
- [x] Softwareentwicklungsprozessmodelle (implizit: inkrementell)
- [x] Grobentwurf (Architektur)
- [x] Architekturmuster (Schichten)
- [x] Entwurfsmuster (Facade, Observer, Builder, Strategy, etc.)

---

## ZUSAMMENFASSUNG

Dieses Dokument bietet eine vollständige Roadmap für das Projekt. Alle wesentlichen Aspekte wurden abgedeckt:

1. **Anforderungen geklärt:** Alle Vorbereitungsfragen beantwortet
2. **Spezifikation erstellt:** Nach IEEE 830 strukturiert
3. **Design definiert:** UML, Architektur, Entwurfsmuster
4. **Implementierung vorbereitet:** Coding Standards, Test-Strategie
5. **Qualität gesichert:** Code-Reviews, Metriken, CI
6. **Abgabe vorbereitet:** Checklisten, Zeitplan

**Nächste Schritte:**
1. Vorlesungsmaterialien detailliert durcharbeiten
2. Spezifikation nach IEEE 830 ausarbeiten
3. UML-Diagramme erstellen
4. Mit Implementierung starten (erst nach Spezifikation!)
5. Parallel: Tests schreiben
6. Dokumentation fortlaufend aktualisieren

**Kritischer Erfolgsfaktor:**
- Nicht mit Implementierung beginnen, bevor Spezifikation und Design abgeschlossen sind!
- Alle Vorlesungsthemen integrieren!
- Regelmäßige Reviews mit Kommilitonen

Viel Erfolg bei der Umsetzung! 🚀
