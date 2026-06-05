// ─────────────────────────────────────────────────────────────────────────────
// LF-/LL-Karten, Produktdaten und Kapitel 3.5 (Qualität)
// ─────────────────────────────────────────────────────────────────────────────
#import "macros.typ": diagramm-box
#import "ch-lf-spezifikationen.typ": ch-lf-spezifikationen

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

Dieses Kapitel bildet den normativen Kern des Dokuments. Die funktionalen Anforderungen sind nach SOPHIST/IEEE-830 formuliert: jede `/LF…/`- bzw. `/LL…/`-Spezifikation enthält Allgemeines, Funktionsbedingungen und Funktionsablauf mit zugehörigem Aktivitätsdiagramm. Ergänzt wird das Kapitel durch nicht-funktionale Anforderungen (3.2), externe Schnittstellen (3.3), Performance-Anforderungen (3.4) und das Qualitätsmodell nach ISO/IEC 25010 (3.5).

// ═════════════════════════════════════════════════════════════════════════════
== Funktionale Anforderungen
// ═════════════════════════════════════════════════════════════════════════════

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

#pagebreak()

#ch-lf-spezifikationen

// ═════════════════════════════════════════════════════════════════════════════
== Nicht-funktionale Anforderungen
// ═════════════════════════════════════════════════════════════════════════════

Nicht-funktionale Anforderungen beschreiben *wie* das System seine Aufgaben erfüllt. Sie sind durch `/LL…/`-Bezeichner referenzierbar und als messbare Qualitätsmerkmale formuliert.

#ll-card("/LL010/", "Eingabevalidierung", "Qualitätsrichtlinie", "/LF030/, /LF010/",
  [Ungültige Eingaben (null, WGS84-Bereich verletzt, Zeitstempel außerhalb Toleranz) dürfen keine undefinierten Zustände erzeugen. Alle Fehlerpfade müssen durch dedizierte Testfälle abgesichert sein; 100 % der Exception-Pfade in Validierungsklassen müssen durch Tests erreichbar sein.])

#ll-card("/LL020/", "Genauigkeit der Peilungsberechnung", "Fachanforderung", "/LF030/, /LF050/",
  [Für Distanzen > 10 m darf der berechnete Azimut maximal ±1° von einer unabhängigen Referenz (Haversine-Formel) abweichen. Überprüfung für mindestens drei Referenzszenarien: Äquator, Polnähe (φ > 80°), Stuttgart (48,77°N/9,18°E).])

#ll-card("/LL030/", "Performance: Peilungszyklus", "Echtzeit-Anforderung", "/LF030/",
  [Vollständiger Update-Zyklus (`onPositionUpdate` → Azimut/Distanz berechnen) soll auf Referenz-Laptop typisch < 1 ms, Worst-Case (ohne GC) < 100 ms betragen. Überschreitung muss im Test-Report dokumentiert werden.])

#ll-card("/LL040/", "Performance: GPX-Export", "Performanceanforderung", "/LF200/",
  [GPX-Export für 10.000 Trackpunkte ohne Optimierung soll auf Referenz-Laptop in unter 2 Sekunden erfolgen. Messung per JMH- oder `@Timeout`-Test in `target/benchmark-report.txt`.])

#ll-card("/LL050/", "Speicherverbrauch", "Ressourcenanforderung", "/LF030/",
  [Heap-Zuwachs der Bibliothek für 10.000 Punkte (alle optionalen Felder) soll typisch < 50 MB betragen. Validierung durch JVM-Heap-Snapshot-Test.])

#ll-card("/LL100/", "Javadoc-Vollständigkeit", "Vorlesung SWE", "–",
  [Gesamte öffentliche API (alle public-/protected-Klassen und Methoden) muss vollständig mit Javadoc dokumentiert sein. Checkstyle-Plugin im Maven-Build erzwingt dies; fehlende Javadoc führen zum Build-Fehler.])

#ll-card("/LL110/", "Portabilität", "Projektauftrag", "–",
  [Keine plattformspezifischen Pfade, Zeilentrennzeichen oder `sun.*`-APIs. Kompilierbar und ausführbar auf Windows 10+, macOS 12+ und Ubuntu 22.04 ohne Anpassungen. CI-Matrix auf mindestens zwei Plattformen empfohlen.])

