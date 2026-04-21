#import "macros.typ": diagramm-box

#let puml-fig(path) = image(path, width: 100%, height: 15.5cm, fit: "contain")

#let ch-grobentwurf-kapitel = [
#set par(justify: true)

Der Grobentwurf beschreibt die Software-Architektur der Java-Peilungskomponente auf Systemebene. Ziel ist eine sprachnahe, aber weiterhin implementierungsunabhängige Strukturierung in Subsysteme mit klaren Verantwortlichkeiten, stabilen Schnittstellen und nachvollziehbaren Kommunikationsregeln.

== Einordnung und Ziel des Grobentwurfs

Die Architektur muss folgende Ziele gleichzeitig erfüllen:

- Parallele Entwicklung durch präzise Subsystem- und Schnittstellenabgrenzung.
- Hohe Testbarkeit durch Entkopplung von Fachlogik und technischen Adaptern.
- Erweiterbarkeit (z. B. zusätzliche Optimierungsverfahren oder weitere externe Dienste).
- Nachvollziehbarkeit der Entwurfsentscheidungen im Sinne der Vorlesungsprinzipien.

== Systemsicht

#diagramm-box("Systemsicht (Kontext und Systemgrenze)")[
  *System of Interest:* Java-Peilungskomponente ohne UI.

  *Externe Akteure/Schnittstellen:*\
  - Host-Anwendung (liefert Ziel, Positions- und Kursdaten; steuert Lebenszyklus).\
  - Dateisystem (optionaler Persistenzkanal für GPX).\
  - Optionaler externer Dienst (What3Words über HTTPS).

  *Systemgrenze:*\
  Keine direkte Hardwareanbindung (GNSS/Sensorfusion im Host), keine Kartenrendering- oder Routingfunktion.
]

#table(
  columns: (2.8cm, 2.9cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Externe Schnittstelle*], [*Richtung*], [*Zweck*],
  [Host-API], [eingehend], [Steuerung von Session, Übergabe von Positions-/Kursdaten],
  [Listener/Result-API], [ausgehend], [Snapshots, Statuswechsel, Fehlerereignisse, GPX-Rückgabe],
  [Dateisystem], [ausgehend, optional], [Persistierung von GPX nur bei expliziter Konfiguration],
  [W3W-HTTP], [ausgehend, optional], [Reverse-Lookup mit Cache],
)

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Context.svg"),
  caption: [Systemsicht als UML-Kontextdiagramm: Systemgrenze und externe Kommunikationspartner.],
)

#pagebreak()

== Statische Sicht (Logische Sicht)

=== Subsystem-Spezifikation

#table(
  columns: (2.7cm, 1fr, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Subsystem*], [*Kernverantwortung*], [*Bereitgestellte Dienste*],
  [API/Application Service], [Orchestrierung der Use Cases, Session-Zustand, Fehlerabbildung], [Session starten/beenden/abbrechen, Snapshot liefern],
  [Domain Core], [Fachregeln ohne I/O], [Azimut/Distanz, Sampling, Validierung, Segmentierung, Optimierungssteuerung],
  [Ports (SPI)], [Abstraktion technischer Abhängigkeiten], [Verträge für GPX, Zeit, Dateisystem, Logging, W3W],
  [Infrastruktur/Adapter], [Technische Realisierung], [XML-Serialisierung, Datei-I/O, HTTP-Client, Clock, Logging],
)

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
  Zuständig für XML, HTTP, Dateisystem und Bibliotheksintegration.
]

== Kommunikationsregeln zwischen Schichten

#table(
  columns: (3.0cm, 3.0cm, 2.0cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Von*], [*Nach*], [*Erlaubt?*], [*Regel / Begründung*],
  [Host-System], [API], [Ja], [Integration ausschließlich über öffentliche Java-API],
  [Host-System], [Domain], [Nein], [Kapselung der Fachlogik hinter API-Fassade],
  [API], [Domain], [Ja], [Use-Case-Orchestrierung ohne I/O-Kopplung],
  [Domain], [Ports], [Ja], [Externe Effekte nur über abstrahierte Verträge],
  [Domain], [Infrastruktur], [Nein], [Business-Logik bleibt I/O-frei],
  [Infrastruktur], [Domain], [Nein], [Keine Rückkopplung mit fachlichen Seiteneffekten],
)

