#import "macros.typ": diagramm-box

#let ch-spezifikation-kapitel = [
#set par(justify: true)

== Einleitung und allgemeine Beschreibung

Dieses Kapitel bildet das *Pflichtenheft* im Sinne einer implementierungsnahen Systemspezifikation. Es präzisiert die in der Anforderungsanalyse geforderten Eigenschaften durch *Use Cases*, *Aktivitäts- und Sequenzdiagramme*, ein *Domänenmodell* (OOA) sowie einen *technischen Feinentwurf* (OOD). Traceability zu `/LF…/`, `/LL…/`, `/LD…/` wird durchgängig hergestellt.

Das System „Java-Peilungskomponente“ ist eine Bibliothek. Akteure sind die *Host-Anwendung* (primär) und *externe Dienste* (sekundär, optional What3Words). Schnittstellen sind Java-Methoden, Ereignislistener und GPX-Strings.

*Randbedingungen:* Java 11+, Maven-Build, keine UI-Abhängigkeiten, deterministische Tests durch `Clock`-Injection.

== Stakeholder und Einflussmatrix

#table(
  columns: (2.4cm, 1fr, 2.2cm),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Rolle*], [*Erwartung*], [*Einfluss*],
  [Dozent/Prüfer], [Nachweis Vorlesungsinhalte, lauffähiger Code, formal saubere Doku], [hoch],
  [Studententeam], [Wartbare Architektur, gute Testbarkeit], [mittel],
  [Host-Entwicklerin], [stabile API, klare Fehlersemantik], [hoch],
  [Endnutzerin (indirekt)], [zuverlässige Peilungswerte], [mittel],
  [Betrieb], [Logging, keine stillen Fehler], [niedrig–mittel],
)

#pagebreak()

== Systemkontext (Kontextdiagramm verbal)

#diagramm-box("Kontext (0-Ebene)")[
  *Internes System:* Java-Peilungskomponente.

  *Schnittstellen nach außen:*\
  - *Nach innen (steuernd):* Positions- und Kursdaten, Konfiguration, Steuerbefehle (Start/Abort/Complete).\
  - *Nach außen (beobachtend):* Listener-Events, GPX-Exportobjekte, Logs.\
  - *Optional:* HTTPS zu What3Words-API.

  *Annahme:* Der Host beschafft GNSS-Fixes und reicht sie weiter; die Bibliothek besitzt keinen Sensorstack.
]

#figure(
  image("../plantuml/out/SWE_Kompass_Context.svg", width: 100%),
  caption: [UML-Kontextdiagramm (PlantUML): Systemgrenze und externe Schnittstellen.],
)

#pagebreak()

== Funktionale Spezifikation

=== Use Cases (Überblick)

#table(
  columns: (1.6cm, 2.8cm, 1fr, 2.4cm),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 5pt,
  [*ID*], [*Name*], [*Kurzbeschreibung*], [*Lastenheft-Verweis (LF)*],
  [UC-01], [Session starten], [Ziel setzen, Konfiguration validieren, ACTIVE], [/LF010/, /LF400/],
  [UC-02], [Positionsupdate], [Validieren, Track aktualisieren, Snapshot ableitbar], [/LF030/, /LF100/],
  [UC-03], [Peilungswerte lesen], [Azimut, Distanz, Ordinal, optional Fehler], [/LF050/],
  [UC-04], [Regulär beenden], [COMPLETED, GPX erzeugen], [/LF060/],
  [UC-05], [Abbrechen], [ABORTED, GPX-Daten ohne Pflichtdatei], [/LF070/, /LF230/],
  [UC-06], [Optimieren + exportieren], [Strategiewahl, Serialisierung], [/LF200/-/LF270/, /LF490/],
  [UC-07], [W3W auflösen], [Optional, Cache], [/LF280/, /LF290/],
)

#figure(
  image("../plantuml/out/SWE_Kompass_UseCases.svg", width: 100%),
  caption: [UML Use-Case-Diagramm (PlantUML): Akteure und zentrale Use Cases der Java-Peilungskomponente.],
)

==== UC-01 Session starten (Spezifikation)

*Primärer Akteur:* Host-App.\
*Vorbedingungen:* Instanz im Leerlauf; Konfiguration konsistent.\
*Nachbedingungen Erfolg:* Session existiert mit UUID; Zustand ACTIVE; Konfiguration eingefroren.\
*Nachbedingungen Fehlschlag:* keine Session; semantische Exception mit Fehlercode.

*Hauptablauf:*

+ Host übergibt `SessionConfig` und `GeoCoordinate target`.
+ System validiert Wertebereiche (`/LF300/`, `/LF400/`).
+ System erzeugt UUID, setzt `startedAt = clock.instant()`, registriert Listener-Basis.
+ System sendet `onSessionStarted` (`/LF080/`).

