// ─────────────────────────────────────────────────────────────────────────────
// Use-Case-Karte nach Vorlesungsvorlage (Bild-Stil)
// Linke Spalte: schwarz / weiße Schrift   Rechte Spalte: weiß / schwarze Schrift
// ─────────────────────────────────────────────────────────────────────────────
#import "macros.typ": diagramm-box
#import "uc-card.typ": uc-card

#let _black  = rgb("#1a1a1a")
#let _white  = rgb("#ffffff")
#let _left-w = 5.8cm
#let _tbl    = 0.45pt + rgb("#9a9a9a")
#let _ins    = 6pt

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

Dieses Kapitel bildet den normativen Kern des Dokuments. Anforderungen und Spezifikation sind hier direkt in vollständigen Use-Case-Beschreibungen nach dem Jacobson-Template integriert. Jede Use-Case-Karte enthält die vollständige fachliche Spezifikation inklusive Systemgrenzen, spezieller Anforderungen, Vor- und Nachbedingungen sowie alternative Szenarien. Ergänzt wird das Kapitel durch nicht-funktionale Anforderungen (3.2), externe Schnittstellen (3.3), Performance-Anforderungen (3.4) und das Qualitätsmodell nach ISO/IEC 25010 (3.5).

// ═════════════════════════════════════════════════════════════════════════════
== Funktionale Anforderungen – Use-Case-Spezifikationen
// ═════════════════════════════════════════════════════════════════════════════

=== Akteure

Gemäß Jacobson werden zwei Akteursklassen unterschieden. *Primärakteure* initiieren den Anwendungsfall und verfolgen ein fachliches Ziel:

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

// ─────────────────────────────────────────────────────────────────────────────
=== UC-01 – Session starten
// ─────────────────────────────────────────────────────────────────────────────

#uc-card(
  nummer: "UC-01 – Session starten",
  referenzen: "IEEE 830; Projektauftrag SWE; Klärungsgespräch Peter Bohl",
  beschreibung: [Der Host-App startet eine neue Peilungs-Session. Das System prüft Zielkoordinate und Konfiguration, vergibt eine UUID, friert die Konfiguration ein und wechselt in den Zustand ACTIVE. Alle registrierten Listener werden benachrichtigt.],
  akteure: [*Primär:* Host-App. — *Sekundär:* keine (kein externer Dienst beteiligt).],
  ausloeser: [Der Nutzer der Host-App startet eine neue Navigations- oder Peilungssitzung. Die Host-App ruft daraufhin `startSession(target, config)` auf.],
  vorbedingungen: [
    1. Die Bibliothek befindet sich im Zustand `IDLE` (keine aktive Session).\
    2. Das übergebene `GeoCoordinate`-Objekt ist nicht `null` und enthält valide WGS84-Werte (lat ∈ [−90°, +90°], lon ∈ [−180°, +180°]).\
    3. Das `SessionConfig`-Objekt ist nicht `null`.\
    4. Alle Pflichtfelder der `SessionConfig` sind mit positiven Werten belegt.
  ],
  standardablauf: [
    1. Host übergibt `GeoCoordinate target` und `SessionConfig config`.\
    2. System prüft: Ist bereits eine Session im Zustand `ACTIVE`? → nein.\
    3. System validiert alle Felder der `SessionConfig` (Budgets ≥ 0, Thresholds > 0, SoftLimit < HardLimit wenn beide > 0).\
    4. System validiert `target` (Koordinatenbereich WGS84).\
    5. System erzeugt UUID (RFC 4122, Version 4).\
    6. System setzt `startedAt = ClockPort.instant()` (testbar via Injection).\
    7. System friert `SessionConfig` ein (alle Felder sind `final`; Builder-Muster).\
    8. System wechselt Zustand zu `ACTIVE`.\
    9. System feuert Ereignis `onSessionStarted(sessionId)` an alle registrierten Listener.\
    10. System gibt `sessionId` (UUID als String) synchron an die Host-App zurück.
  ],
  alternativ: [
    *2a – Aktive Session vorhanden:* System wirft `BearingStateException(ALREADY_ACTIVE)`. Kein Zustandswechsel, keine UUID vergeben. Ende.\
    *3a – Konfiguration ungültig:* System wirft `ValidationException(INVALID_CONFIG)` mit Feldnamen. Keine Session erzeugt. Ende.\
    *4a – Zielkoordinate außerhalb WGS84:* System wirft `ValidationException(COORD_RANGE)`. Ende.\
    *9a – Listener wirft Exception:* Exception intern protokolliert (SLF4J WARN mit sessionId); restliche Listener werden weiter benachrichtigt.
  ],
  ergebnisse: [
    - `sessionId` (UUID) wurde dem Host zurückgegeben.\
    - Zustand der Bibliothek ist `ACTIVE`.\
    - Alle Listener haben `onSessionStarted` empfangen (oder Fehler wurde protokolliert).\
    - `SessionConfig` ist unveränderlich eingefroren.
  ],
  nachbedingungen: [Session existiert mit eindeutiger UUID; Zustand = `ACTIVE`; `startedAt` ist gesetzt; Konfiguration ist eingefroren und unveränderlich.],
  systemgrenzen: [Die Bibliothek hat keinen Zugriff auf GNSS-Hardware. Die Host-App ist allein verantwortlich für Sensordaten. Die Bibliothek startet keine eigenen Threads. Netzwerkzugriff findet in diesem UC nicht statt.],
  spezielle-anforderungen: [UUID: RFC 4122 Version 4. Zeitstempel: `java.time.Instant` (UTC) via `ClockPort`-Abstraktion für Testbarkeit. `SessionConfig`: Immutables Value Object, Builder-Muster. Fehlercode: maschinenlesbar (`String errorCode` in jeder Exception).],
  haeufigkeit: "Einmalig pro Navigationssitzung; typisch mehrfach täglich in der Host-App.",
  prioritaet: "Sehr hoch – Basis aller weiteren Use Cases.",
  bemerkungen: "Ein `reset()` ist nötig, um nach COMPLETED/ABORTED erneut starten zu können (UC-12). Clock-Injection ermöglicht deterministische Unit-Tests.",
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
=== UC-02 – Positionsupdate verarbeiten
// ─────────────────────────────────────────────────────────────────────────────

