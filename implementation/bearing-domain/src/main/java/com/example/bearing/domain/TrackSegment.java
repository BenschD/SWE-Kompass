package com.example.bearing.domain;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/** GPX-kompatibles Segment ({@code /LF170/}). */
public final class TrackSegment {

    private final List<GpsPoint> points;

    public TrackSegment(List<GpsPoint> points) {
        this.points = Collections.unmodifiableList(new ArrayList<>(points));
    }

    public List<GpsPoint> points() {
        return points;
    }
}
