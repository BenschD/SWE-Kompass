#import "lf-card.typ": lf-card
#import "lf-diagram.typ": lf-flowchart, lf-flowchart-custom, lf-sonstiges

#let ch-lf-spezifikationen = [

#lf-card(
  id: "/LF010/",
  funktion: "Session starten",
  akteur: [Host-App (Primär). Sekundär: keine.],
  verweise: [/LF400/, /LF080/, IEEE 830, Projektauftrag SWE],
  einbindungen: [---],
  datenzugriffe: [/LD100/, /LD110/],
  beschreibung: [Die Host-App startet eine neue Peilungs-Session. Das System prüft Zielkoordinate und Konfiguration, vergibt eine UUID, friert die Konfiguration ein und wechselt in den Zustand ACTIVE. Alle registrierten Listener werden benachrichtigt.],
  ausloeser: [Der Nutzer der Host-App startet eine neue Navigations- oder Peilungssitzung. Die Host-App ruft daraufhin `startSession(target, config)` auf.],
  vorbedingung: [
    1. Die Bibliothek befindet sich im Zustand `IDLE`.\
    2. `GeoCoordinate target` ist nicht `null` und enthält valide WGS84-Werte.\
    3. `SessionConfig config` ist nicht `null`; alle Pflichtfelder sind positiv belegt.
  ],
  nach_erfolg: [
    - `sessionId` (UUID) wurde dem Host zurückgegeben.\
    - Zustand = `ACTIVE`; `startedAt` gesetzt; `SessionConfig` eingefroren.\
    - Alle Listener haben `onSessionStarted` empfangen (oder Fehler protokolliert).
  ],
  nach_fehler: [
    *Aktive Session vorhanden:* `BearingStateException(ALREADY_ACTIVE)` — /LF020/.\
    *Konfiguration ungültig:* `ValidationException(INVALID_CONFIG)`.\
    *Zielkoordinate ungültig:* `ValidationException(COORD_RANGE)`.
  ],
  standardablauf: [
    1. Host übergibt `GeoCoordinate target` und `SessionConfig config`.\
    2. System prüft: keine Session im Zustand `ACTIVE`.\
    3. System validiert `SessionConfig` und `target` (WGS84).\
    4. System erzeugt UUID (RFC 4122 v4) und setzt `startedAt`.\
    5. System friert `SessionConfig` ein und wechselt zu `ACTIVE`.\
    6. System feuert `onSessionStarted(sessionId)` an alle Listener.\
    7. System gibt `sessionId` synchron zurück.
  ],
  alternativablauf: [
    *2a – Aktive Session:* `BearingStateException(ALREADY_ACTIVE)`; kein Zustandswechsel.\
    *3a – Config ungültig:* `ValidationException(INVALID_CONFIG)`.\
    *3b – Koordinate ungültig:* `ValidationException(COORD_RANGE)`.\
    *6a – Listener wirft:* WARN-Log; restliche Listener weiter benachrichtigt.
  ],
  sonstiges: lf-sonstiges(
    systemgrenzen: [Kein GNSS-Hardwarezugriff; keine eigenen Threads; kein Netzwerk.],
    speziell: [UUID RFC 4122 v4; `ClockPort`-Injection; immutables `SessionConfig`.],
    bemerkungen: [Ein `reset()` ist nötig, um erneut zu starten (/LL160/).],
  ),
)

#lf-flowchart(
  "/LF010/",
  (
    [Host übergibt target + config],
  ),
  decision: [Bereits ACTIVE?],
  error-label: [ja],
  branch-fail: [`ALREADY_ACTIVE`],
  steps-after: (
    [Validierung Config + Koordinate],
    [UUID erzeugen, ACTIVE setzen],
    [Listener benachrichtigen],
    [sessionId zurückgeben],
  ),
)

#pagebreak()

