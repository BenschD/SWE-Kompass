#import "macros.typ": diagramm-box

#let ch-grobentwurf-kapitel = [
#set par(justify: true)

Die Architektur folgt einer Schichtenarchitektur mit klarer Abhängigkeitsrichtung von oben nach unten. Oberste Schicht ist die API-Fassade (`BearingSessionFactory`, `BearingSession`), darunter die Domänenschicht (Peilungsberechnung, Trackaggregation), gefolgt von Infrastruktur (GPX-Writer, W3W-Client, Dateizugriff).

== Schichtendiagramm 

#diagramm-box("Logische Schichten (C4 Level-2 vereinfacht)")[
  *1. API / Application Service*\
  Koordiniert Session-Lebenszyklus, validiert Eingaben, orchestriert Domäne und Infrastruktur. Keine UI.

  *2. Domain*\
  Pure Business Logic: Haversine, Azimut, Ordinalzuordnung, Sampling-Policy, Track-Segmentierung, Optimierungs-Pipeline.

  *3. Infrastructure*\
  XML-Serialisierung GPX, sicheres Dateischreiben, HTTP-Client für W3W , Clock-Injection.
]

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
