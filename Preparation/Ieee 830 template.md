# Software Requirements Specification (SRS)
## JAVA Peilungs-Komponente mit GPS-Track-Aufzeichnung

**Version:** 1.0  
**Datum:** [DATUM EINFÜGEN]  
**Autor:** [NAME EINFÜGEN]  
**Matrikelnummer:** [NUMMER EINFÜGEN]

---

## Änderungshistorie

| Version | Datum | Autor | Beschreibung |
|---------|-------|-------|--------------|
| 0.1 | | | Initiale Version |
| 1.0 | | | Finale Version |

---

## Inhaltsverzeichnis

1. Einführung
   1.1 Zweck
   1.2 Gültigkeitsbereich
   1.3 Definitionen, Akronyme und Abkürzungen
   1.4 Referenzen
   1.5 Übersicht
2. Systemübersicht
   2.1 Produktperspektive
   2.2 Produktfunktionen
   2.3 Benutzercharakteristika
   2.4 Einschränkungen
   2.5 Annahmen und Abhängigkeiten
3. Detaillierte Anforderungen
   3.1 Externe Schnittstellen
   3.2 Funktionale Anforderungen
   3.3 Performance-Anforderungen
   3.4 Zuverlässigkeits-Anforderungen
   3.5 Wartbarkeits-Anforderungen
   3.6 Portabilitäts-Anforderungen
4. Anhänge

---

## 1. EINFÜHRUNG

### 1.1 Zweck

Dieses Dokument spezifiziert die Anforderungen an die JAVA Peilungs-Komponente mit GPS-Track-Aufzeichnung. Die Spezifikation richtet sich an:

- **Entwickler:** Zur Implementierung der Komponente
- **Tester:** Zur Erstellung von Testfällen
- **Projekt-Betreuer:** Zur Bewertung und Review
- **Wartungsteam:** Für zukünftige Erweiterungen

**Scope dieses Dokuments:**
- Funktionale Anforderungen der Peilungs-Komponente
- Nicht-funktionale Anforderungen (Performance, Zuverlässigkeit, etc.)
- Schnittstellen-Spezifikation
- Datenmodell-Definition

**Nicht im Scope:**
- Benutzerschnittstellen (UI)
- Hardware-Spezifikationen
- Netzwerk-Protokolle

### 1.2 Gültigkeitsbereich

**Produktname:** JAVA Bearing Component  
**Version:** 1.0  
**Produktfamilie:** GPS/Geodäsie-Komponenten

**Beschreibung:**
Die JAVA Peilungs-Komponente ist eine UI-unabhängige, wiederverwendbare Java-Bibliothek zur Berechnung von Peilungen (Azimut und Distanz) zwischen geografischen Koordinaten mit integrierter GPS-Track-Aufzeichnung und GPX-Export-Funktionalität.

