package com.example.bearing.domain.optimize;

import com.example.bearing.domain.BearingCalculator;
import com.example.bearing.domain.GpsPoint;
import java.util.ArrayList;
import java.util.List;

/** {@code /LF250/} */
public final class MinDistanceOptimizer implements TrackOptimizer {

    private final double minDistanceM;
    private final BearingCalculator calc = new BearingCalculator();

    public MinDistanceOptimizer(double minDistanceM) {
        if (minDistanceM <= 0) {
            throw new IllegalArgumentException("minDistanceM > 0");
        }
        this.minDistanceM = minDistanceM;
    }

    @Override
    public String name() {
        return "mindist-" + (int) minDistanceM + "m";
    }

    @Override
    public List<GpsPoint> optimize(List<GpsPoint> points) {
        if (points.isEmpty()) {
            return List.of();
        }
        List<GpsPoint> out = new ArrayList<>();
        out.add(points.get(0));
        GpsPoint last = points.get(0);
        for (int i = 1; i < points.size() - 1; i++) {
            GpsPoint p = points.get(i);
            double d =
                    calc.greatCircleDistanceMeters(
                            last.latitudeDeg(), last.longitudeDeg(), p.latitudeDeg(), p.longitudeDeg());
            if (d >= minDistanceM) {
                out.add(p);
                last = p;
            }
        }
        out.add(points.get(points.size() - 1));
        return out;
    }
}
