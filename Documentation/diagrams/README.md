# Diagramme der Java-Peilungskomponente

Dieser Ordner enthält alle Diagramme der Projektdokumentation als **Quelltext**
(Mermaid `*.mmd` bzw. PlantUML `*.puml`) und als gerendertes **SVG**. Die SVGs
werden im Typst-Dokument über `lf-diagram.typ` (`mermaid-figure`, `lf-flowchart`,
`zustandsdiagramm-session`) eingebunden.

Alle hier aufgeführten Diagramme sind im Dokument bereits eingebunden — in
Kapitel 3 (normativer Teil) bzw. im Anhang; die genaue Stelle steht in der Spalte
„Platzierung". Sehr hohe Diagramme sind in der Höhe begrenzt (`height: 18cm`),
damit sie nicht über die Seite hinauslaufen.

Jedes Diagramm ist aus dem tatsächlichen Code unter `implementation/` abgeleitet
(Klassen, Methoden, Maven-Module) und auf die Anforderungen `/LF…/`, `/LL…/`,
`/LD…/` bezogen. Ziel ist Aussagekraft und Code-Treue, nicht Vollständigkeit um
ihrer selbst willen.

## Verzeichnisaufbau

```
diagrams/
├── mermaid/      Mermaid-Quellen (*.mmd)
├── plantuml/     PlantUML-Quellen (*.puml)
├── svg/          gerenderte SVG (Ausgabe beider Renderer)
├── render-diagrams.ps1    rendert mermaid/*.mmd  (npx @mermaid-js/mermaid-cli)
└── render-plantuml.ps1    rendert plantuml/*.puml (java + PlantUML, Smetana-Layout)
```

Rendern (aus `Documentation/`):

```powershell
pwsh -File diagrams/render-diagrams.ps1     # Mermaid -> SVG
pwsh -File diagrams/render-plantuml.ps1     # PlantUML -> SVG
```

## Werkzeugwahl: Mermaid oder PlantUML?

Das Projekt nutzte bereits **Mermaid** (Schichtenbild, Zustand, LF-Aktivitäten).
Mermaid bleibt für alle Typen gesetzt, die es nativ und sauber beherrscht
(Klassen-, Sequenz-, Zustands-, ER-Diagramm sowie alle Fluss-Notationen).

Für die UML-Typen, die Mermaid **nicht nativ** kennt (Use-Case, Paket, Objekt,
Komponente, Kompositionsstruktur, Verteilung) wird **PlantUML** verwendet, weil
nur dort die korrekte UML-Notation (Akteure, Lollipop/Socket, Knoten/Artefakte)
entsteht. PlantUML läuft mit der eingebauten **Smetana**-Layout-Engine, daher
ist *kein* Graphviz nötig. Die Tabelle (Entscheidungstabelle) entsteht als
PlantUML-`salt`-Widget.

---

## Übersicht aller Diagramme

Spalte „Platzierung": wo das Diagramm im Dokument eingebunden ist — in **Kap. 3**
(normativer Teil) oder im **Anhang** (vertiefende Modelle).