#uc-card(
  nummer: "UC-02 – Positionsupdate verarbeiten",
  referenzen: "UC-01 (Vorbedingung); Projektauftrag SWE; Klärungsgespräch Peter Bohl",
  beschreibung: [Die Host-App liefert einen neuen GPS-Fix. Das System validiert Koordinaten und Zeitstempel, prüft Segment- und Budgetgrenzen, speichert den Fix im Rohspeicher, berechnet Azimut und Distanz und benachrichtigt alle Listener.],
  akteure: [*Primär:* Host-App. — *Sekundär:* keine.],
  ausloeser: [Der GNSS-Stack der Host-App liefert eine neue Positionsbestimmung. Die Host-App ruft `onPositionUpdate(GpsFix fix)` auf.],
  vorbedingungen: [
    1. Session befindet sich im Zustand `ACTIVE` (UC-01 erfolgreich abgeschlossen).\
    2. Das übergebene `GpsFix`-Objekt ist nicht `null`.\
    3. Mindestens ein weiterer Aufruf bis zum Hard-Limit ist möglich (anderenfalls greift Alternativfall 5a).
  ],
  standardablauf: [
    1. Host übergibt `GpsFix fix` (enthält lat, lon, time; optional ele, hdop, speed).\
    2. System validiert: `lat` ∈ [−90°, +90°], `lon` ∈ [−180°, +180°].\
    3. System validiert: `time` liegt nicht in der Zukunft und ist nicht älter als `maxFixAge` (Standard: 24 h).\
    4. System prüft Zeitlücke zum vorherigen Fix: Differenz > `segmentGapThreshold`? → neues `<trkseg>` eröffnen.\
    5. System prüft Soft-Limit: Punktanzahl == `softLimitPoints`? → `onSoftLimitReached(count)` feuern (Aufzeichnung läuft weiter).\
    6. System prüft Hard-Limit: Punktanzahl == `hardLimitPoints`? → gemäß Overflow-Modus handeln (STOP oder DOWNSAMPLE).\
    7. System speichert `fix` im internen Rohspeicher (alle Felder, keine stille Normierung).\
    8. System berechnet Azimut (Haversine-Formel), Distanz in Metern, diskrete Himmelsrichtung (8-teilig).\
    9. System berechnet Kursabweichung, falls `headingDeg` bekannt (UC-02a).\
    10. System feuert `onPositionProcessed(BearingSnapshot)` an alle Listener.\
    11. Rückkehr ohne Rückgabewert.
  ],
  alternativ: [
    *2a – Koordinaten außerhalb WGS84:* `ValidationException(COORD_RANGE)`; WARN-Log mit sessionId; kein Punkt gespeichert. Ende.\
    *3a – Zeitstempel ungültig:* `ValidationException(TIMESTAMP_INVALID)`; WARN-Log; kein Punkt gespeichert. Ende.\
    *3b – Erster Fix (kein Vorgänger):* Kein Segmentwechsel; erster Punkt eröffnet automatisch Segment 1.\
    *5a – Hard-Limit (Modus STOP) erreicht:* Kein weiterer Punkt gespeichert; `onHardLimitReached(count)` gefeuert; Session bleibt `ACTIVE`; Export weiterhin möglich. Ende.\
    *10a – Listener wirft:* Exception intern gefangen; WARN-Log; restliche Listener weiter benachrichtigt.
  ],
  ergebnisse: [
    - Fix ist korrekt im Rohspeicher abgelegt.\
    - Azimut, Distanz und Ordinalrichtung sind aktuell.\
    - Alle Listener haben `onPositionProcessed` erhalten.\
    - Bei Limit-Erreichung wurde das entsprechende Limit-Event gefeuert.
  ],
  nachbedingungen: [Rohspeicher enthält einen weiteren `GpsPoint`; aktuelle Peilungsgrößen sind berechnet; Listener wurden benachrichtigt. Bei Hard-Limit: keine weiteren Punkte mehr gespeichert.],
  systemgrenzen: [Die Bibliothek liest keine Sensoren selbst. Aufrufhäufigkeit bestimmt ausschließlich die Host-App. Die Bibliothek reduziert beim Einlesen nicht stillschweigend. `onPositionUpdate` ist nicht thread-sicher; nur aus einem Thread aufzurufen.],
  spezielle-anforderungen: [Azimut-Genauigkeit: Abweichung ≤ ±1° gegenüber Referenz-Haversine für Distanzen > 10 m. Segmentierungsschwelle: konfigurierbar, Standard 5 Minuten. Hard-Limit: Soft-Limit < Hard-Limit (wenn beide > 0). Zeitvalidierung via `ClockPort`-Injection.],
  haeufigkeit: "Pro Session mehrfach pro Sekunde bis einmal pro Minute, je nach Host-Konfiguration.",
  prioritaet: "Sehr hoch – Kernfunktion der Bibliothek.",
  bemerkungen: "Optionale Felder (`ele`, `hdop`, `speed`) werden ohne Normierung gespeichert. Negative Werte für `hdop`/`speed` lösen `ValidationException(INVALID_FIELD_VALUE)` aus.",
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
=== UC-03 – Peilungswerte lesen
// ─────────────────────────────────────────────────────────────────────────────

#uc-card(
  nummer: "UC-03 – Peilungswerte lesen",
  referenzen: "UC-02 (Snapshot setzt mind. einen Fix voraus); Projektauftrag SWE",
  beschreibung: [Die Host-App fragt den aktuellen Peilungsschnappschuss ab. Das System gibt Azimut, Entfernung zum Ziel und diskrete Himmelsrichtung zurück. Optional wird eine Kursabweichung mitgeliefert, falls der Host zuvor einen Kurs übermittelt hat.],
  akteure: [*Primär:* Host-App. — *Sekundär:* keine.],
  ausloeser: [Die Host-App möchte die aktuelle Richtungs- und Entfernungsanzeige für den Nutzer aktualisieren und ruft `getSnapshot()` auf.],
  vorbedingungen: [
    1. Session befindet sich im Zustand `ACTIVE`.\
    2. Mindestens ein gültiger `GpsFix` wurde zuvor erfolgreich über UC-02 verarbeitet.
  ],
  standardablauf: [
    1. Host ruft `getSnapshot()` auf.\
    2. System prüft: Ist mindestens ein Fix im Rohspeicher?\
    3. System leitet diskrete Himmelsrichtung (`compassOrdinal`) aus `azimuthDeg` ab (8-teilige 45°-Segmentierung: N=337,5°–22,5° usw.).\
    4. System befüllt `bearingErrorDeg` mit der gespeicherten Kursabweichung, falls ein Kurs bekannt ist.\
    5. System gibt immutables `Optional<BearingSnapshot>` zurück.
  ],
  alternativ: [
    *2a – Noch kein Fix vorhanden:* System gibt `Optional.empty()` zurück. Kein Fehler, kein Log-Eintrag.\
    *1a – Session nicht ACTIVE:* Rückgabe `Optional.empty()` (Verhalten in Javadoc dokumentiert).
  ],
  ergebnisse: [
    - `BearingSnapshot` mit `azimuthDeg ∈ [0°, 360°)`, `distanceM ≥ 0`, `compassOrdinal ∈ {N, NE, E, SE, S, SW, W, NW}` und optionalem `bearingErrorDeg ∈ (−180°, +180°]`.\
    - Kein interner Zustand verändert.
  ],
  nachbedingungen: [Der zurückgegebene Snapshot ist immutable. Spätere Positionsupdates verändern ihn nicht. Der interne Zustand der Session bleibt unverändert.],
  systemgrenzen: [Nur lesender Zugriff auf interne Berechnungswerte. Kein Netzwerkzugriff, kein Dateizugriff.],
  spezielle-anforderungen: [Snapshot ist immutables Value Object. Ordinalrichtung: gleichmäßige 45°-Segmentierung. Kursabweichung: `Optional.empty()` wenn kein Kurs bekannt. Rückgabe `Optional<BearingSnapshot>` (nie null).],
  haeufigkeit: "Sehr häufig – bei jeder UI-Aktualisierung der Host-App (typisch mehrfach pro Sekunde).",
  prioritaet: "Hoch.",
  bemerkungen: "Der Snapshot repräsentiert den Zustand nach dem zuletzt verarbeiteten Fix. Zwischen zwei `getSnapshot()`-Aufrufen findet kein Live-Tracking statt.",
)

