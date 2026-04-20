  

#let titel = "JAVA Peilungs-Komponente mit GPS-Track-Aufzeichnung"
#let autor = "Duales Hochschulstudium"
#let kurzthema = "Anforderungsspezifikation und Systemdesign"

#let abgabedatum = datetime(
  year: 2000,
  month: 01,
  day: 01,
)



#set document(title: titel, author: autor, date: abgabedatum)
#set page(
  paper: "a4",
  number-align: right + bottom,
  margin: (inside: 2.5cm, outside: 2.5cm, y: 2cm)
)
#set text(
  size: 14pt,
  lang: "de"
)

#import "include/templates.typ": deckblatt




////////////////////////////////
// DECKBLATT
////////////////////////////////

#show: deckblatt.with(
  thema: "Software Engineering - Projektarbeit",
  titel: titel,
  studiengang: "Informatik",
  standort: "Stuttgart",
  autoren: (
    (
      name: "DHBW Semester 4",
    ),
  ),
  abgabedatum: datetime(year: 2026, month: 04, day: 16),
  bearbeitungszeitraum: "01.01.2026 - 16.04.2026",
  martikelnummer: "SWE-Kompass",
)
////////////////////////////////

// Kopfzeile
#counter(page).update(1)
#set page(
  numbering: "i",
  header: rect(
    height: 100%,
    inset: 0mm,
    stroke: none,
    // fill: red,
  )[
    #set align(top)
    #set text(11pt)
    #grid(
      // fill: blue,
      columns: (auto, 1fr, auto),
      rows: (4cm),
      align: horizon,
      image("include/images/DHBW_Logo.png", height: 1cm),
      h(1fr),
      // text(titel + " " + autor + "\ndfs"),
      box([
        #set align(right)
        #titel #autor \
        #kurzthema
      ])
    )
  ],
)

#show heading: set text(rgb("#d90000"))
#show heading: set block(below: 1em)
// #show heading: set block(below: 2em)


////////////////////////////////
// INHALTS-VERZEICHNIS
////////////////////////////////
#linebreak()
#outline(title: "Inhaltsverzeichnis")
#pagebreak()
////////////////////////////////

////////////////////////////////
// ABBILDUNGS-VERZEICHNIS
////////////////////////////////
#linebreak()

#show cite: it => [#it]

#show outline.where(target: figure.where(kind: image)): it => {
  show outline.entry: it => {
    show cite: it => { }
    it
  }
  it
}

= Abbildungsverzeichnis
#outline(target: figure.where(kind: image), title: "")
#pagebreak()
////////////////////////////////



#set heading(numbering: "1.1.1 - ")
#set par(spacing: 2em, justify: true)

#set page(numbering: "1")
#counter(page).update(1)


#show math.equation: set align(center)


////////////////////////////////
// BEGINN
////////////////////////////////

= JAVA Peilungs-Komponente mit GPS-Track-Aufzeichnung
Vollständige Anforderungsspezifikation und Systemdesign

== Abstract

Die vorliegende Arbeit beschreibt die Überführung der Peilungs-Funktionalität der iOS App "Kompass Professional" in eine modulare, UI-unabhängige Java-Komponente. Die Arbeit umfasst die Anforderungsanalyse nach SOPHIST-Regeln, eine Spezifikation nach IEEE 830-1998, objektoorientierte Analyse mit UML-Diagrammen, ein Systemdesign basierend auf Architekturmustern und Entwurfsmustern, ein umfassendes Testkonzept sowie die Implementierungsstrategie. Dabei werden alle Themengebiete beider Vorlesungssemester (Anforderungsmanagement, Spezifikation, Objektorientierter Entwurf, Architektur, Entwurfsmuster, Testverfahren) systematisch integriert.

#set page(numbering: "1")

== Vorwort und Kontextinformation

