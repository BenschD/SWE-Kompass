#import "lf-diagram.typ": zustandsdiagramm-session

#let tbl-stroke = 0.45pt + rgb("#9a9a9a")
#let tbl-inset  = 6pt

#let ch-anhang-kapitel = [
#set par(justify: true)
#show figure: set block(breakable: true)

Der Anhang bündelt vertiefende und unterstützende Artefakte, die den normativen Teil des Dokuments ergänzen, ohne ihn zu unterbrechen: erweiterte Akzeptanzkriterien, den Referenzalgorithmus der Peilung, die vollständige Traceability-Matrix, das objektorientierte Analyse- und Entwurfsmodell sowie Verzeichnisse, Checklisten und die Versionshistorie.

// ─────────────────────────────────────────────────────────────────────────────
== Erweiterte Akzeptanzkriterien (Kap. 3.1)
// ─────────────────────────────────────────────────────────────────────────────

Die normativen Spezifikationen stehen in *Kapitel 3.1*. Dieser Abschnitt ergänzt die Varianten /LF210/, /LF160/, /LF080/ und /LF090/ um prüfbare Akzeptanzkriterien.

#figure(
  caption: [Erweiterte Akzeptanzkriterien zu ausgewählten `/LF…/`- und `/LL…/`-Spezifikationen.],
  kind: table,
  align(left, table(
    columns: (2cm, 2.4cm, 1fr),
    stroke: tbl-stroke, inset: 5pt,
    [*`/LF` / `/LL`*], [*Trigger*], [*Akzeptanzkriterien*],
    [/LF210/], [W3W-Key fehlt],         [Fallback-String zurückgegeben, kein Netzwerkaufruf ausgelöst.],
    [/LF210/], [Netzwerk-Timeout W3W],  [WARN-Log mit `sessionId`, Fallback-Wert, kein Crash.],
    [/LF160/], [GPX nur als Bytes],     [`byte[]` UTF-8 ohne BOM; Länge > 0 nach abgeschlossener Session.],
    [/LF080/], [Listener wirft],        [Exception wird intern gefangen; Session bleibt in konsistentem Zustand.],
    [/LF090/], [Reset nach Ende],       [Zustand IDLE erreichbar nach ABORTED oder COMPLETED.],
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

wobei $R = 6.371.000$ m der mittlere Erdradius ist.

*Azimutberechnung:*

$
  alpha = "atan2"(sin(Delta lambda) dot cos(phi_2), space cos(phi_1) dot sin(phi_2) - sin(phi_1) dot cos(phi_2) dot cos(Delta lambda))
$

Anschließend Normalisierung auf $[0°, 360°)$: `azimuth = (alpha + 360°) mod 360°`.

*Grenzfälle:*
- Identische Punkte (d = 0): Azimut undefiniert → Rückgabe 0° per Konvention.
- Polnähe: Numerische Instabilität durch `cos(φ) → 0` muss durch Klammertests abgesichert werden.
- Antipodische Punkte (d ≈ πR): Azimut mehrdeutig → dokumentieren und testen.

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Douglas-Peucker auf Kugeloberfläche (Hinweis für Erweiterungen)
// ─────────────────────────────────────────────────────────────────────────────

Klassisches Douglas-Peucker arbeitet in der Ebene. Für lange Tracks auf der Erdkugel sollte die Metrik entweder in *lokaler Tangentialebene* (ECEF-Projektion pro Segment) oder über *Chordal-Distanzen* approximiert werden.

Die Spezifikation `/LF200/` verlangt eine *metrische Toleranz in Metern* (Epsilon). Die Implementierung muss daher dokumentieren, welche Näherungsmetrik verwendet wird:

- *Lokale Tangentialebene (empfohlen für kurze Segmente):* ECEF-Projektion des Mittelpunkts; gültig für Segmentlängen < 50 km.
- *Chordal-Distanz:* Euklidische Distanz im 3D-Raum als Näherung für die geodätische Querabweichung.

Parameter im Code: `epsilonM` (in Metern). Der Start- und Endpunkt eines Segments werden immer erhalten.

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Vollständige Traceability-Matrix
// ─────────────────────────────────────────────────────────────────────────────

Die folgende Matrix stellt die vollständige Rückverfolgbarkeit von Anforderungen über OOA-Konzepte und OOD-Klassen bis zu Testclustern her.

#figure(
  caption: [Vollständige Traceability-Matrix],
  kind: table,
  align(left, table(
    columns: (1.9cm, 3.5cm, 4.9cm, 1fr),
    stroke: tbl-stroke, inset: 5pt,
    [*`/LF`*], [*OOA-Konzept*],        [*OOD-Klasse*],                      [*Test*],
    [/LF010/], [`Peilung`],            [`DefaultBearingSession`],            [/TC010/],
    [/LF020/], [`Peilung`],            [`DefaultBearingSession`],            [/TC010/],
    [/LF030/], [`Standortfolge`],      [`DefaultBearingSession`, `GpsFix`], [/TC020/, /TC030/],
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
    [/LF150/], [`Export`],             [`SafeFileSink`],                    [/TC090/],
    [/LF160/], [`Export`],             [`GpxResult`],                       [/TC080/, /TC100/],
    [/LF170/], [`Trackoptimierung`],   [`NthPointOptimizer`],               [/TC110/],
    [/LF180/], [`Trackoptimierung`],   [`MinDistanceOptimizer`],            [implizit /TC110/, Demo],
    [/LF190/], [`Trackoptimierung`],   [`LineCollinearityOptimizer`],       [implizit /TC110/, Demo],
    [/LF200/], [`Trackoptimierung`],   [`DouglasPeuckerOptimizer`],         [implizit /TC110/, Demo],
    [/LF210/], [Externe Referenz],     [`W3wHttpClient`, `NoopW3wClient`],  [Demo (`NoopW3wClient`)],
    [/LF220/], [Externes Caching],     [`W3wHttpClient`],                   [implizit /LF210/; Code-Review],
    [/LF230/], [`Validierung`],        [`ValidationException`],             [/TC020/],
    [/LF240/], [`Validierung`],        [`ValidationException`],             [/TC030/],
    [/LF250/], [`Export`],             [`SafeFileSink`],                    [/TC090/],
  ))
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Objektorientiertes Analyse- und Entwurfsmodell (OOA/OOD)
// ─────────────────────────────────────────────────────────────────────────────

Dieser Abschnitt trennt bewusst zwei Sichten: Die objektorientierte Analyse (OOA) hält fest, _was_ die Domäne ausmacht; der objektorientierte Entwurf (OOD) legt fest, _wie_ sie technisch umgesetzt wird. Diese Reihenfolge stellt sicher, dass der Entwurf der Fachlichkeit folgt und nicht umgekehrt.

=== OOA: Domänenmodell

Die Analyse betrachtet die Fachlichkeit, bevor technische Entscheidungen einfließen. Sie hält fest, welche Konzepte die Domäne kennt und wie sie zusammenhängen - noch ohne Klassen, Schnittstellen oder Frameworks. Die Assoziationen sind daher fachlich zu lesen, die Multiplizitäten bewusst pragmatisch gehalten. Das folgende Domänenmodell bildet die Grundlage für den technischen Entwurf im nächsten Abschnitt.

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

Der Entwurf überführt die fachlichen Konzepte in konkrete Klassen und Schnittstellen und ordnet ihnen ein Stereotyp zu - Value Object, Domain Service, Infrastructure oder Port. Auffällig ist die Trennung über Strategie- und Port-Interfaces (`TrackOptimizer`, `W3wClientPort`, `ClockPort`): Sie hält die Domäne frei von technischen Abhängigkeiten und erlaubt, im Test echte Implementierungen durch Mocks zu ersetzen.

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

=== Zustandsdiagramm: Session-Lebenszyklus

*Zustände:* `IDLE` → `ACTIVE` (start) → `COMPLETED` (complete) oder `ABORTED` (abort). Übergänge aus `COMPLETED`/`ABORTED` zurück zu `IDLE` durch explizite `reset()`-Operation (/LF090/).

*Invariante ACTIVE:* Positionsupdates zulässig; Konfiguration fix; UUID vergeben.\
*Invariante COMPLETED/ABORTED:* Keine weiteren Positionsupdates (/LF060/, /LF070/).

#zustandsdiagramm-session()

Die folgende Tabelle führt dieselben Übergänge mit den jeweiligen Guards und Aktionen im Detail auf.

#figure(
  caption: [Zustandsdiagramm: Session-Lebenszyklus mit Transitionen und Guards.],
  kind: table,
  align(left, table(
    columns: (2.3cm, 2.6cm, 2.9cm, 1fr),
    stroke: tbl-stroke, inset: 5pt,
    [*Von*],      [*Nach*],    [*Auslöser*],          [*Guard / Aktion*],
    [IDLE],       [ACTIVE],    [`start(config, target)`], [Konfiguration gültig; UUID erzeugt; `onSessionStarted` gefeuert.],
    [ACTIVE],     [COMPLETED], [`complete()`],        [GPX materialisiert; `onSessionCompleted` gefeuert.],
    [ACTIVE],     [ABORTED],   [`abort()`],           [GPX materialisiert; optional persistiert; `onSessionAborted` gefeuert.],
    [COMPLETED],  [IDLE],      [`reset()`],           [Alle internen Zustände gelöscht.],
    [ABORTED],    [IDLE],      [`reset()`],           [Alle internen Zustände gelöscht.],
    [ACTIVE],     [ACTIVE],    [`onPositionUpdate()`],[Fix validiert, in Rohtrack gespeichert, Listener benachrichtigt.],
  ))
)

=== Subsystem-Dekomposition

*Erster Schritt - Subsystem-Identifikation:*

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

*Zweiter Schritt - Subsystem-Anordnung:*

Die Anordnung folgt einer streng hierarchischen Struktur (Presentation Layer → Service Layer → Business Rules Layer → Data Access Layer). Die Kommunikation erfolgt strikt einseitig von oben nach unten; direkter Zugriff von der API-Ebene auf den Data Access Layer ist verboten.

#pagebreak()


== Literatur- und Normenverweise

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
/*
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
    [Peilung],                    [Glossar (Kap. 1.3); /LF010/-/LF050/],
    [Azimut],                     [Glossar; /LF050/; Anhang A.2],
    [Haversine-Formel],           [Glossar; /LL020/; Anhang A.2],
    [GPX 1.1],                    [Glossar; /LF140/; Kap. 3.3; Anhang A.2],
    [Session],                    [Glossar; /LF010/-/LF090/; Anhang A.3],
    [SOPHIST],                    [Glossar; Kap. 1.1; Kap. 3 (Einleitung)],
    [Strategy-Pattern],           [Glossar (Trackoptimierung); /LF170/-/LF200/; Anhang A.3],
    [Observer-Pattern],           [Glossar (Listener); /LF080/; Kap. 3.3],
    [Builder-Pattern],            [Glossar; /LD020/],
    [Immutability],               [Glossar; /LD020/; Kap. 2.2],
    [Douglas-Peucker],            [Glossar; /LF200/; Anhang A.2],
    [Path Traversal],             [Glossar; /LF250/; Kap. 2.4],
    [XXE],                        [Glossar; /LL050/; Kap. 2.4],
    [Atomares Schreiben],         [Glossar; /LF150/; Kap. 3.3],
    [Soft-Limit / Hard-Limit],    [Glossar; /LF110/, /LF130/],
    [What3Words],                 [Glossar; /LF210/, /LF220/],
    [SLF4J],                      [Glossar; /LL060/],
    [Maven],                      [Glossar; Kap. 2.5],
    [Traceability],               [Glossar; Anhang A.1; Kap. 3.5],
  ))
)

*/
]