#ll-card("/LL120/", "Build-Reproduzierbarkeit", "Projektauftrag", "–",
  [Maven-Build auf frisch geklontem Repository mit `mvn clean test` in unter 5 Minuten erfolgreich. Alle Abhängigkeiten versioniert und über Maven Central auflösbar. Keine SNAPSHOT-Abhängigkeiten im Release.])

#ll-card("/LL130/", "Sicherheit: XML-Escaping", "Sicherheitsrichtlinie", "/LF200/",
  [Alle Nutzerstrings in XML-Ausgaben müssen escaped werden (`&→&amp;`, `<→&lt;`, `>→&gt;`, `"→&quot;`). XXE-Schutz via `FEATURE_SECURE_PROCESSING = true`. Verifikation durch Integrationstest mit Sonderzeichen.])

#ll-card("/LL140/", "Beobachtbarkeit via SLF4J", "Betriebsanforderung", "–",
  [Alle WARN- und ERROR-Ereignisse via SLF4J protokolliert. Jeder Eintrag auf WARN+ enthält `sessionId` als MDC-Feld. MDC muss nach jedem Aufruf bereinigt werden (Thread-Pool-Schutz).])

#ll-card("/LL150/", "Testabdeckung", "Vorlesung SWE", "/LL010/",
  [Kernmodule `bearing-core`, `gps-tracker`, `gpx-exporter`: Zeilenabdeckung ≥ 85 % (JaCoCo). Kritische Klassen `BearingSession`, `BearingCalculator`: ≥ 90 %. Unterschreitung führt zum Build-Fehler (`jacoco:check`).])

#ll-card("/LL160/", "Wiederanlauf nach Exception", "Betriebsanforderung", "/LF010/, /LF060/, /LF070/",
  [Nach `abort()` + `reset()` muss Zustand `IDLE` erreichbar sein, ohne JVM-Neustart. Verifikation durch Integrationstest: injizierter Fehler → Abort → Reset → neuer Start erfolgreich.])

#ll-card("/LL170/", "Determinismus der Tests", "Testbarkeitsanforderung", "–",
  [`ClockPort`-Mocks mit fixer Zeit in allen zeitabhängigen Tests. `Thread.sleep()` und `System.currentTimeMillis()` im Testcode verboten. Testbaum ist idempotent (kein Abhängigkeit von Dateisystemresten).])

#ll-card("/LL190/", "Determinismus bei gleichen Eingaben", "Qualitätsanforderung", "–",
  [Identische Eingabesequenzen + `ClockPort`-Mock + selbe Konfiguration müssen stets byte-identischen GPX-String erzeugen. Verifikation durch Reproduzierbarkeitstests mit mindestens drei Durchläufen.])

#ll-card("/LL200/", "Abhängigkeitslizenzierung", "Rechtliche Anforderung", "–",
  [Standard-Build: nur permissiv lizenzierte Bibliotheken (Apache 2.0, MIT, BSD 2/3). W3W-Client nur in Maven-Profil `w3w`. Konformität via `license-maven-plugin:check`.])

#pagebreak()

// ═════════════════════════════════════════════════════════════════════════════
== Externe Schnittstellen
// ═════════════════════════════════════════════════════════════════════════════

=== Öffentliche Java-API

#figure(
  caption: [Vollständige öffentliche API-Methoden der Bibliothek.],
  kind: table,
  align(left, table(
    columns: (5.5cm, 1fr, 1.8cm),
    stroke: _tbl, inset: _ins,
    [*Signatur*], [*Beschreibung*], [*LF*],
    [`SessionId startSession(GeoCoordinate, SessionConfig)`], [Neue Peilung starten; UUID zurückgeben.], [/LF010/],
    [`void onPositionUpdate(GpsFix)`],       [GPS-Fix verarbeiten; Track + Peilung aktualisieren.], [/LF030/],
    [`void onHeadingUpdate(double)`],        [Kurs aktualisieren (optional, 0–360°).],              [/LF030/],
    [`Optional<BearingSnapshot> getSnapshot()`], [Aktuellen Schnappschuss abfragen.],               [/LF050/],
    [`GpxResult complete()`],                [Session regulär beenden; GPX erzeugen.],              [/LF060/],
    [`GpxResult abort()`],                   [Session abbrechen; GPX erzeugen.],                   [/LF070/],
    [`void reset()`],                        [Auf IDLE zurücksetzen.],                              [/LL160/],
    [`String resolveW3w(GeoCoordinate)`],    [W3W-Adresse auflösen (optional).],                   [/LF280/],
    [`void addListener(BearingListener)`],   [Listener registrieren.],                              [/LF080/],
    [`void removeListener(BearingListener)`],[Listener deregistrieren.],                            [–],
  ))
)

