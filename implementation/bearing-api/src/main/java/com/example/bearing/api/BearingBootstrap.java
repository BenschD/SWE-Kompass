package com.example.bearing.api;

import com.example.bearing.adapter.gpx.GpxXmlWriter;
import com.example.bearing.adapter.system.NoopW3wClient;
import com.example.bearing.adapter.system.SafeFileSink;
import com.example.bearing.adapter.system.Slf4jLoggerAdapter;
import com.example.bearing.adapter.system.SystemClockAdapter;
import com.example.bearing.adapter.w3w.W3wHttpClient;
import com.example.bearing.spi.ClockPort;
import com.example.bearing.spi.FileSinkPort;
import com.example.bearing.spi.GpxWriterPort;
import com.example.bearing.spi.LoggerPort;
import com.example.bearing.spi.W3wClientPort;
import java.nio.file.Path;
import java.time.Clock;
import java.time.Duration;
import java.util.Optional;

/**
 * Fabrikmethoden für eine lauffähige Session ({@code /LF450/}).
 */
public final class BearingBootstrap {

    private BearingBootstrap() {}

    /**
     * @param clock     testbar injizierbar
     * @param baseDir   optional erlaubtes Basisverzeichnis für Dateizugriffe
     * @param w3wClient optional W3W-Client
     * @return neue Session im Zustand IDLE
     */
    public static DefaultBearingSession newSession(ClockPort clock, Optional<Path> baseDir, W3wClientPort w3wClient) {
        LoggerPort log = new Slf4jLoggerAdapter(DefaultBearingSession.class);
        GpxWriterPort gpx = new GpxXmlWriter();
        Optional<FileSinkPort> sink = baseDir.map(SafeFileSink::new);
        return new DefaultBearingSession(clock, log, gpx, sink, w3wClient);
    }

    /** Produktions-Clock (UTC). */
    public static DefaultBearingSession newSession(Optional<Path> baseDir, W3wClientPort w3wClient) {
        return newSession(new SystemClockAdapter(), baseDir, w3wClient);
    }

    /** Standard ohne Datei-Basis, ohne W3W-Netz. */
    public static DefaultBearingSession newSession() {
        return newSession(Optional.empty(), new NoopW3wClient());
    }

    /**
     * W3W-HTTP-Client nur mit gültigem Key ({@code /LF280/}).
     *
     * @param apiKey API-Key
     * @param clock  Clock für Cache-TTL
     * @return Client
     */
    public static W3wClientPort w3wHttp(String apiKey, Clock clock) {
        return new W3wHttpClient(apiKey, Duration.ofSeconds(5), Duration.ofMinutes(10), 256, clock);
    }
}
