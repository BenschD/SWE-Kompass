#import "lf-card.typ": lf-card
#import "lf-diagram.typ": lf-flowchart, lf-sonstiges
#import "lf-compact.typ": lf-compact
#import "requirement-catalog.typ": catalog-lf-table

#let ch-lf-spezifikationen = [

#figure(
  caption: [Funktionaler Anforderungskatalog /LF010/ … /LF250/ (lückenlos, +10).],
  kind: table,
  catalog-lf-table,
)

#pagebreak()

#lf-card(
  id: "/LF010/",
  funktion: "Session starten",
  akteur: [Host-App (Primär).],
  verweise: [/LF020/, /LF080/, /LD010/, /LD020/],
  datenzugriffe: [/LD010/, /LD020/],
  beschreibung: [Host startet eine Peilungs-Session. System prüft Ziel und Konfiguration, vergibt UUID, friert `SessionConfig` ein, wechselt zu `ACTIVE` und benachrichtigt Listener.],
  ausloeser: [Host ruft `start(SessionConfig config, GeoCoordinate target)` auf.],
  vorbedingung: [Zustand `IDLE`; valide Zielkoordinate und `SessionConfig`.],
  nach_erfolg: [UUID gesetzt; `ACTIVE`; `onSessionStarted` gefeuert.],
  nach_fehler: [/LF020/: `IllegalStateException` bei Doppelstart; /LF230/: `ValidationException` bei Koordinate.],
  standardablauf: [
    1. `start(config, target)` aufrufen.\
    2. IDLE prüfen (/LF020/).\
    3. Koordinaten validieren (/LF230/).\
    4. UUID + `startedAt`; Config einfrieren; `ACTIVE`.\
    5. Listener benachrichtigen (/LF080/).
  ],
  alternativablauf: [*2a* Doppelstart: `IllegalStateException`. *5a* Listener wirft: WARN-Log, weiter.],
  sonstiges: lf-sonstiges(
    systemgrenzen: [Kein GNSS-Hardwarezugriff; kein Netzwerk.],
    speziell: [`ClockPort`-Injection; immutable `SessionConfig`.],
    bemerkungen: [Neustart nach /LF090/.],
  ),
)

#lf-flowchart("/LF010/", [`start(config, target)`], decision: [Bereits ACTIVE?], error-label: [nein], branch-fail: [`IllegalStateException`], steps-after: ([Validierung], [UUID, ACTIVE], [Listener]))

#lf-compact("/LF020/", "Nur eine aktive Session", [Zweiter `start()` im Zustand `ACTIVE` wird mit `IllegalStateException` abgewiesen.], verweise: [/LF010/], code: "compareAndSet IDLE→ACTIVE")

#lf-card(
  id: "/LF030/",
  funktion: "Positionsupdate verarbeiten",
  akteur: [Host-App (Primär).],
  verweise: [/LF010/, /LF100/, /LF110/, /LF120/, /LF130/, /LF230/, /LF240/],
  einbindungen: [/LF100/],
  datenzugriffe: [/LD040/],
  beschreibung: [Host liefert `GpsFix`. System validiert, speichert im Rohtrack, prüft Limits und Segmente, berechnet Peilung, benachrichtigt Listener.],
  ausloeser: [`onPositionUpdate(GpsFix fix)`],
  vorbedingung: [Session `ACTIVE`; Hard-Limit noch nicht erreicht (/LF130/).],
  nach_erfolg: [Fix gespeichert; Peilung aktuell; Listener informiert.],
  nach_fehler: [/LF230/, /LF240/: `ValidationException`; /LF130/: kein weiterer Punkt.],
  standardablauf: [
    1. Fix validieren (/LF230/, /LF240/).\
    2. Segment + Budget (/LF120/, /LF110/, /LF130/).\
    3. Speichern (/LF100/).\
    4. Listener (`onPositionUpdate`, ggf. Limit-Events).
  ],
  alternativablauf: [Ungültiger Fix: Exception, kein Speichern. Hard-Limit: `onHardLimitReached`.],
  sonstiges: lf-sonstiges(speziell: [/LL020/ Azimut-Genauigkeit.], bemerkungen: [Host steuert Frequenz.]),
)

#lf-flowchart("/LF030/", [Fix validieren], decision: [Gültig?], error-label: [nein], branch-fail: [Exception], steps-after: ([Segment + Budget], [Speichern], [Listener]))

#lf-compact("/LF040/", "Kurs aktualisieren", [Host setzt geografischen Kurs 0-360° via `onCourseUpdate`; Wert fließt in /LF050/ ein.], verweise: [/LF030/, /LF050/], code: "onCourseUpdate")