=== Exception-Hierarchie

#diagramm-box("Exception-Hierarchie der Bibliothek")[
  `RuntimeException` (JDK)\
  └── `BearingException` _(Basisklasse; enthält `errorCode: String`, vollständig in Javadoc dokumentiert)_\
  #h(1.2cm) ├── `ValidationException` _(Codes: COORD\_RANGE · TIMESTAMP\_INVALID · INVALID\_CONFIG · INVALID\_FIELD\_VALUE)_\
  #h(1.2cm) ├── `BearingStateException` _(Codes: ALREADY\_ACTIVE · SESSION\_ENDED · SESSION\_STILL\_ACTIVE)_\
  #h(1.2cm) └── `BearingIOException` _(Codes: IO\_WRITE\_ERROR · PATH\_TRAVERSAL)_
]

=== GPX 1.1-Ausgabeformat

#diagramm-box("GPX-1.1-Schemastruktur (normativ)")[
  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <gpx version="1.1" creator="Java-Kompass/1.0"
       xmlns="http://www.topografix.com/GPX/1/1"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.topografix.com/GPX/1/1
                           http://www.topografix.com/GPX/1/1/gpx.xsd">
    <metadata>
      <name>Peilung Stuttgart – Schlossplatz</name>
      <time>2026-06-12T10:00:00Z</time>
      <bounds minlat="48.775" minlon="9.182" maxlat="48.783" maxlon="9.191"/>
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

#pagebreak()

// ═════════════════════════════════════════════════════════════════════════════
== Anforderungen an die Performance
// ═════════════════════════════════════════════════════════════════════════════

=== Quantitative Leistungskennwerte

#figure(
  caption: [Quantitative Performance-Anforderungen mit Messmethode.],
  kind: table,
  align(left, table(
    columns: (4cm, 1fr, 3cm),
    stroke: _tbl, inset: _ins,
    [*Kennwert*], [*Anforderung / Grenzwert*], [*Messmethode*],
    [Peilungszyklus (Worst-Case)], [< 100 ms ohne GC; typisch < 1 ms.], [JMH / `@Timeout`-Test],
    [GPX-Export (10k Punkte)],    [< 2 s ohne Optimierung.], [JMH-Benchmark],
    [Heap-Zuwachs (10k Punkte)],  [Typisch < 50 MB.], [JVM-Heap-Snapshot],
    [W3W Cache-Roundtrip],        [< 1 ms bei Cache-Treffer.], [Unit-Test mit Mock],
    [Build (`mvn clean test`)],   [< 5 Minuten auf Referenz-CI.], [CI-Laufzeit-Tracking],
  ))
)

=== AD-01: Aktivitätsdiagramm `onPositionUpdate` (Standardflussdiagramm)

Dieses Diagramm stellt den vollständigen Ablauf eines Positionsupdates (/LF030/) im Standard-Flussdiagrammstil dar. Es zeigt Entscheidungsknoten für Validierung, Segmentgrenze und Limit-Checks sowie die parallelen Berechnungsschritte.
/*
#figure(
  image("images/AD_01_PositionUpdate.svg", width: 100%),
  caption: [AD-01: Aktivitätsdiagramm `onPositionUpdate` – Standardflussdiagramm mit Entscheidungsknoten, Fehler- und Limit-Pfaden.],
)
*/
#pagebreak()

=== AD-02: Aktivitätsdiagramm GPX-Export (Swimlane-Darstellung)

Das Swimlane-Diagramm zeigt den GPX-Exportvorgang (/LF200/) mit vier Verantwortungsbereichen. Die Fork-/Join-Notation visualisiert die sequentielle Verkettung der Optimierungsstrategien.

// #figure(
//   image("images/AD_02_GpxExport.svg", width: 100%),
//   caption: [AD-02: Aktivitätsdiagramm GPX-Export – Swimlane mit Fork/Join für Optimierungspipeline (Host-App, BearingSession, OptimPipeline, GpxSerializer).],
// )

#pagebreak()

=== AD-03: Aktivitätsdiagramm /LF010/ Session starten (Fork/Join-Stil)

Dieses Diagramm zeigt /LF010/ (Session starten) mit expliziter Fork-/Join-Notation für parallele Initialisierungsschritte.

