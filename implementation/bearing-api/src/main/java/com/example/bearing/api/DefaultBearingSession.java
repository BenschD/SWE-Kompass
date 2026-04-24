package com.example.bearing.api;

import com.example.bearing.api.internal.GpxExportMapper;
import com.example.bearing.domain.BearingCalculator;
import com.example.bearing.domain.BearingSnapshot;
import com.example.bearing.domain.GeoCoordinate;
import com.example.bearing.domain.GpsFix;
import com.example.bearing.domain.Track;
import com.example.bearing.domain.TrackAcceptResult;
import com.example.bearing.domain.TrackAggregator;
import com.example.bearing.domain.optimize.OptimizationPipeline;
import com.example.bearing.spi.ClockPort;
import com.example.bearing.spi.FileSinkPort;
import com.example.bearing.spi.GpxWriterPort;
import com.example.bearing.spi.LoggerPort;
import com.example.bearing.spi.W3wClientPort;
import com.example.bearing.spi.model.GpxDocument;
import com.example.bearing.spi.model.GpxMetadata;
import java.nio.file.Path;
import java.time.Instant;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.Collectors;

/**
 * Standardimplementierung ({@code /LF020/}-{@code /LF500/}). Sammelt validierte Fixes im Rohtrack;
 * vor GPX-Export optional {@link SessionConfig#optimizers()}.
 */
public final class DefaultBearingSession implements BearingSession {

    private enum Lifecycle {
        IDLE,
        ACTIVE,
        COMPLETED,
        ABORTED
    }

    private final ClockPort clock;
    private final LoggerPort logger;
    private final GpxWriterPort gpxWriter;
    private final Optional<FileSinkPort> fileSink;
    private final W3wClientPort w3wClient;
    private final OptimizationPipeline pipeline = new OptimizationPipeline();
    private final BearingCalculator calculator = new BearingCalculator();
    private final List<BearingListener> listeners = new CopyOnWriteArrayList<>();
    private final AtomicReference<Lifecycle> lifecycle = new AtomicReference<>(Lifecycle.IDLE);

    private UUID sessionId;
    private SessionConfig frozenConfig;
    private GeoCoordinate target;
    private TrackAggregator aggregator;
    private Optional<Double> courseDeg = Optional.empty();
    private Instant startedAt;
    private Optional<GpsFix> lastFix = Optional.empty();
    private boolean listenerSerialized;

    /**
     * @param clock      Zeitquelle
     * @param logger     Logger
     * @param gpxWriter  GPX-Writer
     * @param fileSink   optional atomarer Dateizugriff
     * @param w3wClient  W3W-Client (Noop oder HTTP)
     */
    public DefaultBearingSession(
            ClockPort clock, LoggerPort logger, GpxWriterPort gpxWriter, Optional<FileSinkPort> fileSink, W3wClientPort w3wClient) {
        this.clock = Objects.requireNonNull(clock);
        this.logger = Objects.requireNonNull(logger);
        this.gpxWriter = Objects.requireNonNull(gpxWriter);
        this.fileSink = Objects.requireNonNull(fileSink);
        this.w3wClient = Objects.requireNonNull(w3wClient);
    }

    /** Registriert Listener. */
    public void addListener(BearingListener l) {
        if (l != null) {
            listeners.add(l);
        }
    }

    @Override
    public UUID id() {
        return sessionId;
    }

    @Override
    public boolean isActive() {
        return lifecycle.get() == Lifecycle.ACTIVE;
    }

    @Override
    public synchronized void start(SessionConfig config, GeoCoordinate target) {
        if (!lifecycle.compareAndSet(Lifecycle.IDLE, Lifecycle.ACTIVE)) {
            throw new IllegalStateException("Session must be IDLE (call reset after COMPLETED/ABORTED)");
        }
        this.sessionId = UUID.randomUUID();
        this.frozenConfig = Objects.requireNonNull(config);
        this.target = Objects.requireNonNull(target);
        this.listenerSerialized = config.listenerSerialized();
        this.aggregator = new TrackAggregator(config.toRecordingParameters());
        this.startedAt = clock.instant();
        this.lastFix = Optional.empty();
        this.courseDeg = Optional.empty();
        fire(l -> l.onSessionStarted(sessionId));
    }

    @Override
    public synchronized void onPositionUpdate(GpsFix fix) {
        ensureActive();
        validate(fix);
        lastFix = Optional.of(fix);
        TrackAcceptResult res = aggregator.accept(fix);
        fire(l -> l.onPositionUpdate(sessionId, new TrackAcceptSummary(res.flags())));
        if (res.has(TrackAcceptResult.Flag.SOFT_LIMIT_WARN)) {
            fire(l -> l.onSoftLimitWarn(sessionId));
        }
        if (res.has(TrackAcceptResult.Flag.HARD_LIMIT_REACHED)) {
            fire(l -> l.onHardLimitReached(sessionId));
        }
    }