=== Paket- und Modulschnitt

#table(
  columns: (2.4cm, 3.3cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  align: (left, left, left),
  [*Modul*], [*Paketbasis*], [*Verantwortung*],
  [`bearing-api`], [`com.example.bearing.api`], [Öffentliche Fassade, DTOs, Fehlercodes],
  [`bearing-domain`], [`com.example.bearing.domain`], [Fachlogik, Policies, Zustandsmodell],
  [`bearing-spi`], [`com.example.bearing.spi`], [Technologieunabhängige Port-Schnittstellen],
  [`bearing-adapter-gpx`], [`com.example.bearing.adapter.gpx`], [GPX 1.1 Writer],
  [`bearing-adapter-w3w`], [`com.example.bearing.adapter.w3w`], [Optionaler W3W-Client + Cache],
  [`bearing-adapter-system`], [`com.example.bearing.adapter.system`], [Dateisystem, Clock, Logging],
)

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Component_Layers.svg"),
  caption: [UML-Komponentendiagramm: Schichten sowie Port-Adapter-Kopplung.],
)

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Package_Architecture.svg"),
  caption: [UML-Paketdiagramm: logische Paketabhängigkeiten und Schnittstellenrichtung.],
)

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Composite_BearingSession.svg"),
  caption: [UML-Kompositionsstrukturdiagramm: interne Struktur der zentralen Session-Komponente.],
)

#pagebreak()

== Dynamische Sicht (Ablaufsicht)

#diagramm-box("Laufzeitzusammenarbeit der Subsysteme")[
  *Szenario A: Positionsupdate*\
  Host ruft `onPositionUpdate` auf -> API validiert Vorbedingungen -> Domain verarbeitet Sampling/Filter/Berechnung -> Snapshot/Event wird bereitgestellt.

  *Szenario B: Session-Abschluss*\
  Host ruft `complete` auf -> Domain finalisiert Track -> Port fuer GPX wird angesprochen -> Infrastruktur serialisiert -> Ergebnis an Host.

  *Szenario C: Fehlerpfad*\
  Bei ungueltigen Koordinaten wird fruehzeitig validiert, semantische Exception erzeugt, Logging ausgefuehrt und kein Zustand inkonsistent fortgefuehrt.
]

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Activity_PositionUpdate.svg"),
  caption: [UML-Aktivitätsdiagramm: Ablauf der Verarbeitung eines Positionsupdates.],
)

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Sequence_Complete.svg"),
  caption: [UML-Sequenzdiagramm: regulärer Abschluss inklusive GPX-Aufbereitung.],
)

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Sequence_ValidationError.svg"),
  caption: [UML-Sequenzdiagramm: Fehlerpfad bei ungültiger Koordinate.],
)

== Physische Sicht

#diagramm-box("Physische Sicht (Deployment)")[
  Die Lösung ist als Bibliothek innerhalb eines Host-Prozesses (JVM) ausgeführt.
  Externe Kommunikation erfolgt optional über HTTPS (W3W) und optional über Dateisystemzugriffe.
  Dadurch bleibt die Komponente lokal lauffähig, testbar und ohne Netzabhängigkeit betreibbar.
]

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Deployment_Runtime.svg"),
  caption: [UML-Verteilungsdiagramm: Laufzeitknoten, Artefakte und Kommunikationspfade.],
)

#pagebreak()

== Entwurfsprinzipien und Kriterien

#table(
  columns: (3.1cm, 1fr, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Prinzip*], [*Architekturentscheidung*], [*Nutzen*],
  [Hohe Kohäsion], [Subsysteme entlang fachlicher Verantwortung statt Technik-Mischung], [Leichte Wartung, klare Zuständigkeiten],
  [Schwache Kopplung], [Abhängigkeit über Ports/SPI statt konkreten Adaptern], [Austauschbarkeit, geringere Änderungsfolgen],
  [Information Hiding], [Domain-Interna hinter API-Fassade und Value Objects verborgen], [Stabile öffentliche Verträge],
  [Separation of Concerns], [Fachlogik strikt getrennt von XML/HTTP/Datei-I/O], [Testbarkeit und Robustheit],
  [Wiederverwendung], [Gemeinsame Policies und Optimierer als austauschbare Strategien], [Weniger Redundanz, bessere Erweiterbarkeit],
)

