package com.example.bearing.demo;

import com.example.bearing.adapter.system.NoopW3wClient;
import com.example.bearing.adapter.system.SystemClockAdapter;
import com.example.bearing.api.BearingBootstrap;
import com.example.bearing.api.BearingListener;
import com.example.bearing.api.DefaultBearingSession;
import com.example.bearing.api.GpxResult;
import com.example.bearing.api.SessionConfig;
import com.example.bearing.api.ValidationException;
import com.example.bearing.domain.BearingCalculator;
import com.example.bearing.domain.BearingSnapshot;
import com.example.bearing.domain.GeoCoordinate;
import com.example.bearing.domain.GpsFix;
import com.example.bearing.domain.optimize.DouglasPeuckerOptimizer;
import com.example.bearing.domain.optimize.LineCollinearityOptimizer;
import com.example.bearing.domain.optimize.MinDistanceOptimizer;
import com.example.bearing.domain.optimize.NthPointOptimizer;
import com.google.common.jimfs.Configuration;
import com.google.common.jimfs.Jimfs;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileSystem;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Konsolen-Demo aller zentral implementierten Funktionen (Domain, Session, GPX, Datei, W3W-Noop,
 * Optimierer-Pipeline, Sicherheitspfad).
 *
 * <p>Start: {@code mvn -pl bearing-demo -am compile exec:java} (im Verzeichnis {@code implementation/}).
 */
public final class AllCapabilitiesDemo {

    private static final Pattern TRKPT_OPEN = Pattern.compile("<trkpt ");

    private AllCapabilitiesDemo() {}

    public static void main(String[] args) {
        outHeader("SWE-Kompass / Peilungskomponente — Funktionsdemo");
        runDomainBearingCalculator();
        runSessionLifecycleErrors();
        runRawTrackKeepsAllFixesIncludingHdop();
        runSessionListenerSnapshotComplete();
        runOptimizerPipeline();
        runPersistOnCompleteJimfs();
        runPersistOnAbortJimfs();
        runPathTraversalBlocked();
        runW3wNoop();
        runInvalidCourseArgument();
        outHeader("Ende (alle Schritte durchlaufen)");
    }

    private static void outHeader(String title) {
        String line = "=".repeat(Math.min(72, Math.max(title.length() + 8, 16)));
        System.out.println();
        System.out.println(line);
        System.out.println("  " + title);
        System.out.println(line);
    }

    private static void out(String label, Object value) {
        System.out.println(String.format("  %-34s %s", label + ":", value));
    }

    /**
     * Synthetischer Wanderweg: laengerer Verlauf mit Ueberhoehungen durch Sinus/Cosinus (nicht nur
     * Gerade). Schrittweite in der Zeit bleibt {@code stepSeconds}, Koordinaten klein genug fuer
     * plausible Geschwindigkeiten.
     */
    private static double[] demoCurvedLatLon(int index, int total, double lat0, double lon0) {
        if (total <= 1) {
            return new double[] {lat0, lon0};
        }
        double u = index / (double) (total - 1);
        double lat = lat0 + 0.0019 * u + 0.00013 * Math.sin(u * Math.PI * 6);
        double lon = lon0 + 0.0023 * u + 0.00015 * Math.cos(u * Math.PI * 4.5);
        return new double[] {lat, lon};
    }

    private static void feedCurvedTrack(
            DefaultBearingSession session,
            SettableClock clock,
            Instant t0,
            int pointCount,
            long stepSeconds,
            double lat0,
            double lon0) {
        for (int i = 0; i < pointCount; i++) {
            Instant ti = t0.plusSeconds(stepSeconds * i);
            clock.set(ti);
            double[] p = demoCurvedLatLon(i, pointCount, lat0, lon0);
            session.onPositionUpdate(
                    new GpsFix(ti, p[0], p[1], Optional.empty(), Optional.empty(), Optional.empty()));
        }
    }

