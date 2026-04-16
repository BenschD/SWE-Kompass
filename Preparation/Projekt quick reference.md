# JAVA PEILUNGS-KOMPONENTE - QUICK REFERENCE

## 🎯 PROJEKT-ÜBERSICHT
**Ziel:** Peilungs-Funktionalität der iOS Kompass App in Java-Komponente überführen  
**Abgabe:** Source-Code + Dokumentation (65-85 Seiten)  
**Besonderheit:** KEINE UI, systemneutral, lauffähiger Code

---

## ✅ VORLESUNGSTHEMEN-CHECKLISTE

### ✓ Semester 1
- [ ] **Einführung:** Projektkontext verstanden
- [ ] **Analyse (Sophist Regeln):** 
  - [ ] Anforderungen nach Sophist-Regeln formuliert
  - [ ] Stakeholder-Analyse durchgeführt
  - [ ] User Stories vs. Anforderungen (KEINE User Stories laut Bohl!)
- [ ] **Aufwandsschätzung:** Laut Notiz KEINE Aufwandsschätzung nötig
- [ ] **Spezifikation (IEEE 830):**
  - [ ] Einführung (Zweck, Scope, Definitionen)
  - [ ] Systemübersicht
  - [ ] Funktionale Anforderungen
  - [ ] Schnittstellen-Spezifikation
  - [ ] Nicht-funktionale Anforderungen
- [ ] **UML - Klassendiagramm:**
  - [ ] Klassendiagramm für Hauptkomponenten
  - [ ] Beziehungen (Assoziation, Aggregation, Komposition, Vererbung)
  - [ ] Multiplizitäten angeben
- [ ] **Objektorientierte Analyse:**
  - [ ] Use-Case-Diagramme
  - [ ] Sequenzdiagramme (wichtige Abläufe)
  - [ ] Zustandsdiagramme (BearingState)
  - [ ] Aktivitätsdiagramme (optional)
- [ ] **Prozessmodelle:**
  - [ ] Gewähltes Modell dokumentieren (z.B. inkrementell/iterativ)
  - [ ] Begründung für Wahl

### ✓ Semester 2
- [ ] **Grobentwurf:**
  - [ ] Systemarchitektur definiert
  - [ ] Komponentendiagramm
  - [ ] Paketdiagramm
  - [ ] Schichten-Architektur
- [ ] **Architekturmuster:**
  - [ ] Schichtenarchitektur dokumentiert
  - [ ] Alternative Muster diskutiert (MVC, etc.)
  - [ ] Begründung für gewähltes Muster
- [ ] **Entwurfsmuster:**
  - [ ] Facade Pattern (BearingComponent)
  - [ ] Observer Pattern (Event-System)
  - [ ] Builder Pattern (GeoCoordinate, Config)
  - [ ] Strategy Pattern (Distanzberechnungen)
  - [ ] Template Method (GPX-Export)
  - [ ] Factory Pattern (Filter-Erstellung)
  - [ ] Weitere nach Bedarf
  - [ ] UML-Diagramme für jedes Pattern

---

## 📋 WICHTIGE KLÄRUNGEN (beantwortet)

| Frage | Antwort |
|-------|---------|
| Was ist Peilung? | Richtungsbestimmung (Azimut) + Distanzberechnung zum Ziel |
| GPX-Standard? | GPX 1.1 (Topografix) |
| Aufzuzeichnende Daten? | Lat/Lon, Elevation, Timestamp, HDOP, Speed, Course |
| Tracking-Intervall? | Konfigurierbar: 0.5s - 10s (Standard: 2s) |
| Genauigkeit? | ±10m horizontal, ±15m vertikal |
| Performance? | Peilung < 50ms, GPS-Verarbeitung < 100ms |
| Ungültige Koordinaten? | Validierung + Logging + Verwerfung |
| Speicherort GPX? | Konfigurierbar (Default: ./gps-tracks/) |
| Schnittstellen? | Java API (BearingComponent) + GPX-Datei |
| Doku-Umfang? | 65-85 Seiten gesamt |
| GPX-Limit? | Soft: 10.000 Punkte, Hard: 50.000 |
| Module? | 5 Module (core, tracker, exporter, model, utils) |
| Tests? | Ja, jedes Modul eigene Tests |
| Abbruch? | GPX mit "_aborted" speichern |
| APIs? | Optional: What3Words, GeographicLib |
| 1+ Features? | Kalman-Filter, Multi-Target, Geo-Fencing, Stats |

