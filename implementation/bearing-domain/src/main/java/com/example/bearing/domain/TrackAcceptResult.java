package com.example.bearing.domain;

import java.util.EnumSet;
import java.util.Optional;

/** Ergebnis eines Aufzeichnungsschritts (Rohspeicher ohne Einlese-Filter). */
public final class TrackAcceptResult {

    public enum Flag {
        STORED,
        SOFT_LIMIT_WARN,
        HARD_LIMIT_REACHED,
        NEW_SEGMENT,
        RECORDING_STOPPED
    }

    private final EnumSet<Flag> flags;
    private final Optional<GpsPoint> storedPoint;

    private TrackAcceptResult(EnumSet<Flag> flags, Optional<GpsPoint> storedPoint) {
        this.flags = flags.clone();
        this.storedPoint = storedPoint;
    }

    public static TrackAcceptResult of(EnumSet<Flag> flags, Optional<GpsPoint> stored) {
        return new TrackAcceptResult(flags, stored);
    }

    public EnumSet<Flag> flags() {
        return flags.clone();
    }

    public Optional<GpsPoint> storedPoint() {
        return storedPoint;
    }

    public boolean has(Flag f) {
        return flags.contains(f);
    }
}