*Sonderfälle:* Doppelstart ohne Finalisierung → `/LF020/`.

==== UC-05 Abbruch (Spezifikation)

*Auslöser:* Host bricht Feldaktion ab.\
*Hauptablauf:*

+ `abort()` wird aufgerufen.
+ System setzt ABORTED, `endedAt`.
+ System materialisiert GPX-Datenstruktur im Speicher.
+ Wenn `persistOnAbort = true`, atomares Schreiben (`/LF220/`), sonst nur Rückgabeobjekt (`/LF230/`).
+ Listener `onSessionAborted` mit Statistik (`/LF500/`).

#pagebreak()

=== Aktivitätsdiagramme (textuelle UML-Abbilder)

Die folgenden Aktivitätsbeschreibungen ergänzen die UML-Aktivitätsdiagramme (PlantUML, siehe Abbildungen am Ende dieses Abschnitts) um narrative Details, Entscheidungslogik und Verweise auf `/LF…/`-Anforderungen.

#diagramm-box("Aktivität: Positionsupdate (`onPositionUpdate`)")[
  *Startknoten* → *Eingangsparameter prüfen* (nicht `null`, Lat/Lon in WGS84, Zeit plausibel `/LF310/`).

  *Entscheidung:* ungültig? → *Exception werfen* (`/LF090/`, `/LF300/`) → *Endknoten (Fehler)*.

  *Aktion:* *Sampling-Gate* - wenn die Zeit seit dem letzten gespeicherten Punkt *kleiner als* `samplingIntervalMs` ist, dann *Join ohne Speichern* → *Peilung trotzdem aktualisieren?*\
  - Policy: Snapshot darf auch bei verworfenem Trackpunkt neu berechnet werden, wenn letzter Fix gültig bleibt (konfigurierbar dokumentieren).

  *Entscheidung:* HDOP *größer als* Schwelle? → gemäß Konfiguration verwerfen/markieren (`/LF130/`).

  *Entscheidung:* Geschwindigkeitssprung? → verwerfen/protokollieren (`/LF140/`).

  *Aktion:* *Duplikatfilter* (`/LF160/`).

  *Aktion:* *Segmentierung prüfen* - große Zeitlücke → neues `trkseg` (`/LF170/`).

  *Aktion:* *Punktbudget prüfen* - Soft-Limit → WARN-Event; Hard-Limit → kontrollierter Stopp (`/LF180/`).

  *Aktion:* *Haversine + Azimut* berechnen, optional Kursabweichung (`/LF030/`, `/LF040/`, `/LF050/`).

  *Aktion:* *Listener feuern* (`/LF080/`).

  *Endknoten (Erfolg)*.
]

#diagramm-box("Aktivität: GPX-Export mit Optimierungspipeline")[
  *Start* → *Rohtrack klonen/immutabel halten*.

  *Fork (sequentiell dokumentiert):* Strategie n-ter Punkt (`/LF240/`) → Strategie Mindestabstand (`/LF250/`) → Geraden-Heuristik (`/LF260/`) → optional Douglas-Peucker (`/LF270/`).

  *Merge* → *Metadaten anreichern* (`/LF210/`) → *XML erzeugen + escapen* (`/LF200/`, `/LL130/`) → *String/Bytes* (`/LF230/`).

  *Ende*.
]

Die textuellen Aktivitätsbeschreibungen oben werden durch die folgenden UML-Aktivitätsdiagramme (PlantUML) ergänzt.

#figure(
  image("../plantuml/out/SWE_Kompass_Activity_PositionUpdate.svg", width: 100%),
  caption: [UML-Aktivitätsdiagramm: Ablauf `onPositionUpdate` inkl. Sampling und Qualitätsprüfungen.],
)

#figure(
  image("../plantuml/out/SWE_Kompass_Activity_GpxExport.svg", width: 100%),
  caption: [UML-Aktivitätsdiagramm: GPX-Export mit sequentieller Optimierungskette.],
)

#pagebreak()

=== Sequenzdiagramme (Algorithmuspfade)

Die textuellen Sequenzen werden durch die nachfolgenden UML-Sequenzdiagramme (PlantUML) visualisiert.

#diagramm-box("Sequenz: `complete()` bis GPX-String")[
  `Host` → `BearingSession`: `complete()`\
  `BearingSession` → `TrackRepository`: `immutableView()`\
  `BearingSession` → `OptimizationPipeline`: `apply(config.strategies)`\
  `OptimizationPipeline` → `TrackOptimizer`: `optimize(points)`\
  `BearingSession` → `GpxSerializer`: `toDocument(track, metadata)`\
  `GpxSerializer` → `XmlEscaper`: `escape(textFields)`\
  `GpxSerializer` → `Host`: `GpxResult(bytes, stats)`\
  *Hinweis:* Reihenfolge der Optimierer ist konfigurationsabhängig; Sequenzdiagramm im Anhang kann verfeinert werden.
]

