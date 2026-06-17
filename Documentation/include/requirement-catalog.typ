// Master-Katalog: Single Source of Truth für LF / LL / LD / TC (+10, lückenlos)

#let catalog-lf-range = [/LF010/ … /LF250/]
#let catalog-ll-range = [/LL010/ … /LL080/]
#let catalog-ld-range = [/LD010/ … /LD060/]
#let catalog-tc-range = [/TC010/ … /TC150/]

#let catalog-lf-table = table(
  columns: (2.2cm, 1fr, 5.5cm),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  table.header([*ID*], [*Funktion*], [*Code-Anker*]),
  [/LF010/], [Session starten], [`DefaultBearingSession.start`],
  [/LF020/], [Nur eine aktive Session], [`start` (IDLE/CAS)],
  [/LF030/], [Positionsupdate verarbeiten], [`onPositionUpdate`],
  [/LF040/], [Kurs aktualisieren], [`onCourseUpdate`],
  [/LF050/], [Peilungswerte lesen], [`currentSnapshot`],
  [/LF060/], [Session regulär beenden], [`complete`],
  [/LF070/], [Session abbrechen], [`abort`],
  [/LF080/], [Listener-Fehler isolieren], [`BearingListener` / `fire()`],
  [/LF090/], [Session zurücksetzen], [`reset`],
  [/LF100/], [GPS-Rohtrack speichern], [`TrackAggregator.accept`],
  [/LF110/], [Soft-Limit warnen], [`onSoftLimitWarn`],
  [/LF120/], [Segment bei Zeitlücke], [`TrackAggregator` Split],
  [/LF130/], [Hard-Limit Stop], [`hardLimitPoints` (STOP)],
  [/LF140/], [GPX 1.1 exportieren], [`DefaultBearingSession.complete`, `GpxExportMapper`, `GpxXmlWriter`, `OptimizationPipeline`],
  [/LF150/], [GPX atomar persistieren], [`SafeFileSink`],
  [/LF160/], [GPX als UTF-8-Bytes], [`GpxResult`],
  [/LF170/], [Optimierung n-ter Punkt], [`NthPointOptimizer`],
  [/LF180/], [Optimierung Mindestabstand], [`MinDistanceOptimizer`],
  [/LF190/], [Optimierung Geraden-Heuristik], [`LineCollinearityOptimizer`],
  [/LF200/], [Optimierung Douglas-Peucker], [`DouglasPeuckerOptimizer`],
  [/LF210/], [What3Words auflösen], [`W3wHttpClient` / \ `NoopW3wClient`],
  [/LF220/], [What3Words cachen], [`W3wHttpClient` \ LRU/TTL],
  [/LF230/], [Koordinaten validieren (GpsFix)], [`ValidationException COORD_RANGE`],
  [/LF240/], [Zeitstempel validieren], [`ValidationException TIMESTAMP_INVALID`],
  [/LF250/], [Path-Traversal verhindern], [`SafeFileSink` \ `SecurityException`],
)

#let catalog-ll-table = table(
  columns: (2.2cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  table.header([*ID*], [*Nicht-funktionale Anforderung*]),
  [/LL010/], [Eingabevalidierung - kritische Fehlerpfade getestet],
  [/LL020/], [Azimut ±1° vs. Haversine-Referenz],
  [/LL030/], [Portabilität Java 11+, keine UI-Frameworks],
  [/LL040/], [`mvn test` reproduzierbar auf frischem Clone],
  [/LL050/], [XML-Escaping in GPX-Ausgabe],
  [/LL060/], [Strukturiertes Logging mit sessionId in der Log-Nachricht],
  [/LL070/], [Test-Determinismus via `ClockPort`-Mock],
  [/LL080/], [Öffentliche API mit Javadoc (ohne Build-Gate)],
)

#let catalog-ld-table = table(
  columns: (2.2cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  table.header([*ID*], [*Produktdaten*]),
  [/LD010/], [Peilungs-Session],
  [/LD020/], [SessionConfig],
  [/LD030/], [GPS-Track / Segment],
  [/LD040/], [GpsPoint / GpsFix],
  [/LD050/], [BearingSnapshot],
  [/LD060/], [GpxResult],
)

#let catalog-tc-table = table(
  columns: (2cm, 2.5cm, 1fr, 5.5cm),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  table.header([*TC*], [*LF / LL*], [*Beschreibung*], [*JUnit*]),
  [/TC010/], [/LF010/, /LF020/], [Start + Doppelstart], [`tc010_doubleStartThrows`],
  [/TC020/], [/LF030/, /LF230/], [Ungültige Breite], [`tc020_invalidLatThrows`],
  [/TC030/], [/LF030/, /LF240/], [Zeitstempel Zukunft], [`tc030_futureTimestampThrows`],
  [/TC040/], [/LF060/, /LF030/], [Update nach complete], [`tc040_updateAfterCompleteThrows`],
  [/TC050/], [/LF050/], [Snapshot ohne Fix], [`tc050_snapshotWithoutFixThrows`],
  [/TC060/], [/LF110/], [Soft-Limit], [`tc060_softLimitWarns`],
  [/TC070/], [/LF130/], [Hard-Limit Stop], [`tc070_hardLimitStopsRecording`],
  [/TC080/], [/LF070/], [abort liefert GPX], [`tc080_abortProducesGpx`],
  [/TC090/], [/LF250/], [Path Traversal], [`tc090_pathTraversalSecurity`],
  [/TC100/], [/LF140/], [GPX-Namespace 1.1], [`tc100_gpxNamespace`],
  [/TC110/], [/LF170/], [n-Optimizer], [`tc110_nthOptimizer`],
  [/TC120/], [/LF080/], [Listener isoliert], [`tc120_listenerExceptionIsolated`],
  [/TC130/], [/LF090/], [reset + Neustart], [`tc130_resetAllowsRestart`],
  [/TC140/], [/LL020/], [Azimut-Referenz], [`tc140_azimuthReference`],
  [/TC150/], [/LF120/], [Segment bei Zeitlücke], [`tc150_segmentSplit`],
)

#let catalog-api-table = table(
  columns: (5.5cm, 1fr, 1.8cm),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  table.header([*Signatur*], [*Beschreibung*], [*LF*]),
  [`void start(SessionConfig, GeoCoordinate)`], [Session starten], [/LF010/],
  [`void onPositionUpdate(GpsFix)`], [GPS-Fix verarbeiten], [/LF030/],
  [`void onCourseUpdate(double)`], [Kurs 0-360°], [/LF040/],
  [`BearingSnapshot currentSnapshot()`], [Peilungsschnappschuss], [/LF050/],
  [`GpxResult complete()`], [Regulär beenden], [/LF060/],
  [`GpxResult abort()`], [Abbrechen], [/LF070/],
  [`void reset()`], [Auf IDLE zurücksetzen], [/LF090/],
  [`Optional<String> resolveWhat3Words(lat, lon)`], [W3W optional], [/LF210/],
  [`void addListener(BearingListener)`], [Listener (`DefaultBearingSession`)], [-],
)
