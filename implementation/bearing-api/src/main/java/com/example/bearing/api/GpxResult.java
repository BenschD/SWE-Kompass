package com.example.bearing.api;

import com.example.bearing.domain.SessionStatistics;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Optional;

/**
 * GPX-Export inkl. Statistik ({@code /LF230/}, {@code /LF500/}).
 */
public final class GpxResult {

    private final byte[] utf8Bytes;
    private final SessionStatistics statistics;
    private final List<String> appliedOptimizers;

    /**
     * @param utf8Bytes         GPX als UTF-8
     * @param statistics        Laufzeitstatistik
     * @param appliedOptimizers Namen der angewandten Optimierer
     */
    public GpxResult(byte[] utf8Bytes, SessionStatistics statistics, List<String> appliedOptimizers) {
        this.utf8Bytes = utf8Bytes.clone();
        this.statistics = statistics;
        this.appliedOptimizers = List.copyOf(appliedOptimizers);
    }

    public byte[] utf8Bytes() {
        return utf8Bytes.clone();
    }

    /** GPX als {@link String} (UTF-8). */
    public String asUtf8String() {
        return new String(utf8Bytes, StandardCharsets.UTF_8);
    }

    public SessionStatistics statistics() {
        return statistics;
    }

    public List<String> appliedOptimizers() {
        return appliedOptimizers;
    }

    /** Optionaler Hinweis auf persistierte Datei (nicht normativ). */
    public Optional<String> persistedPathHint() {
        return Optional.empty();
    }
}