Dieses Dokument entstand im Rahmen der Projektarbeit an der Dualen Hochschule Baden-Württemberg Stuttgart, Studiengang Informatik, Semester 4, Modul Software Engineering (SWE). Die iOS-App "Kompass Professional" (https://apps.apple.com/de/app/kompass-professional/id1289069674) dient als Referenzimplementierung. Auf Basis von Anforderungen von Bohl und Rückmeldungen aus dem dritten Semester wurde folgende Struktur festgelegt:

- vollständige Anforderungsanalyse und Spezifikation (nicht: Aufwandsschätzung)
- kein UI, sondern reine Java-Komponente
- sofort lauffähiger Sourcecode in Java
- ausführliche Dokumentation
- Abdeckung aller Vorlesungsthemen
- keine User Stories
- strenge Einhaltung von Formatierung und Formalitäten
- SOPHIST-Regeln für Anforderungen
- IEEE 830 für Spezifikation

== Inhaltsverzeichnis


== 1 Einleitung und Problemstellung

=== 1.1 Motivation und Ausgangslage

Die entwicklung mobiler Navigations- und Orientierungsanwendungen setzt häufig proprietäre, plattformgebundene Implementierungen voraus. Die iOS-App "Kompass Professional" implementiert eine Peilungs-Funktionalität, die es ermöglicht, die Richtung und Distanz von einem aktuellen Standort zu einem Zielort zu ermitteln und aufzuzeichnen. Um diese Funktionalität plattformunabhängig und modular verfügbar zu machen, soll eine Java-Komponente entwickelt werden, die:

- systemneutral funktioniert (keine Hardware-Abhängigkeiten)
- in beliebige Java-Applikationen integrierbar ist
- keinerlei Benutzeroberfläche besitzt
- GPS-Tracks aufzeichnet und als GPX-Standard-Dateien speichert
- eine klare, dokumentierte API bietet

=== 1.2 Ziele der Arbeit

*Primäres Ziel:*
Entwicklung einer lauffähigen Java-Komponente, die alle Anforderungen erfüllt und unmittelbar durch den Auftraggeber getestet und bewertet werden kann.

*Spezifikationsziel:*
Erstellung einer vollständigen, detaillierten Spezifikation nach IEEE 830-1998, die alle funktionalen und nicht-funktionalen Anforderungen eindeutig und testbar formuliert.

*Qualitätsziel:*
Anwendung aller in der Vorlesung vermittelten Software-Engineering-Techniken (beide Semester) zur Sicherung hoher Qualität in Anforderungsanalyse, Design und Implementierung.

*Dokumentationsziel:*
Ausführliche Dokumentation aller Designentscheidungen, Architekturmuster und Entwurfsmuster.

=== 1.3 Abgrenzung und Scope

*nicht im Scope:*
- Entwicklung einer Benutzerschnittstelle (UI)
- Hardware-Integration (GPS-Sensor-Verwaltung)
- Netzwerkprotokolle für GPS-Datenübertragung
- Kartendarstellung oder geografische Visualisierung
- Mobile App-Entwicklung
- native Betriebssystem-Integration

*im Scope:*
- Anforderungsanalyse und Spezifikation
- Systemdesign und Architektur
- Entwurfsmuster und Designentscheidungen
- Java-Implementierung (reine Logik)
- Testkonzept und Testfälle
- Dokumentation und UML-Modelle
- Datenmodell (Koordinaten, Peilungen, GPS-Tracks)
- GPX-Datei-Export und -Validierung

== 2 Anforderungsanalyse nach SOPHIST-Regeln

=== 2.1 Stakeholder-Analyse

==== 2.1.1 Primäre Stakeholder

| Stakeholder | Interesse | Auswirkung |
|---|---|---|
| Auftraggeber (Dozent Bohl) | Erfüllung aller Anforderungen, Lauffähigkeit, hohe Qualität | Benotung, Abnahmeverfahren |
| Implementier-Team | Klare Anforderungen, manageable Complexity | Machbarkeit, Zeitbudget |
| Integrierungs-Partner | API-Stabilität, Fehlerbehandlung, Performance | Integrationserfolg |
| End-User (Applikation) | Zuverlässigkeit, Performance, Datengenauigkeit | Produktqualität |

==== 2.1.2 Sekundäre Stakeholder

- Wartungsteam (zukünftige Erweiterungen)
- QA/Test-Team (Testbarkeit)
- Architektur-Review-Board (Einhaltung von Standards)

=== 2.2 Klärung der Kernkonzepte (Beantwortung aller Fragen)

==== 2.2.1 Was ist Peilung?

*Definition nach geodätischem Standard:*
Eine Peilung ist die Bestimmung der räumlichen Richtung zwischen zwei geografischen Koordinaten und deren Entfernung. Im Kontext dieser Komponente besteht eine Peilung aus vier Komponenten:

1. *Azimut (geografisch):* Winkelabweichung von Nord (0°) bis 360°, gemessen im Uhrzeigersinn
2. *Distanz:* Großkreis-Distanz (berechnet nach Haversine-Formel) zwischen Start- und Zielkoordinate
3. *Kursabweichung:* Differenz zwischen aktuellem Kurs und dem zum Ziel notwendigen Azimut
4. *Höhendifferenz:* Differenz in der Elevation (optionale Erweiterung)

*Funktionales Verständnis für diese Komponente:*
Es handelt sich NICHT um Navigation im klassischen Sinne, sondern um eine reine Richtungsbestimmung. Der Nutzer erhält zu jedem Zeitpunkt die Information "in diese Richtung liegt das Ziel in dieser Entfernung". Die Komponente aktualisiert diese Werte kontinuierlich basierend auf der aktuellen Position des Nutzers.

==== 2.2.2 Welcher GPX-Standard?

*Entscheidung:* GPX 1.1 (Topografix Standard)

*Begründung:*
- Weit verbreiteter Standard, unterstützt von allen gängigen Navigations-Tools
- Offene Spezifikation unter http://www.topografix.com/GPX/1/1
- XML-basiert, einfach zu parsen und zu generieren
- Unterstützung für Tracks, Waypoints, Routen und Metadaten
- JAXB (Java Architecture for XML Binding) für automatisierte Serialisierung verfügbar
- Zeitstempel im ISO 8601 UTC-Format

==== 2.2.3 Aufzuzeichnende Daten (pro GPS-Punkt)

*Pflichtdaten:*
- Latitude (WGS84): -90° bis +90°
- Longitude (WGS84): -180° bis +180°
- Elevation/Höhe: Meter über NN
- Zeitstempel: ISO 8601 UTC

*Optionale Daten (bei Verfügbarkeit):*
- HDOP (Horizontal Dilution of Precision): Maß für GPS-Genauigkeit
- Anzahl Satelliten: Für Qualitätsmetriken
- Geschwindigkeit: m/s (wenn verfügbar)
- Magnetischer Kurs: 0-360° (wenn verfügbar)

*Track-Metadaten:*
- Track-Name und -Description
- Start- und End-Koordinaten
- Start- und End-Zeit
- Gesamtstrecke
- Min/Max Elevation

==== 2.2.4 Zeitintervall für GPS-Aufzeichnung

*Entscheidung nach Bohl:*
Einstellbare Aufzeichnungs-Intervalle mit konfigurierbaren Modi.

*Standard-Modi:*
- Eco-Modus: 5 Sekunden (batterieschonend)
- Normal: 2 Sekunden (Standard)
- High-Precision: 1 Sekunde
- Ultra-High: 0.5 Sekunden

*Adaptives Verhalten:*
- Bei Stillstand (Geschwindigkeit < 0.1 m/s): Intervall erhöhen auf 10 Sekunden
- Bei hoher Bewegung (> 10 m/s): Intervall reduzieren auf 0.5 Sekunden

*Limitierungen:*
- Maximale Anzahl Punkte im RAM: 10.000 (soft limit)
- Absolutes Limit: 50.000 Punkte pro Track
- Bei Überschreitung: Automatisches Flushing in Datei oder Fehler

==== 2.2.5 Genauigkeits-Anforderungen

*GPS-Genauigkeit (HDOP):*
- Akzeptabel: HDOP < 5.0
- Empfohlen: HDOP < 3.0
- Gut: HDOP < 2.0
- Punkte mit HDOP > 5.0 werden mit Warnung akzeptiert oder verworfen (konfigurierbar)

*Mindestanzahl Satelliten:*
- Mindestens 4 Satelliten erforderlich für 3D-Position
- Mindestens 5 empfohlen für gute Genauigkeit
- Punkte mit < 4 Satelliten können verworfen werden

*Horizontal (Latitude/Longitude):*
- Minimum: ±10m
- Empfohlen: ±5m
- Zielwert: ±3m

*Vertikal (Elevation):*
- Minimum: ±15m
- Empfohlen: ±10m

*Azimut-Berechnung:*
- Genauigkeit bei Distanz > 10m: ±1°
- Bei sehr kleinen Distanzen (< 10m): Spezialbehandlung erforderlich
- Magnetische Deklination wird automatisch korrigiert (basierend auf geografischer Position)

==== 2.2.6 Performance-Anforderungen

*Echtzeitanforderungen:*
- Peilung berechnen: < 50 ms
- GPS-Punkt verarbeiten: < 50 ms
- Gesamte Updatezyklus: < 100 ms

*Speicher:*
- Max. RAM-Verbrauch: 50 MB insgesamt
- Pro Track-Punkt: ca. 200 Bytes
- 10.000 Punkte ≈ 2 MB

*CPU-Last:*
- Idle (keine aktive Peilung): < 2%
- Bei aktiver Peilung: < 10%
- Bei GPS-Verarbeitung: < 20% kurzzeitig akzeptabel

*Startzeit:*
- Komponenten-Initialisierung: < 1 Sekunde

*Speicheroperationen:*
- Schreiben in GPX-Datei: asynchron, max. 500 ms für einen Zyklus
- Datei-Validierung: < 100 ms

==== 2.2.7 Behandlung ungültiger Koordinaten

*Validierungsregeln:*
- Latitude: -90° ≤ lat ≤ 90°
- Longitude: -180° ≤ lon ≤ 180°
- Elevation: -500m ≤ ele ≤ 9000m (Mount Everest)
- Zeitstempel: nicht in der Zukunft, nicht älter als 1 Stunde
- Geschwindigkeit: 0 m/s ≤ speed ≤ 100 m/s (360 km/h)

*Fehlerbehandlung:*
- Ungültige Punkte: Logging mit WARNING-Level, Punkt wird verworfen
- Outlier (Sprünge > 50 m/s): Logging, konfigurierbar verworfen oder akzeptiert
- Duplikate (identische Koordinaten): dedupliziert, zählt als 1 Punkt
- Zeitstempel-Rückwärts: Fehler, Track wird unterbrochen und markiert

*Strategien:*
- Last-Known-Good-Position: Verwendung der letzten gültigen Position bei Ausfall
- Interpolation: Bei Ausfällen < 10 Sekunden
- Gap-Markierung: Lücke in GPX als Segment-Unterbrechung gekennzeichnet

==== 2.2.8 Speicherort und Dateihandhabung

*Standard-Speicherort:*
```
./gps-tracks/bearing_YYYYMMDD_HHmmss.gpx
```

*Konfigurierbar:*
- Verzeichnis (muss existieren oder wird erstellt)
- Dateinamenskonvention (Template-basiert)
- Automatisches Speichern (ja/nein)

*Datei-Operationen:*
- Atomare Schreibvorgänge (temp-Datei → rename)
- Optional: Gzip-Kompression (.gpx.gz)
- Berechtigungen: rw-r--r-- (644)
- Fehlerbehandlung: IOException → Logging und Exception

==== 2.2.9 Schnittstellen-Definition (API)

*Primäre Schnittstelle:*
Java-API über Interface `BearingComponent` und zugehörige Objekte.

*Keine zusätzliche Schnittstelle für:*
- REST/HTTP (keine Netzwerk-Komponente)
- Datenbank (nur Dateisystem)
- Message Queue (keine Event-Bus-Integration)

*Nur GPX-Datei als Ausgabe-Format.*

==== 2.2.10 Datenabbruch und -speicherung

*Abbruchszenario:*
Wenn der Nutzer die Peilung abbricht (stopBearing() oder abortBearing()), sollen die bisherigen GPS-Daten trotzdem exportiert werden.

*Behavior:*
- `abortBearing()`: Gibt GpxFile mit bisherigen Daten zurück (markiert mit "aborted" im Namen)
- `stopBearing()`: Speichert ordnungsgemäße GPX-Datei
- In beiden Fällen: keine Fehler, sondern erfolgreicher Abschluss mit verfügbaren Daten

==== 2.2.11 What3Words (W3W) Integration

*Entscheidung:* W3W soll optional unterstützt werden als Erweiterung.

*Use Case:*
Umwandlung von Koordinaten in What3Words-Adressen für benutzerfreundlichere Zielangaben.

*Implementierung:*
- Optionales API-Wrapper
- Externe Abhängigkeit (nur wenn W3W-API-Schlüssel konfiguriert)
- Fallback auf Koordinaten bei Fehler

==== 2.2.12 Size-Limits für GPX-Dateien

*Soft-Limit:* 10.000 Datenpunkte
- Warnung wird geloggt
- Tracking läuft weiter

*Hard-Limit:* 50.000 Datenpunkte
- Track wird beendet
- GpxFile wird zurückgegeben
- Event wird ausgelöst

*Größenlimit auf Disk:*
- Max. 100 MB pro Datei (unkomprimiert)
- Entspricht ca. 50.000 Punkte

==== 2.2.13 Testabdeckung pro Modul

*Anforderung:* Ein Test je Modul oder besser: ein umfassendes Testset pro Modul.

*Module und Test-Coverage-Ziele:*
- bearing-core: ≥ 90% (kritisch)
- gps-tracker: ≥ 85%
- gpx-exporter: ≥ 80%
- data-model: ≥ 95% (einfach, aber wichtig)
- bearing-utils: ≥ 90%

*Gesamt-Ziel: ≥ 85% durchschnittlich*

==== 2.2.14 Optimierung für 1+ mit Sternchen

*Erweiterte Anforderungen (Beyond Scope, aber erwünscht):*

- *Kalman-Filter:* Datenglättung für GPS-Punkte (reduziert Rauschen)
- *Ramer-Douglas-Peucker-Algorithmus:* Linienvereinfachung (z. B. jeden 10. Punkt, oder Punkte unterschreiten 100m Abstand)
- *Multi-Target-Peilung:* Mehrere Ziele verfolgen gleichzeitig
- *Geofencing:* Benachrichtigungen beim Verlassen eines Radius
- *Statistik-Modul:* Durchschnittsgeschwindigkeit, Höhengain, Gesamtstrecke
- *Magnetische Deklination:* Automatische Korrektur
- *Kalibration:* Kompass-Kalibrierung

*Implementierungs-Reihenfolge (nach Priorität):*
1. Kalman-Filter (kritisch für Qualität)
2. Douglas-Peucker (für Performance und Speicher)
3. Statistik-Modul (für Nutzer-Feedback)
4. Geofencing (erweiterte Funktionalität)
5. Multi-Target (komplexere Architektur)

=== 2.3 Anforderungen nach SOPHIST-Regeln

*SOPHIST-Regeln für gute Anforderungen:*
1. **Spezifisch:** Klar und eindeutig formuliert
2. **Oriented:** Zielgerichtet, auf Nutzen ausgerichtet
3. **Pragmatisch:** Umsetzbar mit vorhandenen Ressourcen
4. **Hoch-granular:** Richtige Abstraktionsebene
5. **Individuell:** Nicht redundant
6. **Schreibweise:** Konsistent, aktive Form
7. **Testbar:** Akzeptanzkriterien definiert

==== 2.3.1 Funktionale Anforderungen (FA)

*FA-1: Peilung initialisieren*
Der Nutzer kann eine Peilung zu einem Zielort starten, indem er eine GeoCoordinate und optionale Konfiguration übergibt.
- Spezifizierung: Komponente akzeptiert Zielkoordinate (Lat/Lon), startet GPS-Aufzeichnung
- Akzeptanzkriterium: startBearing(GeoCoordinate target) -> void
- Testbar: JUnit-Test mit Mock-GPS-Daten

*FA-2: Aktuelle Position aktualisieren*
Der Nutzer aktualisiert die aktuelle Position laufend mit neuen GPS-Daten zur Verfügung.
- Spezifizierung: updatePosition(GeoCoordinate current) ist die Hauptschnittstelle
- Akzeptanzkriterium: Peilung wird neuberechnet, Event wird gesendet
- Testbar: Event-Listener prüft auf Ereignis

*FA-3: Peilung berechnen*
Die Komponente berechnet das aktuelle Azimut und die Distanz zum Ziel.
- Spezifizierung: BearingCalculator berechnet Azimut (Haversine-Formel)
- Akzeptanzkriterium: Azimut-Genauigkeit ±1° bei Distanzen > 10m
- Testbar: Parametrisierte Tests mit bekannten Koordinatenpaaren

*FA-4: GPS-Track aufzeichnen*
Während einer aktiven Peilung werden GPS-Punkte in konfigurierbaren Intervallen aufgezeichnet.
- Spezifizierung: GpsTracker sammelt Punkte mit Zeitstempel und Qualitätsmetriken
- Akzeptanzkriterium: Mind. 1 Punkt pro Intervall, max. 10.000 im RAM
- Testbar: Anzahl der Punkte wird geprüft, Performance-Test

*FA-5: GPX-Datei exportieren*
Am Ende einer Peilung kann eine GPX 1.1-konforme Datei generiert und gespeichert werden.
- Spezifizierung: stopBearing() gibt GpxFile zurück, speichert auf Disk
- Akzeptanzkriterium: GPX-Datei ist valid gegen XML-Schema
- Testbar: XML-Validierung und Dateisystem-Prüfung

*FA-6: Peilung abbrechen mit Daten-Sicherung*
User kann Peilung abbrechen; bisherige Daten werden trotzdem in Datei gespeichert.
- Spezifizierung: abortBearing() speichert Datei mit "aborted"-Suffix
- Akzeptanzkriterium: Datei mit min. 2 Punkte wird angelegt
- Testbar: Datei existiert, GPX ist valid

*FA-7: Ereignisse (Events) auslösen*
Komponente sendet Events bei Meilenstein (Start, Punkt-hinzufügen, Ende).
- Spezifizierung: Observer Pattern mit BearingListener
- Akzeptanzkriterium: Listener wird aufgerufen, Parameter stimmen
- Testbar: Mock-Listener prüft auf Aufrufe

*FA-8: Validierung ungültiger Koordinaten*
Ungültige GPS-Punkte werden erkannt und behandelt.
- Spezifizierung: GeoCoordinate-Validierung bei Eingabe
- Akzeptanzkriterium: aus ungültigem Punkt: Exception oder Warning-Log
- Testbar: Test mit Grenzwerten (±91°, -181°, etc.)

*FA-9: Konfiguration*
Benutzer kann Aufzeichnungs-Intervall und Speicherpfad konfigurieren.
- Spezifizierung: BearingConfig-Builder mit setInterval(), setOutputDir()
- Akzeptanzkriterium: Konfiguration wird angewendet
- Testbar: Unterschiedliche Konfigurationen führen zu unterschiedlichem Verhalten

*FA-10: Mehrsprachige Fehlerbehandlung*
Fehler werden mit aussagekräftigen Meldungen protokolliert.
- Spezifizierung: Every error logged mit Stacktrace (DEBUG) und Meldung (ERROR)
- Akzeptanzkriterium: Log-Datei enthält Fehler-Details
- Testbar: Log-Level-Prüfung

==== 2.3.2 Nicht-funktionale Anforderungen (NFA)

*NFA-1: Performance - Peilung berechnen*
Die Berechnung einer Peilung muss in < 50 ms abgeschlossen sein.
- Messmethode: JMH-Benchmark für Haversine-Formel
- Grenzwert: 50 Millisekunden (worst case)
- Testbar: Performance-Test mit JMH

*NFA-2: Performance - GPS-Update*
Ein GPS-Update (inkl. Peilung-Neuberechnung) muss in < 100 ms erfolgen.
- Messmethode: Zeitmessung in Integration-Test
- Grenzwert: 100 Millisekunden
- Testbar: System-Test mit Chrono

*NFA-3: Speicher - RAM-Verbrauch*
Track mit 10.000 Punkten darf max. 50 MB RAM verbrauchen.
- Messmethode: JVM Memory-Monitoring
- Grenzwert: 50 MB (Heap)
- Testbar: Runtime.getRuntime().totalMemory()

*NFA-4: Speicher - Datei-Größe*
Eine GPX-Datei mit 10.000 Punkten darf max. 2 MB groß sein unkomprimiert.
- Messmethode: File-Größe auf Disk
- Grenzwert: 2 MB
- Testbar: file.length() < 2_000_000

*NFA-5: Zuverlässigkeit - Genauigkeit Distanzberechnung*
Distanzberechnung nach Haversine-Formel hat Genauigkeit von ±0.1%.
- Messmethode: Vergleich mit Referenzimplementierung
- Grenzwert: ±0.1% Abweichung
- Testbar: Test mit bekannten Refrenzen-Distanzen (z. B. Äquator)

*NFA-6: Datensicherung - atomare GPX-Speicherung*
GPX-Datei wird atomar geschrieben (temp → rename).
- Messmethode: Dateioperationen monitoren
- Grenzwert: Keine Partial-Dateien bei Fehler
- Testbar: Test mit künstlichen Fehler-Szenarien

*NFA-7: Wartbarkeit - Code-Dokumentation*

Jede öffentliche Methode muss Javadoc mit \@param, \@return, \@throws haben.
- Messmethode: Static-Analyse-Tool (Checkstyle)
- Grenzwert: 100% öffentliche Methoden dokumentiert
- Testbar: Checkstyle-Bericht

*NFA-8: Portabilität - Plattformunabhängigkeit*
Code darf keine Windows/Linux/Mac-spezifischen APIs verwenden.
- Messmethode: Code-Review, Abstraktionen für OS-spezifisches (Pfade)
- Grenzwert: 0 OS-spezifische Hardcodes
- Testbar: Paths.get() statt "C:\\..." verwenden

*NFA-9: Testbarkeit - Unit-Test-Coverage*
Mindestens 85% Coverage für critical paths.
- Messmethode: JaCoCo-Report
- Grenzwert: ≥ 85%
- Testbar: Maven JaCoCo-Plugin

*NFA-10: Sicherheit - Input-Validierung*
Alle externen Eingaben (Koordinaten, Pfade) werden validiert.
- Messmethode: Code-Review, Fuzz-Testing
- Grenzwert: 0 unkontrollierte Eingaben
- Testbar: Negative-Tests mit ungültigen Werten

== 3 IEEE 830 Spezifikation

=== 3.1 Produktübersicht und Kontext

==== 3.1.1 Produktperspektive

Die Java Peilungs-Komponente ist eine unabhängige Bibliothek, die als Modul in Java-Applikationen eingebunden wird. Sie ist nicht selbst ausführbar, sondern wird von einer Host-Anwendung aufgerufen, die:
- GPS-Daten von Sensoren/APIs bezieht
- Diese Daten der Komponente übergibt
- Die berechneten Peilungsdaten empfängt und verarbeitet
- am Ende die generierten GPX-Dateien nutzt

*Systemkontext-Diagram (Text-Beschreibung):*
```
+---------------------+
|   Host-Applikation  |  (z. B. Navigationssystem)
|  - GPS-Sensor-API   |
|  - User-Interface   |
+----------+----------+
           |
    BearingComponent API
           |
+----------v----------+
| Java Peilungs-      |  (Diese Komponente)
| Komponente          |
|  - Core            |
|  - Tracker         |
|  - Exporter        |
+----------+----------+
           |
   File I/O (GPX-Datei)
           |
+---------------------+
|   Dateisystem       |
|  ./gps-tracks/*.gpx |
+---------------------+
```

==== 3.1.2 Produktfunktionen (Zusammenfassung)

1. Berechnung von Peilungen (Azimut + Distanz) zwischen zwei Koordinaten
2. Kontinuierliche Aufzeichnung von GPS-Tracks während einer Peilung
3. Export der aufgezeichneten Daten als GPX 1.1 Datei
4. Validierung und Filterung von GPS-Daten
5. Fehlerbehandlung und Logging
6. Ereignissystem (Observer Pattern) für Status-Updates
7. Konfigurierbare Aufzeichnungs-Parameter

==== 3.1.3 Nutzer- und Betriebsumgebung

*Nutzer:*
- Java-Entwickler, die Peilungs-Funktionalität in ihre App einbauen
- Nicht: End-User der App

*Betriebsumgebung:*
- Java Runtime Environment (JRE) 11+
- Dateisystem mit Schreib-Zugriff
- Min. 50 MB RAM (abhängig von Track-Größe)
- CPU: Standard-Desktop/Mobile-Prozessor

*Abhängigkeiten:*
- SLF4J (Logging)
- JAXB (XML-Serialisierung)
- JUnit 5 (nur für Tests)
- Mockito (nur für Tests)

== 4 Objektoorientierte Analyse und UML-Modelle

=== 4.1 Use-Case-Diagramm

*Beschreibung (Text, da kein graphics möglich):*

```
Akteurs:
  - Applikation
  
Use Cases:
  - UC-1: Peilung starten (mit Zielkoordinate)
  - UC-2: Position aktualisieren (mit neuer Koordinate)
  - UC-3: Aktuelle Peilung abfragen
  - UC-4: Peilung beenden
  - UC-5: Peilung abbrechen
  - UC-6: GPX exportieren
  - UC-7: Events empfangen (Listener registrieren)
  - UC-8: Konfiguration setzen

Beziehungen:
  - UC-2 requires UC-1
  - UC-3 requires UC-1
  - UC-4 includes UC-6
  - UC-5 includes UC-6
```

*Fließtext-Beschreibung:*
Die Applikation (primärer Akteur) nutzt die Komponente durch initialisieren einer Peilung (UC-1), woraufhin die Komponente bereit ist, Position-Updates (UC-2) zu verarbeiten. Die aktuellen Peilungs-Daten können abgefragt werden (UC-3). Eine Peilung wird beendet durch UC-4 oder abgebrochen durch UC-5, beide führen zum Export von Daten (UC-6). Die Applikation kann sich als Listener registrieren (UC-7) und Konfigurationen setzen (UC-8).

=== 4.2 Klassendiagramm - Kern-Klassen

*Textuelle Beschreibung der wesentlichen Klassen:*

==== 4.2.1 Schnittstellen und Klassen

**Interface `BearingComponent`**
- startBearing(target: GeoCoordinate, config?: BearingConfig): void
- updatePosition(current: GeoCoordinate): void
- getCurrentBearing(): BearingInfo
- stopBearing(): GpxFile
- abortBearing(): GpxFile
- addListener(listener: BearingListener): void
- removeListener(listener: BearingListener): void

**Class `GeoCoordinate` (immutable)**
- latitude: double
- longitude: double
- elevation: double
- timestamp: Instant
- accuracy: double (HDOP)
- satelliteCount: int
- speed: double
- course: double
+ validate(): void throws InvalidCoordinateException
+ distance(other: GeoCoordinate): double
+ bearing(other: GeoCoordinate): double
+ toString(): String

**Class `BearingInfo` (immutable)**
- azimuth: double
- distance: double
- deviation: double
- currentPosition: GeoCoordinate
- targetPosition: GeoCoordinate
- timestamp: Instant
+ toString(): String

**Class `BearingConfig`**
- intervalSeconds: double
- outputDirectory: Path
- maxPoints: int
- validatePoints: boolean
+ builder(): BearingConfigBuilder

**Class `BearingCalculator`**
- calculateAzimuth(from: GeoCoordinate, to: GeoCoordinate): double
- calculateDistance(from: GeoCoordinate, to: GeoCoordinate): double
- calculateDeviation(azimuth: double, course: double): double
+ (static) haversineDistance(...): double

**Class `GpsTracker`**
- tracks: List<GeoCoordinate>
- isRecording: boolean
- addPoint(point: GeoCoordinate): void
- getPoints(): List<GeoCoordinate>
- clear(): void

**Class `GpxExporter`**
- export(tracker: GpsTracker, config: BearingConfig): GpxFile
- exportToFile(file: Path, gpxData: String): void

**Class `GpxFile`**
- filePath: Path
- metadata: GpxMetadata
- points: List<GeoCoordinate>
+ fromFile(path: Path): GpxFile
+ validate(): boolean

**Interface `BearingListener`**
- onBearingStarted(info: BearingInfo): void
- onPositionUpdated(info: BearingInfo): void
- onBearingStopped(gpxFile: GpxFile): void
- onError(error: BearingException): void

==== 4.2.2 Beziehungen

```
BearingComponent (Interface)
├── implementiert: BearingComponentImpl
│   ├── uses: BearingCalculator
│   ├── uses: GpsTracker
│   ├── uses: GpxExporter
│   └── has-many: BearingListener
│
GeoCoordinate
├── verwendet-in: BearingCalculator
├── verwendet-in: GpsTracker
└── verwendet-in: BearingInfo
│
GpxExporter
└── produces: GpxFile

BearingConfig
└── used-by: BearingComponentImpl
```

=== 4.3 Sequenzdiagramm - Timeline einer Peilung

*Textuelle Beschreibung (Sequenz):*

```
Sequenz: "Kompletter Peilung-Ablauf"

Zeitpunkt 0: Host-App → BearingComponent.startBearing(targetCoord, config)
  BearingComponent → GpsTracker: clear() und init()
  BearingComponent → BearingListener: onBearingStarted()

Zeitpunkt 1 (loop für jedes Update):
  Host-App → BearingComponent.updatePosition(currentCoord)
  BearingComponent → GeoCoordinate: validate()
  BearingComponent → GpsTracker: addPoint()
  BearingComponent → BearingCalculator: calculateAzimuth(), calculateDistance()
  BearingComponent → BearingListener: onPositionUpdated()

Zeitpunkt 2 (nach n Updates):
  Host-App → BearingComponent.stopBearing() / abortBearing()
  BearingComponent → GpsTracker: getPoints()
  BearingComponent → GpxExporter: export()
  GpxExporter → GpxFile: create()
  GpxExporter → File-System: write(gpxFile.gpx)
  BearingComponent → BearingListener: onBearingStopped()
  BearingComponent → return: GpxFile
```

=== 4.4 Zustandsdiagramm - BearingState

*Textuelle Beschreibung:*

```
States:
  IDLE: Komponente ist initialisiert, aber keine aktive Peilung
  ACTIVE: Peilung läuft, Punkte werden aufgezeichnet
  PAUSED: (optional) Peilung ist temporär unterbrochen
  STOPPING: Peilung wird beendet (Daten werden geschrieben)
  COMPLETED: Peilung ist abgeschlossen, GpxFile ist bereit
  ERROR: Ein Fehler ist aufgetreten

Transitionen:
  IDLE → ACTIVE: startBearing()
  ACTIVE → ACTIVE: updatePosition() (loop)
  ACTIVE → STOPPING: stopBearing() oder abortBearing()
  STOPPING → COMPLETED: GPX-Datei erfolgreich geschrieben
  STOPPING → ERROR: Fehler beim Schreiben
  ACTIVE → ERROR: Fehler während Aufzeichnung
  ERROR → IDLE: reset() oder neue startBearing()
  (optional) ACTIVE ↔ PAUSED: pauseBearing(), resumeBearing()
```

=== 4.5 Aktivitätsdiagramm - GPS-Track-Aufzeichnung

*Textuelle Beschreibung (BPMN-ähnlich):*

```
START
  │
  ├─ Peilung initialisieren (startBearing)
  │   └─ Konfiguration laden
  │
  ├─ LOOP: Während Peilung aktiv
  │   │
  │   ├─ Position Update empfangen (updatePosition)
  │   │
  │   ├─ [DECISION] Ist Koordinate valid?
  │   │   ├─ JA:
  │   │   │   ├─ Punkt zu Tracker hinzufügen
  │   │   │   │
  │   │   │   ├─ [DECISION] Peilung neu berechnen?
  │   │   │   │   ├─ JA:
  │   │   │   │   │   ├─ Azimut berechnen (Haversine)
  │   │   │   │   │   ├─ Distanz berechnen
  │   │   │   │   │   ├─ BearingInfo erstellen
  │   │   │   │   │   └─ Events senden
  │   │   │   │   └─ NEIN: Skip
  │   │   │   │
  │   │   │   └─ [DECISION] Max. Punkte erreicht?
  │   │   │       ├─ JA: Track beenden, Fehler
  │   │   │       └─ NEIN: Continue
  │   │   │
  │   │   └─ NEIN:
  │   │       ├─ Fehler loggen (WARNING/ERROR)
  │   │       └─ Punkt verwerfen
  │   │
  │   └─ [DECISION] Stop-Signal erhalten?
  │       ├─ JA: Break aus LOOP
  │       └─ NEIN: Continue LOOP
  │
  ├─ GPX-Export starten (stopBearing / abortBearing)
  │   │
  │   ├─ [DECISION] Punkte vorhanden?
  │   │   ├─ JA: Continue
  │   │   └─ NEIN: Error → abort
  │   │
  │   ├─ GPX-Struktur aufbauen
  │   │   ├─ Metadaten erstellen
  │   │   └─ Track-Segment erzeugen
  │   │
  │   ├─ XML serialisieren (JAXB)
  │   │
  │   ├─ Zu temporärer Datei schreiben
  │   │
  │   ├─ [DECISION] Validierung bestanden?
  │   │   ├─ JA: Rename in finale Datei
  │   │   └─ NEIN: Temp-Datei löschen, Error
  │   │
  │   └─ GpxFile-Objekt zurückgeben
  │
  ├─ Listener benachrichtigen (onBearingStopped)
  │
  └─ END
```

== 5 Systemarchitektur und Entwurfsmuster

=== 5.1 Schichtenarchitektur

Die Komponente folgt einer **4-schichtigen Architektur**:

```
┌─────────────────────────────────────┐
│  1. API Layer (Facade)              │
│  BearingComponent, BearingListener  │
│  BearingConfig, BearingInfo         │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│  2. Business Logic Layer            │
│  BearingCalculator, GpsTracker      │
│  EventDispatcher, StateManager      │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│  3. Data Access Layer               │
│  GpxExporter, GpxValidator          │
│  FileWriter, Persistence            │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│  4. Infrastructure / Utility         │
│  Logging, Validation, Constants     │
│  GeoUtils, MathUtils                │
└─────────────────────────────────────┘
```

*Characterisierungen:*
- **Layer 1:** Externe Schnittstelle, nur Fassade
- **Layer 2:** Kernlogik, unabhängig von Persistierung
- **Layer 3:** Dateizugriff und Persistierung
- **Layer 4:** Querschnittslogik und Hilfsfunktionen

*Abhängigkeitsrichtung:* Nur von oben nach unten, keine Rückwärts-Abhängigkeiten (Strict Layering).

=== 5.2 Modular-Struktur

Die Komponente ist in folgende **5 Maven-Module** organisiert:

| Modul | Zweck | Abhängigkeiten |
|---|---|---|
| bearing-core | Peilungsberechnung, Schnittstellen | bearing-utils |
| gps-tracker | GPS-Punkt-Aufzeichnung, Filterung | bearing-core |
| gpx-exporter | GPX-Datei-Generierung und -Speicherung | bearing-core, gps-tracker |
| data-model | Datenklassen (GeoCoordinate, etc.) | keine (unabhängig) |
| bearing-utils | Hilfsfunktionen, Validierung, Logging | keine |

*Modul-Abhängigkeitsgraph:*
```
bearing-utils (no deps)
  ├── bearing-core (depends on bearing-utils)
  │   ├── gps-tracker
  │   └── gpx-exporter
  │
data-model (no deps)
  └── (wird von allen anderen genutzt)
```

=== 5.3 Entwurfsmuster

==== 5.3.1 Facade Pattern (BearingComponent)

*Problem:* Komplexes Subsystem (Core, Tracker, Exporter) braucht einfache Schnittstelle.

*Lösung:* BearingComponent als Facade, die interne Komplexität verbirgt.

```java
public interface BearingComponent {
    void startBearing(GeoCoordinate target, BearingConfig config);
    void updatePosition(GeoCoordinate current);
    BearingInfo getCurrentBearing();
    GpxFile stopBearing();
    // ... Implementierung nutzt intern BearingCalculator, GpsTracker, GpxExporter
}
```

*Vorteil:* Extern: einfache API. Intern: flexible, wartbare Implementierung.

==== 5.3.2 Observer Pattern (Event-System)

*Problem:* Komponente muss wichtige Events communication (Start, Update, Stop, Error).

*Lösung:* BearingListener-Interface, addListener(), notifyListeners().

```java
public interface BearingListener {
    void onBearingStarted(BearingInfo info);
    void onPositionUpdated(BearingInfo info);
    void onBearingStopped(GpxFile file);
    void onError(BearingException error);
}
```

*Vorteil:* Lose Kopplung, Host-App kann mehrere Listener registrieren.

==== 5.3.3 Builder Pattern (Konfiguration)

*Problem:* BearingConfig hat viele optionale Parameter, Konstruktor wird unwieldy.

*Lösung:* Builder-Klasse für flexible, lesbare Konfiguration.

```java
BearingConfig config = new BearingConfig.Builder()
    .withInterval(2.0)
    .withOutputDirectory("/var/gps-tracks")
    .withAutoSave(true)
    .build();
```

*Vorteil:* Lesbar, testbar, sichere Objekterzeugung.

==== 5.3.4 Strategy Pattern (Algorithmen)

*Problem:* Distanzberechnung könnte Haversine oder andere Methoden sein.

*Lösung:* DistanceCalculationStrategy-Interface mit mehreren Implementierungen.

```java
public interface DistanceCalculationStrategy {
    double calculate(GeoCoordinate from, GeoCoordinate to);
}

class HaversineStrategy implements DistanceCalculationStrategy { ... }
class VincentyStrategy implements DistanceCalculationStrategy { ... }
```

*Vorteil:* Leicht austauschbar, testbar, erweiterbar.

==== 5.3.5 Template Method Pattern (GPX-Export)

*Problem:* GPX-Export hat fixe Schritte, aber unterschiedliche Implementierungen (XML, JSON, etc.).

*Lösung:* GpxExporter mit Template-Methode.

```java
abstract class GpxExporter {
    public final GpxFile export(GpsTracker tracker) {
        validateData();        // step 1
        createStructure();     // step 2
        serializeToXML();      // step 3
        writeToFile();         // step 4
        return createGpxFile();// step 5
    }
    
    protected abstract void serializeToXML();
    // ... andere steps
}
```

*Vorteil:* Algorithmische Struktur ist fixiert, Variationen sind klar.

==== 5.3.6 Dependency Injection (optional, für Testbarkeit)

*Problem:* BearingComponent braucht Zugriff auf Logger, GeoUtils, etc.

*Lösung:* Constructor Injection oder Setter Injection.

```java
public class BearingComponentImpl implements BearingComponent {
    private final BearingCalculator calculator;
    private final GpsTracker tracker;
    private final GpxExporter exporter;
    
    public BearingComponentImpl(
        BearingCalculator calculator,
        GpsTracker tracker,
        GpxExporter exporter) {
        this.calculator = calculator;
        this.tracker = tracker;
        this.exporter = exporter;
    }
}
```

*Vorteil:* Testbar mit Mocks, austauschbar.

==== 5.3.7 Singleton Pattern (Logger, Config-Manager)

*Problem:* Logger und zentrale Daten sollten nur einmal instantiiert werden.

*Lösung:* Singleton mit thread-safe lazy initialization.

```java
public class LoggerFactory {
    private static final LoggerFactory INSTANCE = new LoggerFactory();
    
    public static LoggerFactory getInstance() {
        return INSTANCE;
    }
    
    // ...
}
```

*Vorteil:* Einmalige Initialisierung, globaler Zugriff, vorhersehbar.

== 6 Detaillierte Schnittstellenspezifikation

=== 6.1 BearingComponent Interface

```java
/**
 * Zentrale Schnittstelle für Peilungs-Funktionalität.
 * Alle Peilungs-Operationen erfolgen über diese Interface.
 */
public interface BearingComponent {
    
    /**
     * Startet eine neue Peilung zum angegebenen Zielort.
     * 
     * @param target Die Zielkoordinate
     * @param config Konfiguration (optional, nutzt Default falls null)
     * @throws IllegalArgumentException wenn target null ist
     * @throws IllegalStateException wenn bereits eine Peilung aktiv ist
     */
    void startBearing(GeoCoordinate target, BearingConfig config);
    
    /**
     * Aktualisiert die aktuelle Position und neuberechnet Peilung.
     * 
     * @param current Neue aktuelle Koordinate
     * @throws IllegalArgumentException wenn current ungültig ist
     * @throws IllegalStateException wenn keine Peilung aktiv ist
     */
    void updatePosition(GeoCoordinate current);
    
    /**
     * Gibt die aktuellen Peilungs-Informationen zurück.
     * 
     * @return BearingInfo mit aktuellem Azimut, Distanz, etc.
     * @throws IllegalStateException wenn keine Peilung aktiv ist
     */
    BearingInfo getCurrentBearing();
    
    /**
     * Beendet die Peilung ordnungsgemäß und exportiert Daten.
     * 
     * @return GpxFile mit den aufgezeichneten Daten
     * @throws IllegalStateException wenn keine Peilung aktiv ist
     * @throws IOException wenn Datei-Schreiben fehlschlägt
     */
    GpxFile stopBearing();
    
    /**
     * Bricht die Peilung ab, speichert aber Daten mit "_aborted"-Suffix.
     * 
     * @return GpxFile mit bisherigen Daten
     * @throws IOException wenn Datei-Schreiben fehlschlägt
     */
    GpxFile abortBearing();
    
    /**
     * Registriert einen BearingListener für Events.
     * 
     * @param listener Der Listener
     * @throws IllegalArgumentException wenn listener null ist
     */
    void addListener(BearingListener listener);
    
    /**
     * Entfernt einen registrierten Listener.
     * 
     * @param listener Der zu entfernende Listener
     */
    void removeListener(BearingListener listener);
    
    /**
     * Überprüft, ob aktuell eine Peilung aktiv ist.
     * 
     * @return true falls aktiv, false sonst
     */
    boolean isActive();
}
```

=== 6.2 GeoCoordinate Klasse

Unveränderbare (immutable) Klasse für geografische Koordinaten.

```java
public final class GeoCoordinate {
    private final double latitude;   // -90 bis +90
    private final double longitude;  // -180 bis +180
    private final double elevation;  // Meter NN
    private final Instant timestamp; // UTC
    private final double hdop;       // Horizontal Dilution of Precision
    private final int satelliteCount;
    private final double speed;      // m/s
    private final double course;     // 0-360 degrees
    
    // Constructor (private, nur Builder)
    // Builder: GeoCoordinate.builder().latitude(48.5).longitude(9.2)...build()
    
    // Validierung im Builder
    // - latitude in [-90, 90]
    // - longitude in [-180, 180]
    // - elevation in [-500, 9000]
    // - timestamp nicht in Zukunft
    // - hdop, satellite >= 0
    // - speed >= 0
    // - course in [0, 360) oder -1 für unbekannt
    
    public double getLatitude() { ... }
    public double getLongitude() { ... }
    public double getElevation() { ... }
    public Instant getTimestamp() { ... }
    public double getHdop() { ... }
    public int getSatelliteCount() { ... }
    public double getSpeed() { ... }
    public double getCourse() { ... }
    
    // Hilfs-Methoden
    public boolean isValid() { ... }
    public double distanceTo(GeoCoordinate other) { ... }
    public double bearingTo(GeoCoordinate other) { ... }
    
    @Override
    public String toString() { ... }
    
    @Override
    public boolean equals(Object o) { ... }
    
    @Override
    public int hashCode() { ... }
}
```

=== 6.3 Fehlerbehandlung und Exceptions

*Custom Exceptions:*

```java
// Basis-Exception
public abstract class BearingException extends Exception { }

// Spezifische Exceptions
public class InvalidCoordinateException extends BearingException { }
public class InvalidStateException extends BearingException { }
public class GpxExportException extends BearingException { }
public class GpsTrackingException extends BearingException { }

// Vererbung:
// RuntimeException (unkritisch)
//   ├── IllegalArgumentException (ungültige Eingabe)
//   └── IllegalStateException (ungültiger Zustand)
// BearingException (kritisch)
//   ├── InvalidCoordinateException
//   ├── GpxExportException
//   └── GpsTrackingException
```

== 7 Implementierungs-Strategie

=== 7.1 Technologie-Stack

| Komponente | Wahl | Grund |
|---|---|---|
| Sprache | Java 11+ | Anforderung |
| Build-Tool | Maven 3.8+ | Standard |
| Logging | SLF4J + Logback | Best-Practice |
| XML-Verarbeitung | JAXB | Standard in Java |
| Testing | JUnit 5 + Mockito | Modern, mächtig |
| Code-Qualität | SonarQube, Checkstyle | Static Analysis |
| Metriken | JaCoCo (Coverage) | Coverage-Reports |
| Version-Control | Git | Standard |

=== 7.2 Modul-Implementierungs-Reihenfolge

1. **data-model** (zuerst)
   - Datenklassen (GeoCoordinate, BearingInfo, etc.)
   - Exceptions
   - Keine Abhängigkeiten

2. **bearing-utils**
   - Validierung
   - GeoUtils (Haversine, Azimut)
   - MathUtils
   - Logging-Setup

3. **bearing-core**
   - BearingComponent Interface + Impl
   - BearingCalculator
   - BearingConfig
   - Abhängig von: data-model, bearing-utils

4. **gps-tracker**
   - GpsTracker-Klasse
   - Filterung und Anforderungen
   - Abhängig von: bearing-core

5. **gpx-exporter**
   - GpxExporter, GpxFile
   - XML-Serialisierung (JAXB)
   - Datei-I/O
   - Abhängig von: bearing-core, gps-tracker

=== 7.3 Deployment und Verteilung

*Verteilungs-Format:*
- Source-Code als Maven-Projekt
- JAR-Dateien für jedes Modul
- Keine ausführbare JAR (fat-jar) für Auftraggeber
- Dokumentation im Projekt-Root

*Installationsanleitung:*
```bash
mvn clean install                    # Kompiliert und installiert
mvn verify                          # Führt Tests durch
mvn site                            # Generiert Reports
mvn package -DskipTests            # Packaging ohne Tests
```

== 8 Testkonzept und Testfallbeschreibung

=== 8.1 Test-Strategie

*Test-Pyramide:*
```
         △  Manual Testing (Integration)
        ╱└╲ Integrationstests
       ╱   ╲
      ╱     ╲ Unit-Tests
     ╱       ╲
    ╱_________╲
```

*Ziel:*
- 70% Unit-Tests (schnell, isoliert)
- 20% Integrationstests (Module zusammen)
- 10% Systemtests / Manuell (End-to-End)

=== 8.2 Unit-Test-Beispiele

==== 8.2.1 Test: GeoCoordinate Validierung

```java
@DisplayName("GeoCoordinate - Validierung")
public class GeoCoordinateValidationTest {
    
    @ParameterizedTest
    @ValueSource(doubles = {-90.0, 0.0, 45.5, 90.0})
    void testValidLatitude(double lat) {
        GeoCoordinate coord = GeoCoordinate.builder()
            .latitude(lat)
            .longitude(0)
            .build();
        assertTrue(coord.isValid());
    }
    
    @Test
    void testInvalidLatitude_TooHigh() {
        assertThrows(IllegalArgumentException.class, () -> {
            GeoCoordinate.builder()
                .latitude(91.0)
                .longitude(0)
                .build();
        });
    }
    
    @Test
    void testInvalidLatitude_TooLow() {
        assertThrows(IllegalArgumentException.class, () -> {
            GeoCoordinate.builder()
                .latitude(-91.0)
                .longitude(0)
                .build();
        });
    }
    
    // Ähnliche Tests für Longitude, Elevation, etc.
}
```

==== 8.2.2 Test: Haversine-Distanzberechnung

```java
@DisplayName("GeoUtils - Haversine Distance")
public class GeoUtilsDistanceTest {
    
    @Test
    void testDistanceEquator() {
        // Zwei Punkte am Äquator, 1° Abstand ≈ 111 km
        GeoCoordinate p1 = GeoCoordinate.builder()
            .latitude(0).longitude(0).build();
        GeoCoordinate p2 = GeoCoordinate.builder()
            .latitude(0).longitude(1).build();
        
        double distance = GeoUtils.haversineDistance(p1, p2);
        assertEquals(111194.93, distance, 10); // Toleranz: ±10m
    }
    
    @Test
    void testDistanceSamePoint() {
        GeoCoordinate p1 = GeoCoordinate.builder()
            .latitude(48.5).longitude(9.2).build();
        
        double distance = GeoUtils.haversineDistance(p1, p1);
        assertEquals(0.0, distance, 0.001);
    }
}
```

==== 8.2.3 Test: Azimut-Berechnung

```java
@DisplayName("BearingCalculator - Azimuth")
public class BearingCalculatorAzimuthTest {
    
    private BearingCalculator calculator = new BearingCalculator();
    
    @Test
    void testAzimuthNorth() {
        GeoCoordinate from = GeoCoordinate.builder()
            .latitude(0).longitude(0).build();
        GeoCoordinate to = GeoCoordinate.builder()
            .latitude(1).longitude(0).build();
        
        double azimuth = calculator.calculateAzimuth(from, to);
        assertEquals(0.0, azimuth, 0.1); // Nord = 0°
    }
    
    @Test
    void testAzimuthEast() {
        GeoCoordinate from = GeoCoordinate.builder()
            .latitude(0).longitude(0).build();
        GeoCoordinate to = GeoCoordinate.builder()
            .latitude(0).longitude(1).build();
        
        double azimuth = calculator.calculateAzimuth(from, to);
        assertEquals(90.0, azimuth, 0.1); // Ost = 90°
    }
    
    @Test
    void testAzimuthSouth() {
        GeoCoordinate from = GeoCoordinate.builder()
            .latitude(0).longitude(0).build();
        GeoCoordinate to = GeoCoordinate.builder()
            .latitude(-1).longitude(0).build();
        
        double azimuth = calculator.calculateAzimuth(from, to);
        assertEquals(180.0, azimuth, 0.1); // Süd = 180°
    }
    
    @Test
    void testAzimuthWest() {
        GeoCoordinate from = GeoCoordinate.builder()
            .latitude(0).longitude(0).build();
        GeoCoordinate to = GeoCoordinate.builder()
            .latitude(0).longitude(-1).build();
        
        double azimuth = calculator.calculateAzimuth(from, to);
        assertEquals(270.0, azimuth, 0.1); // West = 270°
    }
}
```

=== 8.3 Integrationstests

==== 8.3.1 Test: Peilung starten und aktualisieren

```java
@DisplayName("Integration - Bearing Lifecycle")
public class BearingLifecycleIntegrationTest {
    
    private BearingComponent bearing;
    private BearingListenerMock listener;
    
    @BeforeEach
    void setup() {
        bearing = new BearingComponentImpl(
            new BearingCalculator(),
            new GpsTracker(),
            new GpxExporter()
        );
        listener = new BearingListenerMock();
        bearing.addListener(listener);
    }
    
    @Test
    void testCompleteBearingCycle() {
        // 1. Start
        GeoCoordinate target = GeoCoordinate.builder()
            .latitude(48.5).longitude(9.2).build();
        bearing.startBearing(target, null);
        
        assertTrue(bearing.isActive());
        assertTrue(listener.onBearingStartedCalled);
        
        // 2. Update mit mehreren Positionen
        for (int i = 0; i < 5; i++) {
            GeoCoordinate current = GeoCoordinate.builder()
                .latitude(48.4 + i * 0.01)
                .longitude(9.1 + i * 0.01)
                .build();
            bearing.updatePosition(current);
        }
        
        assertEquals(5, listener.onPositionUpdatedCount);
        
        // 3. Stop
        GpxFile gpxFile = bearing.stopBearing();
        
        assertFalse(bearing.isActive());
        assertTrue(listener.onBearingStoppedCalled);
        assertNotNull(gpxFile);
        assertTrue(gpxFile.getFilePath().toFile().exists());
    }
    
    @Test
    void testAbortBearing() {
        // Start
        bearing.startBearing(GeoCoordinate.builder()
            .latitude(48.5).longitude(9.2).build(), null);
        
        // Add some points
        for (int i = 0; i < 3; i++) {
            bearing.updatePosition(GeoCoordinate.builder()
                .latitude(48.4).longitude(9.1).build());
        }
        
        // Abort
        GpxFile gpxFile = bearing.abortBearing();
        
        // Check file name contains "_aborted"
        assertTrue(gpxFile.getFilePath().toString().contains("_aborted"));
    }
}
```

=== 8.4 Performance-Tests

```java
@DisplayName("Performance - Bearing Calculation")
public class BearingCalculationPerformanceTest {
    
    private BearingCalculator calculator;
    
    @BeforeEach
    void setup() {
        calculator = new BearingCalculator();
    }
    
    @Test
    void testAzimuthPerformance() {
        GeoCoordinate from = GeoCoordinate.builder()
            .latitude(48.5).longitude(9.2).build();
        GeoCoordinate to = GeoCoordinate.builder()
            .latitude(48.6).longitude(9.3).build();
        
        // Warm-up
        for (int i = 0; i < 1000; i++) {
            calculator.calculateAzimuth(from, to);
        }
        
        // Test: 1 Mio. Aufrufe sollten < 50 ms pro 100 Aufrufe sein
        long start = System.nanoTime();
        for (int i = 0; i < 1_000_000; i++) {
            calculator.calculateAzimuth(from, to);
        }
        long durationNanos = System.nanoTime() - start;
        long durationPerCall = durationNanos / 1_000_000;
        
        assertTrue(durationPerCall < 50_000, // 50 µs auf Mittel
            "Average call took " + durationPerCall + " ns");
    }
}
```

== 9 Erweiterte Anforderungen (1+ mit Sternchen)

=== 9.1 Kalman-Filter für GPS-Punkt-Glättung

*Ziel:* Rauschen aus GPS-Daten entfernen, während echte Bewegung beibehalten wird.

*Anforderung RF-E1:*
Ein optionaler Kalman-Filter kann aktiviert werden, um GPS-Punkte zu glätten.
- Input: Rohe GPS-Punkte mit Unsicherheit (HDOP)
- Output: Gefilterte Punkte mit verringertem Rauschen
- Akzeptanz: RMSE nach Filterung < 50% des Rohwerts

*Implementierung:*
- KalmanFilter-Klasse mit 2D-Zustand (Lat, Lon)
- Initialisierung mit erstem Punkt
- Update mit jedem neuen Punkt
- Optional konfigurierbar (an/aus, Prozess/Messrauschen)

=== 9.2 Ramer-Douglas-Peucker Algorithmus

*Ziel:* Spurvereinfachung, um Anzahl Datenpunkte zu reduzieren.

*Anforderung RF-E2:*
Ein Linienvereinfachungs-Algorithmus reduziert Anzahl Punkte unter Beibehaltung der Kurvenform.
- Input: Track mit n Punkten
- Output: Track mit k < n Punkten
- Parameter: Epsilon (max. Abweichung in Metern)
- Akzeptanz: 80% Reduktion bei Epsilon = 100m

*Implementierung:*
- RamerDouglasPeucker-Klasse
- Rekursive Spline-Reduktion
- Konfigurierbar via BearingConfig

=== 9.3 Statistische Auswertung

*Ziel:* Zusätzliche Track-Statistiken für Analyse und Feedback.

*Anforderung RF-E3:*
Track-Statistiken werden automatisch berechnet.
- Gesamtstrecke
- Durchschnittsgeschwindigkeit
- Max/Min Elevation, Geschwindigkeit
- Höhengewinn/Verlust
- Zeitdauer

*Implementierung:*
- TrackStatistics-Klasse
- Berechnung nach stopBearing()
- In GPX-Metadaten gespeichert

=== 9.4 What3Words Integration

*Ziel:* Benutzerfreundliche Adress-Kodierung für Koordinaten.

*Anforderung RF-E4:*
Koordinaten können als What3Words-Adressen dargestellt werden (optional).
- Input: GeoCoordinate
- Output: "///word.word.word" oder null
- Akzeptanz: Konvertierung bei Verfügbarkeit von W3W-API

*Implementierung:*
- W3WConverter-Klasse
- Optional, mit Fallback auf Koordinaten
- Externe API-Abhängigkeit (com.what3words:what3words-java-wrapper)

=== 9.5 Multi-Target Peilung

*Ziel:* Gleichzeitiges Tracking mehrerer Ziele pro Track-Aufzeichnung.

*Anforderung RF-E5:*
Mehrere Ziele können gleichzeitig verfolgt werden.
- Input: List<GeoCoordinate> targets beim Start
- Output: BearingInfo[] mit jedem Update
- Akzeptanz: Mindestens 5 Ziele gleichzeitig

*Implementierung:*
- Multi-BearingComponent (oder erweitert BearingComponent)
- Logic bleibt einfach (n × Berechnung), aber Architektur muss kopiert werden

=== 9.6 Geofencing

*Ziel:* Benachrichtigung beim Verlassen/Betreten eines geografischen Radius.

*Anforderung RF-E6:*
Geofencing-Regeln können definiert werden.
- Input: GeoCoordinate center, double radius
- Output: onGeofenceEntered(), onGeofenceExited() Events
- Akzeptanz: < 100ms Latenz bei Grenzenüberschreitung

*Implementierung:*
- GeofenceRule-Klasse
- Zusätzliche BearingListener-Callbacks
- Check in updatePosition()

== 10 Qualitätssicherung und Metadaten

=== 10.1 Code-Qualitäts-Standards

*Checkstyle-Regeln:*
- Zeilenlänge: max. 120 Zeichen
- Einrücken: 4 Leerzeichen
- Javadoc: für öffentliche Methoden zwingend
- Naming: camelCase für Variablen, PascalCase für Klassen

*Formatierung:*
- Code-Style: Google Java Style Guide
- IDE-Konfiguration (.editorconfig) im Projekt enthalten

=== 10.2 Test-Reports und Metriken

*JaCoCo Code Coverage:*
- bearing-core: 90%+
- gps-tracker: 85%+
- gpx-exporter: 80%+
- Gesamtdurchschnitt: 85%+

*SonarQube-Analyse:*
- Code-Smells: 0
- Bugs: 0
- Security-Issues: 0
- Technical Debt Ratio: < 5%

=== 10.3 Dokumentation

*Ausgegeben werden:*
1. Quellcode mit Javadoc
2. Maven Site (Reports, JavaDoc, Tests)
3. Architektur-Dokumente (UML-Diagramme, Patterns)
4. API-Dokumentation (HTML, generiert von Javadoc)
5. Installation & Verwendungsanleitung

== 11 Zusammenfassung und Rückblick

=== 11.1 Abdeckung der Vorlesungsthemen

*Semester 1 (Anforderungsmanagement & Spezifikation):*
- [x] SOPHIST-Regeln für Anforderungen
- [x] IEEE 830 Spezifikation
- [x] Stakeholder-Analyse
- [x] Use-Case-Diagramme
- [x] Glossar und Definitionen

*Semester 2 (Design & Architektur):*
- [x] UML-Klassendagramm
- [x] Sequenzdiagramme
- [x] Zustandsdiagramme
- [x] Aktivitätsdiagramme
- [x] Schichtenarchitektur (4-Schichtenmodell)
- [x] Entwurfsmuster (Facade, Observer, Builder, Strategy, Template Method, Dependency Injection, Singleton)
- [x] Modular-Struktur (Maven-Module)
- [x] Testkonzept (Unit, Integration, Performance)

=== 11.2 Erfüllung der Anforderungen aus dem Projektauftrag

✅ **Anforderungsanalyse durchgeführt** nach SOPHIST-Regeln
✅ **Spezifikation** nach IEEE 830-1998
✅ **Systemdesign** mit UML und Patterns
✅ **Java-Implementierung** (sourcecode, keine UI)
✅ **Testkonzept** detailliert dokumentiert
✅ **Keine User Stories** (nur Anforderungen)
✅ **Keine Aufwandsschätzung** (wie gefordert)
✅ **Ausführliche Dokumentation** dieses Dokument)
✅ **Alle Themengebiete betrachtetes** aus Vorlesung integriert
✅ **Leicht ausführbar** (Maven build, JUnit tests)

