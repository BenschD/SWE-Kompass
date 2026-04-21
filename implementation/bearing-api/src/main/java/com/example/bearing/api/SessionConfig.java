package com.example.bearing.api;

import com.example.bearing.domain.OverflowMode;
import com.example.bearing.domain.RecordingParameters;
import com.example.bearing.domain.SpeedJumpPolicy;
import com.example.bearing.domain.optimize.TrackOptimizer;
import java.nio.file.Path;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

/**
 * Immutable Session-Konfiguration ({@code /LD110/}, {@code /LF400/}).
 */
public final class SessionConfig {

    public static final long DEFAULT_SAMPLING_MS = 2000L;
    public static final double DEFAULT_HDOP = 5.0;

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
    private final boolean persistOnAbort;
    private final Optional<Path> allowedBaseDir;
    private final Optional<Path> completePersistPath;
    private final Optional<Path> abortPersistPath;
    private final boolean listenerSerialized;
    private final List<TrackOptimizer> optimizers;
    private final Optional<String> w3wApiKey;

    private SessionConfig(Builder b) {
        this.samplingIntervalMs = b.samplingIntervalMs;
        this.softLimitPoints = b.softLimitPoints;
        this.hardLimitPoints = b.hardLimitPoints;
        this.overflowMode = b.overflowMode;
        this.hdopThreshold = b.hdopThreshold;
        this.discardWhenHdopExceeded = b.discardWhenHdopExceeded;
        this.segmentGapThreshold = b.segmentGapThreshold;
        this.maxFixAge = b.maxFixAge;
        this.maxImpliedSpeedMps = b.maxImpliedSpeedMps;
        this.speedJumpPolicy = b.speedJumpPolicy;
        this.recalculateSnapshotWhenPointDropped = b.recalculateSnapshotWhenPointDropped;
        this.persistOnAbort = b.persistOnAbort;
        this.allowedBaseDir = b.allowedBaseDir;
        this.completePersistPath = b.completePersistPath;
        this.abortPersistPath = b.abortPersistPath;
        this.listenerSerialized = b.listenerSerialized;
        this.optimizers = List.copyOf(b.optimizers);
        this.w3wApiKey = b.w3wApiKey;
    }

