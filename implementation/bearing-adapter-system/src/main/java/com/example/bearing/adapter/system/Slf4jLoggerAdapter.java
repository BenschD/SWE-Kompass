package com.example.bearing.adapter.system;

import com.example.bearing.spi.LoggerPort;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/** SLF4J-Adapter ({@code /LL140/}). */
public final class Slf4jLoggerAdapter implements LoggerPort {

    private final Logger log;

    public Slf4jLoggerAdapter(Class<?> clazz) {
        this.log = LoggerFactory.getLogger(clazz);
    }

    @Override
    public void debug(String phase, UUID sessionId, String message) {
        log.debug("[phase={} sessionId={}] {}", phase, sessionId, message);
    }

    @Override
    public void info(String phase, UUID sessionId, String message) {
        log.info("[phase={} sessionId={}] {}", phase, sessionId, message);
    }

    @Override
    public void warn(String phase, UUID sessionId, String errorCode, String message) {
        log.warn("[phase={} sessionId={} code={}] {}", phase, sessionId, errorCode, message);
    }

    @Override
    public void warn(String phase, UUID sessionId, String errorCode, String message, Throwable cause) {
        log.warn("[phase={} sessionId={} code={}] {}", phase, sessionId, errorCode, message, cause);
    }

    @Override
    public void error(String phase, UUID sessionId, String errorCode, String message, Throwable cause) {
        log.error("[phase={} sessionId={} code={}] {}", phase, sessionId, errorCode, message, cause);
    }
}
