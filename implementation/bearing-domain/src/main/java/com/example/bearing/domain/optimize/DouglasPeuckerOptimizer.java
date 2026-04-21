package com.example.bearing.domain.optimize;

import com.example.bearing.domain.BearingCalculator;
import com.example.bearing.domain.GpsPoint;
import java.util.ArrayList;
import java.util.List;

/**
 * Douglas–Peucker mit metrischer Toleranz ({@code /LF270/}) — lokale Tangentialebene um den
 * Segmentstart als dokumentierte Kugel-Näherung.
 */
public final class DouglasPeuckerOptimizer implements TrackOptimizer {

    private final double epsilonM;
    private final BearingCalculator calc = new BearingCalculator();

    public DouglasPeuckerOptimizer(double epsilonM) {
        if (epsilonM <= 0) {
            throw new IllegalArgumentException("epsilonM > 0");
        }
        this.epsilonM = epsilonM;
    }

    @Override
    public String name() {
        return "dp-" + epsilonM + "m";
    }

    @Override
    public List<GpsPoint> optimize(List<GpsPoint> points) {
        if (points.size() < 3) {
            return List.copyOf(points);
        }
        boolean[] keep = new boolean[points.size()];
        keep[0] = true;
        keep[points.size() - 1] = true;
        douglasPeucker(points, 0, points.size() - 1, keep);
        List<GpsPoint> out = new ArrayList<>();
        for (int i = 0; i < points.size(); i++) {
            if (keep[i]) {
                out.add(points.get(i));
            }
        }
        return out;
    }

    private void douglasPeucker(List<GpsPoint> pts, int i0, int i1, boolean[] keep) {
        GpsPoint a = pts.get(i0);
        GpsPoint b = pts.get(i1);
        int idx = -1;
        double maxD = 0;
        for (int i = i0 + 1; i < i1; i++) {
            double d = perpendicularDistanceM(a, b, pts.get(i));
            if (d > maxD) {
                maxD = d;
                idx = i;
            }
        }
        if (maxD > epsilonM && idx >= 0) {
            keep[idx] = true;
            douglasPeucker(pts, i0, idx, keep);
            douglasPeucker(pts, idx, i1, keep);
        }
    }

    private double perpendicularDistanceM(GpsPoint a, GpsPoint b, GpsPoint p) {
        double lat0 = a.latitudeDeg();
        double lon0 = a.longitudeDeg();
        double ax = 0;
        double ay = 0;
        double bx = metersPerDegLon(lat0) * (b.longitudeDeg() - lon0);
        double by = metersPerDegLat() * (b.latitudeDeg() - lat0);
        double px = metersPerDegLon(lat0) * (p.longitudeDeg() - lon0);
        double py = metersPerDegLat() * (p.latitudeDeg() - lat0);
        double abx = bx - ax;
        double aby = by - ay;
        double apx = px - ax;
        double apy = py - ay;
        double ab2 = abx * abx + aby * aby;
        if (ab2 < 1e-12) {
            return calc.greatCircleDistanceMeters(
                    p.latitudeDeg(), p.longitudeDeg(), a.latitudeDeg(), a.longitudeDeg());
        }
        double t = Math.max(0, Math.min(1, (apx * abx + apy * aby) / ab2));
        double qx = ax + t * abx;
        double qy = ay + t * aby;
        double dx = px - qx;
        double dy = py - qy;
        return Math.hypot(dx, dy);
    }

    private static double metersPerDegLat() {
        return Math.PI / 180.0 * 6_371_000.0;
    }

    private static double metersPerDegLon(double latDeg) {
        return Math.PI / 180.0 * 6_371_000.0 * Math.cos(Math.toRadians(latDeg));
    }
}
