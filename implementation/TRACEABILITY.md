# Traceability: Anforderungen ↔ Code ↔ Tests

Master-Katalog: [`Documentation/include/requirement-catalog.typ`](../Documentation/include/requirement-catalog.typ)

Nummerierung: `/LF010/` … `/LF250/`, `/LL010/` … `/LL080/`, `/TC010/` … `/TC150/`

## Testfälle

| TC | LF / LL | JUnit-Methode | Testklasse |
|----|---------|---------------|------------|
| /TC010/ | /LF010/, /LF020/ | `tc010_doubleStartThrows` | `BearingSessionTest` |
| /TC020/ | /LF030/, /LF230/ | `tc020_invalidLatThrows` | `BearingSessionTest` |
| /TC030/ | /LF030/, /LF240/ | `tc030_futureTimestampThrows` | `BearingSessionTest` |
| /TC040/ | /LF060/, /LF030/ | `tc040_updateAfterCompleteThrows` | `BearingSessionTest` |
| /TC050/ | /LF050/ | `tc050_snapshotWithoutFixThrows` | `BearingSessionTest` |
| /TC060/ | /LF110/ | `tc060_softLimitWarns` | `TrackAggregatorTest` |
| /TC070/ | /LF130/ | `tc070_hardLimitStopsRecording` | `TrackAggregatorTest` |
| /TC080/ | /LF070/ | `tc080_abortProducesGpx` | `BearingSessionTest` |
| /TC090/ | /LF250/ | `tc090_pathTraversalSecurity` | `BearingSessionTest` |
| /TC100/ | /LF140/ | `tc100_gpxNamespace` | `GpxXmlWriterTest` |
| /TC110/ | /LF170/ | `tc110_nthOptimizer` | `BearingSessionTest` |
| /TC120/ | /LF080/ | `tc120_listenerExceptionIsolated` | `BearingSessionTest` |
| /TC130/ | /LF090/ | `tc130_resetAllowsRestart` | `BearingSessionTest` |
| /TC140/ | /LL020/ | `tc140_azimuthReference` | `BearingCalculatorReferenceTest` |
| /TC150/ | /LF120/ | `tc150_segmentSplit` | `TrackAggregatorTest` |

## Ergänzende Nachweise (ohne `/TC…/`)

| LF | JUnit-Methode | Testklasse | Hinweis |
|----|---------------|------------|---------|
| /LF150/ | `writesInsideBase` | `SafeFileSinkJimfsTest` | Atomares Schreiben unter `allowedBaseDir`; ergänzt Demo Schritt 6–7 |

## Funktionale Anforderungen

| LF | Code (Auszug) |
|----|----------------|
| /LF010/ | `DefaultBearingSession.start` |
| /LF020/ | `DefaultBearingSession.start` (IDLE/CAS) |
| /LF030/ | `DefaultBearingSession.onPositionUpdate` |
| /LF040/ | `DefaultBearingSession.onCourseUpdate` |
| /LF050/ | `DefaultBearingSession.currentSnapshot` |
| /LF060/ | `DefaultBearingSession.complete` |
| /LF070/ | `DefaultBearingSession.abort` |
| /LF080/ | `DefaultBearingSession.fire`, `BearingListener` |
| /LF090/ | `DefaultBearingSession.reset` |
| /LF100/ | `TrackAggregator.accept` |
| /LF110/ | `onSoftLimitWarn` |
| /LF120/ | `TrackAggregator` Segment-Split |
| /LF130/ | Hard-Limit STOP in `TrackAggregator` |
| /LF140/ | `GpxXmlWriter`, `OptimizationPipeline` |
| /LF150/ | `SafeFileSink` |
| /LF160/ | `GpxResult` |
| /LF170/ | `NthPointOptimizer` |
| /LF180/ | `MinDistanceOptimizer` |
| /LF190/ | `LineCollinearityOptimizer` |
| /LF200/ | `DouglasPeuckerOptimizer` |
| /LF210/ | `W3wHttpClient`, `NoopW3wClient` |
| /LF220/ | `W3wHttpClient` Cache |
| /LF230/ | `ValidationException COORD_RANGE` |
| /LF240/ | `ValidationException TIMESTAMP_INVALID` |
| /LF250/ | `SafeFileSink` → `SecurityException` |

## Nicht-funktionale Anforderungen

| LL | Nachweis |
|----|----------|
| /LL010/ | /TC020/, /TC030/ |
| /LL020/ | /TC140/ |
| /LL030/ | Java 11 Enforcer, keine UI-Imports |
| /LL040/ | `mvn test` |
| /LL050/ | /TC100/, `XmlEscaper` |
| /LL060/ | `Slf4jLoggerAdapter` |
| /LL070/ | `ClockPort` in Tests |
| /LL080/ | Javadoc öffentliche API |
