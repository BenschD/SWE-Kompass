package com.example.bearing.domain;

import java.time.Instant;
import java.util.Objects;
import java.util.Optional;

/**
 * Eingabe-Positionsfix ({@code /LF030/}, {@code /LD130/}).
 */
public final class GpsFix {

    private final Instant time;
    private final double latitudeDeg;
    private final double longitudeDeg;
    private final Optional<Double> elevationM;
    private final Optional<Double> hdop;
    private final Optional<Double> speedMps;

    public GpsFix(
            Instant time,
            double latitudeDeg,
            double longitudeDeg,
            Optional<Double> elevationM,
            Optional<Double> hdop,
            Optional<Double> speedMps) {
        this.time = Objects.requireNonNull(time, "time");
        this.latitudeDeg = latitudeDeg;
        this.longitudeDeg = longitudeDeg;
        this.elevationM = elevationM == null ? Optional.empty() : elevationM;
        this.hdop = hdop == null ? Optional.empty() : hdop;
        this.speedMps = speedMps == null ? Optional.empty() : speedMps;
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
