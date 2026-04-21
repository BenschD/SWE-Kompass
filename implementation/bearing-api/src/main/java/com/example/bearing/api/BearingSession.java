package com.example.bearing.api;

import com.example.bearing.domain.BearingSnapshot;
import com.example.bearing.domain.GeoCoordinate;
import com.example.bearing.domain.GpsFix;
import java.util.Optional;
import java.util.UUID;

/**
 * Lebenszyklus einer Peilungssession ({@code /LF010/}–{@code /LF070/}).
 *
 * <p>Threading: Standard ist ein einzelner Host-Thread ({@code /LF350/}).
 */
public interface BearingSession {

    /** @return Session-ID */
    UUID id();

    /** @return {@code true}, wenn ACTIVE */
    boolean isActive();

    /**
     * Startet die Session ({@code /LF010/}).
     *
     * @param config Konfiguration (eingefroren nach Start)
     * @param target Zielpunkt
     */
    void start(SessionConfig config, GeoCoordinate target);

    /**
     * @param fix GNSS-Fix
     */
    void onPositionUpdate(GpsFix fix);

    /**
     * @param courseDeg Kurs geografisch Nord 0..360
     */
    void onCourseUpdate(double courseDeg);

    /**
     * @return aktueller Snapshot ({@code /LF050/})
     */
    BearingSnapshot currentSnapshot();

    /**
     * Regulärer Abschluss ({@code /LF060/}).
     *
     * @return GPX-Ergebnis
     */
    GpxResult complete();

    /**
     * Abbruch ({@code /LF070/}).
     *
     * @return GPX-Ergebnis
     */
    GpxResult abort();

    /** Optional W3W ({@code /LF280/}). */
    Optional<String> resolveWhat3Words(double latitude, double longitude);

    /** Wiederanlauf ({@code /LL160/}). */
    void reset();
}