---

## 🏗️ ARCHITEKTUR-ÜBERSICHT

```
┌─────────────────────────────────────┐
│   Integrierende Anwendung           │ ← Außerhalb Scope
└──────────────┬──────────────────────┘
               │ BearingComponent API
┌──────────────▼──────────────────────┐
│   API Layer (Facade)                │
│   - BearingComponent                │
│   - BearingListener                 │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Business Logic Layer              │
│   - BearingCalculator               │
│   - GpsTracker                      │
│   - EventDispatcher                 │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Data Access Layer                 │
│   - GpxExporter                     │
│   - GpxValidator                    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   File System                       │
│   - GPX Files                       │
└─────────────────────────────────────┘
```

**Module:**
1. **bearing-core:** Peilungsberechnung, Koordination
2. **gps-tracker:** GPS-Aufzeichnung, Filterung
3. **gpx-exporter:** GPX-Generierung, Validierung
4. **data-model:** GeoCoordinate, BearingInfo, GpxFile
5. **bearing-utils:** GeoUtils, MathUtils, Logging

---

## 🔑 KERN-KLASSEN

### BearingComponent (Interface)
```java
void startBearing(GeoCoordinate target, BearingConfig config)
void updatePosition(GeoCoordinate position)
GpxFile stopBearing()
GpxFile abortBearing()
BearingInfo getCurrentBearing()
void addListener(BearingListener listener)
```

### GeoCoordinate (Immutable)
```java
double latitude      // -90.0 bis +90.0
double longitude     // -180.0 bis +180.0
double elevation     // Meter
Instant timestamp    // UTC
double accuracy      // HDOP
```

### BearingInfo (Snapshot)
```java
double azimuth              // 0-360°
double distance             // Meter
double deviation            // Kursabweichung
GeoCoordinate current
GeoCoordinate target
```

---

## 🧪 TEST-STRATEGIE

### Test-Coverage-Ziele
- bearing-core: ≥ 90%
- gps-tracker: ≥ 85%
- gpx-exporter: ≥ 80%
- data-model: ≥ 95%
- bearing-utils: ≥ 90%

### Test-Arten
1. **Unit-Tests:** Jede Klasse/Methode isoliert
2. **Integration-Tests:** Module zusammen
3. **System-Tests:** End-to-End
4. **Performance-Tests:** < 50ms Peilung

### Test-Framework
- JUnit 5
- Mockito
- AssertJ

---

## 📐 ENTWURFSMUSTER (Must-Have)

1. **Facade:** BearingComponent vereinfacht Subsystem-Zugriff
2. **Observer:** Event-System für Benachrichtigungen
3. **Builder:** Flexible Objekterzeugung (GeoCoordinate, Config)
4. **Strategy:** Austauschbare Algorithmen (Distanzberechnung)
5. **Template Method:** Fixe Ablaufstruktur (GPX-Export)
6. **Factory:** Objekt-Erstellung (Filter)
7. **Dependency Injection:** Loose Coupling

---

## 📊 UML-DIAGRAMME (Pflicht)

### Für Spezifikation/Design:
- [ ] **Use-Case-Diagramm:** Alle Anwendungsfälle
- [ ] **Klassendiagramm:** Hauptklassen mit Beziehungen
- [ ] **Sequenzdiagramm:** 
  - [ ] Peilung starten
  - [ ] Position aktualisieren
  - [ ] Peilung beenden
- [ ] **Zustandsdiagramm:** BearingState (IDLE → ACTIVE → SAVING → COMPLETED)
- [ ] **Komponentendiagramm:** Module und Dependencies
- [ ] **Paketdiagramm:** Package-Struktur

### Für Entwurfsmuster:
- [ ] **UML für jedes Pattern:** Zeigt Anwendung im Projekt

---

## 🎓 SOPHIST-REGELN (für Anforderungen)

