# Java-Projektaufbau: SWE-Kompass (Peilung + GPX-Track)

Diese Datei ist die **Implementierungs-Blaupause**, damit das Maven-Projekt **1:1 zur Dokumentation** (`Documentation/main.typ`, Kapitel 4–7, Anhänge) und zu den PlantUML-Modellen unter `Documentation/plantuml/` passt.

## Leitprinzipien

- **Keine UI** in der Bibliothek; nur öffentliche API + Domäne + Services + Adapter.
- **Systemneutral**: Keine Android-/JavaFX-/Swing-Abhängigkeiten; GPS und Magnetometer kommen vom **Host** als Daten.
- **GPX 1.1** als Zielformat; Export als `String`/`byte[]` ist Pflicht, Dateisystem ist optional.
- **Abbruch**: Session endet mit Status `ABORTED`, Track bleibt konsistent; GPX-Daten werden erzeugt, **automatisches Speichern** nur, wenn Konfiguration `persistOnAbort=true` (siehe Spezifikation) oder Host explizit `saveGPXToFile` aufruft.
- **W3W**: eigener Adapter-Modul, hinter Interface, default `NoOpW3wClient` für Offline-Builds.

## Maven-Reactor (empfohlenes Multi-Modul-Layout)

```
swe-kompass/
├── pom.xml                     (Parent: DependencyManagement, Plugins)
├── swe-kompass-bom/            (optional: rein BOM)
├── bearing-api/                (nur Interfaces, DTOs, Exceptions – minimal)
├── bearing-domain/             (Entities, Value Objects, Domain Services pur)
├── bearing-core/               (Anwendungsfälle / BearingServiceImpl)
├── gps-tracker/                (Sampling, Filter, Limits, optional Kalman)
├── gpx-export/                 (GPX 1.1 Builder, Validierung, NIO Writer)
├── w3w-adapter/                (HTTP Client, Caching, Fehler-Fallback)
├── bearing-app-starter/       (optional: CLI-Demo für Bohl, keine UI – nur main zum Testen)
└── bearing-tests/              (Integrationstests über Module hinweg)
```

Abhängigkeitsrichtung (strikt nach innen):

`bearing-app-starter` → `bearing-core` → (`gps-tracker`, `gpx-export`, `w3w-adapter`) → `bearing-domain` → `bearing-api`

## Paketstruktur (Java Packages)

### `com.swe.kompass.api`

- `BearingComponent` (Fassade)
- `BearingListener` / `BearingEvent` (Observer)
- `BearingConfig`, `BearingConfigBuilder`
- DTOs/Records: `GeoCoordinate`, `BearingInfo`, `GpxDocument`, `TrackStatistics`, `W3wAddress`

### `com.swe.kompass.domain`

- `bearing.BearingSession` (Aggregate Root)
- `bearing.BearingStatus` (Enum)
- `track.GpsTrack`, `track.GpsPoint`
- `geo.Azimuth`, `geo.Distance`
- Domänenregeln: `BearingPolicy` (Validierung, Limits)

### `com.swe.kompass.core`

- `impl.BearingComponentImpl` (delegiert an Service)
- `service.BearingApplicationService` (Use-Case-Orchestrierung)
- `service.TrackRecordingService`
- `service.BearingCalculationService` (Haversine, Azimut, Kursabweichung)

### `com.swe.kompass.tracker`

- `SamplingStrategy` (Interface) + `TimeIntervalStrategy`, `PointBudgetStrategy`
- `GpsQualityFilter` (HDOP, Satelliten, Geschwindigkeits-Sprünge)
- `TrackOptimizer` (Interface) + `EveryNthPointOptimizer`, `MinDistanceOptimizer`, `StraightSegmentCollapser`, `DouglasPeuckerOptimizer` (1+)

### `com.swe.kompass.gpx`

- `GpxSerializer` (GPX 1.1, UTF-8, Zeit UTC ISO-8601)
- `GpxWriter` (temp-Datei + `Files.move`, atomar)
- `GpxSchemaValidator` (optional gegen XSD)

### `com.swe.kompass.w3w`

- `What3WordsClient` (Interface)
- `HttpWhat3WordsClient`
- `CachingWhat3WordsClient` (Decorator)
- `NoOpWhat3WordsClient`

### `com.swe.kompass.util`

- `Clock` (Interface, für Tests `FakeClock`)
- `Logger` nur SLF4J

## Wichtigste öffentliche API (Alignierung mit Doku)

Die Namen können leicht von älteren Entwürfen abweichen; **normativ** ist die in `main.typ` beschriebene Semantik:

| Operation | Semantik |
| --- | --- |
| `startBearing(target, config)` | Neue Session, Ziel fix, Tracker leeren |
| `updatePosition(current)` | Validierung, Sampling, Peilung neu, Events |
| `updateHeading(degrees)` | optional, falls Host Kurs separat liefert |
| `getCurrentBearing()` | aktuelle `BearingInfo` |
| `stopBearing()` | reguläres Ende, Optimierung optional, GPX erzeugen |
| `abortBearing()` | Abbruch, GPX-Daten verfügbar, Datei nur nach Policy |
| `exportGpx(result)` | rein funktionaler GPX-String |
| `saveGpx(path, result)` | optional persistieren |

## Teststruktur (pro Modul, plus integrativ)

- `bearing-domain`: reine Unit-Tests ohne I/O
- `bearing-core`: Mockito für Ports (`GpxWriter`, `W3wClient`)
- `gps-tracker`: deterministische Zeit (`Clock`)
- `gpx-export`: Golden-File-Tests (XML vergleichen, Whitespace normalisiert)
- `bearing-tests`: End-to-End über `BearingComponent` mit Fake-GPS-Stream

## Lauffähigkeit für Abgabe (ohne JAR-Pflicht)

- `mvn -q -DskipTests=false test` muss auf Rechner des Dozenten grün werden.
- Keine Secrets im Repo: W3W-API-Key via Umgebungsvariable `W3W_API_KEY` oder `BearingConfig`.

## Diagramm-Synchronisation

Nach Änderungen an Klassen **immer** `Documentation/plantuml/01_klassendiagramm.puml` nachziehen und SVG exportieren (siehe `plantuml/README.md`).
