package com.example.bearing.api;

import static org.assertj.core.api.Assertions.assertThat;

import com.example.bearing.adapter.gpx.GpxXmlWriter;
import com.example.bearing.spi.model.GpxDocument;
import com.example.bearing.spi.model.GpxMetadata;
import com.example.bearing.spi.model.GpxTrackPoint;
import com.example.bearing.spi.model.GpxTrackSegment;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;

/** TC-100 — GPX-Namespace ({@code /LF200/}). */
class GpxXmlWriterTest {

    @Test
    void containsGpx11Namespace() {
        GpxXmlWriter w = new GpxXmlWriter();
        GpxTrackPoint p =
                new GpxTrackPoint(
                        48.77,
                        9.17,
                        Instant.parse("2026-01-01T12:00:00Z"),
                        Optional.empty(),
                        Optional.empty(),
                        Optional.empty());
        GpxDocument doc =
                new GpxDocument(
                        new GpxMetadata(Optional.of("t"), Optional.empty(), Optional.empty(), Optional.empty(), Optional.empty()),
                        List.of(new GpxTrackSegment(List.of(p))));
        String xml = new String(w.serialize(doc), StandardCharsets.UTF_8);
        assertThat(xml).contains("http://www.topografix.com/GPX/1/1");
    }
}
