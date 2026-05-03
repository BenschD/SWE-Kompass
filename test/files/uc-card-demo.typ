#import "uc-card.typ": uc-card

#set page(paper: "a4", margin: (x: 1.8cm, y: 2cm))
#set text(lang: "de", font: "Helvetica Neue", size: 11pt, fallback: true)

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