    @Override
    public synchronized void onCourseUpdate(double courseDeg) {
        ensureActive();
        if (courseDeg < 0 || courseDeg > 360 || Double.isNaN(courseDeg)) {
            throw new IllegalArgumentException("courseDeg 0..360");
        }
        this.courseDeg = Optional.of(courseDeg);
    }

    @Override
    public synchronized BearingSnapshot currentSnapshot() {
        ensureActive();
        GpsFix fix =
                lastFix.orElseThrow(() -> new IllegalStateException("No position fix available yet"));
        return calculator.snapshotTowardTarget(
                fix.latitudeDeg(), fix.longitudeDeg(), target, courseDeg);
    }

    @Override
    public synchronized GpxResult complete() {
        ensureActive();
        aggregator.finalizeOpenSegment();
        Track raw = aggregator.immutableTrack();
        Track optimized = pipeline.apply(raw, frozenConfig.optimizers());
        GpxMetadata meta = GpxExportMapper.metadataFor(optimized, Optional.of("bearing-session"));
        GpxDocument doc = GpxExportMapper.toDocument(optimized, meta);
        byte[] bytes = gpxWriter.serialize(doc);
        Instant ended = clock.instant();
        var stats = aggregator.statistics(startedAt, ended);
        List<String> names =
                frozenConfig.optimizers().stream().map(o -> o.name()).collect(Collectors.toList());
        frozenConfig
                .completePersistPath()
                .ifPresent(
                        p -> fileSink.ifPresent(fs -> fs.writeAtomically(relativeToBase(p), bytes)));
        lifecycle.set(Lifecycle.COMPLETED);
        GpxResult result = new GpxResult(bytes, stats, names);
        fire(l -> l.onSessionCompleted(sessionId, result));
        return result;
    }

    @Override
    public synchronized GpxResult abort() {
        ensureActive();
        aggregator.finalizeOpenSegment();
        Track raw = aggregator.immutableTrack();
        Track optimized = pipeline.apply(raw, frozenConfig.optimizers());
        GpxMetadata meta = GpxExportMapper.metadataFor(optimized, Optional.of("bearing-session-aborted"));
        GpxDocument doc = GpxExportMapper.toDocument(optimized, meta);
        byte[] bytes = gpxWriter.serialize(doc);
        Instant ended = clock.instant();
        var stats = aggregator.statistics(startedAt, ended);
        List<String> names =
                frozenConfig.optimizers().stream().map(o -> o.name()).collect(Collectors.toList());
        if (frozenConfig.persistOnAbort()) {
            frozenConfig
                    .abortPersistPath()
                    .ifPresent(
                            p -> fileSink.ifPresent(fs -> fs.writeAtomically(relativeToBase(p), bytes)));
        }
        lifecycle.set(Lifecycle.ABORTED);
        GpxResult result = new GpxResult(bytes, stats, names);
        fire(l -> l.onSessionAborted(sessionId, result));
        return result;
    }

    @Override
    public Optional<String> resolveWhat3Words(double latitude, double longitude) {
        return Optional.of(w3wClient.reverse(latitude, longitude));
    }

    @Override
    public synchronized void reset() {
        lifecycle.set(Lifecycle.IDLE);
        sessionId = null;
        frozenConfig = null;
        target = null;
        aggregator = null;
        lastFix = Optional.empty();
        courseDeg = Optional.empty();
    }

    private Path relativeToBase(Path p) {
        return p;
    }

    private void validate(GpsFix fix) throws ValidationException {
        try {
            new GeoCoordinate(fix.latitudeDeg(), fix.longitudeDeg());
        } catch (IllegalArgumentException ex) {
            throw new ValidationException(ErrorCode.COORD_RANGE, ex.getMessage());
        }
        Instant now = clock.instant();
        if (fix.time().isAfter(now.plusSeconds(1))) {
            throw new ValidationException(ErrorCode.TIMESTAMP_INVALID, "Fix time in future");
        }
        if (fix.time().isBefore(now.minus(frozenConfig.maxFixAge()))) {
            throw new ValidationException(ErrorCode.TIMESTAMP_INVALID, "Fix time too old");
        }
    }

    private void ensureActive() {
        if (lifecycle.get() != Lifecycle.ACTIVE) {
            throw new IllegalStateException("Session not ACTIVE");
        }
    }

    private void fire(java.util.function.Consumer<BearingListener> c) {
        for (BearingListener l : listeners) {
            runListener(() -> c.accept(l));
        }
    }

    private void runListener(Runnable r) {
        if (listenerSerialized) {
            synchronized (this) {
                safeRun(r);
            }
        } else {
            safeRun(r);
        }
    }

    private void safeRun(Runnable r) {
        try {
            r.run();
        } catch (Throwable t) {
            logger.error("listener", sessionId, "LISTENER_FAILED", t.getMessage(), t);
        }
    }
}