    private static void runDomainBearingCalculator() {
        outHeader("1) Domain: BearingCalculator (Distanz, Azimut, Ordinal, Snapshot)");
        GeoCoordinate target = new GeoCoordinate(48.78, 9.18);
        BearingCalculator calc = new BearingCalculator();
        double lat = 48.77;
        double lon = 9.17;
        double dist = calc.greatCircleDistanceMeters(lat, lon, target.latitudeDeg(), target.longitudeDeg());
        double az = calc.azimuthDegrees(lat, lon, target.latitudeDeg(), target.longitudeDeg());
        out("Entfernung zum Ziel (m)", String.format("%.1f", dist));
        out("Azimut (deg)", String.format("%.2f", az));
        out("Himmelsrichtung", calc.toOrdinal(az));
        BearingSnapshot s1 = calc.snapshotTowardTarget(lat, lon, target, Optional.empty());
        out("Snapshot ohne Kursfehler", snapLine(s1));
        BearingSnapshot s2 = calc.snapshotTowardTarget(lat, lon, target, Optional.of(90.0));
        out("Snapshot mit Kurs 90 deg", snapLine(s2));
        if (s2.bearingErrorDeg().isPresent()) {
            out("Kursfehler (deg)", String.format("%.2f", s2.bearingErrorDeg().get()));
        }
    }

    private static String snapLine(BearingSnapshot s) {
        return String.format(
                "az=%.1f deg, dist=%.0f m, ordinal=%s",
                s.azimuthDeg(), s.distanceM(), s.compassOrdinal());
    }