#lf-card(
  id: "/LF030/",
  funktion: "Positionsupdate verarbeiten",
  akteur: [Host-App (Primär). Sekundär: keine.],
  verweise: [/LF010/, /LF100/, /LF050/, Projektauftrag SWE],
  einbindungen: [/LF100/ Track-Speicherung],
  datenzugriffe: [/LD120/, /LD130/, /LD140/],
  beschreibung: [Die Host-App liefert einen neuen GPS-Fix. Das System validiert Koordinaten und Zeitstempel, prüft Segment- und Budgetgrenzen, speichert den Fix im Rohspeicher, berechnet Azimut und Distanz und benachrichtigt alle Listener.],
  ausloeser: [GNSS-Stack liefert Positionsbestimmung; Host ruft `onPositionUpdate(GpsFix fix)` auf.],
  vorbedingung: [
    1. Session im Zustand `ACTIVE` (/LF010/).\
    2. `GpsFix` ist nicht `null`.\
    3. Hard-Limit noch nicht erreicht (sonst Alternativfall 5a).
  ],
  nach_erfolg: [
    Fix im Rohspeicher; Azimut, Distanz und Ordinalrichtung aktuell; Listener benachrichtigt. Bei Limit: entsprechendes Limit-Event gefeuert.
  ],
  nach_fehler: [
    Koordinaten ungültig: `ValidationException(COORD_RANGE)`.\
    Zeitstempel ungültig: `ValidationException(TIMESTAMP_INVALID)`.\
    Hard-Limit STOP: kein weiterer Punkt gespeichert.
  ],
  standardablauf: [
    1. Host übergibt `GpsFix fix`.\
    2. System validiert lat/lon (WGS84) und Zeitstempel.\
    3. System prüft Segmentlücke und Punktbudget (Soft/Hard-Limit).\
    4. System speichert Fix im Rohspeicher (/LF100/).\
    5. System berechnet Azimut, Distanz, Ordinal; optional Kursabweichung.\
    6. System feuert `onPositionProcessed(BearingSnapshot)` an alle Listener.
  ],
  alternativablauf: [
    *2a – Koordinaten ungültig:* Exception; kein Punkt gespeichert.\
    *2b – Zeitstempel ungültig:* Exception; kein Punkt gespeichert.\
    *3b – Erster Fix:* eröffnet Segment 1 automatisch.\
    *5a – Hard-Limit STOP:* `onHardLimitReached`; Session bleibt ACTIVE.\
    *6a – Listener wirft:* Exception gefangen; restliche Listener weiter.
  ],
  sonstiges: lf-sonstiges(
    systemgrenzen: [Kein Sensorzugriff; nicht thread-sicher; Host steuert Aufrufhäufigkeit.],
    speziell: [Azimut ±1° für D > 10 m; Segmentierung konfigurierbar; /LL020/.],
    bemerkungen: [Optionale Felder ohne Normierung; negative hdop/speed → `ValidationException(INVALID_FIELD_VALUE)`.],
  ),
)

#lf-flowchart(
  "/LF030/",
  (
    [Fix validieren],
  ),
  decision: [Gültig?],
  error-label: [nein],
  branch-fail: [Exception],
  steps-after: (
    [Segment + Budget prüfen],
    [Speichern + Peilung berechnen],
    [Listener benachrichtigen],
  ),
)

#pagebreak()

#lf-card(
  id: "/LF050/",
  funktion: "Peilungswerte lesen",
  akteur: [Host-App (Primär). Sekundär: keine.],
  verweise: [/LF030/, Projektauftrag SWE],
  einbindungen: [---],
  datenzugriffe: [/LD140/],
  beschreibung: [Die Host-App fragt den aktuellen Peilungsschnappschuss ab. Das System gibt Azimut, Entfernung zum Ziel und diskrete Himmelsrichtung zurück. Optional Kursabweichung, falls Kurs bekannt.],
  ausloeser: [Host ruft `getSnapshot()` zur UI-Aktualisierung auf.],
  vorbedingung: [
    1. Session im Zustand `ACTIVE`.\
    2. Mindestens ein gültiger Fix wurde über /LF030/ verarbeitet (für befüllten Snapshot).
  ],
  nach_erfolg: [
    `BearingSnapshot` mit Azimut, Distanz, Ordinal; optional `bearingErrorDeg`. Kein interner Zustand verändert.
  ],
  nach_fehler: [
    Session nicht ACTIVE oder kein Fix: `Optional.empty()` — kein Fehler, kein Log.
  ],
  standardablauf: [
    1. Host ruft `getSnapshot()` auf.\
    2. System prüft: mindestens ein Fix im Rohspeicher?\
    3. System leitet `compassOrdinal` aus `azimuthDeg` ab (8-teilig).\
    4. System befüllt optionale Kursabweichung.\
    5. System gibt immutables `Optional<BearingSnapshot>` zurück.
  ],
  alternativablauf: [
    *2a – Kein Fix:* `Optional.empty()`.\
    *1a – Nicht ACTIVE:* `Optional.empty()` (Javadoc).
  ],
  sonstiges: lf-sonstiges(
    systemgrenzen: [Nur lesend; kein Netzwerk/Dateizugriff.],
    speziell: [Immutables Value Object; 45°-Segmentierung; nie null-Rückgabe.],
    bemerkungen: [Snapshot = Zustand nach letztem Fix; kein Live-Tracking zwischen Aufrufen.],
  ),
)

