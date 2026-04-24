package com.example.bearing.api;

import com.example.bearing.domain.OverflowMode;
import com.example.bearing.domain.RecordingParameters;
import com.example.bearing.domain.optimize.TrackOptimizer;
import java.nio.file.Path;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

/**
 * Immutable Session-Konfiguration ({@code /LD110/}, {@code /LF400/}). Punktbudget und Segmentierung
 * gelten für den Roh-Track; {@link #optimizers()} sind ausschließlich für den GPX-Export und optional.
 */
public final class SessionConfig {

    private final int softLimitPoints;
    private final int hardLimitPoints;
    private final OverflowMode overflowMode;
    private final Duration segmentGapThreshold;
    private final Duration maxFixAge;
    private final boolean persistOnAbort;
    private final Optional<Path> allowedBaseDir;
    private final Optional<Path> completePersistPath;
    private final Optional<Path> abortPersistPath;
    private final boolean listenerSerialized;
    private final List<TrackOptimizer> optimizers;
    private final Optional<String> w3wApiKey;

    private SessionConfig(Builder b) {
        this.softLimitPoints = b.softLimitPoints;
        this.hardLimitPoints = b.hardLimitPoints;
        this.overflowMode = b.overflowMode;
        this.segmentGapThreshold = b.segmentGapThreshold;
        this.maxFixAge = b.maxFixAge;
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
        return new RecordingParameters(softLimitPoints, hardLimitPoints, overflowMode, segmentGapThreshold);
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

    public Duration maxFixAge() {
        return maxFixAge;
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

    public static Builder builder() {
        return new Builder();
    }

    public static SessionConfig defaults() {
        return builder().build();
    }

    public static final class Builder {

        private int softLimitPoints;
        private int hardLimitPoints;
        private OverflowMode overflowMode = OverflowMode.STOP;
        private Duration segmentGapThreshold = Duration.ofMinutes(5);
        private Duration maxFixAge = Duration.ofHours(24);
        private boolean persistOnAbort;
        private Optional<Path> allowedBaseDir = Optional.empty();
        private Optional<Path> completePersistPath = Optional.empty();
        private Optional<Path> abortPersistPath = Optional.empty();
        private boolean listenerSerialized;
        private final List<TrackOptimizer> optimizers = new ArrayList<>();
        private Optional<String> w3wApiKey = Optional.empty();

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

        public Builder segmentGapThreshold(Duration d) {
            this.segmentGapThreshold = Objects.requireNonNull(d);
            return this;
        }

        public Builder maxFixAge(Duration d) {
            this.maxFixAge = Objects.requireNonNull(d);
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

        public SessionConfig build() {
            if (softLimitPoints < 0 || hardLimitPoints < 0) {
                throw new IllegalArgumentException("limits must be >= 0");
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