== Methodische Dekomposition

=== Schritt 1: Subsystem-Identifikation

#table(
  columns: (2.8cm, 3.1cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Operation*], [*Dienst*], [*Ziel-Subsystem*],
  [`startSession`], [Sessionanlage + Zustandsinitialisierung], [API/Application Service],
  [`onPositionUpdate`], [Validierung + Track/Fachupdate], [Domain Core],
  [`complete`/`abort`], [Finalisierung + Exporttrigger], [API + Domain + Ports],
  [`exportGpx`], [Serialisierung + optionale Persistenz], [Ports + Infrastruktur],
  [`resolveW3w`], [Reverse-Lookup + Caching], [Ports + Infrastruktur],
)

=== Schritt 2: Dienstspezifikation (typisierte Operationen)

#table(
  columns: (4.2cm, 1fr, 2.7cm),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Signatur*], [*Vertrag (Kurzform)*], [*Fehlerfälle*],
  [`UUID startSession(SessionConfig config, GeoCoordinate target)`], [Erzeugt ACTIVE-Session; genau eine aktive Session pro Instanz], [`IllegalStateException`, `ValidationException`],
  [`void onPositionUpdate(GpsFix fix)`], [Verarbeitet gültige Fixes gemäß Policy; aktualisiert Fachzustand], [`ValidationException`, `IllegalStateException`],
  [`void onCourseUpdate(double courseDeg)`], [Optionaler Kursbezug für Abweichung], [`ValidationException`, `IllegalStateException`],
  [`BearingSnapshot currentSnapshot()`], [Liefert konsistente Momentaufnahme], [`IllegalStateException`],
  [`GpxResult complete()`], [Finalisiert Session und liefert GPX-Daten], [`IllegalStateException`, `ExportException`],
  [`GpxResult abort()`], [Bricht Session ab und liefert bis dahin erfasste GPX-Daten], [`IllegalStateException`, `ExportException`],
)

=== Schritt 3: Subsystem-Anordnung

Die Subsysteme sind als Schichten organisiert: Host -> API -> Domain -> Ports -> Adapter. Es existieren keine zyklischen Abhängigkeiten. Optionalfunktionen (W3W, Dateipersistenz) sind als Adapter austauschbar und beeinflussen die Kernlogik nicht.

== Security Engineering im Grobentwurf

#table(
  columns: (2.8cm, 1fr, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Risiko*], [*Architekturmaßnahme*], [*Ort im Entwurf*],
  [Pfadmanipulation beim Export], [Whitelisting/Validierung erlaubter Basisverzeichnisse], [API + FileSinkPort + SafeFileSink],
  [XML Injection], [Konsequentes Escaping bei GPX-Serialisierung], [GpxWriterPort + GpxXmlWriter],
  [Ausfall externer Dienste], [Timeouts, Retry-Policy begrenzt, Fallback ohne W3W], [W3wClientPort + W3wHttpClient],
  [Unkontrollierter Ressourcenverbrauch], [Punktbudget, Sampling-Intervall, Segmentierung], [Domain Core],
  [Unklare Fehlerbehandlung], [Semantische Fehlercodes und definierte Exception-Hierarchie], [API/Application Service],
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
  [Adapter], [Port-Implementierungen], [Entkopplung externer Technologien],
  [Null Object (optional)], [No-Op-Logger in Tests], [Reduktion von `null`-Zweigen],
)

== Schnittstellenübersicht (extern sichtbar)

Die Host-Anwendung interagiert ausschließlich über Java-APIs. Persistenz ist optional: GPX wird als `String` oder `byte[]` bereitgestellt; Dateischreiben bleibt eine explizite Host-Entscheidung.

#table(
  columns: (3.9cm, 2.7cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Operation*], [*Typ*], [*Semantik*],
  [`startSession(config, target)`], [Command], [Legt Session an, UUID, Zustand ACTIVE],
  [`onPositionUpdate(fix)`], [Command], [Validiert und verarbeitet Fix gemäß Sampling/Filter],
  [`onCourseUpdate(deg)`], [Command], [Optionaler Kursbezug für Kursabweichung],
  [`currentSnapshot()`], [Query], [Liefert konsistenten `BearingSnapshot`],
  [`complete()`], [Command + Result], [COMPLETED + GPX-Ergebnis],
  [`abort()`], [Command + Result], [ABORTED + GPX-Ergebnis bis Abbruchzeitpunkt],
)

