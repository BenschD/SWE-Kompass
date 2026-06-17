// ─────────────────────────────────────────────────────────────────────────────
// LF-/LL-Karten, Produktdaten und Kapitel 3.5 (Qualität)
// ─────────────────────────────────────────────────────────────────────────────
#import "macros.typ": diagramm-box
#import "ch-lf-spezifikationen.typ": ch-lf-spezifikationen
#import "requirement-catalog.typ": catalog-ll-table, catalog-ld-table, catalog-tc-table, catalog-api-table

#let _black  = rgb("#1a1a1a")
#let _white  = rgb("#ffffff")
#let _left-w = 5.8cm
#let _tbl    = 0.45pt + rgb("#9a9a9a")
#let _ins    = 6pt
#let _rf     = rgb("#d6e9f8")
#let _card-stroke = 0.5pt + rgb("#AAAAAA")
#let _card-ins    = (x: 7pt, y: 6pt)

#let _trace-hdr(body) = table.cell(
  fill: _rf,
  align: center + horizon,
)[#body]

#let _row(label, body) = (
  table.cell(fill: _black)[
    #set text(fill: _white, weight: "bold", size: 10.5pt)
    #label
  ],
  table.cell(fill: _white)[
    #set text(fill: _black, size: 10.5pt)
    #body
  ],
)

#let ll-card(id, funktion, quelle, verweise, beschreibung) = {
  let _rf = rgb("#d6e9f8")
  v(0.6em)
  table(
    columns: (1.9cm, 2.7cm, 1fr, 2.3cm, 1fr),
    stroke: 0.5pt + rgb("#AAAAAA"),
    fill: (x, _y) => if x == 0 or x == 1 { _rf } else { white },
    inset: (x: 7pt, y: 6pt),
    align: (x, _y) => if x <= 1 { center + horizon } else { left + top },
    table.cell(rowspan: 3)[
      #set align(center + horizon)
      #text(weight: "bold", size: 10pt)[#id]
    ],
    [Funktion], table.cell(colspan: 3)[#funktion],
    [Quelle],   [#quelle], table.cell(fill: _rf)[Verweise], [#verweise],
    [Beschreibung], table.cell(colspan: 3)[#beschreibung],
  )
}

#let ld-card(id, speicherinhalt, verweise, attribute) = {
  let _rf = rgb("#d6e9f8")
  v(0.6em)
  table(
    columns: (1.9cm, 2.7cm, 1fr),
    stroke: 0.5pt + rgb("#AAAAAA"),
    fill: (x, _y) => if x == 0 or x == 1 { _rf } else { white },
    inset: (x: 7pt, y: 6pt),
    align: (x, _y) => if x <= 1 { center + horizon } else { left + top },
    table.cell(rowspan: 3)[
      #set align(center + horizon)
      #text(weight: "bold", size: 10pt)[#id]
    ],
    [Speicherinhalt], [#speicherinhalt],
    [Verweise],       [#verweise],
    [Attribute],      [#attribute],
  )
}


// ─────────────────────────────────────────────────────────────────────────────
// KAPITEL-INHALT
// ─────────────────────────────────────────────────────────────────────────────

#let ch-spezifische-anforderungen-kapitel = [
#set par(justify: true)

Dieses Kapitel bildet den normativen Kern des Dokuments. Funktionale Anforderungen `/LF010/` … `/LF250/` und nicht-funktionale `/LL010/` … `/LL080/` sind nach SOPHIST/IEEE-830 formuliert. Ergänzt werden externe Schnittstellen (3.3), Produktdaten, Testfälle `/TC010/` … `/TC150/` und das Qualitätsmodell nach ISO/IEC 25010 (3.4).

// ═════════════════════════════════════════════════════════════════════════════
== Funktionale Anforderungen
// ═════════════════════════════════════════════════════════════════════════════
/*
=== Akteure

Primär- und Sekundärakteure der Java-Peilungskomponente:

#figure(
  caption: [Primärakteure der Java-Peilungskomponente.],
  kind: table,
  align(left, table(
    columns: (3cm, 1fr, 3cm),
    stroke: _tbl, inset: _ins,
    [*Akteur*], [*Beschreibung*], [*Beispiel*],
    [Host-App], [Beliebige Java-Anwendung, die die Bibliothek einbettet. Steuert den Session-Lebenszyklus und übergibt GNSS-Fixes.], [Desktop-App, REST-Backend, Embedded-System],
    [Team (Entwicklung)], [Das Entwicklungsteam konfiguriert und baut die Bibliothek; relevant für Build- und Wartungsanforderungen.], [Studierendenteam DHBW Stuttgart],
  ))
)

*Sekundärakteure* unterstützen das System oder werden vom System genutzt:

#figure(
  caption: [Sekundärakteure der Java-Peilungskomponente.],
  kind: table,
  align(left, table(
    columns: (3cm, 1fr),
    stroke: _tbl, inset: _ins,
    [*Akteur*], [*Beschreibung*],
    [What3Words-API], [Externer HTTPS-Dienst für Koordinaten-Reverse-Lookup. Optional; Timeout und Fallback abgesichert.],
    [Dateisystem],   [Optionaler Ausgabekanal für GPX-Dateien. Zugriff nur bei expliziter Host-Konfiguration.],
    [SLF4J-Backend], [Empfängt strukturierte Log-Events der Bibliothek; konkrete Implementierung ist Host-Sache.],
  ))
)
*/

#ch-lf-spezifikationen

// ═════════════════════════════════════════════════════════════════════════════
== Nicht-funktionale Anforderungen
// ═════════════════════════════════════════════════════════════════════════════

Nicht-funktionale Anforderungen beschreiben *wie* das System seine Aufgaben erfüllt (`/LL010/` … `/LL080/`).

#figure(
  caption: [Nicht-funktionale Anforderungen /LL010/ … /LL080/.],
  kind: table,
  catalog-ll-table,
)

#ll-card("/LL010/", "Eingabevalidierung", "Qualitätsrichtlinie", "/LF030/, /LF230/, /LF240/",
  [Kritische Fehlerpfade (ungültige Koordinaten, Zeitstempel) erzeugen definierte `ValidationException` und sind durch /TC020/, /TC030/ abgesichert.])

#ll-card("/LL020/", "Genauigkeit der Peilungsberechnung", "Fachanforderung", "/LF030/, /LF050/",
  [Azimut-Abweichung ≤ ±1° vs. Haversine-Referenz für D > 10 m; Nachweis /TC140/.])

#ll-card("/LL030/", "Portabilität", "Projektauftrag", "-",
  [Java 11+, keine UI-Framework-Abhängigkeiten; plattformunabhängige Pfade und APIs.])