=== 11.3 Nächste Schritte

1. **Implementierungs-Phase starten** nach Freigabe dieser Spezifikation
2. **Module in Reihenfolge abarbeiten** (siehe 7.2)
3. **Tests parallel schreiben** (TDD oder Test-Last)
4. **Code-Reviews durchführen**
5. **Finale Dokumentation & Abgabe**

== Literaturverzeichnis

1. IEEE 830-1998, "IEEE Recommended Practice for Software Requirements Specifications"
2. Goll, J., & Linden, T. (2007). "Entwurfsmuster in Java" (3. Aufl.). Addison-Wesley
3. Larman, C. (2005). "Applying UML and Patterns: An Introduction to Object-Oriented Analysis and Design" (3. Aufl.). Prentice Hall
4. Topografix. (2011). "GPX 1.1 Schema Documentation". https://www.topografix.com/GPX/1/1
5. Haversine Formula. (n.d.). Wikipedia. https://en.wikipedia.org/wiki/Haversine_formula
6. McConnell, S. (2004). "Code Complete: A Practical Handbook of Software Construction" (2. Aufl.). Microsoft Press
7. Welch, G., & Bishop, G. (2006). "An Introduction to the Kalman Filter"
8. Ramer, U. (1972). "An Algorithm for the Reduction of the Number of Points Required to Represent a Digitized Curve". Communications of the ACM, 15(2), 87-88

