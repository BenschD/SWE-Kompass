package com.example.bearing.domain.optimize;

import com.example.bearing.domain.BearingCalculator;
import com.example.bearing.domain.GpsPoint;
import java.util.ArrayList;
import java.util.List;

/**
 * Reduziert fast kollineare Ketten ({@code /LF260/}): wenn {@code |AB|+|BC|≈|AC|} innerhalb Toleranz,
 * wird der Zwischenpunkt verworfen.
 */
public final class LineCollinearityOptimizer implements TrackOptimizer {

    private final double toleranceM;
    private final BearingCalculator calc = new BearingCalculator();

    public LineCollinearityOptimizer(double toleranceM) {
        this.toleranceM = toleranceM;
    }

    @Override
    public String name() {
        return "line-" + toleranceM + "m";
    }

    @Override
    public List<GpsPoint> optimize(List<GpsPoint> points) {
        if (points.size() < 3) {
            return List.copyOf(points);
        }
        List<GpsPoint> work = new ArrayList<>(points);
        boolean changed = true;
        while (changed && work.size() >= 3) {
            changed = false;
            for (int i = 1; i < work.size() - 1; i++) {
                GpsPoint a = work.get(i - 1);
                GpsPoint b = work.get(i);
                GpsPoint c = work.get(i + 1);
                double ab = dist(a, b);
                double bc = dist(b, c);
                double ac = dist(a, c);
                double detour = ab + bc - ac;
                if (detour <= toleranceM) {
                    work.remove(i);
                    changed = true;
                    break;
                }
            }
        }
        return work;
    }

    private double dist(GpsPoint p, GpsPoint q) {
        return calc.greatCircleDistanceMeters(
                p.latitudeDeg(), p.longitudeDeg(), q.latitudeDeg(), q.longitudeDeg());
    }
}
