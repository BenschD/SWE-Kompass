package com.example.bearing.spi;

import java.time.Clock;
import java.time.Instant;

/**
 * Abstraktion der Systemzeit für deterministische Tests ({@code /LF340/}, {@code /LL170/}).
 */
public interface ClockPort {

    /**
     * @return aktueller Zeitpunkt (UTC)
     */
    Instant instant();

    /**
     * @return zugrundeliegende {@link Clock}-Instanz, falls benötigt
     */
    Clock clock();
}