| Datei (Quelle → SVG) | Typ | Werkzeug | Bezug im Code / Text | Platzierung |
|---|---|---|---|---|
| `use_case.puml` | Use-Case-Diagramm | PlantUML | `BearingSession`-API, `/LF010/–/LF250/` | Kap. 3.1 |
| `paketdiagramm.puml` | Paketdiagramm | PlantUML | Maven-Module + `com.example.bearing.*` | Anhang (zu 2.1) |
| `klassendiagramm.mmd` | Klassendiagramm | Mermaid | OOD-Klassen, Kap. „OOA/OOD" | Anhang |
| `objektdiagramm.puml` | Objektdiagramm | PlantUML | Momentaufnahme aktiver Session | Anhang |
| `komponentendiagramm.puml` | Komponentendiagramm | PlantUML | `BearingBootstrap`, SPI-Ports | Anhang (zu 2.1) |
| `kompositionsstruktur.puml` | Kompositionsstruktur | PlantUML | `DefaultBearingSession`-Felder | Anhang |
| `verteilungsdiagramm.puml` | Verteilungsdiagramm | PlantUML | Physische Sicht (2.1) | Anhang (zu 2.1) |
| `aktivitaet_session.mmd` | Aktivitätsdiagramm | Mermaid | Sessionverlauf start→Export | Anhang |
| `sequenz_complete.mmd` | Sequenzdiagramm | Mermaid | `complete()` `/LF060/`,`/LF140/` | Kap. 3 / Anhang |
| `sequenz_position_update.mmd` | Sequenzdiagramm | Mermaid | `onPositionUpdate()` `/LF030/` | Kap. 3 / Anhang |
| `zustand_session_detail.mmd` | Zustandsdiagramm | Mermaid | `lifecycle`, `/LF010/–/LF090/` | Anhang |
| `interaktionsuebersicht.mmd` | Interaktionsübersicht | Mermaid | Verweise auf die Sequenzen | Anhang |
| `dfd_kontext.mmd` | Kontextdiagramm (DFD-0) | Mermaid | externe Schnittstellen (2.1) | Kap. 3.3 |
| `dfd_level1.mmd` | Datenflussdiagramm (DFD-1) | Mermaid | Teilprozesse + Datenspeicher | Anhang |
| `er_modell.mmd` | ER-Modell | Mermaid | Produktdaten `/LD010/–/LD060/` | Kap. 3.5 |
| `petri_session.mmd` | Petri-Netz | Mermaid | Session-Lebenszyklus | Anhang |
| `kontrollflussgraph.mmd` | Kontrollflussgraph | Mermaid | `TrackAggregator.accept` | Kap. 3.4 (Test) |
| `entscheidungstabelle.puml` | Entscheidungstabelle | PlantUML (salt) | Fix-Validierung | Kap. 3.4 |
| `entscheidungsbaum.mmd` | Entscheidungsbaum | Mermaid | Fix-Validierung (Baumform) | Kap. 3.4 |
| `muster_pipes_filter.mmd` | Architekturmuster | Mermaid | `OptimizationPipeline` | Anhang |
| `muster_ports_adapter.mmd` | Architekturmuster | Mermaid | Hexagonal, SPI-Ports | Anhang (zu 2.1) |

Bereits vorhanden (unverändert): `arch_layers` (Schichtenarchitektur, Kap. 2.1),
`session_state` (kompaktes Zustandsdiagramm, Anhang), `lf_010 … lf_100`
(Aktivitätsdiagramme je Anforderung, Kap. 3.1).

---

## Begründung je Diagramm

### Statische (Struktur-)Diagramme

**Use-Case-Diagramm — `use_case.puml`**
Zeigt die Anwendungsfälle der einzigen Außenschnittstelle (der öffentlichen
`BearingSession`-API) mit dem Primärakteur *Host-Anwendung* und den
Sekundärakteuren *What3Words-API*, *Dateisystem* und *SLF4J-Backend*. Die
`<<include>>`/`<<extend>>`-Beziehungen bilden den realen Code ab: jedes
`onPositionUpdate` schließt die Validierung ein (`validate`), `complete()`/
`abort()` schließen den GPX-Export ein, das Dateispeichern ist eine optionale
Erweiterung (`completePersistPath`). So bleibt das Diagramm an `/LF010/–/LF250/`
verankert und erfindet keine UI-Funktionen, die die Bibliothek nicht hat.

**Paketdiagramm — `paketdiagramm.puml`**
Bildet die sieben Maven-Module und die enthaltenen Java-Pakete samt erlaubter
Abhängigkeitsrichtung ab (Quelle: die `pom.xml` der Module). Es macht die
Kommunikationsregeln aus Kap. 2.1 sichtbar: Adapter hängen nur an `bearing-spi`,
`bearing-api` orchestriert Domain + SPI + Adapter, `bearing-domain` und
`bearing-spi` sind frei von internen Abhängigkeiten. Damit ist die
Azyklizität (keine Domain→Infrastruktur-Kante) direkt prüfbar.

