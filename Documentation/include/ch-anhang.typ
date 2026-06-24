#import "lf-diagram.typ": zustandsdiagramm-session, mermaid-figure

#let tbl-stroke = 0.45pt + rgb("#9a9a9a")
#let tbl-inset  = 6pt

#let ch-anhang-kapitel = [
#set par(justify: true)
#show figure: set block(breakable: true)

Der Anhang ergänzt den normativen Teil um vertiefende Artefakte: die vollständige Traceability-Matrix, das objektorientierte Analyse- und Entwurfsmodell, den Referenzalgorithmus der Peilung sowie Literatur- und Normenverweise.

// ─────────────────────────────────────────────────────────────────────────────
== Vollständige Traceability-Matrix
// ─────────────────────────────────────────────────────────────────────────────

Die folgende Matrix stellt die vollständige Rückverfolgbarkeit von Anforderungen über OOA-Konzepte und OOD-Klassen bis zu Testclustern her. Die Testzuordnung zu `/TC…/` ist in Kap.~3.4 detailliert.
#v(-0.5em)
#figure(
  caption: [Vollständige Traceability-Matrix],
  kind: table,
  align(left, table(
    columns: (1.9cm, 3.5cm, 5cm, 1fr),
    stroke: tbl-stroke, inset: 5pt,
    [*`/LF`*], [*OOA-Konzept*],        [*OOD-Klasse*],                      [*Test*],
    [/LF010/], [`Peilung`],            [`DefaultBearingSession`],            [/TC010/],
    [/LF020/], [`Peilung`],            [`DefaultBearingSession`],            [/TC010/],
    [/LF030/], [`Standortfolge`],      [`DefaultBearingSession`, `GpsFix`], [/TC020/, /TC030/, /TC040/],
    [/LF040/], [`Peilung`],            [`DefaultBearingSession`],            [implizit Demo],
    [/LF050/], [`Peilungsgrößen`],     [`BearingSnapshot`],                 [/TC050/],
    [/LF060/], [`Export`],             [`DefaultBearingSession`],            [/TC040/],
    [/LF070/], [`Peilung`],            [`DefaultBearingSession`],            [/TC080/],
    [/LF080/], [`Peilung`],            [`BearingListener`],                 [/TC120/],
    [/LF090/], [`Peilung`],            [`DefaultBearingSession`],            [/TC130/],
    [/LF100/], [`Standortfolge`],      [`TrackAggregator`],                 [implizit /TC060/, /TC070/, /TC110/, /TC150/],
    [/LF110/], [`Standortfolge`],      [`TrackAggregator`],                 [/TC060/],
    [/LF120/], [`Track`],              [`TrackAggregator`],                 [/TC150/],
    [/LF130/], [`Standortfolge`],      [`TrackAggregator`],                 [/TC070/],
    [/LF140/], [`Export`],             [`GpxXmlWriter`, `OptimizationPipeline`], [/TC100/],
    [/LF150/], [`Export`],             [`SafeFileSink`],                    [Demo,  `SafeFileSinkJimfsTest.writesInsideBase`],
    [/LF160/], [`Export`],             [`GpxResult`],                       [/TC080/, /TC100/],
    [/LF170/], [`Trackoptimierung`],   [`NthPointOptimizer`],               [/TC110/],
    [/LF180/], [`Trackoptimierung`],   [`MinDistanceOptimizer`],            [implizit /TC110/, Demo],
    [/LF190/], [`Trackoptimierung`],   [`LineCollinearityOptimizer`],       [implizit /TC110/, Demo],
    [/LF200/], [`Trackoptimierung`],   [`DouglasPeuckerOptimizer`],         [implizit /TC110/, Demo],
    [/LF210/], [Externe Referenz],     [`W3wHttpClient`, `NoopW3wClient`],  [Demo (`NoopW3wClient`)],
    [/LF220/], [Externes Caching],     [`W3wHttpClient`],                   [implizit /LF210/, Code-Review],
    [/LF230/], [`Validierung`],        [`ValidationException`],             [/TC020/],
    [/LF240/], [`Validierung`],        [`ValidationException`],             [/TC030/],
    [/LF250/], [`Export`],             [`SafeFileSink`],                    [/TC090/],
  ))
)


