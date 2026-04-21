package com.example.bearing.adapter.gpx;

import com.example.bearing.spi.GpxWriterPort;
import com.example.bearing.spi.model.GpxDocument;
import com.example.bearing.spi.model.GpxMetadata;
import com.example.bearing.spi.model.GpxTrackPoint;
import com.example.bearing.spi.model.GpxTrackSegment;
import java.nio.charset.StandardCharsets;
import java.time.format.DateTimeFormatter;

/**
 * GPX 1.1 Serialisierung ({@code /LF200/}).
 */
public final class GpxXmlWriter implements GpxWriterPort {

    private static final DateTimeFormatter ISO_INSTANT =
            DateTimeFormatter.ISO_INSTANT.withZone(java.time.ZoneOffset.UTC);

    @Override
    public byte[] serialize(GpxDocument document) {
        String xml = toXml(document);
        return xml.getBytes(StandardCharsets.UTF_8);
    }

    public String toXml(GpxDocument document) {
        StringBuilder sb = new StringBuilder(4096);
        sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        sb.append("<gpx version=\"1.1\" creator=\"bearing-java\" ");
        sb.append("xmlns=\"").append(GpxDocument.GPX_11_NAMESPACE).append("\" ");
        sb.append("xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" ");
        sb.append("xsi:schemaLocation=\"")
                .append(GpxDocument.GPX_11_NAMESPACE)
                .append(" http://www.topografix.com/GPX/1/1/gpx.xsd\">\n");
        appendMetadata(sb, document.metadata());
        sb.append("<trk>\n");
        for (GpxTrackSegment seg : document.segments()) {
            sb.append("<trkseg>\n");
            for (GpxTrackPoint p : seg.points()) {
                sb.append("<trkpt lat=\"")
                        .append(p.lat())
                        .append("\" lon=\"")
                        .append(p.lon())
                        .append("\">\n");
                sb.append("<time>").append(ISO_INSTANT.format(p.time())).append("</time>\n");
                p.elevationM()
                        .ifPresent(
                                e ->
                                        sb.append("<ele>")
                                                .append(e)
                                                .append("</ele>\n"));
                p.hdop().ifPresent(h -> sb.append("<hdop>").append(h).append("</hdop>\n"));
                p.speedMps().ifPresent(s -> sb.append("<speed>").append(s).append("</speed>\n"));
                sb.append("</trkpt>\n");
            }
            sb.append("</trkseg>\n");
        }
        sb.append("</trk>\n</gpx>\n");
        return sb.toString();
    }

    private static void appendMetadata(StringBuilder sb, GpxMetadata m) {
        sb.append("<metadata>\n");
        m.name().ifPresent(n -> sb.append("<name>").append(XmlEscaper.escape(n)).append("</name>\n"));
        m.description()
                .ifPresent(d -> sb.append("<desc>").append(XmlEscaper.escape(d)).append("</desc>\n"));
        m.author().ifPresent(a -> sb.append("<author>").append(XmlEscaper.escape(a)).append("</author>\n"));
        if (m.timeStart().isPresent() && m.timeEnd().isPresent()) {
            sb.append("<time>")
                    .append(ISO_INSTANT.format(m.timeStart().get()))
                    .append("</time>\n");
        }
        sb.append("</metadata>\n");
    }
}