// ─────────────────────────────────────────────────────────────────────────────
=== UC-04 – Peilung regulär beenden
// ─────────────────────────────────────────────────────────────────────────────

#uc-card(
  nummer: "UC-04 – Peilung regulär beenden",
  referenzen: "UC-01 (Vorbedingung), UC-06 (intern ausgelöst); Projektauftrag SWE",
  beschreibung: [Die Host-App schließt eine laufende Peilungs-Session regulär ab. Das System wechselt in den Zustand COMPLETED, erzeugt ein GPX-1.1-Dokument, berechnet Session-Statistiken und benachrichtigt alle Listener.],
  akteure: [*Primär:* Host-App. — *Sekundär:* Dateisystem (optional, wenn Dateipfad konfiguriert).],
  ausloeser: [Die Navigationsaufgabe ist abgeschlossen. Die Host-App ruft `complete()` auf.],
  vorbedingungen: [
    1. Session befindet sich im Zustand `ACTIVE`.\
    2. Kein gleichzeitiger Aufruf von `abort()`.
  ],
  standardablauf: [
    1. Host ruft `complete()` auf.\
    2. System setzt `endedAt = ClockPort.instant()`.\
    3. System wechselt Zustand zu `COMPLETED`.\
    4. System erstellt immutable View des Rohtracks.\
    5. System führt Optimierungs-Pipeline aus (konfigurierte `TrackOptimizer` in Reihenfolge, falls vorhanden).\
    6. System serialisiert GPX 1.1 (Namespace, Metadaten, Zeitstempel UTC, XML-Escaping).\
    7. System schreibt GPX-Datei atomar (temp → rename), falls Pfad konfiguriert.\
    8. System berechnet `SessionStats` (Gesamtdistanz, Dauer, Punktanzahl).\
    9. System feuert `onSessionCompleted(GpxResult, SessionStats)` an alle Listener.\
    10. System gibt `GpxResult` synchron an die Host-App zurück.
  ],
  alternativ: [
    *1a – Session nicht ACTIVE:* `BearingStateException(SESSION_ENDED)`; kein Zustandswechsel. Ende.\
    *7a – Dateischreiben schlägt fehl:* `BearingIOException(IO_WRITE_ERROR)`; Zustand bleibt COMPLETED; `GpxResult` ist dennoch gültig.\
    *9a – Listener wirft:* Intern gefangen; WARN-Log; restliche Listener weiter benachrichtigt.
  ],
  ergebnisse: [
    - `GpxResult` mit `gpxString` (UTF-8) und `gpxBytes` (UTF-8 ohne BOM) zurückgegeben.\
    - `SessionStats` mit Gesamtdistanz, Dauer und Punktanzahl vorhanden.\
    - Alle Listener haben `onSessionCompleted` erhalten.\
    - Optional: GPX-Datei auf Disk geschrieben.
  ],
  nachbedingungen: [Zustand = `COMPLETED`; `endedAt` gesetzt; `GpxResult` und `SessionStats` abrufbar; kein weiterer `onPositionUpdate` möglich.],
  systemgrenzen: [Optimierung verändert ausschließlich den Export-Track, nicht den Rohspeicher. Path-Traversal wird aktiv verhindert (SecurityException bei unzulässigem Pfad).],
  spezielle-anforderungen: [GPX: Namespace `http://www.topografix.com/GPX/1/1`, Version `1.1`, UTF-8. Zeitstempel: ISO-8601 UTC. Atomares Schreiben: `Files.move(ATOMIC_MOVE)`. Optimierer: Strategy-Pattern, Start/Ende immer erhalten. Export < 2 s für 10.000 Punkte (ohne DP).],
  haeufigkeit: "Einmalig pro Session.",
  prioritaet: "Sehr hoch.",
  bemerkungen: "Nach `complete()` ist `reset()` nötig für neue Session (UC-12). Rohspeicher bleibt intern erhalten bis zum Reset.",
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
=== UC-05 – Peilung abbrechen
// ─────────────────────────────────────────────────────────────────────────────

#uc-card(
  nummer: "UC-05 – Peilung abbrechen",
  referenzen: "UC-01 (Vorbedingung), UC-06 (intern ausgelöst); Klärungsgespräch Peter Bohl",
  beschreibung: [Die Host-App bricht eine laufende Peilungs-Session vorzeitig ab. Alle bis dahin aufgezeichneten Track-Daten bleiben als GPX-Ergebnis abrufbar. Eine Datei wird nur bei entsprechender Konfiguration (`persistOnAbort = true`) atomar geschrieben.],
  akteure: [*Primär:* Host-App. — *Sekundär:* Dateisystem (optional, wenn `persistOnAbort = true`).],
  ausloeser: [Benutzer bricht die Feldoperation ab; Verbindungsabbruch; externe Steuerlogik ruft `abort()` auf.],
  vorbedingungen: [
    1. Session befindet sich im Zustand `ACTIVE`.\
    2. Kein gleichzeitiger Aufruf von `complete()`.
  ],
  standardablauf: [
    1. Host ruft `abort()` auf.\
    2. System setzt `endedAt = ClockPort.instant()`.\
    3. System wechselt Zustand zu `ABORTED`.\
    4. System erstellt immutable View des bis dahin aufgezeichneten Rohtracks.\
    5. System serialisiert GPX 1.1 aus den vorhandenen Daten (auch wenn Track leer).\
    6. Falls `persistOnAbort = true`: GPX atomar in Datei schreiben (temp → rename).\
    7. System berechnet `SessionStats` (Gesamtdistanz, Dauer, Punktanzahl bis Abort).\
    8. System feuert `onSessionAborted(GpxResult, SessionStats)` an alle Listener.\
    9. System gibt `GpxResult` synchron zurück.
  ],
  alternativ: [
    *1a – Session nicht ACTIVE:* `BearingStateException(SESSION_ENDED)`; kein Zustandswechsel. Ende.\
    *5a – Track ist leer (0 Punkte):* GPX-Dokument mit leerem `<trk>`-Element wird erzeugt. Kein Fehler.\
    *6a – `persistOnAbort = false`:* Kein Dateizugriff; `GpxResult` trotzdem gültig und zurückgegeben.\
    *6b – Dateischreiben schlägt fehl:* `BearingIOException`; `GpxResult` dennoch gültig.
  ],
  ergebnisse: [
    - `GpxResult` enthält alle Punkte bis einschließlich des letzten validen Fix vor dem Abort.\
    - `SessionStats` sind berechnet.\
    - Zustand ist `ABORTED`.\
    - Datei nur bei `persistOnAbort = true` vorhanden.
  ],
  nachbedingungen: [Zustand = `ABORTED`; `endedAt` gesetzt; Track-Daten im `GpxResult` unverändert; kein weiterer `onPositionUpdate` möglich.],
  systemgrenzen: [GPX-Export ist keine Pflicht beim Abort. Die Bibliothek schreibt keine feste Datei; Pfad und Persistenzentscheidung obliegen der Host-App.],
  spezielle-anforderungen: [Abort-Ergebnis ohne Datei: `GpxResult.gpxBytes()` muss trotzdem befüllbar sein. Atomar schreiben wenn `persistOnAbort = true`. Track-Daten werden durch Abort nicht verworfen (Invariante). Leerer Track erzeugt valides GPX (kein Fehler).],
  haeufigkeit: "Seltener als UC-04; tritt bei Feldabbrüchen, Fehlern oder manuellen Unterbrechungen auf.",
  prioritaet: "Hoch.",
  bemerkungen: "Der Abort ist primäre Methode für Ausnahmefälle. Das GPX-Ergebnis enthält alle Punkte bis zum letzten erfolgreich verarbeiteten Fix.",
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
=== UC-06 – GPX exportieren und optimieren
// ─────────────────────────────────────────────────────────────────────────────

