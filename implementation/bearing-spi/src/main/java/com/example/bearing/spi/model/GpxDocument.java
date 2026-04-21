package com.example.bearing.spi.model;

import java.util.List;

/** {@code /LD150/} — Eingabe für {@link com.example.bearing.spi.GpxWriterPort}. */
public final class GpxDocument {

    public static final String GPX_11_NAMESPACE = "http://www.topografix.com/GPX/1/1";

    private final GpxMetadata metadata;
    private final List<GpxTrackSegment> segments;

    public GpxDocument(GpxMetadata metadata, List<GpxTrackSegment> segments) {
        this.metadata = metadata;
        this.segments = List.copyOf(segments);
    }

    public GpxMetadata metadata() {
        return metadata;
    }

    public List<GpxTrackSegment> segments() {
        return segments;
    }
}