#lf-flowchart(
  "/LF050/",
  (
    [`getSnapshot()` aufrufen],
  ),
  decision: [Fix vorhanden?],
  error-label: [nein],
  branch-fail: [Optional.empty()],
  steps-after: (
    [Snapshot ableiten],
    [`Optional<BearingSnapshot>` zurück],
  ),
)

#lf-card(
  id: "/LF060/",
  funktion: "Peilung regulär beenden",
  akteur: [Host-App (Primär). Sekundär: Dateisystem (optional).],
  verweise: [/LF010/, /LF200/, Projektauftrag SWE],
  einbindungen: [/LF200/ GPX-Export],
  datenzugriffe: [/LD150/],
  beschreibung: [Die Host-App schließt eine laufende Peilungs-Session regulär ab. Das System wechselt zu COMPLETED, erzeugt GPX 1.1, berechnet Statistiken und benachrichtigt Listener.],
  ausloeser: [Navigationsaufgabe abgeschlossen; Host ruft `complete()` auf.],
  vorbedingung: [
    1. Session im Zustand `ACTIVE`.\
    2. Kein gleichzeitiger `abort()`-Aufruf.
  ],
  nach_erfolg: [
    Zustand = `COMPLETED`; `GpxResult` und `SessionStats` zurückgegeben; Listener benachrichtigt; optional GPX-Datei geschrieben.
  ],
  nach_fehler: [
    Session nicht ACTIVE: `BearingStateException(SESSION_ENDED)`.\
    Dateischreiben fehlgeschlagen: `BearingIOException`; Zustand dennoch COMPLETED.
  ],
  standardablauf: [
    1. Host ruft `complete()` auf.\
    2. System setzt `endedAt` und Zustand `COMPLETED`.\
    3. System erstellt immutable View des Rohtracks.\
    4. System führt GPX-Export aus (/LF200/).\
    5. System berechnet `SessionStats` und feuert `onSessionCompleted`.\
    6. System gibt `GpxResult` zurück.
  ],
  alternativablauf: [
    *1a – Nicht ACTIVE:* `SESSION_ENDED`.\
    *4a – IO-Fehler:* `BearingIOException`; `GpxResult` gültig.\
    *5a – Listener wirft:* WARN-Log; restliche Listener weiter.
  ],
  sonstiges: lf-sonstiges(
    systemgrenzen: [Optimierung nur auf Export-Kopie; Path-Traversal-Schutz.],
    speziell: [GPX 1.1 Namespace; ISO-8601 UTC; atomares Schreiben; Export < 2 s / 10k Punkte.],
    bemerkungen: [Nach `complete()` ist `reset()` für neue Session nötig (/LL160/).],
  ),
)

#lf-flowchart(
  "/LF060/",
  (),
  decision: [Session ACTIVE?],
  error-label: [nein],
  branch-fail: [`SESSION_ENDED`],
  steps-after: (
    [`complete()` aufrufen],
    [Zustand COMPLETED setzen],
    [GPX exportieren (/LF200/)],
    [Listener + GpxResult],
  ),
)

#pagebreak()

