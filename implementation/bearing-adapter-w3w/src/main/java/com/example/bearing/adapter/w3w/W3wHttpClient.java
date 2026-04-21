package com.example.bearing.adapter.w3w;

import com.example.bearing.spi.W3wClientPort;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * What3Words Reverse-Lookup mit TTL-Cache ({@code /LF280/}, {@code /LF290/}). Nur JDK-HTTP.
 */
public final class W3wHttpClient implements W3wClientPort {

    private static final Pattern WORDS = Pattern.compile("\"words\"\\s*:\\s*\"([^\"]+)\"");

    private final String apiKey;
    private final Duration timeout;
    private final Duration ttl;
    private final Clock clock;
    private final Map<String, CacheEntry> cache;

    public W3wHttpClient(String apiKey, Duration timeout, Duration ttl, int maxEntries, Clock clock) {
        this.apiKey = Objects.requireNonNull(apiKey);
        this.timeout = timeout == null ? Duration.ofSeconds(5) : timeout;
        this.ttl = ttl == null ? Duration.ofMinutes(10) : ttl;
        this.clock = clock == null ? Clock.systemUTC() : clock;
        this.cache =
                new LinkedHashMap<>(16, 0.75f, true) {
                    @Override
                    protected boolean removeEldestEntry(Map.Entry<String, CacheEntry> eldest) {
                        return size() > maxEntries;
                    }
                };
    }

    @Override
    public synchronized String reverse(double latitude, double longitude) {
        if (apiKey.isBlank()) {
            return "w3w.missing.apikey";
        }
        String key = roundKey(latitude, longitude);
        Instant now = clock.instant();
        CacheEntry ce = cache.get(key);
        if (ce != null && Duration.between(ce.resolvedAt, now).compareTo(ttl) < 0) {
            return ce.words;
        }
        try {
            String uri =
                    "https://api.what3words.com/v3/convert-to-3wa?key="
                            + apiKey
                            + "&coordinates="
                            + latitude
                            + ","
                            + longitude
                            + "&language=de";
            HttpClient client = HttpClient.newBuilder().connectTimeout(timeout).build();
            HttpRequest req = HttpRequest.newBuilder(URI.create(uri)).timeout(timeout).GET().build();
            HttpResponse<String> resp = client.send(req, HttpResponse.BodyHandlers.ofString());
            if (resp.statusCode() / 100 != 2) {
                return "w3w.error.http-" + resp.statusCode();
            }
            Optional<String> words = parseWords(resp.body());
            String w = words.orElse("w3w.error.parse");
            cache.put(key, new CacheEntry(w, now));
            return w;
        } catch (IOException | InterruptedException e) {
            Thread.currentThread().interrupt();
            return "w3w.error.timeout";
        }
    }

    private static String roundKey(double lat, double lon) {
        return String.format("%.5f,%.5f", lat, lon);
    }

    static Optional<String> parseWords(String json) {
        Matcher m = WORDS.matcher(json);
        if (m.find()) {
            return Optional.of(m.group(1));
        }
        return Optional.empty();
    }

    private static final class CacheEntry {
        final String words;
        final Instant resolvedAt;

        CacheEntry(String words, Instant resolvedAt) {
            this.words = words;
            this.resolvedAt = resolvedAt;
        }
    }
}
