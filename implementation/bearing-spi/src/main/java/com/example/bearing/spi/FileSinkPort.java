package com.example.bearing.spi;

import java.nio.file.Path;

/**
 * Atomares Schreiben ({@code /LF220/}) mit Pfadprüfung ({@code /LF320/}).
 */
public interface FileSinkPort {

    /**
     * Schreibt Daten atomar (temp + rename) an {@code targetPath}.
     *
     * @param targetPath normalisierter Pfad innerhalb des erlaubten Basisverzeichnisses
     * @param utf8Xml    Inhalt
     */
    void writeAtomically(Path targetPath, byte[] utf8Xml);
}
