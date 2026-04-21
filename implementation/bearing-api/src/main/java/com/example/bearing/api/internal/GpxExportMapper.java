package com.example.bearing.api.internal;

import com.example.bearing.domain.GpsPoint;
import com.example.bearing.domain.Track;
import com.example.bearing.domain.TrackSegment;
import com.example.bearing.spi.model.GpxDocument;
import com.example.bearing.spi.model.GpxMetadata;
import com.example.bearing.spi.model.GpxTrackPoint;
import com.example.bearing.spi.model.GpxTrackSegment;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/** Mappt Domänen-Track auf GPX-Transportmodell ({@code /LF490/}). */
public final class GpxExportMapper {

    private GpxExportMapper() {}

    /**
     * @param track    optimierter Track
     * @param metadata Metadaten
     * @return GPX-Dokument
     */
    public static GpxDocument toDocument(Track track, GpxMetadata metadata) {
        List<GpxTrackSegment> segs = new ArrayList<>();
        for (TrackSegment seg : track.segments()) {
            List<GpxTrackPoint> pts = new ArrayList<>();
            for (GpsPoint p : seg.points()) {
                pts.add(
                        new GpxTrackPoint(
                                p.latitudeDeg(),
                                p.longitudeDeg(),
                                p.time(),
                                p.elevationM(),
                                p.hdop(),
                                p.speedMps()));
            }
            if (!pts.isEmpty()) {
                segs.add(new GpxTrackSegment(pts));
            }
        }
        return new GpxDocument(metadata, segs);
    }

    /**
     * @param track Track
     * @param name  optionaler Name
     * @return Metadaten mit Zeitspanne
     */
    public static GpxMetadata metadataFor(Track track, Optional<String> name) {
        Instant min = null;
        Instant max = null;
        for (TrackSegment seg : track.segments()) {
            for (GpsPoint p : seg.points()) {
                if (min == null || p.time().isBefore(min)) {
                    min = p.time();
                }
                if (max == null || p.time().isAfter(max)) {
                    max = p.time();
                }
            }
        }
        return new GpxMetadata(
                name,
                Optional.empty(),
                Optional.empty(),
                min == null ? Optional.empty() : Optional.of(min),
                max == null ? Optional.empty() : Optional.of(max));
    }
}
