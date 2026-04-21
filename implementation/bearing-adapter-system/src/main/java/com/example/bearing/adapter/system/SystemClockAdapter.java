package com.example.bearing.adapter.system;

import com.example.bearing.spi.ClockPort;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;

/** System-{@link Clock}. */
public final class SystemClockAdapter implements ClockPort {

    private final Clock clock;

    public SystemClockAdapter() {
        this.clock = Clock.systemUTC();
    }

    public SystemClockAdapter(Clock clock) {
        this.clock = clock;
    }

    @Override
    public Instant instant() {
        return clock.instant();
    }

    @Override
    public Clock clock() {
        return clock.withZone(ZoneOffset.UTC);
    }
}