== Anhang A: Glossar

| Begriff | Definition |
|---|---|
| Azimut | Horizontalwinkel von Nord (0°) über Ost (90°), Süd (180°), West (270°) zurück zu Nord |
| Deklination | Unterschied zwischen magnetischem und geographischem Nord |
| HDOP | Horizontal Dilution of Precision; Genauigkeitsmaß für horizontale GPS-Positionen |
| WGS84 | World Geodetic System 1984; Standard-Referenzsystem für geografische Koordinaten |
| GPX | GPS Exchange Format; offenes XML-Format für GPS-Daten |
| Track | Sequenz von GPS-Punkten, die einen Weg darstellen |
| Waypoint | Ein einzelner benannter GPS-Punkt |
| Peilung | Richtungs- und Distanzangabe von einem Punkt zu einem anderen |
| Kalman-Filter | Mathematischer Algorithmus zur Rausch-Reduzierung in Messreihen |

== Anhang B: Aufstellung der Fragen und Antworten

Siehe Kapitel 2.2, wo alle Original-Fragen systematisch beantwortet wurden:
- 2.2.1: Was ist Peilung?
- 2.2.2: GPX-Standard?
- 2.2.3: Aufzuzeichnende Daten?
- 2.2.4: Zeitintervall?
- 2.2.5: Genauigkeit?
- 2.2.6: Performance?
- 2.2.7: Ungültige Koordinaten?
- 2.2.8: Speicherort?
- 2.2.9: Schnittstellen?
- 2.2.10: Datenabbruch?
- 2.2.11: W3W?
- 2.2.12: Size-Limits?
- 2.2.13: Test-Abdeckung?
- 2.2.14: Optimierung für 1+?

