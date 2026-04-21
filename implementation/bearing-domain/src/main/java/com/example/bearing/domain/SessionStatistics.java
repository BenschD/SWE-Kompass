package com.example.bearing.domain;

import java.time.Duration;

/** {@code /LF500/} */
public final class SessionStatistics {

    private final double totalDistanceM;
    private final Duration totalDuration;
    private final int storedPointCount;

    public SessionStatistics(double totalDistanceM, Duration totalDuration, int storedPointCount) {
        this.totalDistanceM = totalDistanceM;
        this.totalDuration = totalDuration;
        this.storedPointCount = storedPointCount;
    }

    public double totalDistanceM() {
        return totalDistanceM;
    }

    public Duration totalDuration() {
        return totalDuration;
    }

    public int storedPointCount() {
        return storedPointCount;
    }
}