#ll-card("/LL040/", "Build-Reproduzierbarkeit", "Projektauftrag", "-",
  [`mvn clean test` auf frisch geklontem Repository erfolgreich; Abhängigkeiten über Maven Central.])

#ll-card("/LL050/", "XML-Escaping", "Sicherheitsrichtlinie", "/LF140/",
  [Nutzerstrings in GPX werden escaped (`XmlEscaper`); Nachweis über /TC100/ und GPX-Writer-Tests.])

#ll-card("/LL060/", "Strukturiertes Logging", "Betriebsanforderung", "/LF080/",
  [WARN/ERROR via SLF4J; `sessionId` in der Log-Nachricht (`Slf4jLoggerAdapter`).])

#ll-card("/LL070/", "Test-Determinismus", "Testbarkeitsanforderung", "-",
  [Zeitabhängige Tests nutzen `ClockPort`-Mocks; kein `Thread.sleep()` im Testcode.])

#ll-card("/LL080/", "Javadoc der öffentlichen API", "Vorlesung SWE", "-",
  [Öffentliche API-Klassen und -Methoden sind mit Javadoc dokumentiert (ohne Build-Gate).])

#pagebreak()

// ═════════════════════════════════════════════════════════════════════════════
== Externe Schnittstellen
// ═════════════════════════════════════════════════════════════════════════════

Die Bibliothek besitzt keine Benutzeroberfläche; ihre einzige Schnittstelle nach außen ist die öffentliche Java-API. Dieser Abschnitt beschreibt die aufrufbaren Methoden, das Fehlerverhalten und das Format der erzeugten GPX-Ausgabe. Zusammen bilden sie den Vertrag, auf den sich eine Host-Anwendung verlassen kann.

=== Öffentliche Java-API