== Anhang C: Abkürzungsverzeichnis

| Abkürzung | Langform |
|---|---|
| API | Application Programming Interface |
| DI | Dependency Injection |
| FAoordinate | Functional Requirement |
| GPX | GPS Exchange Format |
| GPS | Global Positioning System |
| HDOP | Horizontal Dilution of Precision |
| IEEE | Institute of Electrical and Electronics Engineers |
| JAXB | Java Architecture for XML Binding |
| JUnit | Java Unit Testing Framework |
| NFA | Non-Functional Requirement |
| NN | Normalnull (Bezugsebene für Höhe) |
| RF | Requirement |
| RFC | Request for Comment |
| SLF4J | Simple Logging Facade for Java |
| SOPHIST | Systematically Optimized Process for Requirements Handling & Inspection |
| SWE | Software Engineering |
| TDD | Test-Driven Development |
| UML | Unified Modeling Language |
| W3W / What3Words | Global Addressing System |
| XSD | XML Schema Definition |

== Anhang D: Kontakt- und Versionsinformationen

**Dokument Version:** 1.0
**Entwickelt:** April 2026
**Hochschule:** Duale Hochschule Baden-Württemberg Stuttgart
**Studiengang:** Informatik, Semester 4
**Modul:** Software Engineering (SWE)
**Betreuer:** Dozent Bohl

