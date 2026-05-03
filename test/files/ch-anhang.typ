#let tbl-stroke = 0.45pt + rgb("#9a9a9a")
#let tbl-inset  = 6pt

#let ch-anhang-kapitel = []
#set par(justify: true)

// ─────────────────────────────────────────────────────────────────────────────
== Vollständige Use-Case-Liste mit Akzeptanzkriterien
// ─────────────────────────────────────────────────────────────────────────────

Die tabellarische Kurzfassung in Kapitel 3 wird hier um narrative Akzeptanzkriterien für die erweiterten Use Cases ergänzt.

#figure(
  caption: [Erweiterte Use-Case-Liste mit Akzeptanzkriterien.],
  kind: table,
  align(left, table(
    columns: (1.5cm, 2.4cm, 1fr),
    stroke: tbl-stroke, inset: 5pt,
    [*UC*], [*Trigger*], [*Akzeptanzkriterien*],
    [UC-08], [W3W-Key fehlt],         [Fallback-String zurückgegeben, kein Netzwerkaufruf ausgelöst.],
    [UC-09], [Netzwerk-Timeout W3W],  [WARN-Log mit `sessionId`, Fallback-Wert, kein Crash.],
    [UC-10], [GPX nur als Bytes],     [`byte[]` UTF-8 ohne BOM; Länge > 0 nach abgeschlossener Session.],
    [UC-11], [Listener wirft],        [Exception wird intern gefangen; Session bleibt in konsistentem Zustand.],
    [UC-12], [Reset nach Fehler],     [Zustand IDLE erreichbar nach ABORTED oder COMPLETED (/LL160/).],
  ))
)

#pagebreak()

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

wobei $R = 6{,}371{,}000$ m der mittlere Erdradius ist.

*Azimutberechnung:*

$
  alpha = "atan2"(sin(Delta lambda) dot cos(phi_2),; cos(phi_1) dot sin(phi_2) - sin(phi_1) dot cos(phi_2) dot cos(Delta lambda))
$

Anschließend Normalisierung auf [0°, 360°): `azimuth = (alpha + 360°) mod 360°`.

*Grenzfälle:*
- Identische Punkte (d = 0): Azimut undefiniert → Rückgabe 0° per Konvention.
- Polnähe: Numerische Instabilität durch `cos(φ) → 0` muss durch Klammertests abgesichert werden.
- Antipodische Punkte (d ≈ πR): Azimut mehrdeutig → dokumentieren und testen.

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Douglas–Peucker auf Kugeloberfläche (Hinweis für Erweiterungen)
// ─────────────────────────────────────────────────────────────────────────────

Klassisches Douglas–Peucker arbeitet in der Ebene. Für lange Tracks auf der Erdkugel sollte die Metrik entweder in *lokaler Tangentialebene* (ECEF-Projektion pro Segment) oder über *Chordal-Distanzen* approximiert werden.

Die Spezifikation `/LF270/` verlangt eine *metrische Toleranz in Metern* (Epsilon). Die Implementierung muss daher dokumentieren, welche Näherungsmetrik verwendet wird:

- *Lokale Tangentialebene (empfohlen für kurze Segmente):* ECEF-Projektion des Mittelpunkts; gültig für Segmentlängen < 50 km.
- *Chordal-Distanz:* Euklidische Distanz im 3D-Raum als Näherung für die geodätische Querabweichung.

Parameter im Code: `epsilonM` (in Metern). Der Start- und Endpunkt eines Segments werden immer erhalten.

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Vollständige Traceability-Matrix
// ─────────────────────────────────────────────────────────────────────────────

Die folgende Matrix stellt die vollständige Rückverfolgbarkeit von Anforderungen über OOA-Konzepte und OOD-Klassen bis zu Testclustern her.

