package com.example.bearing.domain;

import java.util.EnumSet;
import java.util.Optional;

/** Ergebnis eines Aufzeichnungsschritts. */
public final class TrackAcceptResult {

    public enum Flag {
        STORED,
        SOFT_LIMIT_WARN,
        HARD_LIMIT_REACHED,
        DUPLICATE_DISCARDED,
        HDOP_DISCARDED,
        SPEED_JUMP_DISCARDED,
        SPEED_JUMP_LOGGED,
        NEW_SEGMENT,
        SAMPLING_SKIPPED,
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