Alle Aufrufe laufen über eine einzige Fassade. Sie spiegelt den Session-Lebenszyklus wider: Eine Session wird gestartet, mit Positions- und Kursdaten versorgt, abgefragt und schließlich regulär beendet oder abgebrochen. Jede Methode ist einer funktionalen Anforderung zugeordnet, was die Spalte _LF_ festhält.

#figure(
  caption: [Öffentliche API-Methoden der Bibliothek (`BearingSession` / `DefaultBearingSession`).],
  kind: table,
  catalog-api-table,
)
#pagebreak()
=== Fehlerverhalten

Die Bibliothek nutzt durchgängig *unchecked* Exceptions (`RuntimeException` und Subtypen). Der Host muss sie nicht deklarieren, kann sie aber gezielt abfangen. Details je Anforderung stehen in den `/LF…/`-Karten; hier die Zuordnung nach Fehlertyp:

#figure(
  caption: [Geworfene Exceptions nach Auslöser (Vertrag der öffentlichen API).],
  kind: table,
  align(left, table(
    columns: (4.5cm, 1fr, 3.2cm),
    stroke: 0.45pt + rgb("#9a9a9a"),
    inset: 6pt,
    table.header([*Exception*], [*Typische Auslöser*], [*Anforderungen*]),
    [`ValidationException`], [
      Ungültige Koordinaten oder Zeitstempel bei `onPositionUpdate(GpsFix)`;\
      Feld `errorCode()`: `COORD_RANGE` oder `TIMESTAMP_INVALID`.
    ], [/LF230/, /LF240/ (via /LF030/)],
    [`IllegalStateException`], [
      Session nicht `ACTIVE` (z.\ B. Update oder Snapshot vor Start, nach `complete()`/`abort()`);\
      Doppelstart; `reset()` während `ACTIVE`; Snapshot ohne vorherigen Fix.
    ], [/LF020/, /LF030/, /LF050/, /LF060/, /LF070/, /LF090/],
    [`IllegalArgumentException`], [
      Kurs außerhalb 0–360° (`onCourseUpdate`);\
      ungültige `GeoCoordinate` bei Erzeugung;\
      fehlerhafte `SessionConfig` beim `build()`.
    ], [/LF040/, /LF010/ (Ziel), /LD020/],
    [`SecurityException`], [Persistenzpfad liegt außerhalb von `allowedBaseDir`.], [/LF250/ (via /LF150/)],
    [`RuntimeException`], [I/O-Fehler beim atomaren Dateischreiben (`SafeFileSink`).], [/LF150/],
  ))
)

Die GPX-Serialisierung (`GpxXmlWriter`, /LF140/) definiert unter normalen Eingaben keine eigenen Fehlertypen. Listener-Fehler (/LF080/) werden intern abgefangen; die Session bleibt konsistent.



=== GPX 1.1-Ausgabeformat

Der Export folgt dem GPX-1.1-Schema von Topografix (/LF140/, /LF160/). Verbindlich sind Namespace, UTF-8 ohne BOM und UTC-Zeitstempel (`Z`). Metadaten enthalten Name und Zeitspanne; `<bounds>` ist optional.

