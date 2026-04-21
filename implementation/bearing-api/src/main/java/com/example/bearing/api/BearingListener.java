package com.example.bearing.api;

import java.util.UUID;

/**
 * Observer für Session-Ereignisse ({@code /LF080/}). Implementierungen sollten kurz sein; bei
 * Exceptions bleibt die Session konsistent (Host-Thread, {@code /LF350/}).
 */
public interface BearingListener {

    /** Session wurde gestartet. */
    default void onSessionStarted(UUID sessionId) {}

    /** Positionsupdate verarbeitet (gespeichert oder verworfen). */
    default void onPositionUpdate(UUID sessionId, TrackAcceptSummary notification) {}

    /** Soft-Limit Warnung. */
    default void onSoftLimitWarn(UUID sessionId) {}

    /** Hard-Limit erreicht. */
    default void onHardLimitReached(UUID sessionId) {}

    /** Regulärer Abschluss. */
    default void onSessionCompleted(UUID sessionId, GpxResult result) {}

    /** Abbruch. */
    default void onSessionAborted(UUID sessionId, GpxResult result) {}
}