// #figure(
//   image("images/AD_03_SessionStart.svg", width: 90%),
//   caption: [AD-03: Aktivitätsdiagramm /LF010/ Session starten – Fork/Join-Stil mit Fehlerausflüssen.],
// )

#pagebreak()

// ═════════════════════════════════════════════════════════════════════════════
== Qualitäts-Anforderungen
// ═════════════════════════════════════════════════════════════════════════════

=== Qualitätsmodell nach ISO/IEC 25010

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

#ld-card("/LD100/", "Peilungs-Session", "/LF010/, /LF070/", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [sessionId], [UUID RFC 4122 v4, 36 Zeichen],
    [status], [Enum: IDLE · ACTIVE · COMPLETED · ABORTED],
    [target], [GeoCoordinate (WGS84, validiert)],
    [startedAt], [Instant UTC (gesetzt bei Start)],
    [endedAt], [Optional\<Instant\> (gesetzt bei complete/abort)],
    [config], [SessionConfig (immutable, eingefroren)],
  )
])

#ld-card("/LD110/", "Konfiguration (SessionConfig)", "/LF010/", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [softLimitPoints], [int ≥ 0 (0 = deaktiviert)],
    [hardLimitPoints], [int ≥ softLimit (0 = deaktiviert)],
    [overflowMode], [Enum: STOP · DOWNSAMPLE],
    [segmentGapThreshold], [Duration > 0 (Standard: PT5M)],
    [maxFixAge], [Duration > 0 (Standard: PT24H)],
    [persistOnAbort], [boolean (Standard: false)],
    [w3wApiKey], [Optional\<String\>],
    [w3wCacheTtl], [Duration (Standard: PT1H)],
    [optimizers], [List\<TrackOptimizer\>],
  )
])

#ld-card("/LD120/", "GPS-Track", "/LF030/, /LF200/", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [segments], [List\<TrackSegment\> (mind. 1)],
    [totalPoints], [int (abgeleitete Kennzahl)],
    [bounds], [Optional\<GeoBounds\> (min/max lat/lon)],
  )
])

#ld-card("/LD130/", "GPS-Punkt (GpsPoint)", "/LF030/", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [lat], [double ∈ [−90,0, +90,0]],
    [lon], [double ∈ [−180,0, +180,0]],
    [time], [Instant UTC (Pflichtfeld)],
    [ele], [Optional\<Double\> (Höhe in m)],
    [hdop], [Optional\<Double\> (≥ 0)],
    [speed], [Optional\<Double\> (≥ 0 m/s)],
  )
])

#ld-card("/LD140/", "Peilungs-Snapshot", "/LF050/", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [azimuthDeg], [double ∈ [0,0°, 360,0°)],
    [distanceM], [double ≥ 0],
    [compassOrdinal], [Enum: N · NE · E · SE · S · SW · W · NW],
    [bearingErrorDeg], [Optional\<Double\> ∈ (−180°, +180°]],
  )
])

#ld-card("/LD150/", "GPX-Dokument (GpxResult)", "/LF200/", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [gpxString], [String UTF-8 (valides GPX 1.1)],
    [gpxBytes], [byte[] UTF-8, kein BOM],
    [optimizationResult], [OptimizationResult (Statistik)],
    [stats], [SessionStats],
  )
])

#ld-card("/LD160/", "W3W-Cache-Eintrag", "/LF280/", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [lat], [double (gerundet 6 Dezimalstellen)],
    [lon], [double (gerundet 6 Dezimalstellen)],
    [words], [String (3 Wörter, Punkt-getrennt)],
    [resolvedAt], [Instant UTC],
    [ttl], [Duration (aus SessionConfig)],
  )
])

=== Testfälle (Traceability)

