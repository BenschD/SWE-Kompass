package com.example.bearing.domain;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

/** {@code /LL020/} — Plausibilitäts- und Grenzwerttests für Haversine/Azimut. */
class BearingCalculatorReferenceTest {

    private final BearingCalculator calc = new BearingCalculator();

    @Test
    void stuttgartLikePoint_distanceAndOrdinal() {
        double lat1 = 48.7758459;
        double lon1 = 9.1829326;
        double lat2 = 48.784;
        double lon2 = 9.195;
        double az = calc.azimuthDegrees(lat1, lon1, lat2, lon2);
        double d = calc.greatCircleDistanceMeters(lat1, lon1, lat2, lon2);
        assertThat(d).isGreaterThan(10.0);
        assertThat(az).isBetween(0.0, 360.0);
        assertThat(calc.toOrdinal(az)).isNotNull();
    }

    @Test
    void equatorPoint_distanceReasonable() {
        double d = calc.greatCircleDistanceMeters(0.0, 0.0, 0.0, 1.0);
        assertThat(d).isBetween(100_000.0, 120_000.0);
    }
}
