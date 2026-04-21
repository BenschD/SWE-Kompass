package com.example.bearing.spi;

/**
 * Optionales Reverse-Geocoding zu What3Words ({@code /LF280/}).
 */
public interface W3wClientPort {

    /**
     * @param latitude  WGS84
     * @param longitude WGS84
     * @return drei Wörter oder Fallback-String bei Fehler/fehlendem Key
     */
    String reverse(double latitude, double longitude);
}
