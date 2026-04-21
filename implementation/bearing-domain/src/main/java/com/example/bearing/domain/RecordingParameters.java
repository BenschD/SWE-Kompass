package com.example.bearing.domain;

import java.time.Duration;
import java.util.Objects;

/**
 * Eingefrorene Aufzeichnungsparameter ({@code /LF410/}), aus {@code SessionConfig} abgeleitet.
 */
public final class RecordingParameters {

    private final long samplingIntervalMs;
    private final int softLimitPoints;
    private final int hardLimitPoints;
    private final OverflowMode overflowMode;
    private final double hdopThreshold;
    private final boolean discardWhenHdopExceeded;
    private final Duration segmentGapThreshold;
    private final Duration maxFixAge;
    private final double maxImpliedSpeedMps;
    private final SpeedJumpPolicy speedJumpPolicy;
    private final boolean recalculateSnapshotWhenPointDropped;

    public RecordingParameters(
            long samplingIntervalMs,
            int softLimitPoints,
            int hardLimitPoints,
            OverflowMode overflowMode,
            double hdopThreshold,
            boolean discardWhenHdopExceeded,
            Duration segmentGapThreshold,
            Duration maxFixAge,
            double maxImpliedSpeedMps,
            SpeedJumpPolicy speedJumpPolicy,
            boolean recalculateSnapshotWhenPointDropped) {
        this.samplingIntervalMs = samplingIntervalMs;
        this.softLimitPoints = softLimitPoints;
        this.hardLimitPoints = hardLimitPoints;
        this.overflowMode = Objects.requireNonNull(overflowMode);
        this.hdopThreshold = hdopThreshold;
        this.discardWhenHdopExceeded = discardWhenHdopExceeded;
        this.segmentGapThreshold = Objects.requireNonNull(segmentGapThreshold);
        this.maxFixAge = Objects.requireNonNull(maxFixAge);
        this.maxImpliedSpeedMps = maxImpliedSpeedMps;
        this.speedJumpPolicy = Objects.requireNonNull(speedJumpPolicy);
        this.recalculateSnapshotWhenPointDropped = recalculateSnapshotWhenPointDropped;
    }

    public long samplingIntervalMs() {
        return samplingIntervalMs;
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

    public double hdopThreshold() {
        return hdopThreshold;
    }

    public boolean discardWhenHdopExceeded() {
        return discardWhenHdopExceeded;
    }

    public Duration segmentGapThreshold() {
        return segmentGapThreshold;
    }

    public Duration maxFixAge() {
        return maxFixAge;
    }

    public double maxImpliedSpeedMps() {
        return maxImpliedSpeedMps;
    }

    public SpeedJumpPolicy speedJumpPolicy() {
        return speedJumpPolicy;
    }

    public boolean recalculateSnapshotWhenPointDropped() {
        return recalculateSnapshotWhenPointDropped;
    }
}
