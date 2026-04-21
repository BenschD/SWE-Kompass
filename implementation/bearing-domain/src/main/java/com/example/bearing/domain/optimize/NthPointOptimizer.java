package com.example.bearing.domain.optimize;

import com.example.bearing.domain.GpsPoint;
import java.util.ArrayList;
import java.util.List;

/** {@code /LF240/} */
public final class NthPointOptimizer implements TrackOptimizer {

    private final int everyN;

    public NthPointOptimizer(int everyN) {
        if (everyN < 1) {
            throw new IllegalArgumentException("everyN >= 1");
        }
        this.everyN = everyN;
    }

    @Override
    public String name() {
        return "nth-" + everyN;
    }

    @Override
    public List<GpsPoint> optimize(List<GpsPoint> points) {
        if (points.size() <= 2) {
            return List.copyOf(points);
        }
        List<GpsPoint> out = new ArrayList<>();
        out.add(points.get(0));
        for (int i = 1; i < points.size() - 1; i++) {
            if (i % everyN == 0) {
                out.add(points.get(i));
            }
        }
        out.add(points.get(points.size() - 1));
        return out;
    }
}
