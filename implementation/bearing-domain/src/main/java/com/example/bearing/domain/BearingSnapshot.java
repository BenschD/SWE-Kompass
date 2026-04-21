package com.example.bearing.domain;

import java.util.Optional;

/** {@code /LD140/} */
public final class BearingSnapshot {

    private final double azimuthDeg;
    private final double distanceM;
    private final CompassOrdinal compassOrdinal;
    private final Optional<Double> bearingErrorDeg;

    public BearingSnapshot(
            double azimuthDeg,
            double distanceM,
            CompassOrdinal compassOrdinal,
            Optional<Double> bearingErrorDeg) {
        this.azimuthDeg = azimuthDeg;
        this.distanceM = distanceM;
        this.compassOrdinal = compassOrdinal;
        this.bearingErrorDeg = bearingErrorDeg == null ? Optional.empty() : bearingErrorDeg;
    }

    public double azimuthDeg() {
        return azimuthDeg;
    }

    public double distanceM() {
        return distanceM;
    }

    public CompassOrdinal compassOrdinal() {
        return compassOrdinal;
    }

    public Optional<Double> bearingErrorDeg() {
        return bearingErrorDeg;
    }
}
