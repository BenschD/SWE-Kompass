package com.example.bearing.domain.optimize;

import com.example.bearing.domain.GpsPoint;
import java.util.List;

/** Strategie-Interface für Track-Optimierung ({@code /LF170/}–{@code /LF200/}). */
public interface TrackOptimizer {

    String name();

    List<GpsPoint> optimize(List<GpsPoint> points);
}
