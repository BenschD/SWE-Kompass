package com.example.bearing.domain.optimize;

import com.example.bearing.domain.GpsPoint;
import java.util.List;

/** {@code /LF480/} */
public interface TrackOptimizer {

    String name();

    List<GpsPoint> optimize(List<GpsPoint> points);
}