#lf-card(
  id: "/LF070/",
  funktion: "Peilung abbrechen",
  akteur: [Host-App (Primär). Sekundär: Dateisystem (optional).],
  verweise: [/LF010/, /LF200/, /LF230/, Klärungsgespräch Peter Bohl],
  einbindungen: [/LF200/ GPX-Export],
  datenzugriffe: [/LD150/],
  beschreibung: [Die Host-App bricht eine laufende Session vorzeitig ab. Track-Daten bleiben als GPX abrufbar. Datei nur bei `persistOnAbort = true`.],
  ausloeser: [Feldabbruch, Verbindungsabbruch oder externe Steuerlogik; Host ruft `abort()` auf.],
  vorbedingung: [
    1. Session im Zustand `ACTIVE`.\
    2. Kein gleichzeitiger `complete()`-Aufruf.
  ],
  nach_erfolg: [
    Zustand = `ABORTED`; `GpxResult` mit allen Punkten bis Abort; `SessionStats` berechnet.
  ],
  nach_fehler: [
    Session nicht ACTIVE: `BearingStateException(SESSION_ENDED)`.
  ],
  standardablauf: [
    1. Host ruft `abort()` auf.\
    2. System setzt `endedAt` und Zustand `ABORTED`.\
    3. System serialisiert GPX 1.1 (/LF200/).\
    4. Optional: atomares Dateischreiben bei `persistOnAbort = true`.\
    5. System feuert `onSessionAborted` und gibt `GpxResult` zurück.
  ],
  alternativablauf: [
    *1a – Nicht ACTIVE:* `SESSION_ENDED`.\
    *3a – Leerer Track:* valides GPX mit leerem `<trk>`.\
    *4a – persistOnAbort false:* kein Dateizugriff.\
    *4b – IO-Fehler:* `BearingIOException`; `GpxResult` gültig.
  ],
  sonstiges: lf-sonstiges(
    systemgrenzen: [GPX-Export keine Pflicht; Pfad obliegt Host.],
    speziell: [Track-Daten werden nicht verworfen; leerer Track = valides GPX.],
    bemerkungen: [Primäre Methode für Ausnahmefälle.],
  ),
)

#lf-flowchart(
  "/LF070/",
  (),
  decision: [Session ACTIVE?],
  error-label: [nein],
  branch-fail: [`SESSION_ENDED`],
  steps-after: (
    [`abort()` aufrufen],
    [Zustand ABORTED setzen],
    [GPX erzeugen (/LF200/)],
    [Optional Datei schreiben],
    [GpxResult zurückgeben],
  ),
)

#pagebreak()

#lf-card(
  id: "/LF200/",
  funktion: "GPX exportieren und optimieren",
  akteur: [Host-App (Primär). Sekundär: Dateisystem (optional).],
  verweise: [/LF060/, /LF070/, GPX 1.1, OWASP Path Traversal],
  einbindungen: [/LF240/–/LF270/ Optimierer, /LF490/],
  datenzugriffe: [/LD120/, /LD150/],
  beschreibung: [Nach Abschluss oder Abbruch erzeugt das System ein GPX-1.1-Dokument. Optional Optimierungspipeline. Export als String, Byte-Array und optional Datei.],
  ausloeser: [Intern durch /LF060/ (`complete()`) oder /LF070/ (`abort()`) ausgelöst.],
  vorbedingung: [
    1. Session `COMPLETED` oder `ABORTED`.\
    2. Rohtrack als immutable View verfügbar (auch leer).
  ],
  nach_erfolg: [
    Valides `GpxResult` (String + Bytes); optional Datei auf Disk; Rohspeicher unverändert.
  ],
  nach_fehler: [
    Path-Traversal: `SecurityException(PATH_TRAVERSAL)`.\
    Dateisystemfehler: `BearingIOException`; `GpxResult` dennoch gültig.
  ],
  standardablauf: [
    1. System klont Rohtrack.\
    2. System wendet registrierte `TrackOptimizer` an (/LF240/–/LF270/).\
    3. System erstellt GPX-Metadaten und serialisiert XML 1.1.\
    4. System escaped Strings und kodiert UTF-8 ohne BOM.\
    5. Optional: Pfad prüfen und atomar schreiben.\
    6. System gibt `GpxResult` zurück.
  ],
  alternativablauf: [
    *2a – Keine Optimizer:* Rohpunkte direkt exportieren.\
    *5a – Path-Traversal:* `SecurityException`; kein Schreiben.\
    *Leerer Track:* GPX mit leerem `<trk>`.
  ],
  sonstiges: lf-sonstiges(
    systemgrenzen: [Kein Netzwerk; Douglas-Peucker bis 50 km Segment.],
    speziell: [Namespace Pflicht; /LL130/ XML-Escaping; Export < 2 s / 10k Punkte.],
    bemerkungen: [Optimierung wirkt nur auf Export-Kopie.],
  ),
)

