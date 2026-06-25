# SWE-Kompass

UI-freie Java-Bibliothek für Peilung, GPS-Rohtrack und GPX-1.1-Export.

DHBW Stuttgart · Softwareentwicklung · Prof. Dr. Bohl

## Inhalt

| Datei / Ordner | Beschreibung |
| --- | --- |
| [`Spezifikation.pdf`](Spezifikation.pdf) | Pflichtenheft (Anforderungen, Schnittstellen, Modelle) |
| [`implementation/`](implementation/) | Maven-Quellcode, Tests, Konsolen-Demo |
| [`implementation/TRACEABILITY.md`](implementation/TRACEABILITY.md) | Zuordnung `/LF…/` · `/LL…/` · `/TC…/` ↔ Code ↔ JUnit |

Anforderungs-IDs: `/LF010/`-`/LF250/` (funktional), `/LL010/`-`/LL080/` (nicht-funktional), `/TC010/`-`/TC150/` (15 verbindliche Tests).

## Voraussetzungen

Java 11 oder höher, Maven 3.6 oder höher (`mvn` im PATH).

## Tests

```powershell
cd implementation
mvn test
```

Erwartung: **BUILD SUCCESS**, 15 verbindliche Testfälle (`tc010_*` … `tc150_*`). Details: [`TRACEABILITY.md`](implementation/TRACEABILITY.md).

Optional — Testabdeckung:

```powershell
cd implementation
mvn verify
```

Report: `implementation/bearing-api/target/site/jacoco/index.html`

## Demo (optional)

Konsolen-Demo aller Funktionen (Session, Optimierer, GPX, Path-Traversal):

```powershell
cd implementation
.\run-all-capabilities.ps1
```

Linux/macOS: `./run-all-capabilities.sh`