#figure(
  caption: [Vollständige Traceability-Matrix: Anforderung → OOA-Konzept → OOD-Klasse → Test.],
  kind: table,
  align(left, table(
    columns: (1.8cm, 2.4cm, 3.5cm, 1fr),
    stroke: tbl-stroke, inset: 5pt,
    [*`/LF`*], [*OOA-Konzept*],        [*OOD-Klasse*],                      [*Test-Cluster*],
    [/LF010/], [`Peilung`],            [`BearingSession`],                   [TC-200, TC-010],
    [/LF030/], [`Standortfolge`],      [`BearingCalculator`, `GpsFix`],     [TC-020, TC-210],
    [/LF050/], [`Peilungsgrößen`],     [`BearingSnapshot`],                 [TC-210],
    [/LF060/], [`Export`],             [`GpxSerializer`, `BearingSession`], [TC-GPX-01..03],
    [/LF070/], [`Peilung`],            [`BearingSession`],                  [TC-070, TC-080],
    [/LF080/], [`Peilung`],            [`BearingListener`],                 [TC-011],
    [/LF100/], [`Standortfolge`],      [`TrackAggregator`],                 [TC-050, TC-060],
    [/LF120/], [`Standortfolge`],      [`TrackAggregator`],                 [TC-050, TC-060],
    [/LF170/], [`Track`],              [`TrackAggregator`],                 [TC-TRACK-04],
    [/LF180/], [`Track`],              [`TrackAggregator`],                 [TC-060],
    [/LF200/], [`Export`],             [`GpxSerializer`],                   [TC-100],
    [/LF220/], [`Export`],             [`SafeFileSink`],                    [TC-080],
    [/LF240/], [`Trackoptimierung`],   [`NthPointOptimizer`],               [TC-110],
    [/LF260/], [`Trackoptimierung`],   [`CollinearityOptimizer`],           [TC-120],
    [/LF270/], [`Trackoptimierung`],   [`DouglasPeuckerOptimizer`],         [TC-130],
    [/LF280/], [Externe Referenz],     [`W3wAdapter`],                      [TC-W3W-01..03],
    [/LF290/], [Externes Caching],     [`W3wCacheAdapter`],                 [TC-150],
    [/LF320/], [`Export`],             [`SafeFileSink`],                    [TC-090],
    [/LF340/], [`Peilung`],            [`ClockProvider`],                   [TC-160],
    [/LF400/], [`Peilung`],            [`SessionConfig`, `BearingSession`], [TC-400],
  ))
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Objektorientiertes Analyse- und Entwurfsmodell (OOA/OOD)
// ─────────────────────────────────────────────────────────────────────────────

=== OOA: Domänenmodell

Die OOA fokussiert *fachliche* Konzepte ohne technische Middleware. Assoziationen sind semantisch, Multiplizitäten pragmatisch.

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

#figure(
  caption: [OOD-Klassenübersicht: Zentrale Entwurfsklassen und Schnittstellen.],
  kind: table,
  align(left, table(
    columns: (3.5cm, 2.2cm, 1fr),
    stroke: tbl-stroke, inset: 5pt,
    [*Klasse / Interface*],  [*Stereotyp*],           [*Kernverantwortung*],
    [`BearingSession`],      [Entity/Controller],     [Zustandsautomat IDLE/ACTIVE/COMPLETED/ABORTED.],
    [`SessionConfig`],       [Value Object],          [Immutable Konfiguration; Builder-Pattern.],
    [`GeoCoordinate`],       [Value Object],          [WGS84 lat/lon validiert.],
    [`GpsFix`],              [Value Object],          [Zeit + Position + optional HDOP/Speed/Elevation.],
    [`BearingCalculator`],   [Domain Service],        [Haversine-Distanz, Azimut, Ordinalrichtung.],
    [`TrackAggregator`],     [Domain Service],        [Rohspeicher, Segmente, Punktbudget.],
    [`GpxSerializer`],       [Infrastructure],        [GPX 1.1, XML-Escaping, UTF-8.],
    [`SafeFileSink`],        [Infrastructure],        [Atomares Dateischreiben, Path-Traversal-Schutz.],
    [`TrackOptimizer`],      [Interface (Strategy)],  [Optimierungsstrategie austauschbar.],
    [`W3wClient`],           [Interface (Port)],      [Reverse-Lookup-Abstraktion.],
    [`ClockProvider`],       [Interface (Port)],      [Testbarkeit via Clock-Injection.],
    [`BearingListener`],     [Interface (Observer)],  [Ereignisbenachrichtigung für den Host.],
    [`NthPointOptimizer`],   [Domain Service],        [Jeder n-te Punkt; Start/Ende erhalten (/LF240/).],
    [`MinDistOptimizer`],    [Domain Service],        [Mindestabstand in Metern (/LF250/).],
    [`CollinearityOptimizer`],[Domain Service],       [Kollinearitätsreduktion (/LF260/).],
    [`DouglasPeuckerOptimizer`],[Domain Service],     [Douglas-Peucker mit metrischem Epsilon (/LF270/).],
  ))
)