#uc-card(
  nummer: "UC-06 – GPX exportieren und optimieren",
  referenzen: "UC-04, UC-05 (Auslöser intern); GPX 1.1 Topografix-Schema; OWASP Path Traversal",
  beschreibung: [Nach Abschluss oder Abbruch erzeugt das System ein vollständig standardkonformes GPX-1.1-Dokument. Optional durchläuft der Track zuvor eine Optimierungspipeline (n-ter Punkt, Mindestabstand, Kollinearität, Douglas-Peucker). Der Export erfolgt als String, Byte-Array und optional als Datei.],
  akteure: [*Primär:* Host-App (konfiguriert Optimizer und Dateipfad). — *Sekundär:* Dateisystem (optional).],
  ausloeser: [Wird intern durch UC-04 (`complete()`) oder UC-05 (`abort()`) ausgelöst.],
  vorbedingungen: [
    1. Session im Zustand `COMPLETED` oder `ABORTED`.\
    2. Rohtrack ist als immutable View verfügbar (auch leer erlaubt).
  ],
  standardablauf: [
    1. System klont Rohtrack als unveränderliche `List<GpsPoint>`.\
    2. System iteriert durch alle in `SessionConfig` registrierten `TrackOptimizer` in konfigurierter Reihenfolge.\
    3. Jeder Optimizer transformiert die Punktliste; Ergebnis ist Eingabe für den nächsten.\
    4. System erstellt `<metadata>`-Block: `<time>` (UTC, ISO-8601), optionaler `<name>`, `<bounds>`.\
    5. System serialisiert Track als GPX-1.1-XML mit Namespace `http://www.topografix.com/GPX/1/1`.\
    6. System escaped alle String-Felder (`&`, `<`, `>`, `"` → XML-Entities).\
    7. System kodiert Ergebnis als UTF-8 ohne BOM.\
    8. Falls Dateipfad konfiguriert: Pfad normalisieren, Path-Traversal prüfen, atomar schreiben.\
    9. System gibt `GpxResult(gpxString, gpxBytes, optimizationResult)` zurück.
  ],
  alternativ: [
    *2a – Keine Optimizer konfiguriert:* Rohpunkte direkt ab Schritt 4 verarbeiten.\
    *8a – Path-Traversal erkannt:* `SecurityException(PATH_TRAVERSAL)`; kein Byte geschrieben.\
    *8b – Dateisystemfehler:* `BearingIOException(IO_WRITE_ERROR)`; `GpxResult` trotzdem gültig.\
    *Leerer Track:* GPX mit leerem `<trk>` erzeugt; kein `<bounds>` in Metadata.
  ],
  ergebnisse: [
    - `GpxResult.gpxString` ist valides GPX 1.1.\
    - `GpxResult.gpxBytes` ist UTF-8-kodiert und byte-äquivalent zum String.\
    - `OptimizationResult` enthält Statistik (originalCount, optimizedCount, angewandte Strategien).\
    - Optional: Datei auf Disk vorhanden und vollständig.
  ],
  nachbedingungen: [Rohspeicher ist unverändert (Optimierung wirkt nur auf Export-Kopie). `GpxResult` ist immutable.],
  systemgrenzen: [Kein Netzwerkzugriff. Dateizugriff nur auf konfiguriertem Basisverzeichnis. Douglas-Peucker nutzt lokale Tangentialebene (gültig bis 50 km Segmentlänge).],
  spezielle-anforderungen: [GPX-Namespace (Pflicht): `http://www.topografix.com/GPX/1/1`. Encoding: UTF-8, kein BOM. Atomares Schreiben: `Files.move(ATOMIC_MOVE)`. Strategy-Pattern: alle Optimizer implementieren `TrackOptimizer.optimize(List<GpsPoint>, OptimizationConfig)`. Start/Ende jedes Optimizers immer erhalten. Exportzeit < 2 s für 10.000 Punkte ohne DP (Richtwert).],
  haeufigkeit: "Einmalig pro Session; immer nach UC-04 oder UC-05.",
  prioritaet: "Sehr hoch.",
  bemerkungen: "Rohspeicher bleibt intern unverändert; Optimierung wirkt ausschließlich auf die Export-Kopie. GPX kann auch bei leerem Track erzeugt werden.",
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
=== UC-07 – What3Words-Adresse auflösen
// ─────────────────────────────────────────────────────────────────────────────

#uc-card(
  nummer: "UC-07 – What3Words-Adresse auflösen",
  referenzen: "What3Words API Docs; Klärungsgespräch Peter Bohl",
  beschreibung: [Die Host-App löst eine WGS84-Koordinate in eine What3Words-Dreiwortkombination auf. Das System prüft zuerst den internen LRU-Cache und stellt bei Cache-Miss eine HTTPS-Anfrage an die W3W-REST-API. Bei Fehler wird ein Fallback-String zurückgegeben.],
  akteure: [*Primär:* Host-App. — *Sekundär:* What3Words-API (HTTPS), interner LRU-Cache.],
  ausloeser: [Host-App möchte für einen Peilungspunkt eine lesbare W3W-Adresse anzeigen. Aufruf: `resolveW3w(GeoCoordinate coordinate)`.],
  vorbedingungen: [
    1. `w3wApiKey` ist in `SessionConfig` konfiguriert und nicht leer.\
    2. Übergebene `GeoCoordinate` ist valide (WGS84).
  ],
  standardablauf: [
    1. Host ruft `resolveW3w(coordinate)` auf.\
    2. System normalisiert Koordinate (gerundet auf 6 Dezimalstellen als Cache-Schlüssel).\
    3. System prüft LRU-Cache: Eintrag vorhanden und TTL noch gültig? → Schritt 8.\
    4. System baut HTTPS-Request an W3W-REST-API (`/v3/convert-to-3wa`).\
    5. System sendet Request; wartet auf Antwort (konfigurierbarer Timeout, Standard: 5 s).\
    6. System parst JSON-Antwort; extrahiert Feld `words`.\
    7. System speichert Ergebnis mit TTL-Stempel im LRU-Cache.\
    8. System gibt `words`-String zurück.
  ],
  alternativ: [
    *1a – Kein API-Key:* Sofort Fallback `"w3w://unavailable"` zurückgeben; WARN-Log mit sessionId. Ende.\
    *5a – Netzwerk-Timeout:* Fallback zurückgeben; WARN-Log mit Timeout-Dauer. Ende.\
    *5b – HTTP 4xx/5xx:* Fallback zurückgeben; WARN-Log mit HTTP-Status-Code. Ende.\
    *3a – Cache-Eintrag TTL abgelaufen:* Eintrag ungültig; weiter ab Schritt 4.\
    *2a – Koordinate ungültig:* `ValidationException(COORD_RANGE)`. Ende.
  ],
  ergebnisse: [
    - Bei Erfolg: W3W-Dreiwortkombination (z. B. `"///filled.count.soap"`) zurückgegeben und gecacht.\
    - Bei Fehler: Fallback `"w3w://unavailable"` zurückgegeben; WARN-Log mit sessionId geschrieben.
  ],
  nachbedingungen: [Cache enthält bei Erfolg einen neuen oder aktualisierten Eintrag mit TTL. Session-Track-Daten sind unverändert.],
  systemgrenzen: [W3W-Lookup ist ausschließlich opportunistisch. Ein Fehler darf keine Session-Funktionalität beeinträchtigen. Die Bibliothek kontaktiert ausschließlich die konfigurierte W3W-API-URL. Ohne API-Key kein Netzwerkzugriff.],
  spezielle-anforderungen: [Cache: LRU-Algorithmus, konfigurierbare Größe (Standard: 256 Einträge), TTL (Standard: 1 h). Cache-Schlüssel: Koordinate gerundet auf 6 Dezimalstellen. Kein Netzwerkaufruf ohne API-Key. Kein unkontrolliertes Exception-Propagieren. W3W-Abhängigkeit nur im Maven-Profil `w3w` aktiv.],
  haeufigkeit: "Selten – nur auf explizite Anfrage der Host-App pro Peilungspunkt.",
  prioritaet: "Mittel – optionale Funktion.",
  bemerkungen: "Netzwerk-Timeout empfohlener Standard: 5 Sekunden. Retry-Anzahl: maximal 1 (konfigurierbar). Cache reduziert Netzwerkkosten bei wiederholten Anfragen für nahe beieinanderliegende Koordinaten.",
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
=== UC-08 – W3W ohne API-Key (Fallback)
// ─────────────────────────────────────────────────────────────────────────────

