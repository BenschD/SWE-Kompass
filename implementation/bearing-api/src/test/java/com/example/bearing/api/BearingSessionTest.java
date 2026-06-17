package com.example.bearing.api;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.example.bearing.adapter.system.NoopW3wClient;
import com.example.bearing.adapter.system.SystemClockAdapter;
import com.example.bearing.domain.GeoCoordinate;
import com.example.bearing.domain.GpsFix;
import com.example.bearing.domain.optimize.NthPointOptimizer;
import com.google.common.jimfs.Configuration;
import com.google.common.jimfs.Jimfs;
import java.nio.file.FileSystem;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicBoolean;
import org.junit.jupiter.api.Test;

/** /TC010/ … /TC130/ - Session-Lebenszyklus und Sicherheit. */
class BearingSessionTest {

    private static final class SettableClock extends Clock {
        private volatile Instant instant;

        SettableClock(Instant initial) {
            this.instant = initial;
        }

        void set(Instant i) {
            this.instant = i;
        }

        @Override
        public ZoneId getZone() {
            return ZoneOffset.UTC;
        }

        @Override
        public Clock withZone(ZoneId zone) {
            return this;
        }

        @Override
        public Instant instant() {
            return instant;
        }
    }

    private static DefaultBearingSession session(Clock clock) {
        return BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());
    }

    private static GpsFix fix(Instant t, double lat, double lon) {
        return new GpsFix(t, lat, lon, Optional.empty(), Optional.empty(), Optional.empty());
    }

    @Test
    void tc010_doubleStartThrows() {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        DefaultBearingSession s = session(clock);
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        assertThatThrownBy(() -> s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18)))
                .isInstanceOf(IllegalStateException.class);
    }

    @Test
    void tc020_invalidLatThrows() {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        DefaultBearingSession s = session(clock);
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        assertThatThrownBy(() -> s.onPositionUpdate(fix(Instant.parse("2026-01-01T12:00:01Z"), 91.0, 9.0)))
                .isInstanceOf(ValidationException.class);
    }

    @Test
    void tc030_futureTimestampThrows() {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        DefaultBearingSession s = session(clock);
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        assertThatThrownBy(() -> s.onPositionUpdate(fix(Instant.parse("2026-01-01T14:00:00Z"), 48.77, 9.17)))
                .isInstanceOf(ValidationException.class);
    }

    @Test
    void tc040_updateAfterCompleteThrows() {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        DefaultBearingSession s = session(clock);
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        s.onPositionUpdate(fix(Instant.parse("2026-01-01T12:00:00Z"), 48.77, 9.17));
        s.complete();
        assertThatThrownBy(() -> s.onPositionUpdate(fix(Instant.parse("2026-01-01T12:00:10Z"), 48.77, 9.17)))
                .isInstanceOf(IllegalStateException.class);
    }

    @Test
    void tc050_snapshotWithoutFixThrows() {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        DefaultBearingSession s = session(clock);
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        assertThatThrownBy(s::currentSnapshot).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void tc080_abortProducesGpx() {
        Instant t0 = Instant.parse("2026-01-01T12:00:00Z");
        SettableClock clock = new SettableClock(t0);
        DefaultBearingSession s = session(clock);
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        clock.set(t0);
        s.onPositionUpdate(fix(t0, 48.77, 9.17));
        GpxResult r = s.abort();
        assertThat(r.asUtf8String()).contains("http://www.topografix.com/GPX/1/1");
        assertThat(r.utf8Bytes().length).isGreaterThan(0);
    }

    @Test
    void tc090_pathTraversalSecurity() throws Exception {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        try (FileSystem fs = Jimfs.newFileSystem(Configuration.unix())) {
            java.nio.file.Path base = fs.getPath("/data");
            java.nio.file.Files.createDirectories(base);
            DefaultBearingSession s = BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.of(base), new NoopW3wClient());
            SessionConfig cfg =
                    SessionConfig.builder()
                            .allowedBaseDir(base)
                            .completePersistPath(fs.getPath("..", "..", "etc", "passwd"))
                            .build();
            s.start(cfg, new GeoCoordinate(48.78, 9.18));
            s.onPositionUpdate(fix(Instant.parse("2026-01-01T12:00:00Z"), 48.77, 9.17));
            assertThatThrownBy(s::complete).isInstanceOf(SecurityException.class);
        }
    }

    @Test
    void tc110_nthOptimizer() {
        Instant t0 = Instant.parse("2026-01-01T12:00:00Z");
        SettableClock clock = new SettableClock(t0);
        DefaultBearingSession s = session(clock);
        SessionConfig cfg = SessionConfig.builder().addOptimizer(new NthPointOptimizer(10)).build();
        s.start(cfg, new GeoCoordinate(48.78, 9.18));
        for (int i = 0; i < 100; i++) {
            Instant ti = t0.plusMillis(500L * i);
            clock.set(ti);
            s.onPositionUpdate(fix(ti, 48.77 + i * 1e-5, 9.17 + i * 1e-5));
        }
        GpxResult r = s.complete();
        assertThat(r.statistics().storedPointCount()).isGreaterThan(2);
        assertThat(r.appliedOptimizers()).contains("nth-10");
    }

    @Test
    void tc120_listenerExceptionIsolated() {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        DefaultBearingSession s = session(clock);
        AtomicBoolean secondCalled = new AtomicBoolean();
        s.addListener(
                new BearingListener() {
                    @Override
                    public void onSessionStarted(java.util.UUID sessionId) {
                        throw new RuntimeException("boom");
                    }
                });
        s.addListener(
                new BearingListener() {
                    @Override
                    public void onSessionStarted(java.util.UUID sessionId) {
                        secondCalled.set(true);
                    }
                });
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        assertThat(secondCalled).isTrue();
    }

    @Test
    void resetWhileActiveThrows() {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        DefaultBearingSession s = session(clock);
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        assertThatThrownBy(s::reset).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void tc130_resetAllowsRestart() {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        DefaultBearingSession s = session(clock);
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        s.onPositionUpdate(fix(Instant.parse("2026-01-01T12:00:00Z"), 48.77, 9.17));
        s.complete();
        s.reset();
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.0, 9.0));
        assertThat(s.isActive()).isTrue();
    }

    @Test
    void happyPathCompleteProducesGpx() {
        Instant t0 = Instant.parse("2026-01-01T12:00:00Z");
        SettableClock clock = new SettableClock(t0);
        DefaultBearingSession s = session(clock);
        s.start(SessionConfig.builder().build(), new GeoCoordinate(48.78, 9.18));
        clock.set(t0);
        s.onPositionUpdate(fix(t0, 48.77, 9.17));
        Instant t1 = t0.plusSeconds(2);
        clock.set(t1);
        s.onPositionUpdate(fix(t1, 48.771, 9.171));
        GpxResult r = s.complete();
        assertThat(r.asUtf8String()).contains("http://www.topografix.com/GPX/1/1");
        assertThat(r.statistics().storedPointCount()).isGreaterThanOrEqualTo(1);
    }
}