#diagramm-box("GPX-1.1-Schemastruktur (normativ)")[
  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <gpx version="1.1" creator="Java-Kompass/1.0"
       xmlns="http://www.topografix.com/GPX/1/1"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.topografix.com/GPX/1/1
                           http://www.topografix.com/GPX/1/1/gpx.xsd">
    <metadata>
      <name>Peilung Stuttgart - Schlossplatz</name>
      <time>2026-06-12T10:00:00Z</time>
    </metadata>
    <trk>
      <trkseg>
        <trkpt lat="48.7758" lon="9.1829">
          <ele>248.0</ele>
          <time>2026-06-12T10:01:00Z</time>
          <hdop>1.2</hdop>
        </trkpt>
      </trkseg>
    </trk>
  </gpx>
  ```
]



// ═════════════════════════════════════════════════════════════════════════════
== Qualitäts-Anforderungen
// ═════════════════════════════════════════════════════════════════════════════

=== Qualitätsmodell nach ISO/IEC 25010

ISO/IEC 25010 beschreibt Produktqualität anhand von acht Hauptmerkmalen mit ihren Unterkriterien. Die folgende Matrix gewichtet jedes Unterkriterium nach seiner Bedeutung für genau dieses Projekt - von _sehr wichtig_ bis _nicht relevant_. Die Gewichtung macht die Schwerpunkte sichtbar: Hoch eingestuft sind vor allem die Richtigkeit der Berechnung, die Zuverlässigkeit und die Wartbarkeit, während Aspekte wie Verbrauchsverhalten oder Anpassbarkeit für eine eingebettete Bibliothek dieser Größe nachrangig sind.

#let _category-rows = (1, 8, 13, 19, 23, 29)
#{
  show figure: set block(breakable: true)
  figure(
    caption: [Gewichtung der Qualitätsmerkmale nach ISO/IEC 25010 (Relevanzstufen je Unterkriterium).],
    kind: table,
    table(
      columns: (2.5fr, 0.9fr, 0.9fr, 0.9fr, 1.1fr),
      stroke: 0.5pt + rgb("#AAAAAA"),
      fill: (x, y) => {
        if y == 0 { rgb("#4a4a4a") }
        else if y in _category-rows { rgb("#9ab8cc") }
        else if calc.even(y) { rgb("#f2f2f2") }
        else { white }
      },
      inset: (x: 7pt, y: 5pt),
      align: (x, y) => if x == 0 { left + horizon } else { center + horizon },
      table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[Produktqualität]],
      table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[sehr wichtig]],
      table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[wichtig]],
      table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[normal]],
      table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[nicht relevant]],
      [*Funktionalität*], [], [], [], [],
      [Angemessenheit], [x], [], [], [],
      [Sicherheit], [], [], [x], [],
      [Interoperabilität], [], [], [x], [],
      [Konformität], [], [x], [], [],
      [Ordnungsmäßigkeit], [], [], [x], [],
      [Richtigkeit], [], [x], [], [],
      [*Zuverlässigkeit*], [], [], [], [],
      [Fehlertoleranz], [], [], [x], [],
      [Konformität], [], [], [x], [],
      [Reife], [], [x], [], [],
      [Wiederherstellbarkeit], [], [x], [], [],
      [*Benutzbarkeit*], [], [], [], [],
      [Attraktivität], [x], [], [], [],
      [Bedienbarkeit], [], [x], [], [],
      [Erlernbarkeit], [x], [], [], [],
      [Konformität], [], [], [x], [],
      [Verständlichkeit], [], [x], [], [],
      [*Effizienz*], [], [], [], [],
      [Konformität], [], [], [x], [],
      [Zeitverhalten], [], [], [x], [],
      [Verbrauchsverhalten], [], [], [], [x],
      [*Änderbarkeit*], [], [], [], [],
      [Analysierbarkeit], [], [], [x], [],
      [Konformität], [], [], [x], [],
      [Modifizierbarkeit], [], [x], [], [],
      [Stabilität], [], [x], [], [],
      [Testbarkeit], [], [], [x], [],
      [*Übertragbarkeit*], [], [], [], [],
      [Anpassbarkeit], [], [], [], [x],
      [Austauschbarkeit], [], [x], [], [],
      [Installierbarkeit], [], [], [x], [],
      [Koexistenz], [], [x], [], [],
      [Konformität], [], [], [x], [],
    ),
  )
}

=== Produktdaten (/LD…/)

Die Produktdaten beschreiben die zentralen Datenstrukturen der Bibliothek mit ihren Feldern, Typen und Wertebereichen. Sie bilden die Brücke zwischen den funktionalen Anforderungen und der späteren Implementierung: Jede `/LD…/`-Karte verweist auf die Anforderungen, in denen die Struktur entsteht oder verwendet wird.

#figure(caption: [Produktdaten /LD010/ … /LD060/.], kind: table, catalog-ld-table)

#ld-card("/LD010/", "Peilungs-Session", "/LF010/, /LF060/, /LF070/, /LF090/", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [sessionId], [UUID RFC 4122 v4],
    [status], [IDLE · ACTIVE · COMPLETED · ABORTED],
    [target], [GeoCoordinate (WGS84)],
    [startedAt], [Instant UTC],
    [config], [SessionConfig (eingefroren)],
  )
])

#ld-card("/LD020/", "SessionConfig", "/LF010/, /LF110/, /LF130/, /LF120/", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [softLimitPoints], [int ≥ 0],
    [hardLimitPoints], [int ≥ 0; Hard-Limit /LF130/ STOP],
    [segmentGapThreshold], [Duration (Standard: PT5M)],
    [maxFixAge], [Duration (Standard: PT24H)],
    [persistOnAbort], [boolean],
    [optimizers], [List\<TrackOptimizer\> (/LF170/-/LF200/)],
  )
])

#ld-card("/LD030/", "GPS-Track / Segment", "/LF100/, /LF120/, /LF140/", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [segments], [List\<TrackSegment\>],
    [totalPoints], [int (abgeleitet)],
  )
])

#ld-card("/LD040/", "GpsPoint / GpsFix", "/LF030/, /LF230/, /LF240/", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [lat], [double ∈ [−90,0, +90,0]],
    [lon], [double ∈ [−180,0, +180,0]],
    [time], [Instant UTC (Pflichtfeld)],
    [ele], [Optional\<Double\> (Höhe in m)],
    [hdop], [Optional\<Double\> (≥ 0)],
    [speed], [Optional\<Double\> (≥ 0 m/s)],
  )
])

#ld-card("/LD050/", "BearingSnapshot", "/LF050/", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [azimuthDeg], [double ∈ [0,0°, 360,0°)],
    [distanceM], [double ≥ 0],
    [compassOrdinal], [Enum: N · NE · E · SE · S · SW · W · NW],
    [bearingErrorDeg], [Optional\<Double\> ∈ (−180°, +180°]],
  )
])

#ld-card("/LD060/", "GpxResult", "/LF140/, /LF160/", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [gpxBytes], [byte[] UTF-8, kein BOM],
    [statistics], [SessionStatistics],
    [appliedOptimizers], [List\<String\>],
  )
])

=== Testfälle (Traceability)

Verbindliche Testfälle `/TC010/` … `/TC150/` mit JUnit-Methodennamen (siehe `implementation/TRACEABILITY.md`).

#figure(
  caption: [Testfälle mit Traceability zu /LF…/ und /LL…/.],
  kind: table,
  catalog-tc-table,
)

#pagebreak()

=== FMEA

Die Fehlermöglichkeits- und Einflussanalyse (FMEA) betrachtet systematisch, was schiefgehen kann, welche Folge das hätte und wie die Bibliothek dem begegnet. Jede Zeile schätzt Auftretenswahrscheinlichkeit (A) und Entdeckungswahrscheinlichkeit bzw. Schwere der Folge (E) qualitativ ein und nennt die konkrete Gegenmaßnahme samt zugehöriger Anforderung.

#{
  show figure: set block(breakable: true)
  figure(
    caption: [FMEA: Fehlermodi, Folgen, Klassen und Gegenmaßnahmen.],
    kind: table,
    table(
    columns: (2.4cm, 1.5fr, 0.8cm, 0.8cm, 2fr),
    stroke: _card-stroke,
    inset: _card-ins,
    align: (x, y) => if x == 0 or x == 2 or x == 3 { center + horizon } else { left + top },
    table.header(
      _trace-hdr([*Fehler*]),
      _trace-hdr([*Folge*]),
      _trace-hdr([*A*]),
      _trace-hdr([*E*]),
      _trace-hdr([*Gegenmaßnahme*]),
    ),
    [Ungültige Koordinate],    [Falsche Peilung oder Exception.],  [M], [K], [`ValidationException`; /LF230/.],
    [Ungültiger Zeitstempel],  [Falsche Segmentierung.],           [M], [M], [/LF240/.],
    [Speicheroverflow],        [OutOfMemoryError der JVM.],        [G], [K], [Hard-Limit /LF130/.],
    [XML-Injection],           [Ungültige GPX-Datei.],             [G], [M], [XmlEscaper; /LF140/, /LL050/.],
    [Path Traversal],          [Kritische Datei überschrieben.],   [G], [M], [/LF250/.],
    [W3W-Ausfall],             [Fehlende W3W-Adresse.],            [G], [G], [Fallback; /LF210/, /LF220/.],
    [Listener wirft],          [Benachrichtigungsschleife abbricht.],[M],[K], [/LF080/, /TC120/.],
    [Clock nicht injiziert],   [Nicht-deterministische Tests.],    [S], [G], [`ClockPort`; /LL070/.],
    ),
  )
}

*Legende A/E:* S = selten, M = mittel, G = gering, K = katastrophal (qualitativ).

#pagebreak()
]



 // end ch-spezifische-anforderungen-kapitel