#lf-flowchart(
  "/LF200/",
  (
    [Rohtrack klonen],
    [Optimizer-Kette],
    [GPX 1.1 serialisieren],
    [Optional atomar schreiben],
  ),
)

#pagebreak()

#lf-card(
  id: "/LF280/",
  funktion: "What3Words-Adresse auflösen",
  akteur: [Host-App (Primär). Sekundär: W3W-API, LRU-Cache.],
  verweise: [/LF290/, What3Words API Docs],
  einbindungen: [---],
  datenzugriffe: [/LD160/],
  beschreibung: [Host löst WGS84-Koordinate in W3W-Dreiwortkombination auf. Cache-Lookup zuerst; bei Miss HTTPS-Anfrage. Bei Fehler Fallback-String.],
  ausloeser: [Host ruft `resolveW3w(GeoCoordinate coordinate)` auf.],
  vorbedingung: [
    1. `w3wApiKey` konfiguriert und nicht leer (sonst Variante ohne Key).\
    2. Koordinate valide (WGS84).
  ],
  nach_erfolg: [
    W3W-String zurückgegeben; bei Erfolg Cache-Eintrag mit TTL.
  ],
  nach_fehler: [
    Kein Key, Timeout, HTTP-Fehler: Fallback `"w3w://unavailable"` + WARN-Log.\
    Koordinate ungültig: `ValidationException(COORD_RANGE)`.
  ],
  standardablauf: [
    1. Host ruft `resolveW3w(coordinate)` auf.\
    2. System normalisiert Koordinate (Cache-Schlüssel).\
    3. Cache-Treffer mit gültiger TTL? → Rückgabe.\
    4. HTTPS-Request an W3W-API (Timeout 5 s).\
    5. JSON parsen, Cache aktualisieren, `words` zurückgeben.
  ],
  alternativablauf: [
    *1a – Kein API-Key:* Fallback sofort (siehe /LF280/ Variante „Ohne Key“).\
    *4a – Timeout:* Fallback + WARN-Log.\
    *4b – HTTP 4xx/5xx:* Fallback + WARN-Log.\
    *2a – Koordinate ungültig:* `ValidationException`.
  ],
  sonstiges: lf-sonstiges(
    systemgrenzen: [Opportunistisch; Fehler beeinträchtigt Session nicht.],
    speziell: [LRU-Cache 256 Einträge, TTL 1 h; Maven-Profil `w3w`.],
    bemerkungen: [Max. 1 Retry konfigurierbar.],
  ),
)

#lf-flowchart(
  "/LF280/",
  (
    [`resolveW3w()` aufrufen],
    [Cache prüfen],
    [HTTPS-Anfrage W3W],
    [Ergebnis cachen + zurückgeben],
  ),
  decision: [Cache-Treffer?],
)