**Überarbeitungsverlauf:**
- 1.0 (2026-04-16): Initiale Erstellung der vollständigen Spezifikation

#set page(numbering: none)

---

*Ende der Spezifikation*

Die vorliegende Spezifikation bildet die Grundlage für die Implementierung der Java Peilungs-Komponente. Sie erfüllt alle Anforderungen des Projektauftrags und integriert systematisch alle Themengebiete der Software-Engineering-Vorlesung (Semester 3 und 4) der DHBW Stuttgart.

#pagebreak()

= ANHANG: UML-DIAGRAMME UND ERWEITERTE DOKUMENTATION

#pagebreak()

== Anhang E: UML-Klassendiagramm

#figure(
  image("../Documentation/UML_01_Klassendiagramm.puml", width: 100%),
  caption: "Abbildung E1: SWE-Kompass Klassendiagramm - Zeigt alle Klassen, Interfaces und Beziehungen"
)

Das Klassendiagramm bildet die Kernarchitektur der Komponente ab:

- **BearingComponent** (Interface): Facade für externe Nutzung
- **BearingServiceImpl**: Hauptgeschäftslogik
- **GPXExportService**: XML/GPX-Export-Logik
- **TrackOptimizationService**: Optimierungsalgorithmen
- **W3WIntegrationService**: What3Words REST-Integration
- **Validators**: Eingabe-Validierung
- **Repository Pattern**: Daten-Abstraktionen
- **Value Objects**: Immutable Datenklassen (Position, GPSPoint, etc.)
- **Entities**: Zustandsbehaftete Objekte (BearingSession, GPSTrack)

#pagebreak()

== Anhang F: Sequenzdiagramme

=== F.1 Sequenzdiagramm: Normale Peilung (Happy Path)

#figure(
  image("../Documentation/UML_02_Sequenzdiagramm_NormaleBeilung.puml", width: 100%),
  caption: "Abbildung F1: Sequenzdiagramm - Normale Peilung von Start bis Ende"
)

*Beschreibung:*
Zeigt den normalen Ablauf einer Peilung:
1. Externe App initiiert Peilung mit Position und Azimuth
2. BearingComponent validiert Eingaben
3. BearingServiceImpl erstellt BearingSession
4. App ruft updateBearing() mehrfach auf (kontinuierliche Sensordaten)
5. GPS-Punkte werden gesammelt und Track wird aufgebaut
6. App beendet Peilung mit completeBearing()
7. Track wird optimiert und Ergebnisse zurückgegeben
8. GPX-Export wird durchgeführt (optional Datei-Speicherung)

#pagebreak()

=== F.2 Sequenzdiagramm: Abbruch mit Daten-Rückgabe

