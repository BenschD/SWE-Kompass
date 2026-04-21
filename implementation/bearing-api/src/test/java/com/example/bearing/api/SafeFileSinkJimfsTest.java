package com.example.bearing.api;

import static org.assertj.core.api.Assertions.assertThat;

import com.example.bearing.adapter.system.SafeFileSink;
import com.google.common.jimfs.Configuration;
import com.google.common.jimfs.Jimfs;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileSystem;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.Test;

/** TC-080 — atomares Schreiben relativ zum Basisdir (Jimfs). */
class SafeFileSinkJimfsTest {

    @Test
    void writesInsideBase() throws Exception {
        try (FileSystem fs = Jimfs.newFileSystem(Configuration.unix())) {
            Path base = fs.getPath("/data");
            Files.createDirectories(base);
            SafeFileSink sink = new SafeFileSink(base);
            Path rel = fs.getPath("tracks", "a.gpx");
            byte[] xml = "<gpx/>".getBytes(StandardCharsets.UTF_8);
            sink.writeAtomically(rel, xml);
            Path abs = base.resolve(rel).normalize();
            assertThat(Files.readAllBytes(abs)).isEqualTo(xml);
        }
    }
}
