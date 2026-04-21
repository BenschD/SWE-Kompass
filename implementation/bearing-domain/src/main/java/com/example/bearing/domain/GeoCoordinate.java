package com.example.bearing.domain;

import java.util.Objects;

/**
 * WGS84-Koordinate ({@code /LF300/}).
 */
public final class GeoCoordinate {

    private final double latitudeDeg;
    private final double longitudeDeg;

    public GeoCoordinate(double latitudeDeg, double longitudeDeg) {
        if (latitudeDeg < -90.0 || latitudeDeg > 90.0 || Double.isNaN(latitudeDeg)) {
            throw new IllegalArgumentException("latitudeDeg out of range");
        }
        if (longitudeDeg < -180.0 || longitudeDeg > 180.0 || Double.isNaN(longitudeDeg)) {
            throw new IllegalArgumentException("longitudeDeg out of range");
        }
        this.latitudeDeg = latitudeDeg;
        this.longitudeDeg = longitudeDeg;
    }

    public double latitudeDeg() {
        return latitudeDeg;
    }

    public double longitudeDeg() {
        return longitudeDeg;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof GeoCoordinate)) {
            return false;
        }
        GeoCoordinate that = (GeoCoordinate) o;
        return Double.compare(that.latitudeDeg, latitudeDeg) == 0
                && Double.compare(that.longitudeDeg, longitudeDeg) == 0;
    }

    @Override
    public int hashCode() {
        return Objects.hash(latitudeDeg, longitudeDeg);
    }
}
