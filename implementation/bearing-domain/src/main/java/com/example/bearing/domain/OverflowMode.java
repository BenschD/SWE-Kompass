package com.example.bearing.domain;

/** Verhalten bei Hard-Limit ({@code /LF180/}). */
public enum OverflowMode {
    /** Aufzeichnung stoppen. */
    STOP,
    /** Grobes Downsampling (jeder zweite Punkt verwerfen) — vereinfachte Policy. */
    DOWNSAMPLE
}
