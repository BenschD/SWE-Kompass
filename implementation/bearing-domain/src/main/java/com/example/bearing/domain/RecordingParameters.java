package com.example.bearing.domain;

import java.time.Duration;
import java.util.Objects;

/**
 * Eingefrorene Aufzeichnungsparameter ({@code /LF410/}), aus {@link com.example.bearing.api.SessionConfig}
 * abgeleitet. Enthält nur Segmentierung und Punktbudget für den Roh-Track — keine Filter beim Einlesen.
 */
public final class RecordingParameters {

    private final int softLimitPoints;
    private final int hardLimitPoints;
    private final OverflowMode overflowMode;
    private final Duration segmentGapThreshold;

    public RecordingParameters(
            int softLimitPoints, int hardLimitPoints, OverflowMode overflowMode, Duration segmentGapThreshold) {
        this.softLimitPoints = softLimitPoints;
        this.hardLimitPoints = hardLimitPoints;
        this.overflowMode = Objects.requireNonNull(overflowMode);
        this.segmentGapThreshold = Objects.requireNonNull(segmentGapThreshold);
    }

    public int softLimitPoints() {
        return softLimitPoints;
    }

    public int hardLimitPoints() {
        return hardLimitPoints;
    }

    public OverflowMode overflowMode() {
        return overflowMode;
    }

    public Duration segmentGapThreshold() {
        return segmentGapThreshold;
    }
}
