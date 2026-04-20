# PlantUML-Diagramme (SWE-Kompass)

Dieser Ordner enthält alle UML- und Architekturdiagramme zur Java-Peilungs-Komponente. Die Dateien sind bewusst **von der Typst-Dokumentation entkoppelt**, weil Typst `.puml`-Dateien nicht direkt als Vektorgrafik einbinden kann. Für die Abgabe empfiehlt sich, die Diagramme mit PlantUML (CLI oder IDE-Plugin) nach **SVG** oder **PNG** zu exportieren und die Bilder unter `Documentation/include/images/uml/` abzulegen.

## Rendering

```bash
# Beispiel (PlantUML JAR oder docker)
java -jar plantuml.jar -tsvg Documentation/plantuml/*.puml
```

## Dateien und inhaltliche Kurzbeschreibung

| Datei | Diagrammtyp | Zweck / Lesart |
| --- | --- | --- |
| `01_klassendiagramm.puml` | Klassendiagramm | Domänen- und API-Klassen: `BearingComponent`, Services, Value Objects, Validatoren, optionale W3W-Integration. Zeigt Abhängigkeiten zwischen Fassade, Anwendungsfall-Logik und Infrastruktur. |
| `02_sequenzdiagramm_happy_path.puml` | Sequenzdiagramm | Normalablauf: Start der Peilung, wiederholte Positions- und Kurs-Updates, Aufzeichnung von Trackpunkten, ordnungsgemäßes Ende inkl. GPX-Erzeugung. |
| `03_sequenzdiagramm_abbruch.puml` | Sequenzdiagramm | Abbruch: Host ruft Abbruch auf; Komponente finalisiert den bisherigen Track, erzeugt **GPX-Daten** (XML/Objekt), optional Datei-Schreiben nur wenn Host dies explizit anfordert (siehe Spezifikation). |
| `04_aktivitaetsdiagramm_peilung.puml` | Aktivitätsdiagramm | Steuerfluss bei `updatePosition`: Validierung, Sampling nach Intervall/Punktbudget, Peilungsberechnung, Listener-Benachrichtigung, Grenzfälle (Hard-Limit Punkte). |
| `05_zustandsdiagramm_session.puml` | Zustandsdiagramm | Lebenszyklus einer `BearingSession` bzw. des Komponentenzustands: IDLE → ACTIVE → STOPPING/COMPLETED/ABORTED. |
| `06_komponentendiagramm.puml` | Komponentendiagramm | Schnittstellen zur Host-App, interne Subkomponenten (Core, Tracker, Export, Optimierung, W3W-Adapter), externe Systeme (Dateisystem, W3W-API). |
| `07_usecase_diagramm.puml` | Anwendungsfalldiagramm | Akteur „Host-Anwendung“ und die fachlichen Use Cases (Peilung führen, Track exportieren, konfigurieren). |
| `08_deployment.puml` | Verteilungsdiagramm | Einbettung als Maven-Artefakt/JAR-Module in eine Host-JVM; keine eigene UI-Schicht. |

## Zuordnung zur Dokumentation

- Kapitel *Objektorientierte Analyse* verweist textuell auf **01, 04, 05, 07**.
- Kapitel *Architektur* verweist auf **06, 08**.
- Kapitel *Schnittstellen / Ablauf* verweist auf **02, 03**.

## Versionshinweis

Die Diagramme sind normativ im Sinne der **fachlichen** Struktur; Details an Methodennamen können sich während der Implementierung leicht unterscheiden, müssen dann aber in Diagramm und Java synchron nachgezogen werden.