#diagramm-box("Sequenz: Fehlerpfad ungültige Koordinate")[
  `Host` → `BearingSession`: `onPositionUpdate(fix)`\
  `BearingSession` → `Validator`: `validate(fix)`\
  `Validator` → `BearingSession`: `throws ValidationException(errorCode=COORD_RANGE)`\
  `BearingSession` → `Logger`: `warn(sessionId, code)`\
  `BearingSession` → `Host`: *propagate*
]

#figure(
  image("../plantuml/out/SWE_Kompass_Sequence_Complete.svg", width: 100%),
  caption: [UML-Sequenzdiagramm: regulärer Abschluss `complete()` bis GPX-Ergebnis.],
)

#figure(
  image("../plantuml/out/SWE_Kompass_Sequence_ValidationError.svg", width: 100%),
  caption: [UML-Sequenzdiagramm: Fehlerpfad bei ungültiger Koordinate / Validierung.],
)

#pagebreak()

=== Objektorientierte Analyse (OOA) - Domänenmodell

Die OOA fokussiert *fachliche* Konzepte ohne technische Middleware. Assoziationen sind semantisch, Multiplizitäten pragmatisch.

#table(
  columns: (3cm, 1fr, 2cm),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Konzept*], [*Beschreibung*], [*Multiplizität*],
  [`Peilung`], [fachlicher Vorgang vom Start bis Complete/Abort], [1 pro Session],
  [`Zielpunkt`], [Geo-Koordinate], [1],
  [`Standortfolge`], [Zeitlich geordnete Fixes], [0..\*],
  [`Peilungsgrößen`], [abgeleitete Werte], [0..1 vor erstem Fix],
  [`Track`], [Sammlung von Segmenten], [0..1],
  [`Export`], [GPX-Dokument als Artefakt], [0..1 nach Abschluss],
)

*Assoziationen:* Peilung hat genau einen Zielpunkt und genau einen Track; der Track enthält beliebig viele Trackpunkte; die Peilung kann optional einen Export (GPX) erzeugen; Standortfolge 0..\*.

#figure(
  image("../plantuml/out/SWE_Kompass_OOA_Domain.svg", width: 100%),
  caption: [UML-Klassendiagramm (OOA): fachliches Domänenmodell ohne technische Infrastruktur.],
)

#pagebreak()

=== Technischer Feinentwurf (OOD) - Klassen (Auszug)

Die folgende Tabelle ersetzt ein grafisches Klassendiagramm in kompakter, aber implementierungsnaher Form.

#table(
  columns: (3.2cm, 1.8cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 5pt,
  [*Klasse / Interface*], [*Stereotyp*], [*Kernverantwortung*],
  [`BearingSession`], [Entity/Controller], [Zustandsautomat ACTIVE/COMPLETED/ABORTED],
  [`SessionConfig`], [Value Object], [immutable Konfiguration],
  [`GeoCoordinate`], [Value Object], [WGS84 lat/lon validiert],
  [`GpsFix`], [Value Object], [Zeit + Position + optional HDOP/Speed],
  [`BearingCalculator`], [Domain Service], [Haversine, Azimut, Ordinal],
  [`TrackAggregator`], [Domain Service], [Sampling, Filter, Segmente],
  [`GpxSerializer`], [Infrastructure], [GPX 1.1, Escaping],
  [`TrackOptimizer`], [Interface], [Optimierungsstrategie],
  [`W3wClient`], [Interface], [Reverse-Lookup],
  [`ClockProvider`], [Interface], [Testbarkeit],
)

#figure(
  image("../plantuml/out/SWE_Kompass_OOD_Design.svg", width: 100%),
  caption: [UML-Klassendiagramm (OOD): zentrale Entwurfsklassen und Schnittstellen der Implementierung.],
)

#pagebreak()

=== Zustandsdiagramm (Session)

Zustände: `IDLE` → `ACTIVE` (start) → `COMPLETED` (complete) oder `ABORTED` (abort).\
Übergänge aus `COMPLETED`/`ABORTED` zurück zu `IDLE` durch explizite `reset()`-Operation (Anforderung `/LL160/` Wiederanlauf).

*Invariante ACTIVE:* Positionsupdates zulässig; Konfiguration fix.\
*Invariante COMPLETED/ABORTED:* keine weiteren Updates (`/LF060/`, `/LF070/`).

