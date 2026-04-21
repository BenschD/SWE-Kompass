package com.example.bearing.domain;

import java.time.Instant;
import java.util.Objects;
import java.util.Optional;

/** Gespeicherter Trackpunkt ({@code /LD130/}). */
public final class GpsPoint {

    private final Instant time;
    private final double latitudeDeg;
    private final double longitudeDeg;
    private final Optional<Double> elevationM;
    private final Optional<Double> hdop;
    private final Optional<Double> speedMps;

    public GpsPoint(
            Instant time,
            double latitudeDeg,
            double longitudeDeg,
            Optional<Double> elevationM,
            Optional<Double> hdop,
            Optional<Double> speedMps) {
        this.time = Objects.requireNonNull(time);
        this.latitudeDeg = latitudeDeg;
        this.longitudeDeg = longitudeDeg;
        this.elevationM = elevationM == null ? Optional.empty() : elevationM;
        this.hdop = hdop == null ? Optional.empty() : hdop;
        this.speedMps = speedMps == null ? Optional.empty() : speedMps;
    }

    public static GpsPoint fromFix(GpsFix fix) {
        return new GpsPoint(
                fix.time(),
                fix.latitudeDeg(),
                fix.longitudeDeg(),
                fix.elevationM(),
                fix.hdop(),
                fix.speedMps());
    }

    public Instant time() {
        return time;
    }

    public double latitudeDeg() {
        return latitudeDeg;
    }

    public double longitudeDeg() {
        return longitudeDeg;
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