=== Zustandsdiagramm: Session-Lebenszyklus

*Zustände:* `IDLE` → `ACTIVE` (start) → `COMPLETED` (complete) oder `ABORTED` (abort). Übergänge aus `COMPLETED`/`ABORTED` zurück zu `IDLE` durch explizite `reset()`-Operation (/LL160/).

*Invariante ACTIVE:* Positionsupdates zulässig; Konfiguration fix; UUID vergeben.\
*Invariante COMPLETED/ABORTED:* Keine weiteren Positionsupdates (/LF060/, /LF070/).

#figure(
  caption: [Zustandsdiagramm: Session-Lebenszyklus mit Transitionen und Guards.],
  kind: table,
  align(left, table(
    columns: (2.5cm, 3cm, 2cm, 1fr),
    stroke: tbl-stroke, inset: 5pt,
    [*Von*],      [*Nach*],    [*Auslöser*],          [*Guard / Aktion*],
    [IDLE],       [ACTIVE],    [`startSession()`],    [Konfiguration gültig; UUID erzeugt; `onSessionStarted` gefeuert.],
    [ACTIVE],     [COMPLETED], [`complete()`],        [GPX materialisiert; `onSessionCompleted` gefeuert.],
    [ACTIVE],     [ABORTED],   [`abort()`],           [GPX materialisiert; optional persistiert; `onSessionAborted` gefeuert.],
    [COMPLETED],  [IDLE],      [`reset()`],           [Alle internen Zustände gelöscht.],
    [ABORTED],    [IDLE],      [`reset()`],           [Alle internen Zustände gelöscht.],
    [ACTIVE],     [ACTIVE],    [`onPositionUpdate()`],[Fix validiert, gespeichert, Peilung berechnet, Listener benachrichtigt.],
  ))
)

=== Subsystem-Dekomposition

*Erster Schritt – Subsystem-Identifikation:*

#figure(
  caption: [Subsystem-Identifikation: Dienste und ihre Fehlerfälle.],
  kind: table,
  align(left, table(
    columns: (2.8cm, 1.8fr, 1fr),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Dienst*],            [*Verhalten*],                                                                                    [*Fehlerfälle*],
    [Session-Management],  [Steuert den Lebenszyklus einer Peilung und liefert eine Referenz-UUID zurück.],                  [Peilung bereits aktiv; Zielkoordinaten ungültig.],
    [Tracking-Logik],      [Wendet Validierungsvorschriften auf GPS-Daten an und berechnet Peilungsfortschritte.],           [Ungültige Koordinaten; Zeitstempel außerhalb Bereich.],
    [Kurs-Analyse],        [Berechnet Kursabweichungen basierend auf Azimut und Heading.],                                  [Kurswert außerhalb [0°, 360°]; fehlende Datenbasis.],
    [Export-Dienst],       [Koordiniert Finalisierung und GPX-Serialisierung; optional Dateischreiben.],                    [Session nicht abgeschlossen; Serialisierungsfehler.],
    [Optimierungs-Dienst], [Führt konfigurierte Optimizer-Strategien vor dem Export sequentiell aus.],                      [Konfigurationsfehler; leere Punktliste.],
    [W3W-Lookup],          [Kapselt HTTP-Anfragen und Cache-Zugriffe für Reverse-Lookup.],                                  [API nicht erreichbar; kein API-Key; Cache-Miss + Netzwerkfehler.],
  ))
)

*Zweiter Schritt – Subsystem-Anordnung:*

Die Anordnung folgt einer streng hierarchischen Struktur (Presentation Layer → Service Layer → Business Rules Layer → Data Access Layer). Die Kommunikation erfolgt strikt einseitig von oben nach unten; direkter Zugriff von der API-Ebene auf den Data Access Layer ist verboten.

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Vorlesungs-Themen-Matrix (Abdeckung SWE)
// ─────────────────────────────────────────────────────────────────────────────

