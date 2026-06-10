package com.example.bearing.spi;

import com.example.bearing.spi.model.GpxDocument;

/**
 * Serialisiert ein fertig aufbereitetes GPX-Dokument ({@code /LF140/}).
 */
public interface GpxWriterPort {

    /**
     * @param document GPX 1.1 inhaltlich vollständig
     * @return UTF-8 codierte Bytes ohne BOM
     */
    byte[] serialize(GpxDocument document);
}