#{
  show figure: set block(breakable: true)
  figure(
    caption: [Testfälle mit Traceability zu funktionalen und nicht-funktionalen Anforderungen.],
    kind: table,
    table(
    columns: (1.6cm, 1fr, 4.5cm, 2cm),
    stroke: _card-stroke,
    inset: _card-ins,
    align: (x, y) => if x == 0 { center + horizon } else { left + top },
    table.header(
      _trace-hdr([*TC-ID*]),
      _trace-hdr([*Beschreibung*]),
      _trace-hdr([*Erwartetes Ergebnis*]),
      _trace-hdr([*LF / LL*]),
    ),
    [TC-010], [Doppelter `startSession()`-Aufruf.], [`BearingStateException(ALREADY_ACTIVE)`.], [/LF010/],
    [TC-020], [`GpsFix` mit `lat = 91°`.], [`ValidationException(COORD_RANGE)`.], [/LF030/],
    [TC-025], [Zeitstempel +2h in der Zukunft.], [`ValidationException(TIMESTAMP_INVALID)`.], [/LF030/],
    [TC-030], [Update nach `complete()`.], [`BearingStateException(SESSION_ENDED)`.], [/LF060/],
    [TC-040], [Snapshot ohne Fix.], [`Optional.empty()`.], [/LF050/],
    [TC-050], [Soft-Limit (n=100).], [`onSoftLimitReached`; Aufzeichnung läuft.], [/LF030/],
    [TC-060], [Hard-Limit STOP (n=200).], [`onHardLimitReached`; kein weiterer Punkt.], [/LF030/],
    [TC-070], [`abort()` ohne persist.], [GPX-String ≠ leer; keine Datei.], [/LF070/],
    [TC-080], [`abort()` mit persist.], [Datei atomar geschrieben; valide.], [/LF070/],
    [TC-090], [Pfad `../../etc/passwd`.], [`SecurityException`.], [/LF200/],
    [TC-100], [GPX-Namespace in Ausgabe.], [`xmlns="http://www.topografix.com/GPX/1/1"`.], [/LF200/],
    [TC-110], [n-Optimizer n=10, 100 Punkte.], [11 Punkte (Start/Ende + 9 dazwischen).], [/LF200/],
    [TC-120], [Kollinear: 3 Punkte auf Linie.], [2 Punkte nach Optimierung.], [/LF200/],
    [TC-130], [Douglas-Peucker ε = 100 m.], [Starke Reduktion; kein Fehler.], [/LF200/],
    [TC-140], [W3W-API Timeout.], [Fallback; WARN-Log mit sessionId.], [/LF280/],
    [TC-150], [W3W-Cache-Treffer (2. Aufruf).], [Kein Netzwerkaufruf beim 2. Mal.], [/LF280/],
    [TC-160], [Clock-Mock; zwei identische Läufe.], [Byte-identischer GPX-String.], [/LL190/],
    [TC-170], [Listener wirft RuntimeException.], [Exception gefangen; nächster Listener weiter.], [/LF080/],
    [TC-180], [`reset()` → neuer Start.], [Neue UUID; Session ACTIVE.], [/LL160/],
    [TC-190], [Sonderzeichen `<>&"` im Namen.], [GPX enthält korrekte XML-Entities.], [/LL130/],
    [TC-200], [Start Happy Path.], [UUID vorhanden; `onSessionStarted` gefeuert.], [/LF010/],
    [TC-210], [Azimut Stuttgart→München vs. Referenz.], [Abweichung ≤ ±1°.], [/LL020/],
    [TC-220], [Zeitlücke 6 min (Threshold 5 min).], [Zwei `<trkseg>` im GPX.], [/LF030/],
    ),
  )
}

#pagebreak()

=== FMEA

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
    [Ungültige Koordinate],    [Falsche Peilung oder Exception.],  [M], [K], [`ValidationException`; /LF030/ Schritt 2.],
    [Ungültiger Zeitstempel],  [Falsche Segmentierung.],           [M], [M], [Zeitvalidierung; /LF030/ Schritt 2.],
    [Speicheroverflow],        [OutOfMemoryError der JVM.],        [G], [K], [Hard-Limit /LF030/ Schritt 3 (Alt. 5a).],
    [XML-Injection],           [Ungültige GPX-Datei.],             [G], [M], [XmlEscaper; /LF200/ Schritt 4.],
    [Path Traversal],          [Kritische Datei überschrieben.],   [G], [M], [Pfadnormalisierung; /LF200/ Schritt 5.],
    [W3W-Ausfall],             [Fehlende W3W-Adresse.],            [G], [G], [Fallback + Cache; /LF280/.],
    [Listener wirft],          [Benachrichtigungsschleife abbricht.],[M],[K], [Isolation-Garantie; /LF080/.],
    [Clock nicht injiziert],   [Nicht-deterministische Tests.],    [S], [G], [`ClockPort`-Injection; /LL170/.],
    ),
  )
}

*Legende A/E:* S = selten, M = mittel, G = gering, K = katastrophal (qualitativ).

#pagebreak()
]



 // end ch-spezifische-anforderungen-kapitel
