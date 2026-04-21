# Traceability: Lastenheft ↔ Code ↔ Tests

Kurzmatrix gemäß Vorschrieb (`/LF…/`, `/TC…/`). Detaillierte Anforderungen: [Vorschrieb/main.typ](../Vorschrieb/main.typ).

| Anforderung | Code (Auszug) | Test |
|-------------|---------------|------|
| /LF010/ Session start | `DefaultBearingSession.start` | `BearingSessionTest.happyPathCompleteProducesGpx` |
| /LF020/ Einzel-aktive Session | `DefaultBearingSession.start` | `BearingSessionTest.tc010_doubleStartThrows` |
| /LF030/ Positionsupdate | `DefaultBearingSession.onPositionUpdate` | `BearingSessionTest.happyPathCompleteProducesGpx` |
| /LF050/ Snapshot | `BearingCalculator`, `currentSnapshot` | `BearingSessionTest` (implizit via GPX-Pfad) |
| /LF060/ Complete | `DefaultBearingSession.complete` | `BearingSessionTest.happyPathCompleteProducesGpx` |
| /LF080/ Listener | `DefaultBearingSession.addListener` | `BearingSessionTest.listenerInvoked` |
| /LF090/ Fehlercodes | `ValidationException`, `ErrorCode` | `BearingSessionTest.tc020_invalidLatThrows` |
| /LF200/ GPX 1.1 | `GpxXmlWriter` | `GpxXmlWriterTest` |
| /LF240/ n-Optimierer | `NthPointOptimizer` | `BearingSessionTest.tc110_nthOptimizer` |
| /LF320/ Path Traversal | `SafeFileSink` | `BearingSessionTest.tc090_pathTraversalSecurity` |
| /LF430/ keine UI | Keine Abhängigkeiten zu AWT/Swing/JavaFX (Review) | manuell / optional ArchUnit |
| /LL020/ Haversine-Referenz | `BearingCalculator` | `BearingCalculatorReferenceTest` |
| /LL160/ Reset | `DefaultBearingSession.reset` | `BearingSessionTest.resetAllowsRestart` |
| /LF220/ Atomares Schreiben | `SafeFileSink` | `SafeFileSinkJimfsTest` |

Weitere `/LF`-IDs sind in den jeweiligen Klassen-Javadocs referenziert.