#lf-card(
  id: "/LF050/",
  funktion: "Peilungswerte lesen",
  akteur: [Host-App (Primär).],
  verweise: [/LF030/, /LF040/],
  datenzugriffe: [/LD050/],
  beschreibung: [Host fragt `currentSnapshot()` ab; System liefert Azimut, Distanz, Ordinal; optional Kursabweichung.],
  ausloeser: [`currentSnapshot()`],
  vorbedingung: [Session `ACTIVE`; mindestens ein Fix nach /LF030/.],
  nach_erfolg: [`BearingSnapshot` zurück; Zustand unverändert.],
  nach_fehler: [Kein Fix: `IllegalStateException`. Nicht ACTIVE: `IllegalStateException`.],
  standardablauf: [1. `currentSnapshot()` 2. Snapshot aus letztem Fix + Ziel ableiten 3. Rückgabe],
  alternativablauf: [Kein Fix → `IllegalStateException`.],
  sonstiges: lf-sonstiges(speziell: [Immutables Value Object; 8 Himmelsrichtungen.]),
)

#lf-flowchart("/LF050/", [`currentSnapshot()`], decision: [Fix vorhanden?], error-label: [nein], branch-fail: [`IllegalStateException`], steps-after: ([Snapshot], [Rückgabe]))

#lf-card(
  id: "/LF060/",
  funktion: "Session regulär beenden",
  akteur: [Host-App (Primär).],
  verweise: [/LF140/, /LF150/, /LF160/],
  datenzugriffe: [/LD060/],
  beschreibung: [`complete()` → `COMPLETED`, GPX-Export (/LF140/), optional Datei (/LF150/), `GpxResult` (/LF160/).],
  ausloeser: [`complete()`],
  vorbedingung: [Session `ACTIVE`.],
  nach_erfolg: [`COMPLETED`; `GpxResult`; `onSessionCompleted`.],
  nach_fehler: [Nicht ACTIVE: `IllegalStateException`. Path Traversal: /LF250/.],
  standardablauf: [1. `complete()` 2. Segment schließen 3. GPX (/LF140/) 4. optional persist (/LF150/) 5. Listener],
  alternativablauf: [IO optional; GPX-Bytes dennoch in `GpxResult`.],
  sonstiges: lf-sonstiges(bemerkungen: [Danach /LF090/ für Neustart.]),
)

#lf-card(
  id: "/LF070/",
  funktion: "Session abbrechen",
  akteur: [Host-App (Primär).],
  verweise: [/LF140/, /LF160/],
  beschreibung: [`abort()` → `ABORTED`; GPX mit bisherigem Track; Datei nur bei `persistOnAbort`.],
  ausloeser: [`abort()`],
  vorbedingung: [Session `ACTIVE`.],
  nach_erfolg: [`ABORTED`; `GpxResult`; `onSessionAborted`.],
  nach_fehler: [Nicht ACTIVE: `IllegalStateException`.],
  standardablauf: [1. `abort()` 2. GPX erzeugen 3. optional Datei 4. Listener],
  alternativablauf: [Leerer Track: valides GPX mit leerem `trk`.],
  sonstiges: lf-sonstiges(bemerkungen: [Track wird nicht verworfen.]),
)

#lf-card(
  id: "/LF080/",
  funktion: "Listener-Fehler isolieren",
  akteur: [Host-App (fehlerhafter Listener).],
  verweise: [/LF010/, /LF030/, /LF060/, /LF070/],
  beschreibung: [Wirft ein `BearingListener` bei Callback, wird die Exception geloggt; übrige Listener werden weiter aufgerufen.],
  ausloeser: [Listener-Callback während Session-Events.],
  vorbedingung: [Listener registriert via `addListener`.],
  nach_erfolg: [Session konsistent; restliche Listener benachrichtigt.],
  nach_fehler: [-],
  standardablauf: [1. Callback 2. Exception fangen 3. WARN-Log mit sessionId 4. nächster Listener],
  alternativablauf: [-],
  sonstiges: lf-sonstiges(speziell: [/LL060/ Logging.]),
)

#lf-card(
  id: "/LF090/",
  funktion: "Session zurücksetzen",
  akteur: [Host-App (Primär).],
  verweise: [/LF010/, /LF060/, /LF070/],
  beschreibung: [Nach `COMPLETED`/`ABORTED` setzt `reset()` auf `IDLE`; erneuter /LF010/ ohne JVM-Neustart.],
  ausloeser: [`reset()`],
  vorbedingung: [Zustand `COMPLETED` oder `ABORTED`.],
  nach_erfolg: [`IDLE`; Felder gelöscht; /LF010/ wieder möglich.],
  nach_fehler: [Bei `ACTIVE`: `IllegalStateException`.],
  standardablauf: [1. `reset()` 2. Zustand prüfen 3. Felder löschen 4. `IDLE`],
  alternativablauf: [ACTIVE → Exception.],
  sonstiges: lf-sonstiges(bemerkungen: [/TC130/ Verifikation.]),
)