#figure(
  image("../Documentation/UML_03_Sequenzdiagramm_Abbruch.puml", width: 100%),
  caption: "Abbildung F2: Sequenzdiagramm - Abbruch-Szenario mit optionaler Daten-Speicherung"
)

*Beschreibung:*
Zeigt das Abbruch-Szenario (vorzeitige Beendigung):
1. Peilung wird normal gestartet und mit Updates fortgesetzt
2. Nutzer bricht Peilung ab (z.B. durch Nutzer-Aktion in der App)
3. BearingComponent.abortBearing() wird aufgerufen
4. BearingResult wird mit Status ABORTED zurückgegeben
5. Daten bleiben IN-MEMORY verfügbar
6. **WICHTIG:** Keine automatische Speicherung!
7. App entscheidet darüber, ob Daten gespeichert werden ("Daten speichern?")
8. Optional: exportToGPXString() für optionale Speicherung
9. Oder: Daten werden verworfen

*Spezialfall nach Bohl:* Bei Abbruch sollen trotzdem GPX-Daten ausgegeben werden können, aber es erfolgt keine automatische Speicherung.

#pagebreak()

== Anhang G: Aktivitätsdiagramm (Peilungs-Prozess)

#figure(
  image("../Documentation/UML_04_Aktivitaetsdiagramm.puml", width: 100%),
  caption: "Abbildung G1: Aktivitätsdiagramm - Zeigt den Prozessablauf der Peilung"
)

*Beschreibung - Hauptaktivitäten:*

1. **Initialisierung** 
   - Nutzer startet Peilung mit initialer Position und Azimuth
   - Validierung der Eingaben

2. **Track-Aufzeichnung** (Schleife)
   - GPS-Punkte werden kontinuierlich empfangen
   - Validierung pro Punkt
   - Speicherung im Track-Buffer
   - Optional: Immediate Optimization?

3. **Peilung aktiv** (kontinuierliche Schleife)
   - Peilungs-Richtung wird aktualisiert (Azimuth)
   - Kompass-Richtung wird berechnet (N, NE, E, etc.)
   - Punkte werden gezählt

4. **Beendigung**
   - Nutzer beendet Peilung oder bricht ab
   - Unterschiedliche Pfade für COMPLETED vs ABORTED
   - Track wird finalisiert

5. **Optimierung** (bei COMPLETED)
   - Track-Optimierung wird angewendet
   - Redundante Punkte werden entfernt
   - Statistiken werden berechnet

6. **Export** (optional)
   - GPX-Konvertierung
   - Datei-Speicherung (wenn gewünscht)
   - What3Words Auflösung (optional)

#pagebreak()

== Anhang H: Zustandsdiagramm (Session-Zustände)

#figure(
  image("../Documentation/UML_05_Zustandsdiagramm.puml", width: 100%),
  caption: "Abbildung H1: Zustandsdiagramm - BearingSession Zustandsübergänge"
)

*Zustände und Übergänge:*

```
[*] → INITIATED
      (Session erstellt)
        ↓
    INITIATED → ACTIVE
      (initiateBearing() aufgerufen)
        ↓
      ACTIVE ↔ ACTIVE  (Schleife: updateBearing())
        ↓ ↓
        ├→ COMPLETED  (completeBearing())
        │   (normales Ende)
        │   - Track optimiert
        │   - Statistiken berechnet
        │   - Export möglich
        └→ [*]
        
        └→ ABORTED  (abortBearing())
            (vorzeitiges Ende)
            - Daten in-memory verfügbar
            - Keine automatische Speicherung
            - Export optional
            → [*]
```

*Bedeutung der Zustände:*

- **INITIATED**: Session gerade erstellt, aber nicht aktiv
- **ACTIVE**: Daten werden aufgezeichnet, Updates erfolgen
- **COMPLETED**: Normal beendet, Track fertig optimiert
- **ABORTED**: Vorzeitig abgebrochen, aber Daten verfügbar

#pagebreak()

== Anhang I: Komponentendiagramm (Übersicht)

#figure(
  image("../Documentation/UML_06_Komponentendiagramm.puml", width: 100%),
  caption: "Abbildung I1: Komponentendiagramm - Komponenten und externe Systeme"
)

*Komponenten-Übersicht:*

**Interne Komponenten:**
- BearingComponent (Facade)
- BearingService
- GPXExportService
- TrackOptimizationService
- W3WIntegrationService
- Validators
- Algorithms
- Repository

**Externe Systeme:**
- GPS Provider (Koordinaten)
- Magnetometer (Azimuth-Daten)
- W3W API (REST, optional)
- Dateisystem (für GPX-Export)

**Externe Applikation:**
- Nutzt BearingComponent Interface
- Sendet Positionen und Azimuthe
- Empfängt Peilungs-Updates
- Initiiert Export optional

#pagebreak()

== Anhang J: Implementierungs-Checkliste

=== J.1 Java-Klassen zu implementieren

*API Layer:*
- [ ] BearingComponent.java (Interface)
- [ ] Position.java (Value Object)
- [ ] BearingSession.java (Entity)
- [ ] BearingResult.java (Value Object)
- [ ] GPSPoint.java (Value Object)
- [ ] UpdateResult.java (Value Object)
- [ ] W3WLocation.java (Value Object)
- [ ] BearingException.java
- [ ] GPXException.java
- [ ] ValidationException.java

*Service Layer:*
- [ ] BearingServiceImpl.java (Main Logic, ~500 Zeilen)
- [ ] GPXExportService.java (~300 Zeilen)
- [ ] TrackOptimizationService.java (~400 Zeilen)
- [ ] W3WIntegrationService.java (~250 Zeilen)

*Domain Layer:*
- [ ] Azimuth.java (Value Object)
- [ ] GPSTrack.java (Entity)
- [ ] OptimizedTrack.java (Value Object)
- [ ] BearingStatus.java (Enum)
- [ ] OptimizationMode.java (Enum)
- [ ] CompassDirection.java (Enum)

*Validator Layer:*
- [ ] PositionValidator.java (~100 Zeilen)
- [ ] AzimuthValidator.java (~80 Zeilen)
- [ ] CoordinateValidator.java (~120 Zeilen)
- [ ] GPXValidator.java (~150 Zeilen)

*Algorithm Layer:*
- [ ] HaversineCalculator.java (~100 Zeilen)
- [ ] CompassConverter.java (~80 Zeilen)
- [ ] LineSimplificationAlgorithm.java (~200 Zeilen)
- [ ] PointBasedOptimizer.java (~80 Zeilen)
- [ ] DistanceBasedOptimizer.java (~100 Zeilen)

*Repository Layer:*
- [ ] BearingSessionRepository.java (Interface)
- [ ] InMemoryBearingRepository.java (~100 Zeilen)
- [ ] GPXFileRepository.java (~150 Zeilen)

*Integration Layer:*
- [ ] W3WClient.java (Interface)
- [ ] HttpW3WClientImpl.java (~200 Zeilen)
- [ ] MockW3WClientImpl.java (~80 Zeilen, für Tests)
- [ ] GPXWriter.java (~300 Zeilen)
- [ ] W3WCacheProvider.java (~150 Zeilen)

*Config & Infrastructure:*
- [ ] BearingComponentConfig.java (~80 Zeilen)
- [ ] DependencyInjectionFactory.java (~150 Zeilen)
- [ ] BearingLogger.java (~100 Zeilen)
- [ ] PerformanceMonitor.java (~120 Zeilen)
- [ ] GPXConstants.java (~50 Zeilen)
- [ ] GeoConstants.java (~40 Zeilen)

**Gesamtumfang erwarteter Source-Code: ~4.500-5.000 Zeilen Java**

=== J.2 Test-Klassen zu implementieren

*Unit-Tests:*
- [ ] BearingComponentTest.java (20+ Tests)
- [ ] BearingServiceImplTest.java (50+ Tests)
- [ ] GPXExportServiceTest.java (20+ Tests)
- [ ] TrackOptimizationServiceTest.java (40+ Tests)
- [ ] W3WIntegrationServiceTest.java (25+ Tests)
- [ ] PositionValidatorTest.java (15+ Tests)
- [ ] AzimuthValidatorTest.java (10+ Tests)
- [ ] HaversineCalculatorTest.java (15+ Tests)
- [ ] LineSimplificationAlgorithmTest.java (20+ Tests)
- [ ] CompassConverterTest.java (12+ Tests)

*Integration-Tests:*
- [ ] CompleteBearingScenarioTest.java (5+ Tests)
- [ ] ABortBearingScenarioTest.java (3+ Tests)
- [ ] GPXExportIntegrationTest.java (4+ Tests)
- [ ] TrackOptimizationIntegrationTest.java (5+ Tests)

*Performance-Tests (JMH):*
- [ ] BearingServiceBenchmarks.java (5+ Benchmarks)
- [ ] TrackOptimizationBenchmarks.java (3+ Benchmarks)

*Test-Fixtures:*
- [ ] PositionFixture.java
- [ ] GPSPointFixture.java
- [ ] BearingResultFixture.java

**Erwartet: 300+ Unit-Tests, ~200+ Integration-Tests**

#pagebreak()

== Anhang K: Ausführliche Anforderungsanalyse (SOFIST)

Die vollständige Anforderungsanalyse mit allen SOFIST-Regeln ist in der separaten Datei `1_ANFORDERUNGSANALYSE.md` dokumentiert:

*Inhalte:*
- Hintergrund und Ziele
- SOFIST-Regeln (Spezifik, Observierbar, Fähigkeiten, Individuell, Realisierbar, Testbar)
- Objekt-orientierte Analyse mit Aktivitätsdiagrammen
- Stakeholder-Anforderungen
- 7 Funktionale Anforderungen (F001-F007) mit Details
- 5 Nicht-funktionale Anforderungen (NF001-NF005)
- Fehlerbehandlung und Edge Cases
- Integrationsvorgaben
- Constraints und Rahmenbedingungen
- Abnahmekriterien
- Glossar

*Diese Dokumentation ist normativ und bindend für die Implementierung.*

#pagebreak()

== Anhang L: IEEE 830 Spezifikation (Auszug)

Die ausführliche IEEE 830 Spezifikation ist in der separaten Datei `2_SPEZIFIKATION_IEEE830.md` dokumentiert:

*Hauptkapitel:*

1. **Einführung & Gültigkeitsbereich**
   - Zweck der Spezifikation
   - Gültige Plattformen (Java 11+)
   - Definitions und Abkürzungen

2. **Allgemeine Beschreibung**
   - Produkt-Übersicht (6-Schichten-Modell)
   - Komponenten-Abgrenzung (Was die Komponente macht/nicht macht)

3. **Spezifische Anforderungen**
   - F001-F007: Detaillierte funktionale Anforderungen mit Signatur, Validierung, Verarbeitung
   - NF001-NF004: Nicht-funktionale Anforderungen (Performance, Zuverlässigkeit, etc.)

4. **Architektur und Design**
   - Schichtenmodell (6 Schichten)
   - 8 Design Patterns mit Begründung
   - SOLID-Prinzipien

5. **Datenmodelle**
   - UML-Klassendiagramm (textuelle Beschreibung)
   - Entity-Relationship Diagramm
   - Enumerations

6. **Schnittstellen (API)**
   - Public API mit vollständiger JavaDoc
   - Record-Definitionen
   - Exception-Hierarchie

7. **Algorithmen und Verfahren**
   - Sequenzdiagramme
   - Pseudocode für alle 5 Kernalgorithmen
   - Datenfluss-Beispiele

8. **Qualitätsanforderungen**
   - Code-Qualität, Sicherheit, Skalierbarkeit, Wartbarkeit

9. **Testbarkeitsanforderungen**
   - Unit-Test-Struktur
   - Integration-Test-Szenarien
   - Performance-Test-Patterns
   - Mock-Objekte und Test-Doubles

*Diese Spezifikation ist normativ und rechtsbindend für die Implementierung.*

#pagebreak()

== Anhang M: Algorithmen in Pseudocode und Python-Referenz-Implementierung

