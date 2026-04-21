package com.example.bearing.api;

import static org.assertj.core.api.Assertions.assertThat;

import com.example.bearing.adapter.system.NoopW3wClient;
import com.example.bearing.adapter.system.SystemClockAdapter;
import com.example.bearing.domain.GeoCoordinate;
import com.example.bearing.domain.GpsFix;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * Demo-Test: schreibt eine HTML/SVG-Datei und druckt eine ASCII-Karte auf stdout.
 *
 * <p>Maven-Befehl zum gezielten Lauf: siehe {@code README.md} im Verzeichnis {@code implementation/}.
 *
 * <p>Danach im Browser öffnen: {@code bearing-api/target/bearing-session-visualization.html}
 */
class BearingSessionVisualizationTest {

    private static final Pattern TRKPT =
            Pattern.compile("<trkpt lat=\"([-0-9.]+)\" lon=\"([-0-9.]+)\"");

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
    @DisplayName("Visualisierung: GPX-Track als HTML/SVG + ASCII-Karte")
    void visualizeSession_writesHtmlAndPrintsAsciiMap() throws Exception {
        Instant t0 = Instant.parse("2026-04-21T10:00:00Z");
        SettableClock clock = new SettableClock(t0);
        DefaultBearingSession session =
                BearingBootstrap.newSession(new SystemClockAdapter(clock), Optional.empty(), new NoopW3wClient());

        GeoCoordinate target = new GeoCoordinate(48.78, 9.18);
        session.start(SessionConfig.builder().samplingIntervalMs(500).build(), target);

        List<double[]> plannedPath = new ArrayList<>();
        int n = 24;
        for (int i = 0; i < n; i++) {
            double t = i / (double) (n - 1);
            double lat = 48.77 + 0.00025 * t;
            double lon = 9.17 + 0.00035 * t;
            plannedPath.add(new double[] {lat, lon});
        }

        for (int i = 0; i < n; i++) {
            Instant ti = t0.plusSeconds(2L * i);
            clock.set(ti);
            double[] p = plannedPath.get(i);
            session.onPositionUpdate(
                    new GpsFix(ti, p[0], p[1], Optional.empty(), Optional.empty(), Optional.empty()));
        }

        GpxResult result = session.complete();
        String gpx = result.asUtf8String();
        List<double[]> exported = parseTrkpts(gpx);

        Path htmlPath = Path.of("target", "bearing-session-visualization.html");
        Files.createDirectories(htmlPath.getParent());
        String html = buildHtml(target, exported, result);
        Files.writeString(htmlPath, html, StandardCharsets.UTF_8);

        String ascii = buildAsciiMap(target, exported, 52, 16);
        System.out.println();
        System.out.println("=== Peilungskomponente: Demo-Visualisierung ===");
        System.out.println("GPX-Punkte (exportiert): " + exported.size());
        System.out.println("Statistik (gespeicherte Punkte): " + result.statistics().storedPointCount());
        System.out.println("Track-Optimierer (SessionConfig): " + formatOptimizers(result));
        System.out.println();
        System.out.println(ascii);
        System.out.println();
        System.out.println("HTML/SVG: " + htmlPath.toAbsolutePath().normalize());
        System.out.println("(Datei im Explorer oeffnen oder per file:// im Browser laden.)");
        System.out.println();

        assertThat(Files.exists(htmlPath)).isTrue();
        assertThat(html).contains("<svg", "polyline", "Ziel");
        assertThat(exported.size()).isGreaterThanOrEqualTo(3);
    }

    /** Namen der optionalen {@link com.example.bearing.domain.optimize.TrackOptimizer}-Strategien, sonst Hinweistext. */
    private static String formatOptimizers(GpxResult result) {
        List<String> names = result.appliedOptimizers();
        if (names.isEmpty()) {
            return "keine konfiguriert (nur Aufzeichnung / Sampling / Qualitaetsregeln)";
        }
        return String.join(", ", names);
    }

    private static List<double[]> parseTrkpts(String gpx) {
        List<double[]> pts = new ArrayList<>();
        Matcher m = TRKPT.matcher(gpx);
        while (m.find()) {
            pts.add(new double[] {Double.parseDouble(m.group(1)), Double.parseDouble(m.group(2))});
        }
        return pts;
    }

