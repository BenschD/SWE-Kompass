package com.example.bearing.spi.model;

import java.time.Instant;
import java.util.Optional;

/** {@code /LD160/} */
public final class GpxMetadata {

    private final Optional<String> name;
    private final Optional<String> description;
    private final Optional<String> author;
    private final Optional<Instant> timeStart;
    private final Optional<Instant> timeEnd;

    public GpxMetadata(
            Optional<String> name,
            Optional<String> description,
            Optional<String> author,
            Optional<Instant> timeStart,
            Optional<Instant> timeEnd) {
        this.name = name;
        this.description = description;
        this.author = author;
        this.timeStart = timeStart;
        this.timeEnd = timeEnd;
    }

    public Optional<String> name() {
        return name;
    }

    public Optional<String> description() {
        return description;
    }

    public Optional<String> author() {
        return author;
    }

    public Optional<Instant> timeStart() {
        return timeStart;
    }

    public Optional<Instant> timeEnd() {
        return timeEnd;
    }
}
