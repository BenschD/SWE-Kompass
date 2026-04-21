package com.example.bearing.api;

import com.example.bearing.domain.TrackAcceptResult;
import java.util.EnumSet;

/** Öffentliche Kurzinfo zum letzten Positionsupdate. */
public final class TrackAcceptSummary {

    private final EnumSet<TrackAcceptResult.Flag> flags;

    /**
     * @param flags gesetzte Flags aus der Domäne
     */
    public TrackAcceptSummary(EnumSet<TrackAcceptResult.Flag> flags) {
        this.flags = flags.clone();
    }

    public EnumSet<TrackAcceptResult.Flag> flags() {
        return flags.clone();
    }

    public boolean stored() {
        return flags.contains(TrackAcceptResult.Flag.STORED);
    }
}
