# SWE-Kompass

UI-freie Java-Bibliothek für Peilung, GPS-Rohtrack und GPX-Export (`com.example.bearing`).

Prof. Dr. Bohl · DHBW Stuttgart · Softwareentwicklung Semester 4

## Wo was liegt

| Ordner | Inhalt |
| ------ | ------ |
| [`Documentation/`](Documentation/) | Pflichtenheft (Typst/PDF): Anforderungen, UML, Glossar |
| [`implementation/`](implementation/) | Maven-Multi-Modul-Code, Tests, Demo |
| [`implementation/TRACEABILITY.md`](implementation/TRACEABILITY.md) | LF/LL ↔ Code ↔ JUnit (vollständige Tabellen) |
| [`archive/`](archive/) | Alte Arbeitsstände (nicht kanonisch) |

**Single Source of Truth** für Anforderungs-IDs: [`Documentation/include/requirement-catalog.typ`](Documentation/include/requirement-catalog.typ)

Spezifikation als PDF: [`Documentation/main.pdf`](Documentation/main.pdf) (Quellen: `Documentation/main.typ` + `include/*.typ`)

## Anforderungs-IDs (+10, lückenlos)

| Präfix | Bereich | Anzahl |
| ------ | ------- | ------ |
| `/LF` | `/LF010/` … `/LF250/` | 25 funktionale Anforderungen |
| `/LL` | `/LL010/` … `/LL080/` | 8 nicht-funktionale Anforderungen |
| `/LD` | `/LD010/` … `/LD060/` | 6 Produktdatenstrukturen |
| `/TC` | `/TC010/` … `/TC150/` | 15 verbindliche JUnit-Tests |

Auszug funktionale API (`BearingSession` / `DefaultBearingSession`):

| LF | Methode / Klasse |
| -- | ---------------- |
| /LF010/ | `start(config, target)` |
| /LF020/ | Doppelstart → `IllegalStateException` |
| /LF030/ | `onPositionUpdate(GpsFix)` |
| /LF040/ | `onCourseUpdate(double)` |
| /LF050/ | `currentSnapshot()` |
| /LF060/ | `complete()` → `GpxResult` |
| /LF070/ | `abort()` → `GpxResult` |
| /LF080/ | `BearingListener` (Fehler isoliert) |
| /LF090/ | `reset()` |
| /LF100/-/LF130/ | Rohtrack, Soft/Hard-Limit, Segmente (`TrackAggregator`) |
| /LF140/-/LF200/ | GPX-Export, Persistenz, vier Optimierer |
| /LF210/-/LF250/ | W3W, Validierung, Path-Traversal |

Details und Code-Anker: Katalog + [`TRACEABILITY.md`](implementation/TRACEABILITY.md).

## Implementierung

Maven-Reactor unter [`implementation/`](implementation/):

| Modul | Rolle |
| ----- | ----- |
| `bearing-api` | `DefaultBearingSession`, `SessionConfig`, `BearingBootstrap` |
| `bearing-domain` | Track, Peilungsrechner, Optimierer, `TrackAggregator` |
| `bearing-spi` | Ports (`ClockPort`, `GpxWriterPort`, `FileSinkPort`, …) |
| `bearing-adapter-gpx` | `GpxXmlWriter` |
| `bearing-adapter-system` | Clock, Logger, `SafeFileSink`, `NoopW3wClient` |
| `bearing-adapter-w3w` | `W3wHttpClient` |
| `bearing-demo` | Konsolen-Demo aller Funktionen |

Mehr Build- und Demo-Details: [`implementation/README.md`](implementation/README.md)

## Tests

```powershell
# Vom Repo-Root (Aggregator-POM) oder aus implementation/:
mvn test
```

15 verbindliche Tests - Namensschema `tcNNN_*` in JUnit:

| TC | LF / LL | Testklasse |
| -- | ------- | ---------- |
| /TC010/ | /LF010/, /LF020/ | `BearingSessionTest` |
| /TC020/ | /LF030/, /LF230/ | `BearingSessionTest` |
| /TC030/ | /LF030/, /LF240/ | `BearingSessionTest` |
| /TC040/ | /LF060/ | `BearingSessionTest` |
| /TC050/ | /LF050/ | `BearingSessionTest` |
| /TC060/ | /LF110/ | `TrackAggregatorTest` |
| /TC070/ | /LF130/ | `TrackAggregatorTest` |
| /TC080/ | /LF070/ | `BearingSessionTest` |
| /TC090/ | /LF250/ | `BearingSessionTest` |
| /TC100/ | /LF140/ | `GpxXmlWriterTest` |
| /TC110/ | /LF170/ | `BearingSessionTest` |
| /TC120/ | /LF080/ | `BearingSessionTest` |
| /TC130/ | /LF090/ | `BearingSessionTest` |
| /TC140/ | /LL020/ | `BearingCalculatorReferenceTest` |
| /TC150/ | /LF120/ | `TrackAggregatorTest` |

Coverage: `mvn verify` → JaCoCo unter `implementation/bearing-api/target/site/jacoco/`

Konsolen-Demo (ohne Tests): `implementation/run-all-capabilities.ps1`

## Schnellstart

Voraussetzungen: Java 11+, Maven 3.6+

```powershell
git clone <repo-url>
cd SWE-Kompass
mvn test
```

Optionale Umgebungsvariablen: Vorlage [`.env.example`](.env.example) → lokale `.env` (nicht committen). `W3W_API_KEY` nur für echte W3W-Calls in der Host-Anwendung.