// ─────────────────────────────────────────────────────────────────────────────
== Objektorientiertes Analyse- und Entwurfsmodell (OOA/OOD)
// ─────────────────────────────────────────────────────────────────────────────

Dieser Abschnitt trennt bewusst zwei Sichten: Die objektorientierte Analyse (OOA) hält fest, _was_ die Domäne ausmacht; der objektorientierte Entwurf (OOD) legt fest, _wie_ sie technisch umgesetzt wird. Die Schichtenarchitektur steht in Kap.~2.1.

=== OOA: Domänenmodell

Die Analyse betrachtet die Fachlichkeit, bevor technische Entscheidungen einfließen. Sie hält fest, welche Konzepte die Domäne kennt und wie sie zusammenhängen, noch ohne konkrete Klassen, Schnittstellen oder Frameworks  zu definieren. Die Assoziationen sind daher fachlich zu lesen, die Multiplizitäten bewusst pragmatisch gehalten.

#figure(
  caption: [Fachliches Domänenmodell (OOA): Konzepte und ihre Beziehungen.],
  kind: table,
  align(left, table(
    columns: (3cm, 1fr, 2.2cm),
    stroke: tbl-stroke, inset: 6pt,
    [*Konzept*],        [*Beschreibung*],                              [*Multiplizität*],
    [`Peilung`],        [Fachlicher Vorgang vom Start bis Complete/Abort.], [1 pro Session],
    [`Zielpunkt`],      [Geo-Koordinate (WGS84).],                    [1],
    [`Standortfolge`],  [Zeitlich geordnete GPS-Fixes.],              [0..\*],
    [`Peilungsgrößen`], [Abgeleitete Werte (Azimut, Distanz, Ordinal).],[0..1 vor erstem Fix],
    [`Track`],          [Sammlung von Segmenten.],                    [0..1],
    [`Export`],         [GPX-Dokument als Artefakt.],                 [0..1 nach Abschluss],
  ))
)

*Assoziationen:* Peilung hat genau einen Zielpunkt und genau einen Track. Der Track enthält beliebig viele Trackpunkte. Die Peilung kann optional einen Export (GPX) erzeugen. Standortfolge: 0..\*.

=== OOD: Technischer Feinentwurf

Der Entwurf überführt die fachlichen Konzepte in konkrete Klassen und Schnittstellen und ordnet ihnen ein Stereotyp zu, dazu zählen das Value Object, Domain Service, Infrastructure oder Port. Auffällig ist die Trennung über Strategie- und Port-Interfaces (`TrackOptimizer`, `W3wClientPort`, `ClockPort`): Sie hält die Domäne frei von technischen Abhängigkeiten und erlaubt, im Test echte Implementierungen durch Mocks zu ersetzen.

#figure(
  caption: [OOD-Klassenübersicht: Zentrale Entwurfsklassen und Schnittstellen.],
  kind: table,
  align(left, table(
    columns: (4.4cm, 1.9cm, 1fr),
    stroke: tbl-stroke, inset: 5pt,
    [*Klasse / Interface*],  [*Stereotyp*],           [*Kernverantwortung*],
    [`BearingSession`],      [Interface (API)],       [Öffentlicher Session-Vertrag.],
    [`DefaultBearingSession`],[Entity/Controller],  [Zustandsautomat IDLE/ACTIVE/COMPLETED/ABORTED.],
    [`SessionConfig`],       [Value Object],          [Immutable Konfiguration; Builder-Pattern.],
    [`GeoCoordinate`],       [Value Object],          [WGS84 lat/lon validiert.],
    [`GpsFix`],              [Value Object],          [Zeit + Position + optional HDOP/Speed/Elevation.],
    [`BearingCalculator`],   [Domain Service],        [Haversine-Distanz, Azimut, Ordinalrichtung.],
    [`TrackAggregator`],     [Domain Service],        [Rohspeicher, Segmente, Punktbudget.],
    [`GpxXmlWriter`],        [Infrastructure],        [GPX 1.1, XML-Escaping, UTF-8 (/LF140/).],
    [`SafeFileSink`],        [Infrastructure],        [Atomares Dateischreiben, Path-Traversal-Schutz.],
    [`TrackOptimizer`],      [Interface (Strategy)],  [Optimierungsstrategie austauschbar.],
    [`W3wClientPort`],       [Interface (Port)],      [Reverse-Lookup-Abstraktion (/LF210/).],
    [`ClockPort`],           [Interface (Port)],      [Testbarkeit via Clock-Injection (/LL070/).],
    [`BearingListener`],     [Interface (Observer)],  [Ereignisbenachrichtigung für den Host.],
    [`NthPointOptimizer`],   [Domain Service],        [Jeder n-te Punkt; Start/Ende erhalten (/LF170/).],
    [`MinDistanceOptimizer`],[Domain Service],        [Mindestabstand in Metern (/LF180/).],
    [`LineCollinearityOptimizer`],[Domain Service],  [Kollinearitätsreduktion (/LF190/).],
    [`DouglasPeuckerOptimizer`],[Domain Service],     [Douglas-Peucker mit metrischem Epsilon (/LF200/).],
  ))
)


