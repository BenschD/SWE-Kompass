package com.example.bearing.spi.model;

import java.util.List;

public final class GpxTrackSegment {

    private final List<GpxTrackPoint> points;

    public GpxTrackSegment(List<GpxTrackPoint> points) {
        this.points = List.copyOf(points);
    }

    public List<GpxTrackPoint> points() {
        return points;
    }
}