**Zielsetzung:**
Überführung der Peilungs-Funktionalitäten der iOS Kompass Professional App (https://apps.apple.com/de/app/kompass-professional/id1289069674) in eine Java-Komponente, die:
- In beliebige Java-Anwendungen integrierbar ist
- Keine UI-Abhängigkeiten besitzt
- Systemunabhängig funktioniert
- GPS-Tracks als GPX-Dateien speichert

**Module:**
1. **bearing-core:** Kernfunktionalität für Peilungsberechnungen
2. **gps-tracker:** GPS-Punkt-Aufzeichnung und -Validierung
3. **gpx-exporter:** GPX-Datei-Generierung und -Validierung
4. **data-model:** Datenmodell-Klassen
5. **bearing-utils:** Hilfsfunktionen und Utilities

### 1.3 Definitionen, Akronyme und Abkürzungen

#### Definitionen

| Begriff | Definition |
|---------|------------|
| **Peilung** | Richtungsbestimmung vom aktuellen Standpunkt zu einem Zielpunkt, ausgedrückt als Azimut (Winkel) und Distanz |
| **Azimut** | Horizontalwinkel von 0° bis 360°, gemessen von Nord im Uhrzeigersinn |
| **Track** | Sequenz von GPS-Punkten, die eine zurückgelegte Route repräsentieren |
| **Waypoint** | Einzelner GPS-Punkt mit geografischen Koordinaten und Metadaten |
| **Haversine-Formel** | Mathematische Formel zur Berechnung der Großkreis-Distanz zwischen zwei Punkten auf einer Kugel |
| **HDOP** | Horizontal Dilution of Precision - Maß für die GPS-Genauigkeit (niedriger = besser) |
| **Kalman-Filter** | Rekursiver Algorithmus zur Schätzung und Glättung von Messwerten |
| **Douglas-Peucker** | Algorithmus zur Vereinfachung von Linienzügen unter Beibehaltung der Form |

#### Akronyme und Abkürzungen

| Akronym | Bedeutung |
|---------|-----------|
| **API** | Application Programming Interface |
| **GPX** | GPS Exchange Format |
| **GPS** | Global Positioning System |
| **UTC** | Coordinated Universal Time (koordinierte Weltzeit) |
| **WGS84** | World Geodetic System 1984 (geodätisches Referenzsystem) |
| **ISO 8601** | Internationaler Standard für Datums- und Zeitangaben |
| **JAXB** | Java Architecture for XML Binding |
| **SLF4J** | Simple Logging Facade for Java |
| **XML** | Extensible Markup Language |
| **JSON** | JavaScript Object Notation |
| **KML** | Keyhole Markup Language |
| **ETA** | Estimated Time of Arrival |

### 1.4 Referenzen

| ID | Titel | Version | Quelle |
|----|-------|---------|--------|
| [IEEE830] | IEEE Recommended Practice for Software Requirements Specifications | IEEE 830-1998 | IEEE Standards |
| [GPX11] | GPX 1.1 Schema Documentation | 1.1 | http://www.topografix.com/GPX/1/1 |
| [WGS84] | World Geodetic System 1984 | TR8350.2 | NIMA |
| [ISO6709] | Standard representation of geographic point location by coordinates | ISO 6709:2008 | ISO |
| [ISO8601] | Date and time format | ISO 8601:2004 | ISO |
| [HAVERSINE] | Haversine Formula | - | Geodäsie-Literatur |
| [KALMAN] | Kalman Filter for GPS | - | Welch & Bishop, 2006 |
| [DOUGLASPEUCKER] | Algorithms for the Reduction of the Number of Points Required to Represent a Digitized Line | 1973 | Ramer-Douglas-Peucker |

### 1.5 Übersicht

Dieses Dokument ist wie folgt strukturiert:

**Kapitel 2 - Systemübersicht:**
Beschreibt den Kontext der Komponente, deren Position im Gesamtsystem und die Hauptfunktionen.

**Kapitel 3 - Detaillierte Anforderungen:**
Spezifiziert alle funktionalen und nicht-funktionalen Anforderungen im Detail. Jede Anforderung ist eindeutig identifiziert und testbar formuliert.

**Kapitel 4 - Anhänge:**
Enthält zusätzliche Informationen wie UML-Diagramme, Beispielcode und Glossar.

---

## 2. SYSTEMÜBERSICHT

### 2.1 Produktperspektive

#### 2.1.1 Systemkontext

Die JAVA Peilungs-Komponente ist eine eigenständige Bibliothek, die in bestehende Java-Anwendungen integriert wird. Sie hat keine direkten Hardware-Anbindungen und erhält alle GPS-Daten von der Host-Anwendung.

**Systemkontext-Diagramm:**

```
┌───────────────────────────────────────────────────────────┐
│                 SYSTEM-UMGEBUNG                           │
│                                                           │
│  ┌─────────────────────────────────────────────────┐     │
│  │   Integrierende Anwendung (außerhalb Scope)    │     │
│  │   - Benutzerschnittstelle (UI)                 │     │
│  │   - GPS-Sensor-Zugriff                         │     │
│  │   - Benutzereingaben (Zieleingabe)             │     │
│  │   - Visualisierung (Karte, Kompass)            │     │
│  └──────────────────┬──────────────────────────────┘     │
│                     │ API-Aufrufe                         │
│                     │ (BearingComponent Interface)        │
│                     ▼                                     │
│  ┌─────────────────────────────────────────────────┐     │
│  │   JAVA PEILUNGS-KOMPONENTE (Scope)             │     │
│  │   ┌─────────────────────────────────────┐       │     │
│  │   │  API Layer                          │       │     │
│  │   │  - BearingComponent (Facade)        │       │     │
│  │   │  - Event Listeners                  │       │     │
│  │   └────────────┬────────────────────────┘       │     │
│  │                ▼                                │     │
│  │   ┌─────────────────────────────────────┐       │     │
│  │   │  Business Logic                     │       │     │
│  │   │  - BearingCalculator                │       │     │
│  │   │  - GpsTracker                       │       │     │
│  │   │  - Validation                       │       │     │
│  │   └────────────┬────────────────────────┘       │     │
│  │                ▼                                │     │
│  │   ┌─────────────────────────────────────┐       │     │
│  │   │  Data Access                        │       │     │
│  │   │  - GpxExporter                      │       │     │
│  │   │  - File I/O                         │       │     │
│  │   └────────────┬────────────────────────┘       │     │
│  └────────────────┼──────────────────────────────────────┘
│                   │ File Write                            │
│                   ▼                                       │
│  ┌─────────────────────────────────────────────────┐     │
│  │   Dateisystem                                   │     │
│  │   - GPX-Dateien (./gps-tracks/)                 │     │
│  │   - Log-Dateien                                 │     │
│  └─────────────────────────────────────────────────┘     │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

**Schnittstellen zu externen Systemen:**
1. **Integrierende Anwendung:** Liefert GPS-Daten, empfängt Peilungsinformationen
2. **Dateisystem:** Speicherung von GPX-Tracks und Logs

**Keine Schnittstellen zu:**
- GPS-Hardware (direkt)
- Netzwerk-Services
- Datenbanken
- UI-Frameworks

#### 2.1.2 Produktschnittstellen

**Hauptschnittstelle: BearingComponent (Java API)**

```java
public interface BearingComponent {
    // Lifecycle
    void startBearing(GeoCoordinate target, BearingConfig config) 
        throws IllegalArgumentException, IllegalStateException;
    void updatePosition(GeoCoordinate position) 
        throws IllegalArgumentException, IllegalStateException;
    GpxFile stopBearing() 
        throws IllegalStateException, IOException;
    GpxFile abortBearing() 
        throws IllegalStateException, IOException;
    
    // Query
    BearingInfo getCurrentBearing() throws IllegalStateException;
    boolean isBearingActive();
    
    // Events
    void addListener(BearingListener listener);
    void removeListener(BearingListener listener);
    
    // Resource Management
    void shutdown();
}
```

**Event-Interface:**

```java
public interface BearingListener {
    default void onBearingUpdate(BearingInfo info) {}
    default void onTrackPointRecorded(GeoCoordinate point) {}
    default void onTargetReached(BearingInfo finalInfo) {}
    default void onGpsSignalLost(Instant lostAt) {}
    default void onGpsSignalRestored(Instant restoredAt) {}
    default void onBearingAborted(BearingInfo lastInfo) {}
    default void onError(BearingException exception) {}
}
```

**Datenstrukturen:**

```java
// Geografische Koordinate (Immutable)
public final class GeoCoordinate {
    private final double latitude;      // -90.0 bis +90.0
    private final double longitude;     // -180.0 bis +180.0
    private final double elevation;     // Meter über NN
    private final Instant timestamp;    // UTC
    private final double accuracy;      // HDOP
    private final double speed;         // m/s (optional)
    private final double course;        // 0-360° (optional)
    
    // Builder für flexible Konstruktion
    public static class Builder { ... }
}

// Peilungsinformationen (Snapshot, Immutable)
public final class BearingInfo {
    private final double azimuth;           // 0-360° (geografisch)
    private final double magneticAzimuth;   // 0-360° (magnetisch)
    private final double distance;          // Meter
    private final double initialDistance;   // Startdistanz
    private final double deviation;         // Kursabweichung
    private final GeoCoordinate current;    // Aktuelle Position
    private final GeoCoordinate target;     // Zielposition
    private final Instant calculatedAt;     // Berechnungszeitpunkt
    
    // Berechnete Werte
    public double getProgress();            // 0.0-1.0
    public double getRemainingDistance();   // Meter
}

// GPX-Datei-Referenz
public final class GpxFile {
    private final Path filePath;            // Pfad zur GPX-Datei
    private final int trackPointCount;      // Anzahl Punkte
    private final Duration duration;        // Tracking-Dauer
    private final double totalDistance;     // Gesamtdistanz
    private final GpxStatus status;         // COMPLETED/ABORTED/ERROR
    
    public enum GpxStatus {
        COMPLETED, ABORTED, ERROR
    }
}

// Konfiguration
public final class BearingConfig {
    private final Duration trackingInterval;        // GPS-Aufzeichnungs-Intervall
    private final Path outputDirectory;             // GPX-Ausgabeverzeichnis
    private final String fileNamePattern;           // Dateinamens-Muster
    private final double minAccuracy;               // Max HDOP
    private final boolean enableKalmanFilter;       // GPS-Glättung
    private final boolean compressGpx;              // GZIP-Kompression
    private final int maxTrackPoints;               // Limit für Auto-Split
    
    // Builder + vordefinierte Konfigurationen
    public static class Builder { ... }
    public static BearingConfig eco() { ... }
    public static BearingConfig standard() { ... }
    public static BearingConfig precise() { ... }
}
```

#### 2.1.3 Hardware-Schnittstellen

**Keine direkten Hardware-Schnittstellen.**

Die Komponente greift nicht direkt auf GPS-Hardware zu. GPS-Daten werden von der integrierenden Anwendung geliefert.

#### 2.1.4 Software-Schnittstellen

**Abhängigkeiten:**

| Komponente | Version | Zweck |
|------------|---------|-------|
| Java SE | 11+ | Laufzeitumgebung |
| SLF4J API | 1.7.36 | Logging-Interface |
| JAXB | 2.3.1 | XML-Binding für GPX |
| (Optional) GeographicLib | 1.52 | Präzise geodätische Berechnungen |

**Datei-Schnittstellen:**

**Output: GPX 1.1 XML-Dateien**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" 
     creator="JAVA Bearing Component 1.0"
     xmlns="http://www.topografix.com/GPX/1/1"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://www.topografix.com/GPX/1/1 
                         http://www.topografix.com/GPX/1/1/gpx.xsd">
  
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
      <bearing:initialDistance>15234.5</bearing:initialDistance>
    </extensions>
    <trkseg>
      <trkpt lat="48.1234" lon="9.5678">
        <ele>300.5</ele>
        <time>2026-04-16T12:00:01Z</time>
        <hdop>1.2</hdop>
        <extensions>
          <speed>2.5</speed>
          <course>45.0</course>
        </extensions>
      </trkpt>
      <!-- weitere Trackpunkte -->
    </trkseg>
  </trk>
</gpx>
```

**Dateinamens-Konvention:**
- Standard: `bearing_YYYYMMDD_HHmmss.gpx`
- Abgebrochen: `bearing_YYYYMMDD_HHmmss_aborted.gpx`
- Beispiel: `bearing_20260416_143022.gpx`

#### 2.1.5 Kommunikations-Schnittstellen

**Keine Netzwerk-Kommunikation erforderlich.**

Die Komponente arbeitet vollständig offline und benötigt keine Internet-Verbindung.

**Optionale externe APIs (nicht im Kern-Scope):**
- What3Words API: Für benutzerfreundliche Adressierung (z.B. "///apfel.baum.wiese")
- Diese APIs sind optional und nicht Teil der Kern-Anforderungen

### 2.2 Produktfunktionen

Die JAVA Peilungs-Komponente bietet folgende Hauptfunktionen:

#### 2.2.1 Peilungsberechnung

**Beschreibung:** Berechnung der Richtung (Azimut) und Entfernung vom aktuellen Standpunkt zum Zielpunkt.

**Funktionen:**
- Berechnung des geografischen Azimuts (0-360°, Nord = 0°)
- Berechnung des magnetischen Azimuts (mit Deklinations-Korrektur)
- Großkreis-Distanzberechnung (Haversine-Formel)
- Kontinuierliche Aktualisierung bei Positionsänderung
- Berechnung der Kursabweichung

**Use Cases:**
- UC-01: Peilung starten
- UC-02: Position aktualisieren
- UC-03: Aktuelle Peilung abfragen

#### 2.2.2 GPS-Track-Aufzeichnung

**Beschreibung:** Kontinuierliche Aufzeichnung von GPS-Punkten während der Peilung.

**Funktionen:**
- Zeitgesteuerte Aufzeichnung (konfigurierbare Intervalle)
- GPS-Punkt-Validierung (Koordinatenbereich, Genauigkeit)
- Filtering von ungültigen Punkten (HDOP, Geschwindigkeit)
- In-Memory-Speicherung mit automatischem Flush
- Optional: Kalman-Filter für Glättung

**Use Cases:**
- UC-02: Position aktualisieren (impliziert Aufzeichnung)
- UC-04: GPS-Signal-Verlust handhaben

#### 2.2.3 GPX-Export

**Beschreibung:** Speicherung der aufgezeichneten GPS-Tracks als GPX 1.1-konforme Dateien.

**Funktionen:**
- Generierung von GPX 1.1 XML
- Metadaten-Einbettung (Start-/Ziel-Koordinaten, Status)
- Validierung gegen GPX-Schema
- Atomare Datei-Operationen
- Optional: Track-Vereinfachung (Douglas-Peucker)
- Optional: GZIP-Kompression

**Use Cases:**
- UC-03: Peilung beenden
- UC-05: Peilung abbrechen

#### 2.2.4 Event-Benachrichtigungen

**Beschreibung:** Asynchrone Benachrichtigungen über Zustandsänderungen.

**Events:**
- Peilungsaktualisierung (neue Berechnung)
- GPS-Punkt aufgezeichnet
- Ziel erreicht (< 10m Distanz)
- GPS-Signal verloren
- GPS-Signal wiederhergestellt
- Peilung abgebrochen
- Fehler aufgetreten

**Use Cases:**
- UC-06: Event-Listener registrieren
- UC-07: Auf Zielannäherung reagieren

#### 2.2.5 Konfiguration

**Beschreibung:** Flexible Konfiguration des Verhaltens.

**Konfigurierbare Parameter:**
- Tracking-Intervall (0.5s - 10s)
- Ausgabeverzeichnis
- Dateinamens-Muster
- Genauigkeitsanforderungen (max HDOP)
- Kalman-Filter (ein/aus)
- GPX-Kompression (ein/aus)
- Track-Punkt-Limit

**Vordefinierte Profile:**
- Eco-Modus (batterieschonend, 5s Intervall)
- Standard (ausgewogen, 2s Intervall)
- Präzise (hohe Genauigkeit, 1s Intervall)

### 2.3 Benutzercharakteristika

#### 2.3.1 Primäre Benutzer: Java-Entwickler

**Profil:**
- Erfahrung mit Java SE 11+
- Grundkenntnisse in Geodäsie/GPS
- Vertrautheit mit Event-Driven Programming
- Kenntnisse in Maven/Gradle

**Nutzungskontext:**
- Integration in Desktop-Anwendungen
- Integration in Mobile-Apps (Android)
- Integration in Server-Anwendungen
- Verwendung als Bibliothek in größeren Projekten

**Erwartungen:**
- Einfache, intuitive API
- Gute Dokumentation (JavaDoc)
- Klare Fehlerbehandlung
- Beispielcode
- Performante Ausführung

#### 2.3.2 Sekundäre Benutzer

**Tester:**
- Benötigen testbare Schnittstellen
- Erwarten umfassende Unit-Tests
- Benötigen klare Testdokumentation

**Wartungsteam:**
- Benötigen klare Architektur-Dokumentation
- Erwarten modularen, erweiterbaren Code
- Benötigen vollständige JavaDoc

**Endnutzer (indirekt):**
- Interagieren nicht direkt mit der Komponente
- Nutzen integrierende Anwendungen
- Profitieren von Zuverlässigkeit und Performance

### 2.4 Einschränkungen

#### 2.4.1 Technische Einschränkungen

**TC-01: Keine UI-Komponenten**
- Die Komponente DARF KEINE grafischen Benutzeroberflächen enthalten
- Alle Interaktionen erfolgen über die Java-API

**TC-02: Keine Hardware-Anbindung**
- Die Komponente greift NICHT direkt auf GPS-Hardware zu
- GPS-Daten werden von der Host-Anwendung geliefert

**TC-03: Keine Kartendarstellung**
- Die Komponente enthält KEINE Karten-Rendering-Funktionalität
- Visualisierung ist Aufgabe der integrierenden Anwendung

**TC-04: Plattformunabhängigkeit**
- Die Komponente MUSS auf allen JVM-11+-Plattformen laufen
- Keine nativen Abhängigkeiten (JNI)
- Keine plattformspezifischen APIs

#### 2.4.2 Regulatorische Einschränkungen

**RC-01: Datenschutz**
- GPS-Daten werden nur lokal gespeichert
- Keine Übertragung an externe Services
- Löschung auf Anforderung möglich

**RC-02: Lizenzen**
- Verwendung von Open-Source-Bibliotheken mit kompatiblen Lizenzen
- Keine GPL-Abhängigkeiten (um kommerzielle Nutzung zu ermöglichen)

#### 2.4.3 Design-Einschränkungen

**DC-01: Java 11 Minimum**
- Mindestens Java 11 (LTS)
- Verwendung moderner Java-Features (Module, etc.)

**DC-02: Maven-Build**
- Projekt MUSS mit Maven 3.6+ buildbar sein
- Standardisierte POM-Struktur

**DC-03: Keine Datenbank**
- Persistierung nur über Dateisystem
- Keine JDBC/JPA-Abhängigkeiten

### 2.5 Annahmen und Abhängigkeiten

#### 2.5.1 Annahmen

**AS-01: GPS-Datenqualität**
- Es wird angenommen, dass die integrierende Anwendung valide GPS-Daten liefert
- GPS-Daten entsprechen WGS84-Standard
- Zeitstempel sind in UTC

**AS-02: Dateisystem-Zugriff**
- Es wird angenommen, dass Schreibrechte im konfigurierten Ausgabeverzeichnis vorhanden sind
- Ausreichender Speicherplatz für GPX-Dateien ist verfügbar

**AS-03: Single-User-Kontext**
- Ein BearingComponent-Instanz wird von nur einer Peilung gleichzeitig genutzt
- Multi-Threading wird nur intern verwendet

**AS-04: Kontinuierliche Positionsupdates**
- Die integrierende Anwendung liefert regelmäßige Positionsupdates
- Updates erfolgen mindestens alle 10 Sekunden

#### 2.5.2 Abhängigkeiten

**DP-01: Java Runtime**
- Abhängigkeit von JRE/JDK 11 oder höher
- Verfügbarkeit von Standard-Java-Bibliotheken

**DP-02: SLF4J**
- Abhängigkeit von SLF4J API für Logging
- Host-Anwendung muss SLF4J-Implementierung bereitstellen (z.B. Logback)

**DP-03: JAXB**
- Abhängigkeit von JAXB für XML-Verarbeitung
- In Java 11+ nicht mehr im JDK enthalten, muss separat bereitgestellt werden

**DP-04: Dateisystem**
- Abhängigkeit von funktionierendem Dateisystem
- Unterstützung für atomare Datei-Operationen (temp + rename)

---

## 3. DETAILLIERTE ANFORDERUNGEN

### 3.1 Externe Schnittstellen

#### 3.1.1 API-Schnittstelle: BearingComponent

[DETAILLIERTE API-DOKUMENTATION HIER EINFÜGEN]

Siehe Abschnitt 2.1.2 für vollständige Interface-Definition.

**Zusätzliche Anforderungen:**

**REQ-API-001: Thread-Safety für Lesezugriffe**
- Priorität: Hoch
- Das BearingComponent-Interface MUSS thread-safe für gleichzeitige Lesezugriffe sein
- Mehrere Threads DÜRFEN gleichzeitig `getCurrentBearing()` und `isBearingActive()` aufrufen
- Schreibzugriffe (`startBearing`, `updatePosition`, etc.) MÜSSEN synchronisiert werden

**REQ-API-002: Exception-Handling**
- Priorität: Hoch
- Alle öffentlichen Methoden MÜSSEN dokumentierte Exceptions werfen
- `IllegalArgumentException` bei ungültigen Parametern
- `IllegalStateException` bei ungültigem Zustand (z.B. keine aktive Peilung)
- `IOException` bei I/O-Fehlern
- `BearingException` (checked) für fachliche Fehler

**REQ-API-003: Null-Sicherheit**
- Priorität: Mittel
- Keine öffentliche Methode DARF `null` als Rückgabewert liefern
- Verwendung von `Optional<T>` für optionale Werte
- `@NonNull` und `@Nullable` Annotationen verwenden

#### 3.1.2 Event-Schnittstelle: BearingListener

**REQ-EVENT-001: Asynchrone Benachrichtigung**
- Priorität: Hoch
- Events MÜSSEN asynchron in einem separaten Thread ausgeliefert werden
- Event-Delivery DARF die Hauptverarbeitung NICHT blockieren
- Thread-Pool-Größe: 10 Threads

**REQ-EVENT-002: Event-Reihenfolge**
- Priorität: Mittel
- Events für denselben Listener MÜSSEN in der Reihenfolge ihres Auftretens geliefert werden
- FIFO-Garantie pro Listener

**REQ-EVENT-003: Exception-Isolation**
- Priorität: Hoch
- Exceptions in Listener-Implementierungen DÜRFEN NICHT die Komponente beeinträchtigen
- Exceptions MÜSSEN geloggt werden
- Fehlerhafte Listener DÜRFEN NICHT automatisch entfernt werden

### 3.2 Funktionale Anforderungen

Die funktionalen Anforderungen sind nach Funktionsgruppen organisiert und mit eindeutigen IDs versehen.

#### 3.2.1 Peilungsberechnung

**FR-001: Azimut-Berechnung (geografisch)**
- **Priorität:** Hoch (Kern-Feature)
- **Beschreibung:** Das System MUSS den geografischen Azimut vom aktuellen Standpunkt zum Zielpunkt berechnen
- **Input:** 
  - Aktuelle Position (GeoCoordinate)
  - Zielposition (GeoCoordinate)
- **Output:** Azimut in Grad (0.0 - 360.0)
  - 0° = Nord
  - 90° = Ost
  - 180° = Süd
  - 270° = West
- **Algorithmus:** Bearing-Formel mit atan2
- **Genauigkeit:** ±1° bei Distanzen > 10 Meter
- **Performance:** < 10 Millisekunden
- **Testbarkeit:** Vergleich mit bekannten Koordinaten-Paaren
- **Abhängigkeiten:** Keine

**FR-002: Azimut-Berechnung (magnetisch)**
- **Priorität:** Mittel
- **Beschreibung:** Das System SOLL den magnetischen Azimut berechnen können
- **Input:** Geografischer Azimut + Position
- **Output:** Magnetischer Azimut (0.0 - 360.0)
- **Algorithmus:** Geografischer Azimut + Magnetische Deklination
- **Deklinations-Quelle:** WMM (World Magnetic Model)
- **Genauigkeit:** ±2°
- **Performance:** < 5 Millisekunden
- **Testbarkeit:** Vergleich mit WMM-Referenzwerten

**FR-003: Distanzberechnung (Haversine)**
- **Priorität:** Hoch (Kern-Feature)
- **Beschreibung:** Das System MUSS die Großkreis-Distanz zwischen zwei Punkten berechnen
- **Input:** Zwei GeoCoordinate-Objekte
- **Output:** Distanz in Metern (double)
- **Algorithmus:** Haversine-Formel
  ```
  a = sin²(Δlat/2) + cos(lat1) * cos(lat2) * sin²(Δlon/2)
  c = 2 * atan2(√a, √(1-a))
  d = R * c (R = Erdradius = 6371000 m)
  ```
- **Genauigkeit:** ±0.1% für Distanzen < 1000 km
- **Performance:** < 5 Millisekunden
- **Testbarkeit:** Bekannte Distanzen (z.B. Stuttgart-München ≈ 192 km)
- **Abhängigkeiten:** Keine

**FR-004: Kursabweichung**
- **Priorität:** Mittel
- **Beschreibung:** Das System SOLL die Abweichung vom Sollkurs berechnen
- **Input:** 
  - Aktueller Kurs (aus GPS-Daten)
  - Soll-Azimut (zum Ziel)
- **Output:** Abweichung in Grad (-180.0 bis +180.0)
  - Negativ = links vom Kurs
  - Positiv = rechts vom Kurs
- **Algorithmus:** Normalisierte Winkeldifferenz
- **Genauigkeit:** ±1°
- **Performance:** < 1 Millisekunde

**FR-005: Fortschrittsberechnung**
- **Priorität:** Niedrig
- **Beschreibung:** Das System KANN den Fortschritt zur Zielerreichung berechnen
- **Input:**
  - Initiale Distanz
  - Aktuelle Distanz
- **Output:** Fortschritt (0.0 - 1.0)
  - 0.0 = Start
  - 1.0 = Ziel erreicht
- **Algorithmus:** `1.0 - (currentDistance / initialDistance)`
- **Performance:** < 1 Millisekunde

#### 3.2.2 GPS-Track-Aufzeichnung

**FR-010: Kontinuierliche Aufzeichnung**
- **Priorität:** Hoch (Kern-Feature)
- **Beschreibung:** Das System MUSS GPS-Punkte kontinuierlich aufzeichnen während eine Peilung aktiv ist
- **Trigger:** `updatePosition()` wird aufgerufen
- **Bedingung:** Peilung ist aktiv (Status = ACTIVE)
- **Aktion:**
  1. GPS-Punkt validieren (siehe FR-011)
  2. Bei Valid: Punkt in Track einfügen
  3. Bei Invalid: Punkt verwerfen + loggen
- **Speicherung:** In-Memory bis Flush oder Ende
- **Performance:** < 50 Millisekunden pro Punkt
- **Testbarkeit:** Anzahl aufgezeichneter Punkte prüfen

**FR-011: GPS-Punkt-Validierung**
- **Priorität:** Hoch (Qualitätssicherung)
- **Beschreibung:** Das System MUSS jeden GPS-Punkt vor Aufzeichnung validieren
- **Validierungsregeln:**
  1. **Koordinaten im gültigen Bereich:**
     - Latitude: -90.0 ≤ lat ≤ 90.0
     - Longitude: -180.0 ≤ lon ≤ 180.0
     - Elevation: -500.0 ≤ ele ≤ 9000.0
  2. **Genauigkeit akzeptabel:**
     - HDOP ≤ konfigurierter Grenzwert (Standard: 5.0)
  3. **Zeitstempel plausibel:**
     - Nicht in der Zukunft (> now + 1 Minute)
     - Nicht älter als 1 Stunde
  4. **Geschwindigkeit plausibel:**
     - < 300 m/s (Outlier-Detection)
- **Bei Validierungs-Fehler:**
  - Punkt verwerfen
  - Warning-Log schreiben
  - Optional: Event `onInvalidGpsPoint()` auslösen
- **Performance:** < 5 Millisekunden
- **Testbarkeit:** Ungültige Punkte erstellen und Verwerfung testen

**FR-012: Kalman-Filter (Optional)**
- **Priorität:** Niedrig (Erweiterung)
- **Beschreibung:** Das System KANN GPS-Punkte mit einem Kalman-Filter glätten
- **Konfiguration:** `BearingConfig.enableKalmanFilter`
- **Algorithmus:** 1D-Kalman-Filter für Latitude und Longitude
- **Parameter:**
  - Process Noise (Q): 0.001
  - Measurement Noise (R): 4.0
- **Effekt:** Reduzierung von GPS-Jitter
- **Performance:** < 10 Millisekunden zusätzlich
- **Testbarkeit:** Vergleich gefilterter vs. ungefilterter Track

**FR-013: GPS-Signal-Verlust**
- **Priorität:** Mittel (Robustheit)
- **Beschreibung:** Das System MUSS GPS-Signal-Verlust erkennen und handhaben
- **Erkennung:** Keine `updatePosition()` für > 30 Sekunden
- **Aktion:**
  1. Status setzen: GPS_SIGNAL_LOST
  2. Event auslösen: `onGpsSignalLost()`
  3. Gap im Track markieren
  4. Letzte bekannte Position speichern
- **Wiederherstellung:**
  1. Erstes `updatePosition()` nach Verlust
  2. Event auslösen: `onGpsSignalRestored()`
  3. Gap-Ende im Track markieren
- **Testbarkeit:** Signal-Verlust simulieren

**FR-014: Track-Punkt-Limit**
- **Priorität:** Mittel (Speicher-Management)
- **Beschreibung:** Das System SOLL Track-Punkte limitieren um Speicher zu schonen
- **Soft-Limit:** 10.000 Punkte
- **Hard-Limit:** 50.000 Punkte
- **Verhalten bei Soft-Limit:**
  - Auto-Flush: Punkte 0-5000 in Datei schreiben
  - Im Speicher bleiben: Punkte 5001-10000
  - Warnung loggen
- **Verhalten bei Hard-Limit:**
  - Automatischer Split in neue GPX-Datei
  - Suffix: `_part1.gpx`, `_part2.gpx`
  - Error-Log schreiben
- **Performance:** Flush < 500 Millisekunden
- **Testbarkeit:** > 10.000 Punkte erzeugen

#### 3.2.3 GPX-Export

**FR-020: GPX 1.1 Standard-Konformität**
- **Priorität:** Hoch (Interoperabilität)
- **Beschreibung:** Das System MUSS GPX-Dateien generieren, die dem GPX 1.1 Standard entsprechen
- **Schema:** http://www.topografix.com/GPX/1/1/gpx.xsd
- **Validierung:** Gegen XSD-Schema vor Speicherung
- **Encoding:** UTF-8
- **XML-Deklaration:** `<?xml version="1.0" encoding="UTF-8"?>`
- **Root-Element:** `<gpx version="1.1" creator="...">`
- **Testbarkeit:** XSD-Validierung mit externem Tool

**FR-021: GPX-Metadaten**
- **Priorität:** Hoch
- **Beschreibung:** Das System MUSS folgende Metadaten in GPX-Dateien einfügen
- **Pflicht-Metadaten:**
  - `<name>`: Track-Name ("Bearing Track")
  - `<time>`: Start-Zeitstempel (UTC, ISO 8601)
  - `<bounds>`: Bounding-Box (min/max Lat/Lon)
- **Optionale Metadaten:**
  - `<desc>`: Beschreibung
  - `<author>`: Creator-Information
  - `<link>`: URL zur Dokumentation
- **Custom Extensions (bearing:*):**
  - `<bearing:target lat="..." lon="..."/>`: Zielkoordinate
  - `<bearing:status>`: COMPLETED | ABORTED | ERROR
  - `<bearing:initialDistance>`: Startdistanz in Metern
  - `<bearing:trackPoints>`: Anzahl Punkte

**FR-022: Track-Segmente**
- **Priorität:** Hoch
- **Beschreibung:** Das System MUSS GPS-Punkte in Track-Segmente (`<trkseg>`) organisieren
- **Segmentierung:**
  - Ein neues Segment bei GPS-Signal-Wiederherstellung
  - Ein neues Segment bei manuellem Split
- **Track-Punkt-Elemente:**
  - `<trkpt lat="..." lon="...">`: Pflicht
  - `<ele>`: Elevation (Pflicht)
  - `<time>`: Zeitstempel UTC (Pflicht)
  - `<hdop>`: Horizontal Dilution of Precision (Optional)
  - `<extensions><speed>`: Geschwindigkeit m/s (Optional)
  - `<extensions><course>`: Kurs 0-360° (Optional)

**FR-023: Atomare Datei-Operationen**
- **Priorität:** Hoch (Datenintegrität)
- **Beschreibung:** Das System MUSS GPX-Dateien atomar schreiben
- **Algorithmus:**
  1. GPX-Content generieren
  2. In Temp-Datei schreiben (`.tmp` Suffix)
  3. Temp-Datei validieren
  4. Atomic Rename: Temp → Final
  5. Bei Fehler: Temp-Datei löschen
- **Fehlerbehandlung:**
  - IOException → Retry (3x mit Exponential Backoff)
  - Validation-Error → Exception, Temp-Datei behalten für Debugging
- **Testbarkeit:** Datei-Corruption-Szenarien

**FR-024: GPX-Validierung**
- **Priorität:** Mittel (Qualitätssicherung)
- **Beschreibung:** Das System SOLL generierte GPX-Dateien validieren
- **Validierung:**
  1. XML Well-Formedness
  2. GPX 1.1 Schema-Konformität
  3. Koordinaten im gültigen Bereich
  4. Zeitstempel chronologisch
- **Bei Validierungs-Fehler:**
  - Exception werfen
  - Detaillierte Fehlermeldung
  - GPX-Datei NICHT speichern
- **Performance:** < 100 Millisekunden für 1000 Punkte
- **Testbarkeit:** Ungültige GPX erzeugen

**FR-025: Track-Vereinfachung (Optional)**
- **Priorität:** Niedrig (Erweiterung)
- **Beschreibung:** Das System KANN Tracks mit Douglas-Peucker vereinfachen
- **Trigger:** Track hat > 5000 Punkte
- **Algorithmus:** Ramer-Douglas-Peucker mit konfigurierbarer Toleranz
- **Toleranz:** Standard 5 Meter
- **Effekt:** Reduzierung um 30-50% bei minimalem Informationsverlust
- **Konfiguration:** `BearingConfig.simplifyTrack`
- **Performance:** < 200 Millisekunden für 10.000 Punkte
- **Testbarkeit:** Anzahl Punkte vor/nach Vereinfachung

**FR-026: GPX-Kompression (Optional)**
- **Priorität:** Niedrig (Erweiterung)
- **Beschreibung:** Das System KANN GPX-Dateien komprimieren
- **Format:** GZIP (.gpx.gz)
- **Konfiguration:** `BearingConfig.compressGpx`
- **Kompressions-Ratio:** ~70-80% Größenreduktion
- **Performance:** < 100 Millisekunden für 1 MB
- **Testbarkeit:** Dateigröße vor/nach Kompression

#### 3.2.4 Zustandsverwaltung

**FR-030: Peilungs-Status**
- **Priorität:** Hoch
- **Beschreibung:** Das System MUSS einen Peilungs-Status verwalten
- **Zustände:**
  - **IDLE:** Keine Peilung aktiv
  - **ACTIVE:** Peilung läuft
  - **SAVING:** GPX wird gespeichert
  - **COMPLETED:** Peilung erfolgreich beendet
  - **ABORTED:** Peilung abgebrochen
  - **ERROR:** Fehler aufgetreten
- **Zustandsübergänge:**
  - IDLE → ACTIVE: `startBearing()`
  - ACTIVE → SAVING: `stopBearing()` oder `abortBearing()`
  - SAVING → COMPLETED: GPX erfolgreich gespeichert
  - SAVING → ERROR: GPX-Speicherung fehlgeschlagen
  - * → IDLE: `shutdown()` oder neue `startBearing()`
- **Zustandsabfrage:** `isBearingActive()`, `getStatus()`
- **Testbarkeit:** Alle Übergänge durchlaufen

**FR-031: Peilung starten**
- **Priorität:** Hoch (Kern-Feature)
- **Beschreibung:** Das System MUSS eine neue Peilung starten können
- **Pre-Condition:** Status = IDLE
- **Input:**
  - `target`: Zielkoordinate (GeoCoordinate)
  - `config`: Konfiguration (BearingConfig)
- **Ablauf:**
  1. Zielkoordinate validieren
  2. Konfiguration validieren
  3. GPS-Tracker initialisieren
  4. Initiale Peilung berechnen
  5. Status → ACTIVE
  6. Event auslösen: `onBearingStarted()`
- **Post-Condition:** Status = ACTIVE
- **Exception:** `IllegalArgumentException` bei ungültigen Parametern
- **Exception:** `IllegalStateException` wenn bereits aktiv
- **Performance:** < 50 Millisekunden
- **Testbarkeit:** Status-Übergang prüfen

**FR-032: Position aktualisieren**
- **Priorität:** Hoch (Kern-Feature)
- **Beschreibung:** Das System MUSS die aktuelle Position aktualisieren können
- **Pre-Condition:** Status = ACTIVE
- **Input:** `position`: Neue GPS-Position (GeoCoordinate)
- **Ablauf:**
  1. Position validieren (FR-011)
  2. Position in Track aufzeichnen
  3. Neue Peilung berechnen
  4. Zielannäherung prüfen (< 10m → Event)
  5. Event auslösen: `onBearingUpdate()`
- **Post-Condition:** Track um einen Punkt erweitert
- **Exception:** `IllegalArgumentException` bei ungültiger Position
- **Exception:** `IllegalStateException` wenn nicht aktiv
- **Performance:** < 50 Millisekunden
- **Testbarkeit:** Track-Länge erhöht sich

**FR-033: Peilung beenden**
- **Priorität:** Hoch (Kern-Feature)
- **Beschreibung:** Das System MUSS eine aktive Peilung beenden können
- **Pre-Condition:** Status = ACTIVE
- **Ablauf:**
  1. Status → SAVING
  2. GPS-Tracker stoppen
  3. GPX-Datei generieren
  4. GPX-Datei speichern (atomar)
  5. Status → COMPLETED
  6. GpxFile-Objekt zurückgeben
  7. Ressourcen freigeben
- **Post-Condition:** 
  - Status = COMPLETED
  - GPX-Datei existiert
  - Track im Speicher gelöscht
- **Exception:** `IOException` bei Speicher-Fehler
- **Performance:** < 500 Millisekunden
- **Testbarkeit:** GPX-Datei existiert und ist valide

**FR-034: Peilung abbrechen**
- **Priorität:** Mittel
- **Beschreibung:** Das System MUSS eine aktive Peilung abbrechen können
- **Pre-Condition:** Status = ACTIVE
- **Ablauf:**
  1. Status → SAVING
  2. GPS-Tracker stoppen
  3. Track markieren: status = ABORTED
  4. GPX-Datei generieren (mit "_aborted" Suffix)
  5. GPX-Datei speichern
  6. Status → ABORTED
  7. Event auslösen: `onBearingAborted()`
  8. GpxFile-Objekt zurückgeben
- **Post-Condition:** 
  - Status = ABORTED
  - GPX-Datei mit "_aborted" existiert
- **Performance:** < 500 Millisekunden
- **Testbarkeit:** Dateiname enthält "_aborted"

#### 3.2.5 Event-System

**FR-040: Event-Listener-Verwaltung**
- **Priorität:** Hoch
- **Beschreibung:** Das System MUSS Event-Listener verwalten können
- **Operationen:**
  - `addListener(listener)`: Listener registrieren
  - `removeListener(listener)`: Listener deregistrieren
- **Constraints:**
  - Mehrere Listener erlaubt
  - Duplikate werden ignoriert (Set-Semantik)
  - Null-Listener werden abgelehnt
- **Testbarkeit:** Listener hinzufügen/entfernen

**FR-041: Peilungsaktualisierung-Event**
- **Priorität:** Hoch
- **Beschreibung:** Das System MUSS bei jeder Peilungsaktualisierung ein Event auslösen
- **Trigger:** Erfolgreicher Aufruf von `updatePosition()`
- **Event:** `onBearingUpdate(BearingInfo info)`
- **Payload:** Aktuelles BearingInfo-Objekt
- **Timing:** Asynchron (innerhalb von 100ms)
- **Testbarkeit:** Event-Counter

**FR-042: Track-Punkt-Aufgezeichnet-Event**
- **Priorität:** Mittel
- **Beschreibung:** Das System SOLL bei jedem aufgezeichneten Punkt ein Event auslösen
- **Trigger:** GPS-Punkt erfolgreich validiert und in Track eingefügt
- **Event:** `onTrackPointRecorded(GeoCoordinate point)`
- **Payload:** Der aufgezeichnete Punkt
- **Timing:** Asynchron
- **Testbarkeit:** Event-Counter

**FR-043: Ziel-Erreicht-Event**
- **Priorität:** Mittel
- **Beschreibung:** Das System SOLL ein Event auslösen wenn Ziel erreicht wurde
- **Trigger:** Distanz zum Ziel < 10 Meter
- **Event:** `onTargetReached(BearingInfo finalInfo)`
- **Payload:** Finales BearingInfo
- **Einmaligkeit:** Nur einmal pro Peilung
- **Testbarkeit:** Position nahe Ziel simulieren

**FR-044: GPS-Signal-Events**
- **Priorität:** Mittel
- **Beschreibung:** Das System SOLL Events bei GPS-Signal-Änderungen auslösen
- **Events:**
  - `onGpsSignalLost(Instant lostAt)`: Signal verloren
  - `onGpsSignalRestored(Instant restoredAt)`: Signal wieder da
- **Trigger:** Siehe FR-013
- **Testbarkeit:** Signal-Verlust simulieren

**FR-045: Fehler-Events**
- **Priorität:** Hoch (Robustheit)
- **Beschreibung:** Das System MUSS Events bei Fehlern auslösen
- **Event:** `onError(BearingException exception)`
- **Trigger:** 
  - Validierungs-Fehler
  - I/O-Fehler
  - Berechnungs-Fehler
- **Payload:** Detaillierte Exception mit Kontext
- **Testbarkeit:** Fehler provozieren

### 3.3 Performance-Anforderungen

**NFR-PERF-001: Peilungsberechnung**
- **Beschreibung:** Peilungsberechnung MUSS in maximal 50 Millisekunden abgeschlossen sein
- **Messung:** 95. Perzentil über 1000 Berechnungen
- **Testmethode:** Performance-Test mit JMH

**NFR-PERF-002: GPS-Punkt-Verarbeitung**
- **Beschreibung:** Verarbeitung eines GPS-Punkts MUSS in maximal 100 Millisekunden abgeschlossen sein
- **Umfang:** Validierung + Filterung + Speicherung + Event
- **Testmethode:** Performance-Test

**NFR-PERF-003: GPX-Speicherung**
- **Beschreibung:** GPX-Speicherung SOLL asynchron erfolgen mit maximal 500 Millisekunden Wartezeit
- **Umfang:** Generierung + Validierung + atomares Schreiben
- **Testmethode:** Zeitmessung für 10.000 Punkte

**NFR-PERF-004: Speicherverbrauch**
- **Beschreibung:** Maximaler RAM-Verbrauch SOLL 50 MB nicht überschreiten
- **Bedingung:** Bei 10.000 Track-Punkten im Speicher
- **Testmethode:** Heap-Dump-Analyse

**NFR-PERF-005: CPU-Last**
- **Beschreibung:** CPU-Last im Idle SOLL < 5% sein, bei aktiver Peilung < 20%
- **Testmethode:** Profiling mit VisualVM

**NFR-PERF-006: Startup-Zeit**
- **Beschreibung:** Initialisierung der Komponente MUSS in < 1 Sekunde erfolgen
- **Testmethode:** Zeitmessung von Constructor bis ready-state

### 3.4 Zuverlässigkeits-Anforderungen

**NFR-REL-001: Fehlertoleranz bei GPS-Ausfall**
- **Beschreibung:** System MUSS bei GPS-Signal-Verlust graceful degradieren
- **Verhalten:** Siehe FR-013
- **Testbarkeit:** Signal-Unterbrechung simulieren

**NFR-REL-002: Datenintegrität**
- **Beschreibung:** Keine Datenverluste bei Programmabsturz
- **Maßnahmen:**
  - Regelmäßiges Auto-Flushing (alle 1000 Punkte)
  - Shutdown-Hook für finale Speicherung
  - Temp-Dateien als Recovery
- **Testbarkeit:** Kill-Test während Peilung

**NFR-REL-003: Exception-Recovery**
- **Beschreibung:** System MUSS nach Exceptions weiterarbeiten können
- **Maßnahmen:**
  - Isolierte Exception-Behandlung
  - Automatische Ressourcen-Freigabe
  - Logging aller Exceptions
- **Testbarkeit:** Exception-Injection

**NFR-REL-004: Konsistenz**
- **Beschreibung:** GPX-Dateien MÜSSEN immer konsistent sein
- **Maßnahmen:**
  - Atomare Schreiboperationen
  - Validierung vor Speicherung
  - Temp-Datei bei Fehler behalten
- **Testbarkeit:** Dateisystem-Fehler simulieren

**NFR-REL-005: MTBF (Mean Time Between Failures)**
- **Beschreibung:** System SOLL > 10.000 Peilungen ohne Fehler durchführen können
- **Testmethode:** Stress-Test mit 10.000+ Peilungen

### 3.5 Wartbarkeits-Anforderungen

**NFR-MAINT-001: Modulare Architektur**
- **Beschreibung:** System MUSS in unabhängige Module aufgeteilt sein
- **Module:** bearing-core, gps-tracker, gpx-exporter, data-model, bearing-utils
- **Coupling:** Loose (nur über Interfaces)
- **Cohesion:** High (jedes Modul hat klar definierte Verantwortlichkeit)

**NFR-MAINT-002: JavaDoc-Abdeckung**
- **Beschreibung:** Alle public APIs MÜSSEN vollständig dokumentiert sein
- **Umfang:** Klassen, Methoden, Parameter, Return-Values, Exceptions
- **Qualität:** Beispiele und Nutzungshinweise
- **Messung:** JavaDoc-Coverage-Plugin

**NFR-MAINT-003: Test-Abdeckung**
- **Beschreibung:** Unit-Test-Coverage MUSS mindestens 80% betragen
- **Messung:** JaCoCo Line-Coverage
- **Ziel-Coverage pro Modul:** Siehe Abschnitt 8.1

**NFR-MAINT-004: Code-Qualität**
- **Beschreibung:** Code MUSS Checkstyle- und PMD-Regeln einhalten
- **Standards:**
  - Google Java Style Guide
  - SOLID Principles
  - Clean Code Practices
- **Messung:** Checkstyle + PMD Plugins

**NFR-MAINT-005: Versionierung**
- **Beschreibung:** Komponente MUSS Semantic Versioning verwenden
- **Format:** MAJOR.MINOR.PATCH
- **Breaking Changes:** MAJOR-Inkrement

### 3.6 Portabilitäts-Anforderungen

**NFR-PORT-001: Plattform-Unabhängigkeit**
- **Beschreibung:** System MUSS auf allen JVM-11+-Plattformen laufen
- **Plattformen:**
  - Windows 10+
  - macOS 10.15+
  - Linux (Ubuntu 20.04+, etc.)
- **Testmethode:** Build und Tests auf allen Plattformen

**NFR-PORT-002: Keine nativen Abhängigkeiten**
- **Beschreibung:** System DARF KEINE nativen Bibliotheken (JNI) verwenden
- **Testmethode:** Dependency-Analyse

**NFR-PORT-003: Standard-Java-APIs**
- **Beschreibung:** System SOLL bevorzugt Standard-Java-APIs verwenden
- **Erlaubte externe Abhängigkeiten:**
  - SLF4J (Logging)
  - JAXB (XML)
  - (Optional) GeographicLib
- **Testmethode:** Dependency-Tree-Analyse

**NFR-PORT-004: Build-System**
- **Beschreibung:** System MUSS mit Standard-Build-Tools buildbar sein
- **Tools:** Maven 3.6+ (primär), Gradle-kompatibel
- **Testmethode:** Clean Build auf frischem System

**NFR-PORT-005: Deployment**
- **Beschreibung:** System MUSS als Standard-JAR deploybar sein
- **Format:** JAR ohne Dependencies (lean JAR)
- **Manifest:** Vollständige Metadaten (Version, Vendor, etc.)

---

## 4. ANHÄNGE

### Anhang A: UML-Diagramme

[UML-Diagramme hier einfügen - siehe Hauptdokumentation]

### Anhang B: Beispielcode

[Beispielcode hier einfügen]

### Anhang C: Glossar

[Zusätzliche Begriffserklärungen]

### Anhang D: Änderungshistorie

[Dokumentierte Änderungen zwischen Versionen]

---

**ENDE DER SPEZIFIKATION**

---

## HINWEISE ZUM AUSFÜLLEN:

1. **[PLATZHALTER]** durch konkrete Werte ersetzen
2. Diagramme aus Hauptdokumentation einfügen
3. Anforderungs-IDs konsistent verwenden
4. Alle Anforderungen mit Priorität versehen
5. Testbarkeit für jede Anforderung sicherstellen
6. Referenzen aktualisieren
7. Inhaltsverzeichnis generieren
8. Seitenzahlen einfügen
9. Formatierung konsistent halten
10. Review durch Kommilitonen

**Umfang-Ziel:** 25-35 Seiten