    private static void runSessionLifecycleErrors() {
        outHeader("2) Session: Doppelstart, Koordinaten-Validierung");
        Instant t0 = Instant.parse("2026-01-01T12:00:00Z");
        SettableClock clock = new SettableClock(t0);
        DefaultBearingSession s =
                BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());
        GeoCoordinate target = new GeoCoordinate(48.78, 9.18);
        s.start(SessionConfig.defaults(), target);
        try {
            s.start(SessionConfig.defaults(), target);
            System.out.println("  FEHLER: Doppelstart haette IllegalStateException werfen muessen.");
        } catch (IllegalStateException ex) {
            out("Doppelstart abgefangen", ex.getMessage());
        }
        GpsFix bad = new GpsFix(t0, 91.0, 9.0, Optional.empty(), Optional.empty(), Optional.empty());
        try {
            s.onPositionUpdate(bad);
            System.out.println("  FEHLER: ungueltige Breite haette ValidationException werfen muessen.");
        } catch (ValidationException ve) {
            out("ValidationException", ve.getMessage());
        }
        s.reset();
        out("reset()", "Session wieder IDLE");
    }

    private static void runRawTrackKeepsAllFixesIncludingHdop() {
        outHeader("3) Roh-Track: schlechter HDOP wird nicht beim Einlesen verworfen");
        Instant t0 = Instant.parse("2026-01-02T08:00:00Z");
        SettableClock clock = new SettableClock(t0);
        DefaultBearingSession s =
                BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());
        s.start(SessionConfig.builder().build(), new GeoCoordinate(48.78, 9.18));
        clock.set(t0);
        s.onPositionUpdate(
                new GpsFix(t0, 48.77, 9.17, Optional.empty(), Optional.empty(), Optional.empty()));
        clock.set(t0.plusSeconds(2));
        s.onPositionUpdate(
                new GpsFix(t0.plusSeconds(2), 48.771, 9.171, Optional.empty(), Optional.of(50.0), Optional.empty()));
        GpxResult r = s.complete();
        out("Statistik gespeicherte Punkte", r.statistics().storedPointCount());
        out("GPX trkpt (ohne Export-Filter)", countTrkptTags(r.asUtf8String()));
        s.reset();
    }

    private static void runSessionListenerSnapshotComplete() {
        outHeader("4) Session: Listener, Kursupdate, Snapshot, complete -> GPX");
        Instant t0 = Instant.parse("2026-01-03T10:00:00Z");
        SettableClock clock = new SettableClock(t0);
        DefaultBearingSession s =
                BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());
        AtomicInteger started = new AtomicInteger();
        AtomicInteger completed = new AtomicInteger();
        s.addListener(
                new BearingListener() {
                    @Override
                    public void onSessionStarted(UUID sessionId) {
                        started.incrementAndGet();
                    }

                    @Override
                    public void onSessionCompleted(UUID sessionId, GpxResult result) {
                        completed.incrementAndGet();
                    }
                });
        s.start(SessionConfig.builder().build(), new GeoCoordinate(48.78, 9.18));
        int trackPoints = 26;
        feedCurvedTrack(s, clock, t0, trackPoints, 2L, 48.77, 9.17);
        out("Demo-Track Rohpunkte (geplant)", trackPoints);
        s.onCourseUpdate(120.0);
        BearingSnapshot snap = s.currentSnapshot();
        out("Listener started", started.get());
        out("Snapshot nach Kurs 120 deg", snapLine(snap));
        GpxResult r = s.complete();
        out("Listener completed", completed.get());
        printGpxSummary(r, "Ohne konfigurierte Track-Optimierer");
        System.out.println("  GPX-Ausschnitt (erste 420 Zeichen):");
        System.out.println(trimForConsole(r.asUtf8String(), 420));
    }

    private static void runOptimizerPipeline() {
        outHeader("5) Session: Optimierer-Pipeline (nth, mindist, Douglas-Peucker, Kollinearitaet)");
        Instant t0 = Instant.parse("2026-01-04T14:00:00Z");
        SettableClock clock = new SettableClock(t0);
        DefaultBearingSession s =
                BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());
        SessionConfig cfg =
                SessionConfig.builder()
                        .addOptimizer(new NthPointOptimizer(5))
                        .addOptimizer(new MinDistanceOptimizer(4.0))
                        .addOptimizer(new DouglasPeuckerOptimizer(25.0))
                        .addOptimizer(new LineCollinearityOptimizer(4.0))
                        .build();
        s.start(cfg, new GeoCoordinate(48.79, 9.19));
        int n = 96;
        out("Demo-Track Rohpunkte (Sinus/Cosinus-Kruemmung)", n);
        feedCurvedTrack(s, clock, t0, n, 2L, 48.768, 9.165);
        GpxResult r = s.complete();
        out("Rohdaten gespeicherte Punkte (Statistik)", r.statistics().storedPointCount());
        out("GPX <trkpt> nach Pipeline", countTrkptTags(r.asUtf8String()));
        out("Angewandte Optimierer", r.appliedOptimizers());
    }

    private static void runPersistOnCompleteJimfs() {
        outHeader("6) Datei: GPX nach complete (SafeFileSink / Jimfs)");
        try (FileSystem fs = Jimfs.newFileSystem(Configuration.unix())) {
            Path base = fs.getPath("/data");
            Files.createDirectories(base);
            Instant t0 = Instant.parse("2026-01-05T09:00:00Z");
            SettableClock clock = new SettableClock(t0);
            DefaultBearingSession s =
                    BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.of(base), new NoopW3wClient());
            Path rel = fs.getPath("export", "fertig.gpx");
            SessionConfig cfg =
                    SessionConfig.builder()
                            .allowedBaseDir(base)
                            .completePersistPath(rel)
                            .build();
            s.start(cfg, new GeoCoordinate(48.78, 9.18));
            feedCurvedTrack(s, clock, t0, 20, 2L, 48.77, 9.17);
            s.complete();
            Path written = base.resolve("export").resolve("fertig.gpx");
            out("Datei existiert", Files.exists(written));
            out("Bytes auf Platte (virtuell)", Files.size(written));
            String first = Files.readString(written, StandardCharsets.UTF_8).lines().findFirst().orElse("");
            out("Erste Zeile", first);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private static void runPersistOnAbortJimfs() {
        outHeader("7) Datei: GPX nach abort mit persistOnAbort");
        try (FileSystem fs = Jimfs.newFileSystem(Configuration.unix())) {
            Path base = fs.getPath("/out");
            Files.createDirectories(base);
            Instant t0 = Instant.parse("2026-01-06T11:30:00Z");
            SettableClock clock = new SettableClock(t0);
            DefaultBearingSession s =
                    BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.of(base), new NoopW3wClient());
            Path rel = fs.getPath("abbruch.gpx");
            SessionConfig cfg =
                    SessionConfig.builder()
                            .allowedBaseDir(base)
                            .persistOnAbort(true)
                            .abortPersistPath(rel)
                            .build();
            s.start(cfg, new GeoCoordinate(48.0, 9.0));
            clock.set(t0);
            s.onPositionUpdate(
                    new GpsFix(t0, 47.999, 8.999, Optional.empty(), Optional.empty(), Optional.empty()));
            s.abort();
            Path written = base.resolve("abbruch.gpx");
            out("Abort-Datei existiert", Files.exists(written));
            out("Bytes", Files.size(written));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private static void runPathTraversalBlocked() {
        outHeader("8) Sicherheit: Path-Traversal bei persist wird geblockt");
        try (FileSystem fs = Jimfs.newFileSystem(Configuration.unix())) {
            Path base = fs.getPath("/data");
            Files.createDirectories(base);
            Instant t0 = Instant.parse("2026-01-07T16:00:00Z");
            SettableClock clock = new SettableClock(t0);
            DefaultBearingSession s =
                    BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.of(base), new NoopW3wClient());
            SessionConfig cfg =
                    SessionConfig.builder()
                            .allowedBaseDir(base)
                            .completePersistPath(fs.getPath("..", "..", "etc", "passwd"))
                            .build();
            s.start(cfg, new GeoCoordinate(48.78, 9.18));
            clock.set(t0);
            s.onPositionUpdate(
                    new GpsFix(t0, 48.77, 9.17, Optional.empty(), Optional.empty(), Optional.empty()));
            try {
                s.complete();
                System.out.println("  FEHLER: SecurityException erwartet.");
            } catch (SecurityException ex) {
                out("SecurityException", ex.getMessage());
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private static void runW3wNoop() {
        outHeader("9) W3W-Noop-Client (resolveWhat3Words)");
        Instant t0 = Instant.parse("2026-01-08T12:00:00Z");
        SettableClock clock = new SettableClock(t0);
        DefaultBearingSession s =
                BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        clock.set(t0);
        s.onPositionUpdate(
                new GpsFix(t0, 48.77, 9.17, Optional.empty(), Optional.empty(), Optional.empty()));
        Optional<String> w = s.resolveWhat3Words(48.77, 9.17);
        out("resolveWhat3Words", w.orElse("(leer)"));
        s.reset();
    }

    private static void runInvalidCourseArgument() {
        outHeader("10) Session: onCourseUpdate mit ungueltigem Winkel");
        Instant t0 = Instant.parse("2026-01-09T07:00:00Z");
        SettableClock clock = new SettableClock(t0);
        DefaultBearingSession s =
                BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());
        s.start(SessionConfig.defaults(), new GeoCoordinate(48.78, 9.18));
        clock.set(t0);
        s.onPositionUpdate(
                new GpsFix(t0, 48.77, 9.17, Optional.empty(), Optional.empty(), Optional.empty()));
        try {
            s.onCourseUpdate(400.0);
            System.out.println("  FEHLER: IllegalArgumentException erwartet.");
        } catch (IllegalArgumentException ex) {
            out("IllegalArgumentException", ex.getMessage());
        }
    }

    private static void printGpxSummary(GpxResult r, String note) {
        out("Hinweis", note);
        out("Statistik Distanz (m)", String.format("%.1f", r.statistics().totalDistanceM()));
        out("Statistik Dauer", r.statistics().totalDuration());
        out("Statistik gespeicherte Punkte (Roh)", r.statistics().storedPointCount());
        out("GPX <trkpt> (export)", countTrkptTags(r.asUtf8String()));
        out("Optimierer-Namen", r.appliedOptimizers());
    }

    private static int countTrkptTags(String gpx) {
        int n = 0;
        Matcher m = TRKPT_OPEN.matcher(gpx);
        while (m.find()) {
            n++;
        }
        return n;
    }

    private static String trimForConsole(String s, int max) {
        String t = s.replace("\r", "");
        if (t.length() <= max) {
            return "  " + t.replace("\n", "\n  ");
        }
        return "  " + t.substring(0, max).replace("\n", "\n  ") + "\n  ...";
    }

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
}