#uc-card(
  nummer: "UC-08 – W3W ohne API-Key (Fallback)",
  referenzen: "UC-07 (Erweiterung); Klärungsgespräch",
  beschreibung: [Host ruft W3W-Lookup auf, ohne einen API-Key in der SessionConfig zu hinterlegen. Das System erkennt dies sofort, verzichtet vollständig auf Netzwerkzugriff und gibt den definierten Fallback-String zurück.],
  akteure: [*Primär:* Host-App. — *Sekundär:* keine (kein Netzwerkaufruf).],
  ausloeser: [Host ruft `resolveW3w()` auf; `w3wApiKey` in `SessionConfig` ist leer oder nicht gesetzt.],
  vorbedingungen: [Feld `w3wApiKey` in `SessionConfig` ist leer oder `Optional.empty()`.],
  standardablauf: [
    1. System stellt fest: kein API-Key vorhanden.\
    2. System schreibt SLF4J-WARN-Log mit `sessionId` und Ursache `NO_API_KEY`.\
    3. System gibt `"w3w://unavailable"` zurück.
  ],
  alternativ: [],
  ergebnisse: [Rückgabe `"w3w://unavailable"`; WARN-Log vorhanden; kein Netzwerkaufruf ausgelöst.],
  nachbedingungen: [Kein Cache-Eintrag erstellt. Session-Zustand unverändert.],
  systemgrenzen: ["Kein Netzwerkaufruf unter keinen Umständen ohne API-Key."],
  spezielle-anforderungen: "WARN-Log muss `sessionId` als MDC-Feld enthalten. Kein Thread-Block, kein Timeout.",
  haeufigkeit: "Selten; nur wenn Host API-Key vergessen hat zu setzen.",
  prioritaet: "Mittel.",
  bemerkungen: "Das Verhalten ist in der Javadoc von `resolveW3w()` explizit dokumentiert.",
)

// ─────────────────────────────────────────────────────────────────────────────
=== UC-09 – W3W-Netzwerk-Timeout
// ─────────────────────────────────────────────────────────────────────────────

#uc-card(
  nummer: "UC-09 – W3W-Netzwerk-Timeout",
  referenzen: "UC-07 (Alternativpfad 5a); OWASP API Security",
  beschreibung: [Die W3W-API antwortet nicht innerhalb des konfigurierten Timeout-Limits. Das System bricht den Aufruf ab, schreibt ein WARN-Log und gibt den Fallback-String zurück. Die laufende Session wird nicht beeinträchtigt.],
  akteure: [*Primär:* Host-App. — *Sekundär:* What3Words-API (nicht erreichbar).],
  ausloeser: [HTTP-Client erkennt Überschreitung des Timeout-Limits bei der W3W-REST-Anfrage.],
  vorbedingungen: [API-Key vorhanden; Netzwerkaufruf wurde ausgelöst; Timeout-Limit überschritten.],
  standardablauf: [
    1. HTTP-Client erkennt Timeout-Überschreitung.\
    2. System fängt Timeout-Exception intern.\
    3. System schreibt WARN-Log (Timeout-Dauer, API-URL, sessionId).\
    4. System gibt `"w3w://unavailable"` zurück.
  ],
  alternativ: [],
  ergebnisse: [Fallback-String zurückgegeben; WARN-Log mit Timeout-Dauer; Session unverändert aktiv.],
  nachbedingungen: [Kein valider Cache-Eintrag für diese Koordinate. Session-Zustand unverändert.],
  systemgrenzen: "Timeout-Wert ist konfigurierbar (Standard: 5 Sekunden). Kein Retry nach Timeout (max. 1 Retry konfigurierbar).",
  spezielle-anforderungen: "Timeout-Exception darf nicht unkontrolliert propagieren. WARN-Log ist Pflicht. Keine unkontrollierten Threads nach Timeout.",
  haeufigkeit: "Selten; tritt bei Netzwerkproblemen auf.",
  prioritaet: "Mittel.",
  bemerkungen: "Timeout-Standard: 5 Sekunden. Empfehlung: im CI-Build mit Mock-Server testen.",
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
=== UC-10 – GPX als Byte-Array exportieren
// ─────────────────────────────────────────────────────────────────────────────

#uc-card(
  nummer: "UC-10 – GPX als Byte-Array exportieren",
  referenzen: "UC-04, UC-05 (Vorbedingung); RFC 3629 (UTF-8)",
  beschreibung: [Die Host-App greift auf den GPX-Export als `byte[]` (UTF-8, kein BOM) zu, z. B. für direktes Versenden über HTTP, Schreiben in einen eigenen OutputStream oder Einbettung in ein Datenbankfeld.],
  akteure: [*Primär:* Host-App. — *Sekundär:* keine.],
  ausloeser: [Host benötigt GPX-Inhalt als Byte-Array nach Abschluss oder Abbruch einer Session.],
  vorbedingungen: [Session im Zustand `COMPLETED` oder `ABORTED`; `GpxResult` wurde bei UC-04 oder UC-05 erzeugt.],
  standardablauf: [
    1. Host ruft `GpxResult.gpxBytes()` auf.\
    2. System gibt vorberechnetes `byte[]`-Feld zurück (kein erneutes Serialisieren).
  ],
  alternativ: [],
  ergebnisse: [`byte[]` in UTF-8 ohne BOM; Länge > 0 bei nicht-leerem Track.],
  nachbedingungen: [Kein interner Zustand verändert. `GpxResult` bleibt immutable.],
  systemgrenzen: "Kein Dateizugriff, kein Netzwerkzugriff.",
  spezielle-anforderungen: "`gpxBytes` ist byte-äquivalent zur UTF-8-Kodierung von `gpxString`. Kein BOM (Byte Order Mark). Wird einmal bei der Serialisierung berechnet und danach gecacht (immutable).",
  haeufigkeit: "Oft – immer wenn Host GPX für eigene Weiterverarbeitung benötigt.",
  prioritaet: "Hoch.",
  bemerkungen: "Leerer Track liefert dennoch valides GPX-Byte-Array (minimales GPX-Dokument).",
)