    private static String buildHtml(GeoCoordinate target, List<double[]> track, GpxResult result) {
        double minLat = target.latitudeDeg();
        double maxLat = target.latitudeDeg();
        double minLon = target.longitudeDeg();
        double maxLon = target.longitudeDeg();
        for (double[] p : track) {
            minLat = Math.min(minLat, p[0]);
            maxLat = Math.max(maxLat, p[0]);
            minLon = Math.min(minLon, p[1]);
            maxLon = Math.max(maxLon, p[1]);
        }
        double padLat = Math.max(1e-6, (maxLat - minLat) * 0.15);
        double padLon = Math.max(1e-6, (maxLon - minLon) * 0.15);
        minLat -= padLat;
        maxLat += padLat;
        minLon -= padLon;
        maxLon += padLon;

        int w = 720;
        int h = 480;
        StringBuilder poly = new StringBuilder();
        for (double[] p : track) {
            if (poly.length() > 0) {
                poly.append(' ');
            }
            poly.append(toSvgX(p[1], minLon, maxLon, w))
                    .append(',')
                    .append(toSvgY(p[0], minLat, maxLat, h));
        }
        double tx = toSvgX(target.longitudeDeg(), minLon, maxLon, w);
        double ty = toSvgY(target.latitudeDeg(), minLat, maxLat, h);
        double sx = track.isEmpty() ? tx : toSvgX(track.get(0)[1], minLon, maxLon, w);
        double sy = track.isEmpty() ? ty : toSvgY(track.get(0)[0], minLat, maxLat, h);

        return "<!DOCTYPE html>\n"
                + "<html lang=\"de\"><head><meta charset=\"UTF-8\"/><title>Peilung – Demo-Track</title>\n"
                + "<style>body{font-family:system-ui,sans-serif;margin:24px;background:#111;color:#eee;}"
                + "svg{background:#1a1a24;border-radius:12px;}"
                + ".box{margin-top:16px;padding:12px;background:#222;border-radius:8px;max-width:760px;}"
                + "a{color:#8cf}</style></head><body>\n"
                + "<h1>Demo: aufgezeichneter Track & Ziel</h1>\n"
                + "<p>Hellblaue Linie = exportierte GPX-Punkte. Kreise: Start (grün), Ziel (orange).</p>\n"
                + "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\""
                + w
                + "\" height=\""
                + h
                + "\" viewBox=\"0 0 "
                + w
                + " "
                + h
                + "\">\n"
                + "<rect width=\"100%\" height=\"100%\" fill=\"#16161f\"/>\n"
                + "<polyline fill=\"none\" stroke=\"#7dd3fc\" stroke-width=\"3\" points=\""
                + poly
                + "\"/>\n"
                + "<circle cx=\""
                + sx
                + "\" cy=\""
                + sy
                + "\" r=\"8\" fill=\"#4ade80\"/>\n"
                + "<circle cx=\""
                + tx
                + "\" cy=\""
                + ty
                + "\" r=\"10\" fill=\"#fb923c\" stroke=\"#fff\" stroke-width=\"2\"/>\n"
                + "</svg>\n"
                + "<div class=\"box\"><strong>Statistik</strong><br/>"
                + "Gespeicherte Punkte: "
                + result.statistics().storedPointCount()
                + "<br/>Track-Optimierer: "
                + formatOptimizers(result)
                + "</div>\n"
                + "</body></html>\n";
    }

    private static double toSvgX(double lon, double minLon, double maxLon, int w) {
        return (lon - minLon) / (maxLon - minLon) * (w - 40) + 20;
    }

    private static double toSvgY(double lat, double minLat, double maxLat, int h) {
        return h - 20 - (lat - minLat) / (maxLat - minLat) * (h - 40);
    }

    private static String buildAsciiMap(GeoCoordinate target, List<double[]> track, int cols, int rows) {
        double minLat = target.latitudeDeg();
        double maxLat = target.latitudeDeg();
        double minLon = target.longitudeDeg();
        double maxLon = target.longitudeDeg();
        for (double[] p : track) {
            minLat = Math.min(minLat, p[0]);
            maxLat = Math.max(maxLat, p[0]);
            minLon = Math.min(minLon, p[1]);
            maxLon = Math.max(maxLon, p[1]);
        }
        double padLat = Math.max(1e-7, (maxLat - minLat) * 0.12);
        double padLon = Math.max(1e-7, (maxLon - minLon) * 0.12);
        minLat -= padLat;
        maxLat += padLat;
        minLon -= padLon;
        maxLon += padLon;

        char[][] g = new char[rows][cols];
        for (int r = 0; r < rows; r++) {
            for (int c = 0; c < cols; c++) {
                g[r][c] = ' ';
            }
        }
        for (int i = 0; i < track.size(); i++) {
            int c = lonToCol(track.get(i)[1], minLon, maxLon, cols);
            int r = latToRow(track.get(i)[0], minLat, maxLat, rows);
            char ch = i == 0 ? 'S' : (i == track.size() - 1 ? 'E' : '*');
            if (g[r][c] == ' ' || g[r][c] == '*') {
                g[r][c] = ch;
            }
        }
        int tc = lonToCol(target.longitudeDeg(), minLon, maxLon, cols);
        int tr = latToRow(target.latitudeDeg(), minLat, maxLat, rows);
        g[tr][tc] = 'T';

        StringBuilder sb = new StringBuilder();
        sb.append('+').append("-".repeat(cols)).append("+\n");
        for (int r = 0; r < rows; r++) {
            sb.append('|');
            for (int c = 0; c < cols; c++) {
                sb.append(g[r][c]);
            }
            sb.append("|\n");
        }
        sb.append('+').append("-".repeat(cols)).append("+\n");
        sb.append("S=Start  *=Weg  E=letzter Exportpunkt  T=Ziel (Peilung)\n");
        return sb.toString();
    }

    private static int lonToCol(double lon, double minLon, double maxLon, int cols) {
        double t = (lon - minLon) / (maxLon - minLon);
        int c = (int) Math.round(t * (cols - 1));
        return Math.max(0, Math.min(cols - 1, c));
    }

    private static int latToRow(double lat, double minLat, double maxLat, int rows) {
        double t = (lat - minLat) / (maxLat - minLat);
        int r = rows - 1 - (int) Math.round(t * (rows - 1));
        return Math.max(0, Math.min(rows - 1, r));
    }
}
