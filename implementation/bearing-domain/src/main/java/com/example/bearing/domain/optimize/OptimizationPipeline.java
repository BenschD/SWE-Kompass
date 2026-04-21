package com.example.bearing.domain.optimize;

import com.example.bearing.domain.GpsPoint;
import com.example.bearing.domain.Track;
import com.example.bearing.domain.TrackSegment;
import java.util.ArrayList;
import java.util.List;

/** Wendet Strategien sequentiell an ({@code /LF200/} Pipeline). */
public final class OptimizationPipeline {

    public Track apply(Track track, List<TrackOptimizer> strategies) {
        List<TrackSegment> newSegs = new ArrayList<>();
        for (TrackSegment seg : track.segments()) {
            List<GpsPoint> pts = new ArrayList<>(seg.points());
            for (TrackOptimizer opt : strategies) {
                pts = opt.optimize(pts);
            }
            if (!pts.isEmpty()) {
                newSegs.add(new TrackSegment(pts));
            }
        }
        return new Track(newSegs);
    }
}
