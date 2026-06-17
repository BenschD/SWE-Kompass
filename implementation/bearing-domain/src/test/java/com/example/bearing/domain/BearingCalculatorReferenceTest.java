package com.example.bearing.domain;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

/** /TC140/ - {@code /LL020/} Haversine/Azimut-Referenz. */
class BearingCalculatorReferenceTest {

    private final BearingCalculator calc = new BearingCalculator();

    @Test
    void tc140_azimuthReference() {
        double lat1 = 48.7758459;
        double lon1 = 9.1829326;
        double lat2 = 48.784;
        double lon2 = 9.195;
        double az = calc.azimuthDegrees(lat1, lon1, lat2, lon2);
        double d = calc.greatCircleDistanceMeters(lat1, lon1, lat2, lon2);
        assertThat(d).isGreaterThan(10.0);
        assertThat(az).isBetween(0.0, 360.0);
        double refAz = referenceAzimuthDegrees(lat1, lon1, lat2, lon2);
        assertThat(Math.abs(az - refAz)).isLessThanOrEqualTo(1.0);
        assertThat(calc.toOrdinal(az)).isNotNull();
    }

    /** Unabhängige Referenzformel für /LL020/ (±1°). */
    private static double referenceAzimuthDegrees(double lat1, double lon1, double lat2, double lon2) {
        double phi1 = Math.toRadians(lat1);
        double phi2 = Math.toRadians(lat2);
        double dLambda = Math.toRadians(lon2 - lon1);
        double y = Math.sin(dLambda) * Math.cos(phi2);
        double x = Math.cos(phi1) * Math.sin(phi2) - Math.sin(phi1) * Math.cos(phi2) * Math.cos(dLambda);
        return (Math.toDegrees(Math.atan2(y, x)) + 360.0) % 360.0;
    }

    @Test
    void equatorPoint_distanceReasonable() {
        double d = calc.greatCircleDistanceMeters(0.0, 0.0, 0.0, 1.0);
        assertThat(d).isBetween(100_000.0, 120_000.0);
    }
}
