package com.example.bearing.domain;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Optional;
import org.junit.jupiter.api.Test;

/** /TC060/, /TC070/, /TC150/ — Track-Limits und Segmentierung. */
class TrackAggregatorTest {

    private static GpsFix fix(Instant t, double lat, double lon) {
        return new GpsFix(t, lat, lon, Optional.empty(), Optional.empty(), Optional.empty());
    }

    @Test
    void tc060_softLimitWarns() {
        RecordingParameters params =
                new RecordingParameters(2, 0, OverflowMode.STOP, Duration.ofMinutes(5));
        TrackAggregator agg = new TrackAggregator(params);
        Instant t0 = Instant.parse("2026-01-01T12:00:00Z");

        TrackAcceptResult r1 = agg.accept(fix(t0, 48.77, 9.17));
        TrackAcceptResult r2 = agg.accept(fix(t0.plusSeconds(1), 48.771, 9.171));
        TrackAcceptResult r3 = agg.accept(fix(t0.plusSeconds(2), 48.772, 9.172));

        assertThat(r1.has(TrackAcceptResult.Flag.STORED)).isTrue();
        assertThat(r2.has(TrackAcceptResult.Flag.SOFT_LIMIT_WARN)).isFalse();
        assertThat(r3.has(TrackAcceptResult.Flag.SOFT_LIMIT_WARN)).isTrue();
        assertThat(r3.has(TrackAcceptResult.Flag.STORED)).isTrue();
    }

    @Test
    void tc070_hardLimitStopsRecording() {
        RecordingParameters params =
                new RecordingParameters(0, 2, OverflowMode.STOP, Duration.ofMinutes(5));
        TrackAggregator agg = new TrackAggregator(params);
        Instant t0 = Instant.parse("2026-01-01T12:00:00Z");

        agg.accept(fix(t0, 48.77, 9.17));
        agg.accept(fix(t0.plusSeconds(1), 48.771, 9.171));
        TrackAcceptResult r3 = agg.accept(fix(t0.plusSeconds(2), 48.772, 9.172));

        assertThat(r3.has(TrackAcceptResult.Flag.HARD_LIMIT_REACHED)).isTrue();
        assertThat(r3.has(TrackAcceptResult.Flag.RECORDING_STOPPED)).isTrue();
        assertThat(agg.immutableTrack().totalPoints()).isEqualTo(2);
    }

    @Test
    void tc150_segmentSplit() {
        RecordingParameters params =
                new RecordingParameters(0, 0, OverflowMode.STOP, Duration.ofMinutes(5));
        TrackAggregator agg = new TrackAggregator(params);
        Instant t0 = Instant.parse("2026-01-01T12:00:00Z");

        agg.accept(fix(t0, 48.77, 9.17));
        agg.accept(fix(t0.plus(6, ChronoUnit.MINUTES), 48.78, 9.18));
        agg.finalizeOpenSegment();

        assertThat(agg.immutableTrack().segments()).hasSize(2);
    }
}