    /** Erzeugt eingefrorene Aufzeichnungsparameter ({@code /LF410/}). */
    public RecordingParameters toRecordingParameters() {
        return new RecordingParameters(
                samplingIntervalMs,
                softLimitPoints,
                hardLimitPoints,
                overflowMode,
                hdopThreshold,
                discardWhenHdopExceeded,
                segmentGapThreshold,
                maxFixAge,
                maxImpliedSpeedMps,
                speedJumpPolicy,
                recalculateSnapshotWhenPointDropped);
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

    public boolean persistOnAbort() {
        return persistOnAbort;
    }

    public Optional<Path> allowedBaseDir() {
        return allowedBaseDir;
    }

    public Optional<Path> completePersistPath() {
        return completePersistPath;
    }

    public Optional<Path> abortPersistPath() {
        return abortPersistPath;
    }

    public boolean listenerSerialized() {
        return listenerSerialized;
    }

    public List<TrackOptimizer> optimizers() {
        return optimizers;
    }

    public Optional<String> w3wApiKey() {
        return w3wApiKey;
    }

    /** Builder ({@code /LF400/}). */
    public static Builder builder() {
        return new Builder();
    }

    /** Standardkonfiguration. */
    public static SessionConfig defaults() {
        return builder().build();
    }

    /** Builder für {@link SessionConfig}. */
    public static final class Builder {

        private long samplingIntervalMs = DEFAULT_SAMPLING_MS;
        private int softLimitPoints;
        private int hardLimitPoints;
        private OverflowMode overflowMode = OverflowMode.STOP;
        private double hdopThreshold = DEFAULT_HDOP;
        private boolean discardWhenHdopExceeded = true;
        private Duration segmentGapThreshold = Duration.ofMinutes(5);
        private Duration maxFixAge = Duration.ofHours(24);
        private double maxImpliedSpeedMps = 300_000.0 / 3600.0;
        private SpeedJumpPolicy speedJumpPolicy = SpeedJumpPolicy.DISCARD;
        private boolean recalculateSnapshotWhenPointDropped = true;
        private boolean persistOnAbort;
        private Optional<Path> allowedBaseDir = Optional.empty();
        private Optional<Path> completePersistPath = Optional.empty();
        private Optional<Path> abortPersistPath = Optional.empty();
        private boolean listenerSerialized;
        private final List<TrackOptimizer> optimizers = new ArrayList<>();
        private Optional<String> w3wApiKey = Optional.empty();

        /**
         * @param ms Mindestabstand gespeicherter Punkte ({@code /LF110/}: 500–60000)
         * @return this
         */
        public Builder samplingIntervalMs(long ms) {
            this.samplingIntervalMs = ms;
            return this;
        }

        public Builder softLimitPoints(int v) {
            this.softLimitPoints = v;
            return this;
        }

        public Builder hardLimitPoints(int v) {
            this.hardLimitPoints = v;
            return this;
        }

        public Builder overflowMode(OverflowMode mode) {
            this.overflowMode = Objects.requireNonNull(mode);
            return this;
        }

        public Builder hdopThreshold(double v) {
            this.hdopThreshold = v;
            return this;
        }

        public Builder discardWhenHdopExceeded(boolean v) {
            this.discardWhenHdopExceeded = v;
            return this;
        }

        public Builder segmentGapThreshold(Duration d) {
            this.segmentGapThreshold = Objects.requireNonNull(d);
            return this;
        }

        public Builder maxFixAge(Duration d) {
            this.maxFixAge = Objects.requireNonNull(d);
            return this;
        }

        public Builder maxImpliedSpeedMps(double v) {
            this.maxImpliedSpeedMps = v;
            return this;
        }

        public Builder speedJumpPolicy(SpeedJumpPolicy p) {
            this.speedJumpPolicy = Objects.requireNonNull(p);
            return this;
        }

        public Builder recalculateSnapshotWhenPointDropped(boolean v) {
            this.recalculateSnapshotWhenPointDropped = v;
            return this;
        }

        public Builder persistOnAbort(boolean v) {
            this.persistOnAbort = v;
            return this;
        }

        public Builder allowedBaseDir(Path p) {
            this.allowedBaseDir = Optional.ofNullable(p);
            return this;
        }

        public Builder completePersistPath(Path p) {
            this.completePersistPath = Optional.ofNullable(p);
            return this;
        }

        public Builder abortPersistPath(Path p) {
            this.abortPersistPath = Optional.ofNullable(p);
            return this;
        }

        public Builder listenerSerialized(boolean v) {
            this.listenerSerialized = v;
            return this;
        }

        public Builder addOptimizer(TrackOptimizer o) {
            this.optimizers.add(Objects.requireNonNull(o));
            return this;
        }

        public Builder w3wApiKey(String key) {
            this.w3wApiKey = Optional.ofNullable(key);
            return this;
        }

        /**
         * @return validierte Konfiguration
         */
        public SessionConfig build() {
            if (samplingIntervalMs < 500 || samplingIntervalMs > 60_000) {
                throw new IllegalArgumentException("samplingIntervalMs must be 500..60000");
            }
            if (softLimitPoints < 0 || hardLimitPoints < 0) {
                throw new IllegalArgumentException("limits must be >= 0");
            }
            if (hdopThreshold < 0) {
                throw new IllegalArgumentException("hdopThreshold must be >= 0");
            }
            if (completePersistPath.isPresent() || abortPersistPath.isPresent()) {
                if (allowedBaseDir.isEmpty()) {
                    throw new IllegalArgumentException("allowedBaseDir required when persist paths set");
                }
            }
            return new SessionConfig(this);
        }
    }
}