Die folgende Matrix ordnet die Themengebiete der Softwareengineering-Vorlesung den Dokumentations- und Implementationsartefakten dieses Projekts zu.

#figure(
  caption: [Vorlesungsthemen und ihre Abdeckung durch Projektartefakte.],
  kind: table,
  align(left, table(
    columns: (3.5cm, 1fr, 2.8cm),
    stroke: tbl-stroke, inset: 5pt,
    [*Themenfeld*],                    [*Projektbezug*],                                                      [*Artefakt / Ort*],
    [Requirements Engineering],        [SOPHIST-Regeln, `/LF`/`/LL`/`/LD`, Traceability],                   [Kap. 3; Matrizen],
    [Lastenheft/Pflichtenheft],         [Zielhierarchie, Spezifikation nach IEEE 830],                       [Kap. 2, Kap. 3],
    [Use-Case-Modellierung],           [UC-01–UC-12, Narrative],                                             [Kap. 2.3, Anhang],
    [Aktivitätsdiagramme],             [Positionsupdate, GPX-Export-Pipeline],                               [Kap. 3.4],
    [Sequenzdiagramme],                [complete()-Pfad, Fehlerpfad Validierung],                            [Kap. 3.3],
    [Zustandsdiagramme],               [Session-Lebenszyklus IDLE/ACTIVE/COMPLETED/ABORTED],                 [Anhang A.3],
    [OOA/OOD],                         [Domänenmodell, Klassentabelle, Entwurfsklassen],                    [Anhang A.3],
    [Entwurfsmuster],                  [Strategy (Optimizer), Observer (Listener), Builder (Config), Port],  [Kap. 2, Kap. 3],
    [Schichtenarchitektur],            [API, Domain Core, Ports, Infrastruktur],                             [Kap. 2.1],
    [Qualitätsmodelle],                [ISO/IEC 25010 Gewichtungsmatrix],                                    [Kap. 3.5],
    [Nicht-funktionale Anforderungen], [Performance, Sicherheit, Portabilität (`/LL…/`)],                   [Kap. 3.2],
    [Testen],                          [JUnit 5, JaCoCo, FMEA, Testfälle],                                  [Kap. 3.5],
    [Konfigurationsmanagement],        [Maven, Profile `w3w`],                                               [Kap. 2.5, /LF450/],
    [Risikomanagement],                [FMEA-Tabelle, Sicherheitsanforderungsklassen],                       [Kap. 2.4, Kap. 3.5],
    [Dokumentationsstandards],         [IEEE/ISO Bezug, Javadoc-Pflicht, SOPHIST],                           [Kap. 1.1, /LL100/],
    [Sicherheit],                      [Path Traversal, XML-Escaping, XXE-Schutz],                          [Kap. 2.4, /LF320/],
    [Performance Engineering],         [Mikrobenchmark-Vorgaben, Heap-Limit],                                [Kap. 3.4, /LL030/],
  ))
)

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
    [Douglas, Peucker (1973)],    [Algorithmus zur Linienvereinfachung /LF270/],
    [SOPHIST-Methode],            [Anforderungsformulierung nach SOPHIST-Regeln],
    [ISO 8601],                   [Zeitstempel-Format UTC; `DateTimeFormatter.ISO_INSTANT`],
    [Apache Maven Docs],          [Build-System, Profilverwaltung (`w3w`-Profil)],
  ))
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Glossar-Index (Schlagwort → Abschnitt)
// ─────────────────────────────────────────────────────────────────────────────