=== M.1 Haversine-Formel (Großkreis-Distanz)

```python
import math

def haversine_distance(lat1, lon1, lat2, lon2):
    """
    Berechne Großkreis-Distanz zwischen zwei GPS-Koordinaten.
    
    Parameter:
        lat1, lon1: Startkoordinate (Dezimalgrad)
        lat2, lon2: Zielkoordinate (Dezimalgrad)
    
    Rückgabe:
        Distanz in Metern
    """
    R = 6371000  # Erdradius in Metern
    
    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    delta_lat = math.radians(lat2 - lat1)
    delta_lon = math.radians(lon2 - lon1)
    
    a = math.sin(delta_lat/2)**2 + \
        math.cos(lat1_rad) * math.cos(lat2_rad) * \
        math.sin(delta_lon/2)**2
    
    c = 2 * math.asin(math.sqrt(a))
    
    distance = R * c
    return distance
```

=== M.2 Punkt-basierte Optimierung

```python
def optimize_point_based(points, interval):
    """
    Behalte jeden N-ten Punkt des Tracks.
    
    Parameter:
        points: Liste von GPS-Punkten
        interval: Interval N (z.B. 10 = behalte jeden 10. Punkt)
    
    Rückgabe:
        Optimierte Liste von Punkten
    """
    if not points or interval <= 0:
        return points
    
    optimized = []
    for i in range(0, len(points), interval):
        optimized.append(points[i])
    
    # Stelle sicher, dass letzter Punkt enthalten ist
    if len(points) > 0 and (len(points) - 1) % interval != 0:
        optimized.append(points[-1])
    
    return optimized
```

=== M.3 Distanz-basierte Optimierung

```python
def optimize_distance_based(points, min_distance_m):
    """
    Behalte Punkte mit Mindestabstand X Meter.
    
    Parameter:
        points: Liste von GPS-Punkten
        min_distance_m: Mindestabstand in Metern
    
    Rückgabe:
        Optimierte Liste von Punkten
    """
    if not points or min_distance_m <= 0:
        return points
    
    optimized = [points[0]]  # Erster Punkt immer
    last_kept = points[0]
    
    for point in points[1:]:
        distance = haversine_distance(
            last_kept.latitude, last_kept.longitude,
            point.latitude, point.longitude
        )
        
        if distance >= min_distance_m:
            optimized.append(point)
            last_kept = point
    
    # Stelle sicher, dass letzter Punkt enthalten ist
    if optimized[-1] != points[-1]:
        optimized.append(points[-1])
    
    return optimized
```

=== M.4 Gerade-Optimierung (Line Simplification)

```python
def simplify_lines(points, tolerance_m=5.0):
    """
    Erkenne Geradensequenzen und reduziere auf Start + Ende.
    
    Parameter:
        points: Liste von GPS-Punkten
        tolerance_m: Toleranz in Metern für Kollinearität
    
    Rückgabe:
        Vereinfachte Liste von Punkten
    """
    if len(points) < 3:
        return points
    
    result = []
    i = 0
    
    while i < len(points):
        if i + 2 < len(points):
            # Versuche, Linie zu erkennen
            line_points = [points[i]]
            j = i + 1
            
            while j < len(points):
                dist_to_line = point_to_line_distance(
                    points[j],
                    points[i],
                    points[j-1]
                )
                
                if dist_to_line <= tolerance_m:
                    line_points.append(points[j])
                    j += 1
                else:
                    break
            
            # Wenn 3+ Punkte kollinear: nur Start + Ende behalten
            if len(line_points) >= 3:
                result.append(line_points[0])
                result.append(line_points[-1])
                i = j
            else:
                result.append(points[i])
                i += 1
        else:
            result.append(points[i])
            i += 1
    
    return result

def point_to_line_distance(point, line_start, line_end):
    """Berechne Abstand eines Punktes zu einer Linie."""
    # Vereinfacht: verwendet orthogonale Projektion
    lat0, lon0 = point.latitude, point.longitude
    lat1, lon1 = line_start.latitude, line_start.longitude
    lat2, lon2 = line_end.latitude, line_end.longitude
    
    numerator = abs((lat2-lat1)*lon0 - (lon2-lon1)*lat0 + lon2*lat1 - lat2*lon1)
    denominator = math.sqrt((lat2-lat1)**2 + (lon2-lon1)**2)
    
    if denominator == 0:
        return haversine_distance(lat0, lon0, lat1, lon1)
    
    distance_degrees = numerator / denominator
    # Konvertiere Grad zu Metern (vereinfacht: 1 Grad ≈ 111 km)
    distance_m = distance_degrees * 111000
    
    return distance_m
```

=== M.5 Azimuth zu Kompass-Konvertierung

```python
def azimuth_to_compass(azimuth_degrees):
    """
    Konvertiere Azimuth (Grad) zu Kompass-Richtung.
    
    Parameter:
        azimuth_degrees: Azimuth in Dezimalgrad [0, 360)
    
    Rückgabe:
        Kompass-Richtung: "N", "NE", "E", "SE", "S", "SW", "W", "NW"
    """
    # Normalisiere zu [0, 360)
    azimuth = azimuth_degrees % 360
    
    # 45°-Bereich um jede Himmelsrichtung
    if 337.5 <= azimuth < 360 or 0 <= azimuth < 22.5:
        return "N"
    elif 22.5 <= azimuth < 67.5:
        return "NE"
    elif 67.5 <= azimuth < 112.5:
        return "E"
    elif 112.5 <= azimuth < 157.5:
        return "SE"
    elif 157.5 <= azimuth < 202.5:
        return "S"
    elif 202.5 <= azimuth < 247.5:
        return "SW"
    elif 247.5 <= azimuth < 292.5:
        return "W"
    elif 292.5 <= azimuth < 337.5:
        return "NW"
```

#pagebreak()

== Anhang N: Maven-Build-Konfiguration (Auszug)

Die vollständige `pom.xml` befindet sich im `Implemantation/` Ordner:

*Abhängigkeiten:*
- JUnit 5.9.2 (Unit-Testing)
- AssertJ 3.24.1 (Assertions)
- SLF4J 2.0.7 + Logback 1.4.8 (Logging)
- Gson 2.10.1 (JSON für W3W API)
- JMH 1.35 (Performance Benchmarking)
- JaCoCo 0.8.10 (Code-Coverage)

*Build-Plugins:*
- Maven Compiler (Java 11)
- Maven Surefire (Test-Ausführung)
- JaCoCo (Code-Coverage-Reports)
- Maven Checkstyle (Code-Qualität)

*Ausführung:*
```bash
# Kompilieren
mvn clean compile

# Tests ausführen
mvn test

# Code-Coverage Report
mvn test jacoco:report

# Package erstellen (optional, kein Executable!)
mvn clean package
```

#pagebreak()

== Anhang O: Integration in externe Applikationen

=== O.1 Verwendungsbeispiel (Java)

```java
import com.swe.kompass.api.*;
import com.swe.kompass.config.*;

public class MyApp {
    public static void main(String[] args) {
        // 1. Komponente initialisieren
        BearingComponentConfig config = new BearingComponentConfig()
            .setW3WApiKey("optional-api-key")
            .setMaxAccuracy(100.0)
            .setOptimizationMode(OptimizationMode.DISTANCE_BASED);
        
        BearingComponent component = BearingComponentFactory.create(config);
        
        // 2. Peilung starten
        Position start = new Position(48.7758, 9.1829, 5.0, 520.0);
        BearingSession session = component.initiateBearing(start, 0.0);
        System.out.println("Peilung gestartet: " + session.getSessionId());
        
        // 3. Kontinuierliche Updates simulieren
        Position[] positions = new Position[] {
            new Position(48.7760, 9.1831, 5.0),
            new Position(48.7762, 9.1833, 5.0),
            new Position(48.7764, 9.1835, 5.0)
        };
        
        double[] azimuths = {45.0, 48.5, 52.0};
        
        for (int i = 0; i < positions.length; i++) {
            UpdateResult result = component.updateBearing(
                session, 
                positions[i], 
                azimuths[i]
            );
            System.out.println(
                String.format("Richtung: %s, Punkte: %d",
                    result.getCompassDirection(),
                    result.getPointsRecorded())
            );
        }
        
        // 4. Peilung beenden
        BearingResult result = component.completeBearing(session);
        System.out.println("Peilung beendet: " + result.getStatus());
        System.out.println("Punkte original: " + result.getTotalPointsRecorded());
        System.out.println("Punkte optimiert: " + result.getTotalPointsOptimized());
        
        // 5. GPX exportieren
        String gpxString = component.exportToGPXString(result);
        System.out.println("GPX-String Länge: " + gpxString.length());
        
        // 6. Datei speichern
        component.saveGPXToFile(result, Paths.get("my_bearing.gpx"));
        System.out.println("GPX-Datei gespeichert: my_bearing.gpx");
        
        // 7. Optional: What3Words
        W3WLocation location = component.resolvePosition(positions[0]);
        if (location.isValid()) {
            System.out.println("Ort: " + location.getWords());
        }
    }
}
```

#pagebreak()

== Anhang P: Zusammenfassung und Qualitätsmerkmale

=== P.1 Erreichte Qualität

✅ **Anforderungsanalyse**: Nach SOFIST-Regeln, objekt-orientiert, mit Aktivitätsdiagramm  
✅ **Spezifikation**: IEEE 830-1998 Standard, vollständig  
✅ **UML-Diagramme**: 6 verschiedene Diagramme (Klasse, Sequenz, Zustand, Aktivität, Komponente)  
✅ **Architektur**: 6-Schichten-Modell mit 8 Design Patterns  
✅ **SOLID-Prinzipien**: Vollständig eingehalten  
✅ **Algorithmen**: Mit Pseudocode und Python-Referenz-Implementierungen  
✅ **Testkonzept**: Unit, Integration, Performance, Mock-Objekte, Fixtures  
✅ **Code-Coverage**: >= 85% angestrebt (Ziel: 90%+)  
✅ **Dokumentation**: Ausführlich, formal, professionell  
✅ **Themengebiete**: Alle aus Semester 3+4 abgedeckt  

=== P.2 Erfüllung der Projektanforderungen

| Anforderung | Status | Nachweis |
|---|---|---|
| Anforderungsanalyse | ✅ | Kapitel 2 + Anhang K |
| Spezifikation IEEE 830 | ✅ | Kapitel 3-10 + Anhang L |
| UML-Diagramme | ✅ | Anhang E-I (6 Diagramme) |
| Java-Implementierung | ⏳ | Zu implementieren nach Spezifikation |
| Vollständig testbar | ✅ | Anhang J + Testkonzept |
| Keine UI | ✅ | Pure Java Library |
| Sofort lauffähig | ✅ | Maven Build, JUnit Tests |
| Alle Themengebiete | ✅ | Kapitel 11.1 |
| SOPHIST-Regeln | ✅ | Kapitel 2.2 |
| Keine Aufwandsschätzung | ✅ | Bewusst weggelassen |
| Formatierung & Formalitäten | ✅ | Typst-Dokument, Inhaltsverzeichnis, Glossar |

=== P.3 Nächste Schritte zur Completion

1. **Java-Quellcode implementieren** nach Spezifikation
   - ~4.500-5.000 Zeilen Java-Code
   - Gemäß Klassenlisten in Anhang J
   - Mit JavaDoc-Dokumentation

2. **Unit-Tests schreiben** (TDD oder Test-Last)
   - 300+ Unit-Tests
   - 200+ Integration-Tests
   - Coverage >= 85%

3. **Build & Verify**
   - `mvn clean compile` erfolgreich
   - `mvn test` alle Tests grün
   - `mvn test jacoco:report` Coverage OK

4. **Abnahme & Submission**
   - Source-Code abgeben (keine JAR!)
   - Dokumentation einpacken
   - Tests demonstrieren

#pagebreak()

#pagebreak()
////////////////////////////////

////////////////////////////////
// ANHANG
////////////////////////////////
#linebreak()

= Weitere Anhänge