== Soll-Ist-Abdeckungsmatrix (Foliensatz 07-SWT II Grobentwurf)

Die Matrix dient als kompakter Nachweis, dass die im Foliensatz geforderten Inhalte systematisch adressiert wurden und zeigt verbleibende Restarbeiten transparent auf.

#table(
  columns: (3.2cm, 2.5cm, 2cm, 1fr, 1.8cm),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Forderung laut Foliensatz*], [*Soll*], [*Ist*], [*Nachweis in dieser Doku*], [*Status*],

  [Subsystem-Spezifikation], [Zerlegung in handhabbare Einheiten], [Vorhanden], [Statische Sicht mit Schichten und Modulschnitt], [Erfüllt],
  [Schnittstellen-Spezifikation], [Dienste nach außen präzisieren], [Vorhanden], [Schnittstellenübersicht mit Operationen], [Erfüllt],

  [Systemsicht], [Systemgrenze + externe Schnittstellen], [Vorhanden], [Systemsicht + Kontextdiagramm], [Erfüllt],
  [Statische Sicht], [Komponentenstruktur + Abhängigkeiten], [Vorhanden], [Schichtendiagramm, Kommunikationsregeln, Paket-/Kompositionssicht], [Erfüllt],
  [Dynamische Sicht], [Laufzeitzusammenwirken], [Vorhanden], [Dynamische Sicht + Aktivitäts-/Sequenzdiagramme], [Erfüllt],
  [Physische Sicht], [Verteilung auf Knoten/Netze], [Vorhanden], [Physische Sicht + Verteilungsdiagramm], [Erfüllt],

  [Hohe Kohäsion], [Starker innerer Zusammenhalt], [Vorhanden], [Entwurfsprinzipien und Kriterien], [Erfüllt],
  [Schwache Kopplung], [Geringe Kopplung zwischen Modulen], [Vorhanden], [Ports/SPI und Kommunikationsregeln], [Erfüllt],
  [Modularisierung / Information Hiding / SoC], [Klare Trennung fachlich/technisch], [Vorhanden], [Domain vs. Infrastruktur + Port-Schicht], [Erfüllt],
  [Wiederverwendung], [Gemeinsamkeiten gezielt nutzen], [Vorhanden], [Strategien/Adapter/Muster], [Erfüllt],

  [Dekomposition Schritt 1], [Subsystem-Identifikation], [Vorhanden], [Methodische Dekomposition, Schritt 1], [Erfüllt],
  [Dekomposition Schritt 2], [Dienstspezifikation typisierter Operationen], [Vorhanden], [Methodische Dekomposition, Schritt 2], [Erfüllt],
  [Dekomposition Schritt 3], [Subsystem-Anordnung], [Vorhanden], [Methodische Dekomposition, Schritt 3], [Erfüllt],

  [UML-Komponentendiagramm], [Bausteine und Abhängigkeiten], [Vorhanden], [SWE_Kompass_Component_Layers], [Erfüllt],
  [UML-Paketdiagramm], [Hierarchische Organisation], [Vorhanden], [SWE_Kompass_Package_Architecture], [Erfüllt],
  [UML-Kompositionsstrukturdiagramm], [Interne Struktur zentraler Komponente], [Vorhanden], [SWE_Kompass_Composite_BearingSession], [Erfüllt],
  [UML-Verteilungsdiagramm], [Architektur zur Laufzeit], [Vorhanden], [SWE_Kompass_Deployment_Runtime], [Erfüllt],

  [Security Engineering], [Sicherheitsanforderungen im Entwurf], [Vorhanden], [Eigenes Security-Kapitel mit Risiken/Gegenmaßnahmen], [Erfüllt],
)

#diagramm-box("Kurzfazit zur Abdeckungsmatrix")[
  Der Grobentwurf deckt die Kernpunkte des Foliensatzes nun vollständig ab.\
  Fuer die Abgabepruefung empfiehlt sich, alle genannten UML-Dateien vor dem PDF-Build einmal zu rendern, damit jede referenzierte Abbildung physisch als SVG vorliegt.
]

#pagebreak()
]