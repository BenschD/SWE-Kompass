package com.example.bearing.adapter.system;

import com.example.bearing.spi.W3wClientPort;

/** Fallback ohne Netz ({@code /LF280/}). */
public final class NoopW3wClient implements W3wClientPort {

    @Override
    public String reverse(double latitude, double longitude) {
        return "w3w.unavailable.offline";
    }
}