// ─────────────────────────────────────────────────────────────────────────────
=== UC-11 – Listener-Exception wird isoliert
// ─────────────────────────────────────────────────────────────────────────────

#uc-card(
  nummer: "UC-11 – Listener-Exception wird isoliert",
  referenzen: "UC-01, UC-02, UC-04, UC-05 (alle Listener-Aufrufe); Vorlesung SWE – Observer-Pattern",
  beschreibung: [Ein registrierter `BearingListener` wirft während der Ereignisbenachrichtigung eine unkontrollierte Exception. Das System fängt die Exception intern ab, protokolliert sie und setzt die Benachrichtigungsschleife mit den verbleibenden Listenern fort. Die Session bleibt konsistent.],
  akteure: [*Primär:* Host-App (verursacht durch fehlerhafte Listener-Implementierung). — *Sekundär:* keine.],
  ausloeser: [Fehler in der Implementierung eines `BearingListener` des Hosts; tritt bei jedem Event-Aufruf (UC-01..05) auf.],
  vorbedingungen: [Mindestens ein `BearingListener` ist registriert; dieser wirft eine `RuntimeException` bei Aufruf seiner Callback-Methode.],
  standardablauf: [
    1. System ruft `listener.onXxx(payload)` auf.\
    2. Listener wirft `RuntimeException`.\
    3. System fängt Exception intern (try/catch um jeden Listener-Aufruf).\
    4. System schreibt WARN-Log: Exception-Typ, Message, `sessionId` als MDC-Feld.\
    5. System setzt Iteration mit nächstem Listener fort.
  ],
  alternativ: [],
  ergebnisse: [Alle weiteren Listener wurden benachrichtigt. WARN-Log mit Exception-Details vorhanden. Session-Zustand ist konsistent.],
  nachbedingungen: [Session bleibt im aktuellen Zustand. Listener-Registrierung bleibt bestehen (fehlerhafter Listener wird nicht automatisch entfernt).],
  systemgrenzen: "Die Exception-Isolation gilt für alle Callback-Methoden des `BearingListener`-Interfaces.",
  spezielle-anforderungen: "Exception-Isolation ist in Javadoc von `BearingListener` explizit dokumentiert (Contract-Garantie). Kein Abbrechen der gesamten Benachrichtigungsschleife durch einen einzelnen Listener.",
  haeufigkeit: "Selten; tritt bei Implementierungsfehlern im Host auf.",
  prioritaet: "Mittel.",
  bemerkungen: "Das Verhalten entspricht dem Robustheitsprinzip (Postel's Law): tolerant gegenüber fehlerhaftem Code im Host.",
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
=== UC-12 – Wiederanlauf / Reset nach Session-Ende
// ─────────────────────────────────────────────────────────────────────────────

#uc-card(
  nummer: "UC-12 – Wiederanlauf / Reset nach Session-Ende",
  referenzen: "UC-01 (Folge-Session), UC-04, UC-05; /LL160/",
  beschreibung: [Die Host-App setzt die Bibliothek nach einer abgeschlossenen oder abgebrochenen Session explizit auf den Ausgangszustand IDLE zurück. Danach ist eine neue Session startbar (UC-01), ohne die JVM neu zu starten.],
  akteure: [*Primär:* Host-App. — *Sekundär:* keine.],
  ausloeser: [Host-App möchte nach UC-04 (`COMPLETED`) oder UC-05 (`ABORTED`) eine neue Peilungs-Session starten.],
  vorbedingungen: [Session befindet sich im Zustand `COMPLETED` oder `ABORTED`.],
  standardablauf: [
    1. Host ruft `reset()` auf.\
    2. System prüft: Zustand ist `COMPLETED` oder `ABORTED`.\
    3. System löscht alle internen Session-Felder (UUID, startedAt, endedAt, Rohspeicher, Peilungsgrößen).\
    4. System wechselt Zustand zu `IDLE`.\
    5. `startSession()` kann erneut aufgerufen werden (UC-01).
  ],
  alternativ: [
    *2a – Session ist `ACTIVE`:* `BearingStateException(SESSION_STILL_ACTIVE)`; kein Reset. Ende.
  ],
  ergebnisse: [Zustand = `IDLE`; UUID gelöscht; alle internen Felder zurückgesetzt; neue Session ist startbar.],
  nachbedingungen: [Die Bibliothek verhält sich wie bei erster Nutzung. Das `GpxResult` der Vorgänger-Session bleibt bis zur GC gültig (Referenz beim Host-Code).],
  systemgrenzen: "Kein Netzwerkzugriff, kein Dateizugriff beim Reset.",
  spezielle-anforderungen: "Reset muss ohne JVM-Neustart funktionieren (/LL160/). Interner LRU-Cache für W3W wird bei Reset *nicht* geleert (Cache ist sessions-übergreifend).",
  haeufigkeit: "Einmalig nach jeder abgeschlossenen Session, wenn die Host-App erneut starten möchte.",
  prioritaet: "Hoch.",
  bemerkungen: "Dieser UC ist Voraussetzung für Langzeit-Betrieb der Bibliothek ohne JVM-Neustart (Wiederanlaufbedingung /LL160/).",
)

#pagebreak()


// ═════════════════════════════════════════════════════════════════════════════
== Nicht-funktionale Anforderungen
// ═════════════════════════════════════════════════════════════════════════════

Nicht-funktionale Anforderungen beschreiben *wie* das System seine Aufgaben erfüllt. Sie sind durch `/LL…/`-Bezeichner referenzierbar und als messbare Qualitätsmerkmale formuliert.

#ll-card("/LL010/", "Eingabevalidierung", "Qualitätsrichtlinie", "/UC-02, UC-01/",
  [Ungültige Eingaben (null, WGS84-Bereich verletzt, Zeitstempel außerhalb Toleranz) dürfen keine undefinierten Zustände erzeugen. Alle Fehlerpfade müssen durch dedizierte Testfälle abgesichert sein; 100 % der Exception-Pfade in Validierungsklassen müssen durch Tests erreichbar sein.])

#ll-card("/LL020/", "Genauigkeit der Peilungsberechnung", "Fachanforderung", "/UC-02, UC-03/",
  [Für Distanzen > 10 m darf der berechnete Azimut maximal ±1° von einer unabhängigen Referenz (Haversine-Formel) abweichen. Überprüfung für mindestens drei Referenzszenarien: Äquator, Polnähe (φ > 80°), Stuttgart (48,77°N/9,18°E).])

