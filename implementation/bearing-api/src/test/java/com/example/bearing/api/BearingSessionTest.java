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
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.jupiter.api.Test;

/** TC-010, TC-020, Happy-Path ({@code /LF010/}–{@code /LF060/}). */
class BearingSessionTest {

    /**
     * {@link Clock#fixed} bleibt auf einem Instant stehen; die Session lehnt Fixes ab, die mehr
     * als eine Sekunde nach der Uhr liegen. Für sequentielle GPS-Zeiten muss die Testuhr mitlaufen.
     */
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

    @Test
    void tc010_doubleStartThrows() {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        DefaultBearingSession s =
                BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());
        GeoCoordinate target = new GeoCoordinate(48.78, 9.18);
        s.start(SessionConfig.defaults(), target);
        assertThatThrownBy(() -> s.start(SessionConfig.defaults(), target))
                .isInstanceOf(IllegalStateException.class);
    }

    @Test
    void tc020_invalidLatThrows() {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        DefaultBearingSession s =
                BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        GpsFix bad = new GpsFix(Instant.parse("2026-01-01T12:00:01Z"), 91.0, 9.0, Optional.empty(), Optional.empty(), Optional.empty());
        assertThatThrownBy(() -> s.onPositionUpdate(bad)).isInstanceOf(ValidationException.class);
    }

    @Test
    void happyPathCompleteProducesGpx() {
        Instant t0 = Instant.parse("2026-01-01T12:00:00Z");
        SettableClock clock = new SettableClock(t0);
        DefaultBearingSession s =
                BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());
        s.start(SessionConfig.builder().build(), new GeoCoordinate(48.78, 9.18));
        clock.set(t0);
        s.onPositionUpdate(new GpsFix(t0, 48.77, 9.17, Optional.empty(), Optional.empty(), Optional.empty()));
        Instant t1 = t0.plusSeconds(2);
        clock.set(t1);
        s.onPositionUpdate(new GpsFix(t1, 48.771, 9.171, Optional.empty(), Optional.empty(), Optional.empty()));
        GpxResult r = s.complete();
        assertThat(r.asUtf8String()).contains("http://www.topografix.com/GPX/1/1");
        assertThat(r.statistics().storedPointCount()).isGreaterThanOrEqualTo(1);
    }

    @Test
    void listenerInvoked() {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        DefaultBearingSession s =
                BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());
        AtomicBoolean started = new AtomicBoolean();
        AtomicInteger updates = new AtomicInteger();
        s.addListener(
                new BearingListener() {
                    @Override
                    public void onSessionStarted(java.util.UUID sessionId) {
                        started.set(true);
                    }

                    @Override
                    public void onPositionUpdate(java.util.UUID sessionId, TrackAcceptSummary notification) {
                        updates.incrementAndGet();
                    }
                });
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        assertThat(started).isTrue();
        s.onPositionUpdate(
                new GpsFix(
                        Instant.parse("2026-01-01T12:00:00Z"),
                        48.77,
                        9.17,
                        Optional.empty(),
                        Optional.empty(),
                        Optional.empty()));
        assertThat(updates.get()).isGreaterThanOrEqualTo(1);
    }

    @Test
    void resetAllowsRestart() {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        DefaultBearingSession s =
                BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        s.onPositionUpdate(
                new GpsFix(
                        Instant.parse("2026-01-01T12:00:00Z"),
                        48.77,
                        9.17,
                        Optional.empty(),
                        Optional.empty(),
                        Optional.empty()));
        s.complete();
        assertThatThrownBy(() -> s.onPositionUpdate(
                        new GpsFix(
                                Instant.parse("2026-01-01T12:00:10Z"),
                                48.77,
                                9.17,
                                Optional.empty(),
                                Optional.empty(),
                                Optional.empty())))
                .isInstanceOf(IllegalStateException.class);
        s.reset();
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.0, 9.0));
        assertThat(s.isActive()).isTrue();
    }

    @Test
    void tc090_pathTraversalSecurity() throws Exception {
        Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
        try (FileSystem fs = Jimfs.newFileSystem(Configuration.unix())) {
            java.nio.file.Path base = fs.getPath("/data");
            java.nio.file.Files.createDirectories(base);
            DefaultBearingSession s =
                    BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.of(base), new NoopW3wClient());
            SessionConfig cfg =
                    SessionConfig.builder()
                            .allowedBaseDir(base)
                            .completePersistPath(fs.getPath("..", "..", "etc", "passwd"))
                            .build();
            s.start(cfg, new GeoCoordinate(48.78, 9.18));
            s.onPositionUpdate(
                    new GpsFix(
                            Instant.parse("2026-01-01T12:00:00Z"),
                            48.77,
                            9.17,
                            Optional.empty(),
                            Optional.empty(),
                            Optional.empty()));
            assertThatThrownBy(s::complete).isInstanceOf(SecurityException.class);
        }
    }

    @Test
    void tc110_nthOptimizer() {
        Instant t0 = Instant.parse("2026-01-01T12:00:00Z");
        SettableClock clock = new SettableClock(t0);
        DefaultBearingSession s =
                BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());
        SessionConfig cfg = SessionConfig.builder().addOptimizer(new NthPointOptimizer(10)).build();
        s.start(cfg, new GeoCoordinate(48.78, 9.18));
        for (int i = 0; i < 100; i++) {
            Instant ti = t0.plusMillis(500L * i);
            clock.set(ti);
            s.onPositionUpdate(
                    new GpsFix(
                            ti,
                            48.77 + i * 1e-5,
                            9.17 + i * 1e-5,
                            Optional.empty(),
                            Optional.empty(),
                            Optional.empty()));
        }
        GpxResult r = s.complete();
        assertThat(r.statistics().storedPointCount()).isGreaterThan(2);
        assertThat(r.appliedOptimizers()).contains("nth-10");
    }
}