#lf-card(
  id: "/LF280/",
  funktion: "W3W-Fallback ohne API-Key",
  akteur: [Host-App (Primär). Sekundär: keine.],
  verweise: [/LF280/ Lookup-Hauptfunktion],
  einbindungen: [---],
  datenzugriffe: [–],
  beschreibung: [Host ruft W3W-Lookup ohne API-Key auf. System verzichtet auf Netzwerk und gibt Fallback-String zurück.],
  ausloeser: [`w3wApiKey` leer oder nicht gesetzt bei `resolveW3w()`.],
  vorbedingung: [`w3wApiKey` in `SessionConfig` ist leer oder `Optional.empty()`.],
  nach_erfolg: [Rückgabe `"w3w://unavailable"`; WARN-Log; kein Netzwerkaufruf.],
  nach_fehler: [–],
  standardablauf: [
    1. System stellt fest: kein API-Key.\
    2. WARN-Log mit `sessionId`, Ursache `NO_API_KEY`.\
    3. Rückgabe `"w3w://unavailable"`.
  ],
  alternativablauf: [–],
  sonstiges: lf-sonstiges(
    systemgrenzen: [Kein Netzwerkaufruf ohne API-Key.],
    speziell: [MDC-Feld `sessionId` im WARN-Log.],
    bemerkungen: [In Javadoc von `resolveW3w()` dokumentiert.],
  ),
)

#lf-flowchart(
  "/LF280/ (ohne Key)",
  (
    [Kein API-Key erkannt],
    [WARN-Log schreiben],
    [Fallback zurückgeben],
  ),
)

#lf-card(
  id: "/LF280/",
  funktion: "W3W-Netzwerk-Timeout",
  akteur: [Host-App (Primär). Sekundär: W3W-API (nicht erreichbar).],
  verweise: [/LF280/ Lookup-Hauptfunktion, OWASP API Security],
  einbindungen: [---],
  datenzugriffe: [–],
  beschreibung: [W3W-API antwortet nicht innerhalb des Timeout-Limits. System bricht ab, loggt WARN und gibt Fallback zurück. Session unbeeinträchtigt.],
  ausloeser: [HTTP-Client erkennt Timeout bei W3W-REST-Anfrage.],
  vorbedingung: [API-Key vorhanden; Netzwerkaufruf ausgelöst; Timeout überschritten.],
  nach_erfolg: [Fallback zurückgegeben; WARN-Log; Session aktiv.],
  nach_fehler: [–],
  standardablauf: [
    1. HTTP-Client erkennt Timeout.\
    2. System fängt Timeout-Exception intern.\
    3. WARN-Log (Dauer, URL, sessionId).\
    4. Rückgabe `"w3w://unavailable"`.
  ],
  alternativablauf: [–],
  sonstiges: lf-sonstiges(
    systemgrenzen: [Timeout konfigurierbar, Standard 5 s.],
    speziell: [Exception darf nicht propagieren; kein unkontrollierter Thread.],
    bemerkungen: [CI-Test mit Mock-Server empfohlen.],
  ),
)

#lf-flowchart(
  "/LF280/ (Timeout)",
  (
    [Timeout erkannt],
    [Exception abfangen],
    [WARN-Log + Fallback],
  ),
)

#pagebreak()

#lf-card(
  id: "/LF230/",
  funktion: "GPX als Byte-Array exportieren",
  akteur: [Host-App (Primär). Sekundär: keine.],
  verweise: [/LF060/, /LF070/, /LF200/, RFC 3629],
  einbindungen: [---],
  datenzugriffe: [/LD150/],
  beschreibung: [Host greift auf GPX-Export als `byte[]` (UTF-8, kein BOM) zu — z. B. HTTP, OutputStream, Datenbank.],
  ausloeser: [Host benötigt GPX als Byte-Array nach Session-Ende.],
  vorbedingung: [Session `COMPLETED` oder `ABORTED`; `GpxResult` von /LF060/ oder /LF070/ vorhanden.],
  nach_erfolg: [`byte[]` UTF-8 ohne BOM; Länge > 0 bei nicht-leerem Track.],
  nach_fehler: [–],
  standardablauf: [
    1. Host ruft `GpxResult.gpxBytes()` auf.\
    2. System gibt vorberechnetes `byte[]` zurück (kein Re-Serialisieren).
  ],
  alternativablauf: [–],
  sonstiges: lf-sonstiges(
    systemgrenzen: [Kein Datei-/Netzwerkzugriff.],
    speziell: [Byte-äquivalent zu `gpxString`; kein BOM; immutable Cache.],
    bemerkungen: [Leerer Track liefert minimales valides GPX-Byte-Array.],
  ),
)

