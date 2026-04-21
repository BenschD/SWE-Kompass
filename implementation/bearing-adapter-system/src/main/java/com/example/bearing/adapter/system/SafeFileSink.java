package com.example.bearing.adapter.system;

import com.example.bearing.spi.FileSinkPort;
import java.io.IOException;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Objects;

/**
 * Atomares Schreiben mit Basispfad-Prüfung ({@code /LF220/}, {@code /LF320/}).
 */
public final class SafeFileSink implements FileSinkPort {

    private final Path allowedBaseDir;

    public SafeFileSink(Path allowedBaseDir) {
        this.allowedBaseDir = Objects.requireNonNull(allowedBaseDir).toAbsolutePath().normalize();
    }

    @Override
    public void writeAtomically(Path targetPath, byte[] utf8Xml) {
        Path normalizedTarget = allowedBaseDir.resolve(targetPath).normalize();
        if (!normalizedTarget.startsWith(allowedBaseDir)) {
            throw new SecurityException("Path outside allowed base directory: " + targetPath);
        }
        try {
            Files.createDirectories(normalizedTarget.getParent());
            Path tmp = Files.createTempFile(normalizedTarget.getParent(), "gpx-", ".tmp");
            Files.write(tmp, utf8Xml);
            try {
                Files.move(tmp, normalizedTarget, StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
            } catch (AtomicMoveNotSupportedException ex) {
                Files.copy(tmp, normalizedTarget, StandardCopyOption.REPLACE_EXISTING);
                Files.deleteIfExists(tmp);
            }
        } catch (IOException e) {
            throw new RuntimeException("Failed to write GPX file", e);
        }
    }
}