Das Klassendiagramm visualisiert diese Entwurfsklassen mit ihren Stereotypen und Beziehungen. Gut erkennbar sind die Strategy-Hierarchie (`TrackOptimizer` mit vier Optimierern), der Observer (`BearingListener`) und die fünf Ports, die die Domain technologiefrei halten.

#mermaid-figure(
  [Klassendiagramm: Fassade, Value Objects, Domain Services, Strategy, Observer und Ports.],
  "klassendiagramm",
  width: 100%,
)

=== Zustandsdiagramm: Session-Lebenszyklus

*Zustände:* `IDLE` #sym.arrow.r `ACTIVE` (`start`) #sym.arrow.r `COMPLETED` (`complete`) oder `ABORTED` (`abort`). Rückkehr zu `IDLE` über `reset()` (/LF090/). Details zu den Anforderungen: Kap.~3.1 (`/LF010/` … `/LF090/`).

#zustandsdiagramm-session()

// ─────────────────────────────────────────────────────────────────────────────
== Struktur- und Architektursicht
// ─────────────────────────────────────────────────────────────────────────────

Dieser Abschnitt ergänzt das Klassenmodell um die grobgranulare Bausteinsicht. Die Schichten- und Kommunikationsregeln stehen in Kap.~2.1.

Das Paketdiagramm zeigt die sieben Maven-Module und die enthaltenen Java-Pakete mit ihren erlaubten Abhängigkeitsrichtungen

#mermaid-figure(
  [Paketdiagramm: Maven-Module und Java-Pakete mit ihren Abhängigkeiten.],
  "paketdiagramm",
  width: 74%,
)

Über die Schichtenarchitektur (Kap.~2.1) hinaus nutzt der Entwurf zwei weitere Muster: Das Ports-and-Adapters-Muster (hexagonal) trennt den Anwendungskern über die SPI-Ports von den Adaptern, das Pipes-and-Filter-Muster beschreibt die Optimierer-Kette vor dem Export.

#mermaid-figure(
  [Architekturmuster Ports-and-Adapters.],
  "muster_ports_adapter",
  width: 100%,
)

#mermaid-figure(
  [Architekturmuster Pipes-and-Filter: die Optimierer-Pipeline.],
  "muster_pipes_filter",
  width: 38%,
)

// ─────────────────────────────────────────────────────────────────────────────
== Dynamische Modelle und Strukturierte Analyse
// ─────────────────────────────────────────────────────────────────────────────

Das Aktivitätsdiagramm fasst den gesamten Sessionverlauf von `start()` bis zum GPX-Export zusammen und verdichtet die anforderungsbezogenen Einzelaktivitäten aus Kap.~3.1.

#mermaid-figure(
  [Aktivitätsdiagramm: vollständiger Verlauf einer Peilungssession.],
  "aktivitaet_session",
  width: 100%,
  height: 15cm,
)

