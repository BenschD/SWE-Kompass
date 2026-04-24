# Traceability: Lastenheft ↔ Code ↔ Tests

Kurzmatrix gemäß Vorschrieb (`/LF…/`, `/TC…/`). Detaillierte Anforderungen: [Vorschrieb/main.typ](../Vorschrieb/main.typ).

Das Pflichtenheft verlangt pro `/LF…/` mindestens einen **Testfall oder Review-Nachweis**. Die Spalte **JUnit** unten bezeichnet ausschließlich **automatisierte** Tests unter `**/src/test/**` (Stand: Analyse des Repos).

## Kernreferenzen (Auszug)

| Anforderung | Code (Auszug) | Test |
|-------------|---------------|------|
| /LF010/ Session start | `DefaultBearingSession.start` | `BearingSessionTest.happyPathCompleteProducesGpx` |
| /LF020/ Einzel-aktive Session | `DefaultBearingSession.start` | `BearingSessionTest.tc010_doubleStartThrows` |
| /LF030/ Positionsupdate | `DefaultBearingSession.onPositionUpdate` | `BearingSessionTest.happyPathCompleteProducesGpx` |
| /LF050/ Snapshot | `BearingCalculator`, `currentSnapshot` | siehe Vollmatrix (kein direkter Aufruf in Tests) |
| /LF060/ Complete | `DefaultBearingSession.complete` | `BearingSessionTest.happyPathCompleteProducesGpx` |
| /LF080/ Listener | `DefaultBearingSession.addListener` | `BearingSessionTest.listenerInvoked` |
| /LF090/ Fehlercodes | `ValidationException`, `ErrorCode` | `BearingSessionTest.tc020_invalidLatThrows` |
| /LF200/ GPX 1.1 | `GpxXmlWriter` | `GpxXmlWriterTest` |
| /LF240/ n-Optimierer | `NthPointOptimizer` | `BearingSessionTest.tc110_nthOptimizer` |
| /LF320/ Path Traversal | `SafeFileSink` | `BearingSessionTest.tc090_pathTraversalSecurity` |
| /LF430/ keine UI | Keine Abhängigkeiten zu AWT/Swing/JavaFX | Review / optional ArchUnit |
| /LL020/ Haversine-Referenz | `BearingCalculator` | `BearingCalculatorReferenceTest` |
| /LL160/ Reset | `DefaultBearingSession.reset` | `BearingSessionTest.resetAllowsRestart` |
| /LF220/ Atomares Schreiben | `SafeFileSink` | `SafeFileSinkJimfsTest` |

Weitere `/LF`-IDs sind in den jeweiligen Klassen-Javadocs referenziert.

**Nicht implementiert (Out-of-Scope, siehe Vorschrieb-Anhang):** `/LF110/`, `/LF130/`, `/LF140/`, `/LF160/` — keine zusätzliche Eingangsreduktion; Rohspeicher mit Limits und Segmentierung.

## Vollständige LF-Matrix — JUnit-Abdeckung (Ist)

Legende: **ja** = dedizierter oder eindeutiger Testpfad; **teilw.** = nur Randfall oder indirekt; **nein** = kein zugeordneter `@Test`; **Build/Review** = Tooling, Doku oder manueller Nachweis; **n. a.** = nicht Lieferumfang.

| /LF/ | JUnit | Hinweis |
|------|-------|---------|
| /LF010/ | ja | `happyPathCompleteProducesGpx`, `listenerInvoked` |
| /LF020/ | ja | `tc010_doubleStartThrows` |
| /LF030/ | ja | Happy Path; Negativ `tc020_invalidLatThrows` |
| /LF040/ | nein | `onCourseUpdate` ohne Test |
| /LF050/ | nein | `currentSnapshot()` in keinem Test |
| /LF060/ | ja | `happyPathCompleteProducesGpx` |
| /LF070/ | nein | `abort()` ohne Test |
| /LF080/ | teilw. | nur Start + Positionsupdate in `listenerInvoked` |
| /LF090/ | teilw. | v. a. Koordinaten-`ValidationException` |
| /LF100/ | teilw. | über Session-Happy-Path / Optimierer-Pfad |
| /LF120/ | nein | Punktbudget Soft/Hard |
| /LF150/ | nein | optionale Fix-Felder in GPX |
| /LF170/ | nein | Segmentierung bei Zeitlücke |
| /LF180/ | nein | Hard-Limit / Overflow-Modus |
| /LF200/ | ja | `GpxXmlWriterTest` + Namespace im Happy Path |
| /LF210/ | nein | GPX-Metadaten nicht assertiert |
| /LF220/ | teilw. | `SafeFileSinkJimfsTest` (positiv); Traversal über `complete` |
| /LF230/ | teilw. | `GpxResult.asUtf8String()` im Happy Path |
| /LF240/ | ja | `tc110_nthOptimizer` |
| /LF250/ | nein | `MinDistanceOptimizer` |
| /LF260/ | nein | `LineCollinearityOptimizer` |
| /LF270/ | nein | `DouglasPeuckerOptimizer` |
| /LF280/ | nein | W3W-Integration standardmäßig übersprungen (`w3w.integration.skip`) |
| /LF290/ | nein | W3W-Cache |
| /LF300/ | teilw. | nur ungültige Breite |
| /LF310/ | nein | Zeitstempel Zukunft/zu alt — keine Tests |
| /LF320/ | ja | `tc090_pathTraversalSecurity` |
| /LF330/ | nein | Logging / „keine stillen Verluste“ |
| /LF340/ | nein | Clock wird in Tests genutzt, kein eigener LF340-Nachweis |
| /LF350/ | Build/Review | Threading nur Javadoc |
| /LF400/ | nein | ungültige `SessionConfig` beim Start |
| /LF410/ | nein | Config-Freeze nach Start |
| /LF420/ | nein | strukturiertes Logging |
| /LF430/ | Build/Review | keine UI-Imports |
| /LF440/ | Build/Review | Java 11+, Enforcer/Compiler |
| /LF450/ | Build/Review | Maven-Build |
| /LF460/ | nein | UTC/`Instant` nicht explizit getestet |
| /LF470/ | nein | Null-Semantik / `Optional`-API |
| /LF480/ | teilw. | nur über registrierten `NthPointOptimizer` |
| /LF490/ | nein | Trennung Mapper vs. Writer nicht isoliert |
| /LF500/ | teilw. | `storedPointCount`; Distanz/Dauer nicht assertiert |
| /LF110/ | n. a. | Out-of-Scope |
| /LF130/ | n. a. | Out-of-Scope |
| /LF140/ | n. a. | Out-of-Scope |
| /LF160/ | n. a. | Out-of-Scope |

Testdateien: `bearing-api` — `BearingSessionTest`, `GpxXmlWriterTest`, `SafeFileSinkJimfsTest`; `bearing-domain` — `BearingCalculatorReferenceTest`.