1. **Eindeutigkeit:** Keine Synonyme, klare Begriffe
2. **Vollständigkeit:** Alle Bedingungen spezifiziert
3. **Korrektheit:** Fachlich richtig
4. **Verständlichkeit:** Für alle Stakeholder lesbar
5. **Verifizierbarkeit:** Testbar formuliert
6. **Konsistenz:** Keine Widersprüche
7. **Atomarität:** Eine Anforderung pro Satz
8. **Nachvollziehbarkeit:** Quelle dokumentiert

**Beispiel:**
❌ "Das System sollte schnell sein"
✅ "Das System MUSS die Peilungsberechnung in maximal 50 Millisekunden abschließen"

---

## 🏃 IMPLEMENTIERUNGS-WORKFLOW

### Phase 1: Setup (Tag 1)
```bash
# Projekt-Struktur erstellen
mkdir -p bearing-component/{bearing-core,gps-tracker,gpx-exporter,data-model,bearing-utils}/src/{main,test}/java

# Parent POM erstellen
# Module POMs erstellen
```

### Phase 2: Data Model (Tag 1-2)
- GeoCoordinate (mit Builder)
- BearingInfo
- GpxFile
- BearingConfig
- Exceptions

### Phase 3: Utilities (Tag 2-3)
- GeoUtils (Haversine, Azimut)
- MathUtils
- ValidationUtils
- Logging-Setup

### Phase 4: Core Logic (Tag 3-5)
- BearingCalculator
- BearingComponentImpl (Facade)
- BearingState
- EventDispatcher

### Phase 5: GPS Tracking (Tag 5-7)
- GpsTracker
- TrackPointValidator
- KalmanFilter (optional)
- Track-Management

### Phase 6: GPX Export (Tag 7-8)
- GpxGenerator
- GpxExporter
- GpxValidator
- JAXB Mapping

### Phase 7: Tests (Tag 8-10)
- Unit-Tests für alle Module
- Integration-Tests
- Performance-Tests
- Test-Daten

### Phase 8: Dokumentation (parallel)
- JavaDoc
- README
- Beispiele
- Architektur-Docs

---

## 📦 MAVEN-STRUKTUR

```xml
<!-- Parent POM -->
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
    <slf4j.version>1.7.36</slf4j.version>
    <junit.version>5.9.0</junit.version>
</properties>
```

**Abhängigkeiten:**
- SLF4J (Logging)
- JAXB (XML)
- JUnit 5 (Testing)
- Mockito (Mocking)
- AssertJ (Assertions)

---

## 🚀 BUILD-KOMMANDOS

```bash
# Kompilieren
mvn clean compile

# Tests
mvn test

# Coverage
mvn jacoco:report

# Vollständiger Build
mvn clean install

# Paketieren (ohne Tests für Abgabe)
mvn clean package -DskipTests
```

---

## 📝 DOKUMENTATIONS-STRUKTUR

### 1. Anforderungsanalyse (8-12 Seiten)
- Stakeholder
- Use Cases (narrativ + UML)
- Funktionale Anforderungen (Sophist-Regeln)
- Nicht-funktionale Anforderungen

### 2. Spezifikation IEEE 830 (25-35 Seiten)
- **1. Einführung**
  - 1.1 Zweck
  - 1.2 Gültigkeitsbereich
  - 1.3 Definitionen
  - 1.4 Referenzen
  - 1.5 Übersicht
- **2. Systemübersicht**
  - 2.1 Produktperspektive
  - 2.2 Produktfunktionen
  - 2.3 Benutzercharakteristika
  - 2.4 Einschränkungen
  - 2.5 Annahmen
- **3. Detaillierte Anforderungen**
  - 3.1 Externe Schnittstellen
  - 3.2 Funktionale Anforderungen (mit IDs)
  - 3.3 Performance
  - 3.4 Zuverlässigkeit
  - 3.5 Wartbarkeit
  - 3.6 Portabilität

### 3. Design-Dokumentation (20-25 Seiten)
- Architektur (Schichten)
- Architekturmuster (Diskussion)
- UML-Diagramme
- Entwurfsmuster (mit UML)
- Datenmodell
- Algorithmen

### 4. Implementierungs-Dokumentation (10-15 Seiten)
- Modulbeschreibung
- Wichtige Algorithmen
- Exception-Handling
- Threading
- Test-Strategie
- Build-Anleitung

---

## ⚠️ HÄUFIGE FEHLER (VERMEIDEN!)