**Klassendiagramm — `klassendiagramm.mmd`**
Der OOD-Kern: Fassade (`BearingSession`/`DefaultBearingSession`), Value Objects,
Domain Services, die Strategy-Hierarchie (`TrackOptimizer` + vier Optimierer),
der Observer (`BearingListener`) und die fünf Ports. Stereotype (`<<Value
Object>>`, `<<Domain Service>>`, `<<interface>>`) entsprechen der OOD-Tabelle im
Anhang. Kompositionen (`Track *-- TrackSegment *-- GpsPoint`) und Multiplizitäten
sind aus den Feldtypen abgeleitet.

**Objektdiagramm — `objektdiagramm.puml`**
Eine konkrete Momentaufnahme einer `ACTIVE`-Session mit zwei gespeicherten
Punkten in einem Segment. Es instanziiert genau die Klassen aus dem
Klassendiagramm mit plausiblen Werten (Default-`SessionConfig`, Ziel Stuttgart)
und zeigt die Verweise `frozenConfig`, `target`, `aggregator`, `lastFix`. Damit
wird der sonst abstrakte Strukturschnitt greifbar.

**Komponentendiagramm — `komponentendiagramm.puml`**
Module als Komponenten mit angebotenen (Lollipop) und benötigten (Socket)
Schnittstellen. Es zeigt, wie `BearingBootstrap` die Adapter an die Ports
verdrahtet und welche Komponente welche externe Ressource anspricht (Dateisystem,
What3Words). Ergänzt das Paketdiagramm um die Schnittstellensicht.

**Kompositionsstrukturdiagramm — `kompositionsstruktur.puml`**
Das Innenleben von `DefaultBearingSession`: die internen Parts (`calculator`,
`pipeline`, `aggregator`, `listeners`) und die fünf benötigten Ports an der
Grenze. Direkt aus den Feldern und dem Konstruktor abgeleitet und zeigt, warum
die Klasse trotz vieler Aufgaben testbar bleibt (alle Ports injiziert).

**Verteilungsdiagramm — `verteilungsdiagramm.puml`**
Die physische Sicht aus Kap. 2.1: die Bibliothek als Artefakt im selben
JVM-Prozess wie die Host-Anwendung (kein eigener Server), mit den optionalen
Kanälen Dateisystem (`SafeFileSink`) und HTTPS zu What3Words (`W3wHttpClient`).
Unterstreicht die Offline-Fähigkeit der Kernfunktion.

### Dynamische (Verhaltens-)Diagramme

**Aktivitätsdiagramm — `aktivitaet_session.mmd`**
Der gesamte Sessionverlauf von `start()` über die Aufzeichnungsschleife (mit
Validierung, Limit- und Segmentprüfung) bis zu `complete()`/`abort()`, Optimierung,
Serialisierung und optionalem Dateischreiben. Es klammert die feingranularen
Einzel-Aktivitäten `lf_0xx` zu einem Gesamtbild.

**Sequenzdiagramme — `sequenz_complete.mmd`, `sequenz_position_update.mmd`**
Die zwei zentralen Abläufe als Objektinteraktion über die Zeit.
`complete()` zeigt die Export-Kette Aggregator → Pipeline → `GpxExportMapper`
→ `GpxXmlWriter` → optional `SafeFileSink` → Listener (genau die Methodenfolge im
Code). `onPositionUpdate()` zeigt die Kernschleife mit `break` bei
`ValidationException` und den optionalen Soft-/Hard-Limit-Ereignissen.

**Zustandsdiagramm — `zustand_session_detail.mmd`**
Detailvariante des vorhandenen `session_state` mit Guards `[…]` und Effekten
`/ …` (z. B. `start()` nur aus `IDLE`, `currentSnapshot()` erst ab einem Fix).
Quelle ist der `AtomicReference<Lifecycle>` und `compareAndSet` in
`DefaultBearingSession`.

**Interaktionsübersichtsdiagramm — `interaktionsuebersicht.mmd`**
Der UML-Oberbegriff „Interaktionsdiagramm" konkret als *interaction overview*:
ein Aktivitätsrahmen, dessen Knoten (Doppelrahmen) auf die beiden Sequenzen
verweisen. Zeigt die Reihenfolge start → (Positions-/Snapshot-Schleife) →
complete/abort → reset und verknüpft so die dynamischen Diagramme.

### Diagramme der Strukturierten Analyse (nicht-UML)