Das Datenflussdiagramm der Stufe 1 verfeinert das Kontextdiagramm (Kap.~3.3) in sechs Teilprozesse mit den Datenspeichern Roh-Track und W3W-Cache.

#mermaid-figure(
  [Datenflussdiagramm: Teilprozesse und Datenspeicher.],
  "dfd_level1",
  width: 100%,
  height: 14cm,
)

// ─────────────────────────────────────────────────────────────────────────────
== Haversine- und Azimutberechnung (Referenzalgorithmus)
// ─────────────────────────────────────────────────────────────────────────────

Die folgende Beschreibung des Referenzalgorithmus dient der Übereinstimmung mit `/LL020/` (Referenzabweichung ≤ ±1°). Die Implementierung nutzt `double` und muss Grenzfälle (identische Punkte, Polnähe) explizit absichern.

*Eingabe:* Breite/Länge von Standort φ₁, λ₁ und Ziel φ₂, λ₂ (in Radiant für die trigonometrischen Funktionen).

*Haversine-Distanzberechnung:*

$
  Delta phi = phi_2 - phi_1, quad Delta lambda = lambda_2 - lambda_1
$
$
  a = sin^2(Delta phi / 2) + cos(phi_1) dot cos(phi_2) dot sin^2(Delta lambda / 2)
$
$
  d = 2 R dot arcsin(sqrt(a))
$

wobei $R = 6.371.000 med m$ der mittlere Erdradius ist.

*Azimutberechnung:*

$
  alpha = "atan2"(sin(Delta lambda) dot cos(phi_2), space cos(phi_1) dot sin(phi_2) - sin(phi_1) dot cos(phi_2) dot cos(Delta lambda))
$

Anschließend Normalisierung auf $[0°, 360°)$: `azimuth = (alpha + 360°) mod 360°`.

*Grenzfälle:*
- Identische Punkte (d = 0): Azimut undefiniert #sym.arrow.r Rückgabe 0° per Konvention.
- Polnähe: Numerische Instabilität durch $cos(φ)$ #sym.arrow.r $0$ muss durch Klammertests abgesichert werden.
- Antipodische Punkte (d ≈ πR): Azimut mehrdeutig #sym.arrow.r dokumentieren und testen.

#pagebreak()
// ─────────────────────────────────────────────────────────────────────────────
== Literatur- und Normenverweise
// ─────────────────────────────────────────────────────────────────────────────

#figure(
  caption: [Primäre Normreferenzen und technische Quellen des Projekts.],
  kind: table,
  align(left, table(
    columns: (3.5cm, 1fr),
    stroke: tbl-stroke, inset: 6pt,
    [*Quelle*], [*Kontext im Projekt*],
    [ISO/IEC/IEEE 29148:2018],   [Requirements Engineering, Traceability],
    [ISO/IEC 25010:2011],        [Produktqualitätsmodell (Qualitätsmatrix Kap. 3.5)],
    [IEEE 830-1998],             [Software Requirements Specifications (Dokumentaufbau)],
    [GPX 1.1 Schema],            [XML-Export, Namespace `http://www.topografix.com/GPX/1/1`],
    [WGS84 / EPSG:4326],         [Koordinatenreferenzsystem für alle Geo-Eingaben],
    [What3words API Docs],        [Optionales Reverse-Lookup-Interface],
    [OWASP],                     [Path Traversal, XML-Sicherheitsrichtlinien],
    [Gamma et al.: Design Patterns (GoF)], [Strategy, Observer, Builder, Factory],
    [Bloch: Effective Java],      [Immutability, Exceptions, API-Design],
    [JUnit 5 User Guide],         [Teststrategie und Testframework],
    [SLF4J Manual],               [Beobachtbarkeit und strukturiertes Logging],
    [Douglas, Peucker (1973)],    [Algorithmus zur Linienvereinfachung /LF200/],
    [SOPHIST-Methode],            [Anforderungsformulierung nach SOPHIST-Regeln],
    [ISO 8601],                   [Zeitstempel-Format UTC; `DateTimeFormatter.ISO_INSTANT`],
    [Apache Maven Docs],          [Build-System, Profilverwaltung (`w3w`-Profil)],
  ))
)

]