1. **Mit Implementierung anfangen ohne fertige Spezifikation**
   → Erst Analyse + Spezifikation + Design FERTIG, dann Code!

2. **User Stories statt Anforderungen**
   → Laut Bohl: KEINE User Stories, sondern klassische Anforderungen!

3. **Unvollständige Themenabdeckung**
   → ALLE Vorlesungsthemen müssen eingebracht werden!

4. **Fehlende UML-Diagramme**
   → Jedes Pattern braucht UML, alle Phasen brauchen Diagramme!

5. **Code ohne Tests**
   → Parallel zu Implementierung Tests schreiben!

6. **Schlechte JavaDoc**
   → Alle public APIs müssen vollständig dokumentiert sein!

7. **Plattform-abhängiger Code**
   → Systemneutral implementieren!

8. **UI-Komponenten**
   → Explizit KEINE UI erstellen!

9. **Executable statt Source-Code**
   → Nur Source-Code abgeben, keine JAR!

10. **Code läuft nicht sofort**
    → Code muss bei Bohl sofort compilieren und laufen!

---

## 🎯 ABGABE-CHECKLISTE

### Dokumentation
- [ ] Anforderungsanalyse.pdf (8-12 S.)
- [ ] Spezifikation_IEEE830.pdf (25-35 S.)
- [ ] Design_Dokumentation.pdf (20-25 S.)
- [ ] Implementierung_Dokumentation.pdf (10-15 S.)
- [ ] Alle UML-Diagramme enthalten

### Source-Code
- [ ] Komplettes Maven-Projekt
- [ ] Kompiliert ohne Fehler/Warnings
- [ ] Alle Tests laufen erfolgreich
- [ ] JaCoCo-Coverage ≥ 80%
- [ ] Checkstyle-konform
- [ ] Vollständige JavaDoc

### Zusätzlich
- [ ] README.md mit Build-Anleitung
- [ ] Beispiel-Code (BasicUsageExample.java)
- [ ] Alle Abhängigkeiten in POM
- [ ] Keine JAR-Datei, nur Source!

### Themenabdeckung
- [ ] Analyse (Sophist)
- [ ] Spezifikation (IEEE 830)
- [ ] UML (alle Diagrammtypen)
- [ ] OOA
- [ ] Prozessmodell
- [ ] Grobentwurf
- [ ] Architekturmuster
- [ ] Entwurfsmuster (≥ 5 verschiedene)

---

## 💡 TIPPS FÜR NOTE 1+

### Code-Qualität
- Clean Code Principles
- SOLID Principles durchgängig
- ≥ 90% Test-Coverage
- Keine PMD/Checkstyle-Violations
- Vollständige JavaDoc

### Erweiterte Features
- Kalman-Filter für GPS-Glättung
- Douglas-Peucker Track-Vereinfachung
- Multi-Target-Peilung
- Geo-Fencing
- Route-Prediction (ETA)
- Track-Statistiken
- KML/GeoJSON-Export

### Design-Patterns (zusätzlich)
- Composite (Multi-Track)
- Chain of Responsibility (Validation)
- Command (Undo/Redo für Tracks)
- Memento (State-Snapshots)

### Dokumentation
- Architektur-Entscheidungen begründen
- Alternativen diskutieren
- Lessons Learned
- Performance-Messungen
- Optimierungen dokumentieren

---

## 📞 BEI FRAGEN KLÄREN MIT:

1. **Herr Bohl:** Alle fachlichen Fragen zur Bewertung
2. **Kommilitonen:** Code-Reviews, Feedback
3. **Dokumentation:** IEEE 830, GPX 1.1 Standard

---

## ⏰ ZEITMANAGEMENT

**10-Wochen-Plan:**
- Wochen 1-2: Analyse + Klärungen
- Wochen 2-4: Spezifikation + UML
- Wochen 4-5: Grobentwurf + Architektur
- Wochen 5-6: Feinentwurf + Design-Patterns
- Wochen 6-9: Implementierung + Tests
- Wochen 9-10: Finalisierung + Dokumentation

**Puffer einplanen!**

---

**WICHTIGSTER GRUNDSATZ:**
Erst ALLE Spezifikation und Design fertig, dann erst mit Code beginnen!

Viel Erfolg! 🎓
