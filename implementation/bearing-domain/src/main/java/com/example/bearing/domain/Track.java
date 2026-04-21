package com.example.bearing.domain;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/** {@code /LD120/} */
public final class Track {

    private final List<TrackSegment> segments;

    public Track(List<TrackSegment> segments) {
        this.segments = Collections.unmodifiableList(new ArrayList<>(segments));
    }

    public List<TrackSegment> segments() {
        return segments;
    }

    public int totalPoints() {
        int n = 0;
        for (TrackSegment s : segments) {
            n += s.points().size();
        }
        return n;
    }
}
