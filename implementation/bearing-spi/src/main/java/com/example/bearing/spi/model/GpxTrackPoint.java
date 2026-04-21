package com.example.bearing.spi.model;

import java.time.Instant;
import java.util.Optional;

/**
 * Ein GPX-Trackpunkt (transportnahes Modell, {@code /LD130/}).
 */
public final class GpxTrackPoint {

    private final double lat;
    private final double lon;
    private final Instant time;
    private final Optional<Double> elevationM;
    private final Optional<Double> hdop;
    private final Optional<Double> speedMps;

    public GpxTrackPoint(
            double lat,
            double lon,
            Instant time,
            Optional<Double> elevationM,
            Optional<Double> hdop,
            Optional<Double> speedMps) {
        this.lat = lat;
        this.lon = lon;
        this.time = time;
        this.elevationM = elevationM;
        this.hdop = hdop;
        this.speedMps = speedMps;
    }

    public double lat() {
        return lat;
    }

    public double lon() {
        return lon;
    }

    public Instant time() {
        return time;
    }

    public Optional<Double> elevationM() {
        return elevationM;
    }

    public Optional<Double> hdop() {
        return hdop;
    }

    public Optional<Double> speedMps() {
        return speedMps;
    }
}
