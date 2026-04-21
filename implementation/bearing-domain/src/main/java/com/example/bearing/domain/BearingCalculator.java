package com.example.bearing.domain;

import java.util.Optional;

/**
 * Haversine, Azimut, Ordinal ({@code /LF050/}, Glossar).
 */
public final class BearingCalculator {

    private static final double EARTH_RADIUS_M = 6_371_000.0;

    public double greatCircleDistanceMeters(double lat1, double lon1, double lat2, double lon2) {
        double phi1 = Math.toRadians(lat1);
        double phi2 = Math.toRadians(lat2);
        double dPhi = Math.toRadians(lat2 - lat1);
        double dLambda = Math.toRadians(lon2 - lon1);

        double a =
                Math.sin(dPhi / 2) * Math.sin(dPhi / 2)
                        + Math.cos(phi1) * Math.cos(phi2) * Math.sin(dLambda / 2) * Math.sin(dLambda / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return EARTH_RADIUS_M * c;
    }

    /**
     * Azimut von Punkt 1 zu Punkt 2, 0..360° geografisch Nord.
     */
    public double azimuthDegrees(double lat1, double lon1, double lat2, double lon2) {
        double phi1 = Math.toRadians(lat1);
        double phi2 = Math.toRadians(lat2);
        double dLambda = Math.toRadians(lon2 - lon1);
        double y = Math.sin(dLambda) * Math.cos(phi2);
        double x = Math.cos(phi1) * Math.sin(phi2) - Math.sin(phi1) * Math.cos(phi2) * Math.cos(dLambda);
        double theta = Math.atan2(y, x);
        double deg = (Math.toDegrees(theta) + 360.0) % 360.0;
        if (Double.isNaN(deg)) {
            return 0.0;
        }
        return deg;
    }

    public CompassOrdinal toOrdinal(double azimuthDeg) {
        int idx = (int) Math.floor((azimuthDeg + 22.5) / 45.0) % 8;
        return CompassOrdinal.values()[idx];
    }

    public BearingSnapshot snapshotTowardTarget(
            double fromLat, double fromLon, GeoCoordinate target, Optional<Double> courseDeg) {
        double dist = greatCircleDistanceMeters(fromLat, fromLon, target.latitudeDeg(), target.longitudeDeg());
        double azimuth = azimuthDegrees(fromLat, fromLon, target.latitudeDeg(), target.longitudeDeg());
        CompassOrdinal ord = toOrdinal(azimuth);
        Optional<Double> bearingErr =
                courseDeg.map(c -> normalizeAngle180(azimuth - c));
        return new BearingSnapshot(azimuth, dist, ord, bearingErr);
    }

    private static double normalizeAngle180(double deg) {
        double a = ((deg + 180.0) % 360.0 + 360.0) % 360.0 - 180.0;
        return a;
    }
}