#ll-card("/LL030/", "Performance: Peilungszyklus", "Echtzeit-Anforderung", "/UC-02/",
  [Vollständiger Update-Zyklus (`onPositionUpdate` → Azimut/Distanz berechnen) soll auf Referenz-Laptop typisch < 1 ms, Worst-Case (ohne GC) < 100 ms betragen. Überschreitung muss im Test-Report dokumentiert werden.])

#ll-card("/LL040/", "Performance: GPX-Export", "Performanceanforderung", "/UC-06/",
  [GPX-Export für 10.000 Trackpunkte ohne Optimierung soll auf Referenz-Laptop in unter 2 Sekunden erfolgen. Messung per JMH- oder `@Timeout`-Test in `target/benchmark-report.txt`.])

#ll-card("/LL050/", "Speicherverbrauch", "Ressourcenanforderung", "/UC-02/",
  [Heap-Zuwachs der Bibliothek für 10.000 Punkte (alle optionalen Felder) soll typisch < 50 MB betragen. Validierung durch JVM-Heap-Snapshot-Test.])

#ll-card("/LL100/", "Javadoc-Vollständigkeit", "Vorlesung SWE", "–",
  [Gesamte öffentliche API (alle public-/protected-Klassen und Methoden) muss vollständig mit Javadoc dokumentiert sein. Checkstyle-Plugin im Maven-Build erzwingt dies; fehlende Javadoc führen zum Build-Fehler.])

#ll-card("/LL110/", "Portabilität", "Projektauftrag", "–",
  [Keine plattformspezifischen Pfade, Zeilentrennzeichen oder `sun.*`-APIs. Kompilierbar und ausführbar auf Windows 10+, macOS 12+ und Ubuntu 22.04 ohne Anpassungen. CI-Matrix auf mindestens zwei Plattformen empfohlen.])

#ll-card("/LL120/", "Build-Reproduzierbarkeit", "Projektauftrag", "–",
  [Maven-Build auf frisch geklontem Repository mit `mvn clean test` in unter 5 Minuten erfolgreich. Alle Abhängigkeiten versioniert und über Maven Central auflösbar. Keine SNAPSHOT-Abhängigkeiten im Release.])

#ll-card("/LL130/", "Sicherheit: XML-Escaping", "Sicherheitsrichtlinie", "/UC-06/",
  [Alle Nutzerstrings in XML-Ausgaben müssen escaped werden (`&→&amp;`, `<→&lt;`, `>→&gt;`, `"→&quot;`). XXE-Schutz via `FEATURE_SECURE_PROCESSING = true`. Verifikation durch Integrationstest mit Sonderzeichen.])

#ll-card("/LL140/", "Beobachtbarkeit via SLF4J", "Betriebsanforderung", "–",
  [Alle WARN- und ERROR-Ereignisse via SLF4J protokolliert. Jeder Eintrag auf WARN+ enthält `sessionId` als MDC-Feld. MDC muss nach jedem Aufruf bereinigt werden (Thread-Pool-Schutz).])

#ll-card("/LL150/", "Testabdeckung", "Vorlesung SWE", "/LL010/",
  [Kernmodule `bearing-core`, `gps-tracker`, `gpx-exporter`: Zeilenabdeckung ≥ 85 % (JaCoCo). Kritische Klassen `BearingSession`, `BearingCalculator`: ≥ 90 %. Unterschreitung führt zum Build-Fehler (`jacoco:check`).])

#ll-card("/LL160/", "Wiederanlauf nach Exception", "Betriebsanforderung", "/UC-12/",
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
    [*Signatur*], [*Beschreibung*], [*UC*],
    [`SessionId startSession(GeoCoordinate, SessionConfig)`], [Neue Peilung starten; UUID zurückgeben.], [UC-01],
    [`void onPositionUpdate(GpsFix)`],       [GPS-Fix verarbeiten; Track + Peilung aktualisieren.], [UC-02],
    [`void onHeadingUpdate(double)`],        [Kurs aktualisieren (optional, 0–360°).],              [UC-02],
    [`Optional<BearingSnapshot> getSnapshot()`], [Aktuellen Schnappschuss abfragen.],               [UC-03],
    [`GpxResult complete()`],                [Session regulär beenden; GPX erzeugen.],              [UC-04],
    [`GpxResult abort()`],                   [Session abbrechen; GPX erzeugen.],                   [UC-05],
    [`void reset()`],                        [Auf IDLE zurücksetzen.],                              [UC-12],
    [`String resolveW3w(GeoCoordinate)`],    [W3W-Adresse auflösen (optional).],                   [UC-07],
    [`void addListener(BearingListener)`],   [Listener registrieren.],                              [UC-11],
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

Dieses Diagramm stellt den vollständigen Ablauf eines Positionsupdates (UC-02) im Standard-Flussdiagrammstil dar. Es zeigt Entscheidungsknoten für Validierung, Segmentgrenze und Limit-Checks sowie die parallelen Berechnungsschritte.
/*
#figure(
  image("images/AD_01_PositionUpdate.svg", width: 100%),
  caption: [AD-01: Aktivitätsdiagramm `onPositionUpdate` – Standardflussdiagramm mit Entscheidungsknoten, Fehler- und Limit-Pfaden.],
)
*/
#pagebreak()

=== AD-02: Aktivitätsdiagramm GPX-Export (Swimlane-Darstellung)

Das Swimlane-Diagramm zeigt den GPX-Exportvorgang (UC-06) mit vier Verantwortungsbereichen. Die Fork-/Join-Notation visualisiert die sequentielle Verkettung der Optimierungsstrategien.

// #figure(
//   image("images/AD_02_GpxExport.svg", width: 100%),
//   caption: [AD-02: Aktivitätsdiagramm GPX-Export – Swimlane mit Fork/Join für Optimierungspipeline (Host-App, BearingSession, OptimPipeline, GpxSerializer).],
// )

#pagebreak()

=== AD-03: Aktivitätsdiagramm UC-01 Session starten (Fork/Join-Stil)

Dieses Diagramm zeigt UC-01 (Session starten) mit expliziter Fork-/Join-Notation für parallele Initialisierungsschritte (UUID, Zeitstempel, Listener). Fehlerausflüsse bei Doppelstart und ungültiger Konfiguration sind als separate Endknoten dargestellt.

// #figure(
//   image("images/AD_03_SessionStart.svg", width: 90%),
//   caption: [AD-03: Aktivitätsdiagramm UC-01 Session starten – Fork/Join-Stil mit Fehlerausflüssen und parallelen Initialisierungsschritten.],
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

#ld-card("/LD100/", "Peilungs-Session", "UC-01, UC-05", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [sessionId], [UUID RFC 4122 v4, 36 Zeichen],
    [status], [Enum: IDLE · ACTIVE · COMPLETED · ABORTED],
    [target], [GeoCoordinate (WGS84, validiert)],
    [startedAt], [Instant UTC (gesetzt bei Start)],
    [endedAt], [Optional\<Instant\> (gesetzt bei complete/abort)],
    [config], [SessionConfig (immutable, eingefroren)],
  )
])

