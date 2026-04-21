package com.example.bearing.spi;

import java.util.UUID;

/**
 * Strukturierte Protokollierung ({@code /LF420/}, {@code /LL140/}).
 */
public interface LoggerPort {

    void debug(String phase, UUID sessionId, String message);

    void info(String phase, UUID sessionId, String message);

    void warn(String phase, UUID sessionId, String errorCode, String message);

    void warn(String phase, UUID sessionId, String errorCode, String message, Throwable cause);

    void error(String phase, UUID sessionId, String errorCode, String message, Throwable cause);
}