**Kontextdiagramm — `dfd_kontext.mmd`**
DFD-Stufe 0: die Bibliothek als ein Prozess mit allen externen Terminatoren und
Datenflüssen. Deckt sich mit der Tabelle „Externe Schnittstellen" (Kap. 2.1) und
eignet sich gut als Einstieg in Kap. 3.3.

**Datenflussdiagramm — `dfd_level1.mmd`**
DFD-Stufe 1: Zerlegung in sechs Teilprozesse (Validieren, Aggregieren, Peilung,
Optimieren, Serialisieren, W3W) mit den Datenspeichern *Roh-Track*
(`TrackAggregator`) und *W3W-Cache* (`W3wHttpClient`). Zeigt den Datenfluss ohne
Kontrollfluss und ergänzt damit die Aktivitäts-/Sequenzsicht.

**ER-Modell — `er_modell.mmd`**
Die Produktdaten `/LD010/–/LD060/` als Entitäten mit Kardinalitäten (Session
1–1 Config/Ziel, 1–0..1 Track, Track 1–* Segment 1–* Punkt). Brücke zwischen den
fachlichen Datenstrukturen und den `/LD…/`-Karten in Kap. 3.5.

**Petri-Netz — `petri_session.mmd`**
Der Session-Lebenszyklus als Stellen/Transitionen-Netz mit einer Marke. Es ist
die nebenläufigkeitsnahe Lesart des Zustandsautomaten: die einzelne Marke macht
die Invariante „genau eine aktive Session" (`/LF020/`) anschaulich.

### Whitebox-Test

**Kontrollflussgraph — `kontrollflussgraph.mmd`**
CFG der verzweigungsreichsten Methode `TrackAggregator.accept`. Die fünf
Entscheidungen (recordingStopped, Hard-Limit, lastPoint, Segmentlücke,
Soft-Limit) ergeben die zyklomatische Komplexität **v(G) = 5 + 1 = 6**, also
sechs unabhängige Pfade als Mindestmaß für die Zweigüberdeckung. Passt direkt zu
den Testfällen `/TC060/`, `/TC070/`, `/TC110/`, `/TC150/`.

### Tabellen-/Baum-Notationen

**Entscheidungstabelle — `entscheidungstabelle.puml`**
Begrenzte-Eintrag-Tabelle der Fix-Verarbeitung mit vier Bedingungen und fünf
Regeln R1–R5 (aus `onPositionUpdate` + `validate` + `accept`). Macht die
Vollständigkeit der Fehlerpfade prüfbar (`/LL010/`, `/TC020/`, `/TC030/`).

**Entscheidungsbaum — `entscheidungsbaum.mmd`**
Dieselbe Logik als Baum — die übliche grafische Schwester der
Entscheidungstabelle. Beide zusammen zeigen Tabelle und Baum als äquivalente
Darstellungen derselben Regelmenge.

### Architekturmuster

**Pipes-and-Filter — `muster_pipes_filter.mmd`**
Die `OptimizationPipeline` als Filterkette: jeder Optimierer ist ein Filter mit
gleicher Schnittstelle (`TrackOptimizer`), die Punktliste fließt sequentiell
hindurch. Belegt das Muster anhand des realen Codes.

**Ports-and-Adapters (Hexagonal) — `muster_ports_adapter.mmd`**
Das übergeordnete Architekturmuster: treibender Akteur (Host) gegen die API,
die Domain definiert Ports (`bearing-spi`), Adapter implementieren sie und
sprechen externe Systeme an. Ergänzt das vorhandene Schichtenbild `arch_layers`
um die hexagonale Lesart.

> **Bewusst weggelassen:** MVC, Client/Server und Repository aus der Vorlesung
> „08 Architekturmuster" werden *nicht* gezeichnet, weil die Komponente eine
> UI-lose, eingebettete Bibliothek ohne Modell-View-Trennung, ohne Server und
> ohne Persistenzschicht ist. Sie zu zeigen wäre irreführend. Die tatsächlich
> verwendeten GoF-Muster (Strategy, Observer, Builder, Factory) sind im Klassen-
> und in den Sequenzdiagrammen sichtbar.