#ld-card("/LD110/", "Konfiguration (SessionConfig)", "UC-01", [
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

#ld-card("/LD120/", "GPS-Track", "UC-02, UC-06", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [segments], [List\<TrackSegment\> (mind. 1)],
    [totalPoints], [int (abgeleitete Kennzahl)],
    [bounds], [Optional\<GeoBounds\> (min/max lat/lon)],
  )
])

#ld-card("/LD130/", "GPS-Punkt (GpsPoint)", "UC-02", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [lat], [double ∈ [−90,0, +90,0]],
    [lon], [double ∈ [−180,0, +180,0]],
    [time], [Instant UTC (Pflichtfeld)],
    [ele], [Optional\<Double\> (Höhe in m)],
    [hdop], [Optional\<Double\> (≥ 0)],
    [speed], [Optional\<Double\> (≥ 0 m/s)],
  )
])

#ld-card("/LD140/", "Peilungs-Snapshot", "UC-03", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [azimuthDeg], [double ∈ [0,0°, 360,0°)],
    [distanceM], [double ≥ 0],
    [compassOrdinal], [Enum: N · NE · E · SE · S · SW · W · NW],
    [bearingErrorDeg], [Optional\<Double\> ∈ (−180°, +180°]],
  )
])

#ld-card("/LD150/", "GPX-Dokument (GpxResult)", "UC-06", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [gpxString], [String UTF-8 (valides GPX 1.1)],
    [gpxBytes], [byte[] UTF-8, kein BOM],
    [optimizationResult], [OptimizationResult (Statistik)],
    [stats], [SessionStats],
  )
])

#ld-card("/LD160/", "W3W-Cache-Eintrag", "UC-07", [
  #table(columns: (1fr, 1fr), stroke: 0.3pt + gray, inset: 5pt,
    [lat], [double (gerundet 6 Dezimalstellen)],
    [lon], [double (gerundet 6 Dezimalstellen)],
    [words], [String (3 Wörter, Punkt-getrennt)],
    [resolvedAt], [Instant UTC],
    [ttl], [Duration (aus SessionConfig)],
  )
])

=== Testfälle (Traceability)

#figure(
  caption: [Testfälle mit Traceability zu Use Cases und nicht-funktionalen Anforderungen.],
  kind: table,
  align(left, table(
    columns: (1.6cm, 1fr, 2.6cm, 2cm),
    stroke: _tbl, inset: 5pt,
    [*TC-ID*], [*Beschreibung*], [*Erwartetes Ergebnis*], [*UC / LL*],
    [TC-010], [Doppelter `startSession()`-Aufruf.], [`BearingStateException(ALREADY_ACTIVE)`.], [UC-01],
    [TC-020], [`GpsFix` mit `lat = 91°`.], [`ValidationException(COORD_RANGE)`.], [UC-02],
    [TC-025], [Zeitstempel +2h in der Zukunft.], [`ValidationException(TIMESTAMP_INVALID)`.], [UC-02],
    [TC-030], [Update nach `complete()`.], [`BearingStateException(SESSION_ENDED)`.], [UC-04],
    [TC-040], [Snapshot ohne Fix.], [`Optional.empty()`.], [UC-03],
    [TC-050], [Soft-Limit (n=100).], [`onSoftLimitReached`; Aufzeichnung läuft.], [UC-02],
    [TC-060], [Hard-Limit STOP (n=200).], [`onHardLimitReached`; kein weiterer Punkt.], [UC-02],
    [TC-070], [`abort()` ohne persist.], [GPX-String ≠ leer; keine Datei.], [UC-05],
    [TC-080], [`abort()` mit persist.], [Datei atomar geschrieben; valide.], [UC-05],
    [TC-090], [Pfad `../../etc/passwd`.], [`SecurityException(PATH_TRAVERSAL)`.], [UC-06],
    [TC-100], [GPX-Namespace in Ausgabe.], [`xmlns="http://www.topografix.com/GPX/1/1"`.], [UC-06],
    [TC-110], [n-Optimizer n=10, 100 Punkte.], [11 Punkte (Start/Ende + 9 dazwischen).], [UC-06],
    [TC-120], [Kollinear: 3 Punkte auf Linie.], [2 Punkte nach Optimierung.], [UC-06],
    [TC-130], [Douglas-Peucker ε = 100 m.], [Starke Reduktion; kein Fehler.], [UC-06],
    [TC-140], [W3W-API Timeout.], [Fallback; WARN-Log mit sessionId.], [UC-09],
    [TC-150], [W3W-Cache-Treffer (2. Aufruf).], [Kein Netzwerkaufruf beim 2. Mal.], [UC-07],
    [TC-160], [Clock-Mock; zwei identische Läufe.], [Byte-identischer GPX-String.], [/LL190/],
    [TC-170], [Listener wirft RuntimeException.], [Exception gefangen; nächster Listener weiter.], [UC-11],
    [TC-180], [`reset()` → neuer Start.], [Neue UUID; Session ACTIVE.], [UC-12],
    [TC-190], [Sonderzeichen `<>&"` im Namen.], [GPX enthält korrekte XML-Entities.], [/LL130/],
    [TC-200], [Start Happy Path.], [UUID vorhanden; `onSessionStarted` gefeuert.], [UC-01],
    [TC-210], [Azimut Stuttgart→München vs. Referenz.], [Abweichung ≤ ±1°.], [/LL020/],
    [TC-220], [Zeitlücke 6 min (Threshold 5 min).], [Zwei `<trkseg>` im GPX.], [UC-02],
  ))
)

=== FMEA

#figure(
  caption: [FMEA: Fehlermodi, Folgen, Klassen und Gegenmaßnahmen.],
  kind: table,
  align(left, table(
    columns: (2.4cm, 1.5fr, 0.8cm, 0.8cm, 1fr),
    stroke: _tbl, inset: 5pt,
    [*Fehler*], [*Folge*], [*A*], [*E*], [*Gegenmaßnahme*],
    [Ungültige Koordinate],    [Falsche Peilung oder Exception.],  [M], [K], [`ValidationException`; UC-02 Schritt 2.],
    [Ungültiger Zeitstempel],  [Falsche Segmentierung.],           [M], [M], [Zeitvalidierung; UC-02 Schritt 3.],
    [Speicheroverflow],        [OutOfMemoryError der JVM.],        [G], [K], [Hard-Limit UC-02 Schritt 6.],
    [XML-Injection],           [Ungültige GPX-Datei.],             [G], [M], [XmlEscaper; UC-06 Schritt 6.],
    [Path Traversal],          [Kritische Datei überschrieben.],   [G], [M], [Pfadnormalisierung; UC-06 Schritt 8.],
    [W3W-Ausfall],             [Fehlende W3W-Adresse.],            [G], [G], [Fallback + Cache; UC-07/08/09.],
    [Listener wirft],          [Benachrichtigungsschleife abbricht.],[M],[K], [Isolation-Garantie; UC-11.],
    [Clock nicht injiziert],   [Nicht-deterministische Tests.],    [S], [G], [`ClockPort`-Injection; /LL170/.],
  ))
)

*Legende A/E:* S = selten, M = mittel, G = gering, K = katastrophal (qualitativ).

#pagebreak()
]



 // end ch-spezifische-anforderungen-kapitel
