#import "macros.typ": diagramm-box

#let ch-grobentwurf-kapitel = [
#set par(justify: true)

Die Architektur folgt einer Schichtenarchitektur mit klarer Abhängigkeitsrichtung von oben nach unten. Oberste Schicht ist die API-Fassade (`BearingSessionFactory`, `BearingSession`), darunter die Domänenschicht (Peilungsberechnung, Trackaggregation), gefolgt von Infrastruktur (GPX-Writer, W3W-Client, Dateizugriff).

== Schichtendiagramm 

#diagramm-box("Detailliertes Schichtenmodell")[
  *0. Host-System (außerhalb der Komponente)*\
  Beliebige Java-UI (Desktop, Web, Mobile), Sensoradapter und App-Lifecycle. Übergibt Positions- und Rechnungsdaten ausschließlich über die API-Fassade.

  ↓ Nur API-Aufrufe; keine direkten Infrastrukturzugriffe

  *1. API / Application Service*\
  `BearingSessionFactory`, `BearingSession`, `SessionConfig`, `BearingSnapshot`.
  Verantwortet Vorbedingungen, Session-Zustandsautomat (`IDLE`, `ACTIVE`, `COMPLETED`, `ABORTED`), Fehler-Mapping und Orchestrierung der Fachfälle.

  ↓ Nutzt ausschließlich Domänenlogik und definierte Ports

  *2. Domain Core*\
  Entitäten/Value Objects: `GeoPoint`, `Target`, `Track`, `TrackSegment`, `GpsPoint`.
  Services/Policies: `BearingCalculator`, `TrackAggregator`, `SamplingPolicy`, `ValidationPolicy`, `SegmentationPolicy`, `TrackOptimizer`.
  Fachregeln: Azimut/Distanz, Ordinalrichtung, Datenqualitätsfilter, Segmentierung, Optimierung.

  ↓ Abstraktion externer Abhängigkeiten über Ports 

  *3. Port-Schicht (Schnittstellenverträge)*\
  `GpxWriterPort`, `W3wClientPort`, `ClockPort`, `FileSinkPort`, `LoggerPort`.
  Stabiler Vertrag zwischen Domäne/API und konkreten technischen Adaptern; erleichtert Mocking, Testbarkeit und Austauschbarkeit.

  ↓ Konkrete Implementierungen der Ports

  *4. Infrastruktur*\
  `GpxXmlWriter` (GPX 1.1), `W3wHttpClient`, `SafeFileSink`, `SystemClock`, `Slf4jLogger`.
  Zuständig für XML, HTTP, Dateisystem und Bibliotheksintegration;
]

#table(
  columns: (3.2cm, 3.2cm, 2.2cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Von*], [*Nach*], [*Erlaubt?*], [*Regel / Begründung*],
  [Host-System], [API], [Ja], [Integration ausschließlich über öffentliche Java-API],
  [Host-System], [Domain], [Nein], [Kapselung der Fachlogik hinter Session-Fassade],
  [API], [Domain], [Ja], [Use-Case-Orchestrierung ohne Infrastrukturkopplung],
  [Domain], [Ports], [Ja], [Externe Effekte nur über abstrahierte Verträge],
  [Domain], [Infrastruktur], [Nein], [Unabhängigkeit der Business-Logik von I/O],
  [Infrastruktur], [Domain], [Nein], [Keine Rückkopplung/Seiteneffekte in Fachregeln],
)

== Paket- und Modulschnitt

Für die referenzielle Entkopplung empfiehlt sich eine Aufteilung in Maven-Module (konzeptionell, physische Aufteilung im Repository optional):

#table(
  columns: (2.2cm, 3.2cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  align: (left, left, left),
  [*Modul*], [*Paketbasis*], [*Verantwortung*],
  [`bearing-core`], [`com.example.bearing.core`], [Session-Zustände, Validierung, Peilungsberechnung],
  [`gps-tracker`], [`com.example.bearing.track`], [Punkte, Segmente, Sampling, Filter],
  [`gpx-exporter`], [`com.example.bearing.gpx`], [GPX 1.1, Escaping, Metadaten],
  [`w3w-adapter`], [`com.example.bearing.w3w`], [Optionaler Client + Cache],
)

#pagebreak()

== Entwurfsmuster (Mapping Vorlesung ↔ Implementierung)

#table(
  columns: (3cm, 1fr, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Muster*], [*Einsatz*], [*Nutzen*],
  [Factory], [Erzeugung gültiger Sessions], [Zentralisierte Vorbedingungen],
  [Builder], [`SessionConfig`], [Lesbare, validierbare Konfiguration],
  [Strategy], [`TrackOptimizer`], [Austauschbare Vereinfachung],
  [Observer/Listener], [`BearingListener`], [UI-agnostische Ereignisse],
  [Template Method (optional)], [GPX-Pipeline], [Stabile Erweiterungspunkte],
  [Null Object (optional)], [No-Op-Logger in Tests], [Reduktion von `null`-Zweigen],
)

#pagebreak()

== Schnittstellenübersicht (extern sichtbar)

Die Host-Anwendung interagiert *ausschließlich* über Java-APIs. Persistenz ist optional: GPX kann als `String` oder `byte[]` zurückgegeben werden (`/LF230/`). Dateipfade werden – falls genutzt – validiert (`/LF320/`).

Wichtige Operationen (konzeptionell):

#table(
  columns: (2.6cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Operation*], [*Semantik*],
  [`startSession(config, target)`], [Legt Session an, UUID, ACTIVE],
  [`onPositionUpdate(fix)`], [Validiert, sampled, aktualisiert Peilung],
  [`onCourseUpdate(deg)`], [Optional, Kursabweichung],
  [`currentSnapshot()`], [Liefert `BearingSnapshot`],
  [`complete()`], [COMPLETED + GPX-Daten],
  [`abort()`], [ABORTED + GPX-Daten, Datei nur wenn konfiguriert],
)

#pagebreak()
]