#figure(
  caption: [Glossar-Schnellreferenz: Begriff und Fundstelle im Dokument.],
  kind: table,
  align(left, table(
    columns: (4cm, 1fr),
    stroke: tbl-stroke, inset: 5pt,
    [*Begriff*],                  [*Vorkommen*],
    [Peilung],                    [Glossar (Kap. 1.3); /LF010/–/LF050/],
    [Azimut],                     [Glossar; /LF050/; Anhang A.2],
    [Haversine-Formel],           [Glossar; /LL020/; Anhang A.2],
    [GPX 1.1],                    [Glossar; /LF200/; Kap. 3.3; Anhang A.2],
    [Session],                    [Glossar; /LF010/–/LF090/; Anhang A.3],
    [SOPHIST],                    [Glossar; Kap. 1.1; Kap. 3 (Einleitung)],
    [Strategy-Pattern],           [Glossar (Trackoptimierung); /LF480/; Anhang A.3],
    [Observer-Pattern],           [Glossar (Listener); /LF080/; Kap. 3.3],
    [Builder-Pattern],            [Glossar; /LF410/],
    [Immutability],               [Glossar; /LF410/; Kap. 2.2],
    [Douglas-Peucker],            [Glossar; /LF270/; Anhang A.2],
    [Path Traversal],             [Glossar; /LF320/; Kap. 2.4],
    [XXE],                        [Glossar; /LL130/; Kap. 2.4],
    [Atomares Schreiben],         [Glossar; /LF220/; Kap. 3.3],
    [Soft-Limit / Hard-Limit],    [Glossar; /LF120/, /LF180/],
    [What3Words],                 [Glossar; /LF280/, /LF290/],
    [SLF4J],                      [Glossar; /LL140/],
    [JaCoCo],                     [Glossar; /LL150/],
    [Maven],                      [Glossar; /LF450/; Kap. 2.5],
    [Traceability],               [Glossar; Anhang A.1; Kap. 3.5],
  ))
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Review-Checkliste „SOPHIST-Kriterien" (Selbstaudit)
// ─────────────────────────────────────────────────────────────────────────────

Die folgende Checkliste dient dem Selbstaudit vor der Abgabe. Alle Punkte müssen erfüllt sein.

+ Keine User Stories als Ersatz für normierte SOPHIST-Anforderungen verwendet.
+ Alle Anforderungen sichtbar und eindeutig identifiziert: `/LF`, `/LL`, `/LD` durchgängig.
+ Spezifikation präziser als Analyse: Use Cases, Zustandsdiagramm, Sequenzen vorhanden.
+ Objektorientierte Analyse: Domänenmodell separat von technischen Entwurfsklassen.
+ Aktivitätsdiagramm-Material vorhanden (textuell in Kap. 3.4).
+ Testfälle abgegeben, nachvollziehbar benannt (TC-Nummern).
+ Quellcode per Maven (`mvn test`) ohne manuelle Schritte ausführbar.
+ Keine UI-Abhängigkeiten in der Bibliothek (/LF430/).
+ Abbruch (`abort()`) liefert GPX-Daten, nicht zwingend Datei (/LF070/, /LF230/).
+ Javadoc vollständig für alle öffentlichen API-Methoden (/LL100/).
+ Sicherheitsanforderungen adressiert: Path Traversal (/LF320/), XML-Escaping (/LL130/).
+ Traceability-Matrix verknüpft Anforderungen mit Klassen und Testfällen.

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Versionshistorie
// ─────────────────────────────────────────────────────────────────────────────

#figure(
  caption: [Versionshistorie des Dokuments.],
  kind: table,
  align(left, table(
    columns: (2cm, 2.5cm, 2.5cm, 1fr),
    stroke: tbl-stroke, inset: 5pt,
    [*Version*], [*Datum*], [*Autor/in*], [*Änderungen*],
    [0.1], [April 2026], [Pfitzenmaier, Müllmaier, Bensch], [Initiale Gliederung und Anforderungserhebung.],
    [0.5], [Mai 2026],   [Pfitzenmaier, Müllmaier, Bensch], [Vervollständigung Glossar, Anforderungskarten, Grobentwurf.],
    [1.0], [Juni 2026],  [Pfitzenmaier, Müllmaier, Bensch], [Finale Überarbeitung; neues Inhaltsverzeichnis nach IEEE 830; Kapitelstruktur 1/2/3 umgesetzt; Qualitätssicherung finalisiert.],
  ))
)

*Werkzeugkette:* Typst-Quelle (`main.typ`) erzeugt PDF; Maven erzeugt Java-Artefakte.\
*Norm-Referenz:* Dokumentstruktur nach IEEE 830 / ISO/IEC/IEEE 29148.

#pagebreak()
]
