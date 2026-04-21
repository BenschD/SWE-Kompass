package com.example.bearing.domain;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;
import java.util.Optional;

/**
 * Track-Aufzeichnung inkl. Sampling und Qualitätsregeln ({@code /LF100/}–{@code /LF180/}).
 */
public final class TrackAggregator {

    private final RecordingParameters params;
    private final BearingCalculator calc = new BearingCalculator();

    private final List<TrackSegment> closedSegments = new ArrayList<>();
    private final List<GpsPoint> current = new ArrayList<>();

    private GpsPoint lastStoredPoint;
    private Instant lastStoredTime;
    private int storedCount;
    private boolean softWarned;
    private boolean recordingStopped;

    public TrackAggregator(RecordingParameters params) {
        this.params = params;
    }

    public TrackAcceptResult accept(GpsFix fix) {
        if (recordingStopped) {
            return TrackAcceptResult.of(EnumSet.of(TrackAcceptResult.Flag.RECORDING_STOPPED), Optional.empty());
        }

        EnumSet<TrackAcceptResult.Flag> flags = EnumSet.noneOf(TrackAcceptResult.Flag.class);

        if (lastStoredPoint != null
                && lastStoredPoint.time().equals(fix.time())
                && lastStoredPoint.latitudeDeg() == fix.latitudeDeg()
                && lastStoredPoint.longitudeDeg() == fix.longitudeDeg()) {
            flags.add(TrackAcceptResult.Flag.DUPLICATE_DISCARDED);
            return TrackAcceptResult.of(flags, Optional.empty());
        }

        if (fix.hdop().isPresent() && fix.hdop().get() > params.hdopThreshold()) {
            if (params.discardWhenHdopExceeded()) {
                flags.add(TrackAcceptResult.Flag.HDOP_DISCARDED);
                return TrackAcceptResult.of(flags, Optional.empty());
            }
        }

        if (lastStoredPoint != null) {
            double dt = Duration.between(lastStoredPoint.time(), fix.time()).toMillis() / 1000.0;
            if (dt > 0) {
                double dist =
                        calc.greatCircleDistanceMeters(
                                lastStoredPoint.latitudeDeg(),
                                lastStoredPoint.longitudeDeg(),
                                fix.latitudeDeg(),
                                fix.longitudeDeg());
                double implied = dist / dt;
                if (implied > params.maxImpliedSpeedMps()) {
                    if (params.speedJumpPolicy() == SpeedJumpPolicy.DISCARD) {
                        flags.add(TrackAcceptResult.Flag.SPEED_JUMP_DISCARDED);
                        return TrackAcceptResult.of(flags, Optional.empty());
                    }
                    flags.add(TrackAcceptResult.Flag.SPEED_JUMP_LOGGED);
                }
            }
        }

        if (params.hardLimitPoints() > 0 && storedCount >= params.hardLimitPoints()) {
            if (params.overflowMode() == OverflowMode.STOP
                    || params.overflowMode() == OverflowMode.DOWNSAMPLE) {
                recordingStopped = true;
                flags.add(TrackAcceptResult.Flag.HARD_LIMIT_REACHED);
                flags.add(TrackAcceptResult.Flag.RECORDING_STOPPED);
                return TrackAcceptResult.of(flags, Optional.empty());
            }
        }

        if (lastStoredTime != null) {
            long gapMs = Duration.between(lastStoredTime, fix.time()).toMillis();
            if (gapMs < params.samplingIntervalMs()) {
                flags.add(TrackAcceptResult.Flag.SAMPLING_SKIPPED);
                return TrackAcceptResult.of(flags, Optional.empty());
            }
        }

        if (lastStoredPoint != null) {
            Duration gap = Duration.between(lastStoredPoint.time(), fix.time());
            if (gap.compareTo(params.segmentGapThreshold()) > 0) {
                closeCurrentSegment();
                flags.add(TrackAcceptResult.Flag.NEW_SEGMENT);
            }
        }

        if (params.softLimitPoints() > 0 && storedCount >= params.softLimitPoints() && !softWarned) {
            flags.add(TrackAcceptResult.Flag.SOFT_LIMIT_WARN);
            softWarned = true;
        }

        GpsPoint stored = GpsPoint.fromFix(fix);
        current.add(stored);
        lastStoredPoint = stored;
        lastStoredTime = fix.time();
        storedCount++;
        flags.add(TrackAcceptResult.Flag.STORED);
        return TrackAcceptResult.of(flags, Optional.of(stored));
    }

    public Track immutableTrack() {
        List<TrackSegment> segs = new ArrayList<>(closedSegments);
        if (!current.isEmpty()) {
            segs.add(new TrackSegment(new ArrayList<>(current)));
        }
        return new Track(segs);
    }

    public SessionStatistics statistics(Instant startedAt, Instant endedAt) {
        Track t = immutableTrack();
        double dist = 0;
        GpsPoint prev = null;
        for (TrackSegment s : t.segments()) {
            for (GpsPoint p : s.points()) {
                if (prev != null) {
                    dist +=
                            calc.greatCircleDistanceMeters(
                                    prev.latitudeDeg(), prev.longitudeDeg(), p.latitudeDeg(), p.longitudeDeg());
                }
                prev = p;
            }
        }
        Duration dur =
                startedAt != null && endedAt != null ? Duration.between(startedAt, endedAt) : Duration.ZERO;
        return new SessionStatistics(dist, dur, t.totalPoints());
    }

    private void closeCurrentSegment() {
        if (!current.isEmpty()) {
            closedSegments.add(new TrackSegment(new ArrayList<>(current)));
            current.clear();
        }
    }

    public void finalizeOpenSegment() {
        closeCurrentSegment();
    }
}