#figure(
  image("../plantuml/out/SWE_Kompass_State_Session.svg", width: 100%),
  caption: [UML-Zustandsdiagramm: Lebenszyklus einer `BearingSession` (vereinfacht).],
)

#pagebreak()

=== Komponenten- / Schichtensicht (Deployment-Logik)

Die logische Schichtung aus dem Grobentwurf wird hier als UML-Komponenten-/Paketdiagramm abgebildet.

#figure(
  image("../plantuml/out/SWE_Kompass_Component_Layers.svg", width: 100%),
  caption: [UML-Komponentendiagramm: API-, Domain- und Infrastrukturpakete.],
)

#pagebreak()

=== Einzelanforderungen (SOPHIST-Schablonen - Auswahl)

Die vollständige Menge ist tabellarisch im Lastenheft. Hier werden exemplarisch drei Anforderungen in der *SOPHIST-Dreierregel* (Bedingung - Subjekt - Predicate) nachpräzisiert:

- * /LF050/ Peilungsinformationen abfragen:*\
  *Wenn* eine aktive Session existiert und mindestens ein gültiger Fix vorliegt, *soll* das System *auf Anfrage* einen `BearingSnapshot` liefern, der geografischen Azimut, Distanz und Ordinalrichtung enthält.

- * /LF230/ Export als String oder Bytes:*\
  *Wenn* eine Session beendet oder abgebrochen wurde, *soll* das System GPX-Daten *ohne* zwingendes Dateisystem bereitstellen.

- * /LF320/ Pfadvalidierung:*\
  *Wenn* ein Ausgabepfad außerhalb des erlaubten Basisverzeichnisses liegt, *soll* das System eine `SecurityException` auslösen.

#pagebreak()

== Datenmodellierung und technischer Feinentwurf

Die persistenten/transienten Daten sind in `/LD100/`-`/LD190/` beschrieben. ER-Diagramm: verzichtet auf relationale Tabellen, da keine DB-Pflicht besteht; stattdessen *Kompositionsgraph*: `Session` enthält `Track`, `Track` enthält `TrackSegment`, Segment enthält `GpsPoint`.

=== Klassendiagramm (struktureller Feinentwurf)

Neben der tabellarischen OOD-Zusammenfassung liegen die *grafischen* Klassendiagramme (OOA und OOD) als PlantUML-Quellen unter `Vorschrieb/plantuml/` und die gerenderten SVG-Dateien unter `Vorschrieb/plantuml/out/`. Die Abbildungen sind in den Abschnitten Objektorientierte Analyse bzw. Technischer Feinentwurf eingebunden.

#pagebreak()

== Nichtfunktionale Spezifikation

=== Qualitätsanforderungen nach ISO/IEC 25010

Die Gewichtung ist im Lastenheft-Kapitel tabellarisch dokumentiert. Für die Spezifikation wird ergänzend festgelegt, dass *Sicherheit* und *Wartbarkeit* über Checkstyle/Javadoc abgesichert werden (`/LL100/`), *Performance* über Benchmark-Tests (`/LL030/`, `/LL040/`), *Zuverlässigkeit* über Exception-Hierarchie und Wiederanlauf (`/LF090/`, `/LL160/`).

=== Mengengerüst und Sicherheitsanforderungen

#table(
  columns: (3cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Größe*], [*Annahme / Grenze*],
  [Max. Punkte im Speicher], [10.000 (Richtwert `/LL040/`, `/LL050/`)],
  [GPX-Exportdauer], [Ziel: unter 2 s für 10.000 Punkte auf Referenz-Laptop],
  [Peilungszyklus], [Worst-Case ohne GC unter 100 ms, typisch deutlich unter 1 ms],
  [XML-Größe], [kein hartes Limit; Host kann Hard-Limit erzwingen],
  [Dateipfad], [muss innerhalb konfigurierbaren Basisdirs liegen],
)

*Sicherheit:* keine XXE in eigener Erzeugung (`/LL130/`), Pfadtraversal-Schutz (`/LF320/`), keine `sun.*` APIs (`/LF440/`).

#pagebreak()

== Angestrebte Eigenschaften & Qualitätscheck

Vor Abgabe ist folgende Checkliste zu erfüllen:

+ Alle Anforderungen von /LF010/ bis /LF500/ sind referenziert durch mindestens einen Testfall oder expliziten Review-Nachweis.
+ `mvn -q test` grün auf Windows/Linux/macOS CI-Matrix (empfohlen: GitHub Actions).
+ Javadoc vollständig öffentliche API (`/LL100/`).
+ Keine UI-Imports (`/LF430/`).
+ GPX-Beispieldatei im Anhang (optional) validiert gegen XSD 1.1.
]