#lf-flowchart(
  "/LF230/",
  (
    [`gpxBytes()` aufrufen],
    [Vorberechnetes byte[] zurückgeben],
  ),
)

#lf-card(
  id: "/LF080/",
  funktion: "Listener-Exception isolieren",
  akteur: [Host-App (Primär; fehlerhafte Listener-Implementierung).],
  verweise: [/LF010/, /LF030/, /LF060/, /LF070/, Observer-Pattern],
  einbindungen: [---],
  datenzugriffe: [–],
  beschreibung: [Ein `BearingListener` wirft bei Callback eine RuntimeException. System fängt ab, loggt und benachrichtigt restliche Listener. Session bleibt konsistent.],
  ausloeser: [Fehlerhafter Listener bei Event-Aufruf (/LF010/–/LF070/).],
  vorbedingung: [Listener registriert; wirft `RuntimeException` bei Callback.],
  nach_erfolg: [Restliche Listener benachrichtigt; WARN-Log; Session konsistent.],
  nach_fehler: [–],
  standardablauf: [
    1. System ruft `listener.onXxx(payload)` auf.\
    2. Listener wirft `RuntimeException`.\
    3. System fängt Exception intern.\
    4. WARN-Log mit Typ, Message, sessionId (MDC).\
    5. Iteration mit nächstem Listener fortsetzen.
  ],
  alternativablauf: [–],
  sonstiges: lf-sonstiges(
    systemgrenzen: [Gilt für alle `BearingListener`-Callbacks.],
    speziell: [Contract in Javadoc; keine Abbruch der gesamten Schleife.],
    bemerkungen: [Postel's Law — tolerant gegenüber fehlerhaftem Host-Code.],
  ),
)

#lf-flowchart(
  "/LF080/",
  (
    [Listener aufrufen],
  ),
  decision: [Exception geworfen?],
  error-label: [ja],
  branch-fail: [WARN-Log],
  steps-after: (
    [Nächster Listener],
  ),
)

#pagebreak()

#lf-card(
  id: "/LL160/",
  funktion: "Session zurücksetzen",
  akteur: [Host-App (Primär). Sekundär: keine.],
  verweise: [/LF010/, /LF060/, /LF070/],
  einbindungen: [---],
  datenzugriffe: [–],
  beschreibung: [Host setzt Bibliothek nach COMPLETED/ABORTED auf IDLE zurück. Neue Session (/LF010/) ohne JVM-Neustart möglich.],
  ausloeser: [Host möchte nach /LF060/ oder /LF070/ erneut starten; ruft `reset()` auf.],
  vorbedingung: [Session im Zustand `COMPLETED` oder `ABORTED`.],
  nach_erfolg: [Zustand = `IDLE`; interne Felder gelöscht; `startSession()` wieder aufrufbar.],
  nach_fehler: [
    Session `ACTIVE`: `BearingStateException(SESSION_STILL_ACTIVE)`; kein Reset.
  ],
  standardablauf: [
    1. Host ruft `reset()` auf.\
    2. System prüft Zustand COMPLETED oder ABORTED.\
    3. System löscht Session-Felder (UUID, Zeiten, Rohspeicher, Peilung).\
    4. System wechselt zu `IDLE`.\
    5. `/LF010/` kann erneut aufgerufen werden.
  ],
  alternativablauf: [
    *2a – Session ACTIVE:* `SESSION_STILL_ACTIVE`; kein Reset.
  ],
  sonstiges: lf-sonstiges(
    systemgrenzen: [Kein Netzwerk/Dateizugriff beim Reset.],
    speziell: [W3W-LRU-Cache wird nicht geleert (sessions-übergreifend).],
    bemerkungen: [Voraussetzung für Langzeit-Betrieb ohne JVM-Neustart.],
  ),
)

#lf-flowchart(
  "/LL160/",
  (
    [`reset()` aufrufen],
  ),
  decision: [COMPLETED/ABORTED?],
  error-label: [nein],
  branch-fail: [`STILL_ACTIVE`],
  steps-after: (
    [Interne Felder löschen],
    [Zustand IDLE setzen],
  ),
)

#pagebreak()

]
