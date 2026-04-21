# Java-Peilungskomponente (Implementierung)

Maven-Multi-Modul-Projekt gemäß Vorschrieb unter [`../Vorschrieb/`](../Vorschrieb/).

## Module

| Modul | Inhalt |
|-------|--------|
| `bearing-spi` | Ports (`ClockPort`, `LoggerPort`, `GpxWriterPort`, …) und GPX-Transportmodell |
| `bearing-domain` | Fachlogik: Track, Rechner, Optimierer, Pipeline |
| `bearing-adapter-gpx` | GPX-1.1-XML-Writer |
| `bearing-adapter-system` | `SystemClockAdapter`, `Slf4jLoggerAdapter`, `SafeFileSink`, `NoopW3wClient` |
| `bearing-adapter-w3w` | `W3wHttpClient` (JDK-HTTP, Cache) |
| `bearing-api` | `DefaultBearingSession`, `SessionConfig`, `BearingBootstrap` |

## Build

Maven liegt bei dir unter `C:\tools\apache-maven-3.9.15` (oder ähnlich). **PATH** sollte `…\bin` enthalten, damit `mvn` überall funktioniert. Nach der Installation ggf. **Terminal/Cursor neu starten**, damit die Umgebungsvariable geladen wird.

```powershell
# Entweder Repo-Root (Aggregator-POM ../pom.xml) oder dieses Verzeichnis:
cd implementation
# Falls mvn nicht im PATH:
& "C:\tools\apache-maven-3.9.15\bin\mvn.cmd" test

mvn test
```

Coverage-Report (JaCoCo): `mvn verify` → `bearing-api/target/site/jacoco/index.html` (pro Modul).

### Demo-Visualisierung (HTML + Konsole)

Ein Test schreibt nach dem Lauf eine **SVG-Karte** und gibt eine **ASCII-Karte** auf stdout aus:

```powershell
cd implementation
mvn -pl bearing-api -am "-Dsurefire.failIfNoSpecifiedTests=false" "-Dtest=BearingSessionVisualizationTest" test
```

Danach im Browser öffnen: `bearing-api/target/bearing-session-visualization.html` (Pfad steht auch in der Maven-Ausgabe).

## Traceability

Siehe [TRACEABILITY.md](TRACEABILITY.md).

## Profil `w3w`

Das Parent-POM definiert die Property `w3w.integration.skip` (Standard `true`). Integrationstests mit echtem Netz können optional ergänzt werden (`-Pw3w`).