#pagebreak()

#lf-compact("/LF100/", "GPS-Rohtrack speichern", [Jeder validierte Fix wird im Rohspeicher abgelegt (/LD030/).], verweise: [/LF030/], code: "TrackAggregator.accept")
#lf-compact("/LF110/", "Soft-Limit warnen", [Bei Erreichen des Soft-Limits einmalig `onSoftLimitWarn`; Aufzeichnung läuft weiter.], verweise: [/LF030/], code: "onSoftLimitWarn")
#lf-compact("/LF120/", "Segment bei Zeitlücke", [Zeitlücke > `segmentGapThreshold` eröffnet neues `trkseg` (/TC150/).], verweise: [/LF030/, /LF100/], code: "TrackAggregator")
#lf-compact("/LF130/", "Hard-Limit Stop", [Bei Hard-Limit stoppt die Aufzeichnung; `onHardLimitReached`.], verweise: [/LF030/, /LF100/], code: "hardLimitPoints")

#lf-card(
  id: "/LF140/",
  funktion: "GPX 1.1 exportieren",
  akteur: [System (intern via /LF060/, /LF070/).],
  verweise: [/LF170/-/LF200/, /LF160/, /LL050/],
  beschreibung: [Rohtrack-Snapshot → optionale Optimierer-Kette → GPX 1.1 XML mit Namespace und UTC-Zeiten.],
  ausloeser: [`complete()` oder `abort()`.],
  vorbedingung: [Session beendet oder Export intern angestoßen.],
  nach_erfolg: [`GpxDocument` serialisiert; /LF160/ erfüllt.],
  nach_fehler: [Serialisierungsfehler: `RuntimeException` aus `GpxXmlWriter`.],
  standardablauf: [
    1. Immutable Track-Snapshot.\
    2. Optimierer (/LF170/-/LF200/) falls konfiguriert.\
    3. `GpxExportMapper` + `GpxXmlWriter` (/LL050/ Escaping).
  ],
  alternativablauf: [Keine Optimierer: Rohpunkte exportieren.],
  sonstiges: lf-sonstiges(speziell: [GPX 1.1 Namespace; UTF-8 ohne BOM.]),
)

#lf-compact("/LF150/", "GPX atomar persistieren", [Optional atomares Schreiben via `SafeFileSink` bei konfiguriertem Pfad.], verweise: [/LF060/, /LF070/, /LF250/], code: "SafeFileSink.writeAtomically")
#lf-compact("/LF160/", "GPX als UTF-8-Bytes", [`GpxResult` liefert `utf8Bytes()` und `asUtf8String()` ohne BOM.], verweise: [/LF140/], code: "GpxResult")

#lf-compact("/LF170/", "Optimierung n-ter Punkt", [Strategy: jeder n-te Punkt; Start/Ende erhalten.], verweise: [/LF140/], code: "NthPointOptimizer")
#lf-compact("/LF180/", "Optimierung Mindestabstand", [Punkte mit Mindestabstand in Metern.], verweise: [/LF140/], code: "MinDistanceOptimizer")
#lf-compact("/LF190/", "Optimierung Geraden-Heuristik", [Kollinearität reduziert Zwischenpunkte.], verweise: [/LF140/], code: "LineCollinearityOptimizer")
#lf-compact("/LF200/", "Optimierung Douglas-Peucker", [Douglas-Peucker mit metrischem Epsilon.], verweise: [/LF140/], code: "DouglasPeuckerOptimizer")

#lf-compact("/LF210/", "What3Words auflösen", [Reverse-Lookup via injiziertem `W3wClientPort`; Fallback bei Offline (`NoopW3wClient`).], verweise: [/LF220/], code: "resolveWhat3Words")
#lf-compact("/LF220/", "What3Words cachen", [LRU-Cache mit TTL im `W3wHttpClient`.], verweise: [/LF210/], code: "W3wHttpClient")

#lf-compact("/LF230/", "Koordinaten validieren", [WGS84-Bereich; `ValidationException(COORD_RANGE)`.], verweise: [/LF030/], code: "GeoCoordinate")
#lf-compact("/LF240/", "Zeitstempel validieren", [Zukunft >1s oder älter als `maxFixAge`; `TIMESTAMP_INVALID`.], verweise: [/LF030/], code: "validate(fix)")
#lf-compact("/LF250/", "Path-Traversal verhindern", [Pfade nur unter `allowedBaseDir`; sonst `SecurityException`.], verweise: [/LF150/], code: "SafeFileSink")

]
