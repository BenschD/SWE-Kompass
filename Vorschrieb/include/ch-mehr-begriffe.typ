#import "macros.typ": begriffskarte

#let ch-mehr-begriffe-kapitel = [
#set par(justify: true)

#begriffskarte(
  "ECEF (Earth-Centered, Earth-Fixed)",
  "Rechtshändiges kartesisches Koordinatensystem mit Ursprung im Erdmittelpunkt (vereinfacht), Z-Achse durch den Nordpol.",
  "",
  "Interne Hilfskonstruktion für Distanzen im Raum optional; öffentliche API bleibt WGS84 lat/lon.",
  "Koordinaten X, Y, Z in Metern.",
  "ISO 19111; GNSS-Standardliteratur.",
)

#begriffskarte(
  "EPSG:4326",
  "Geographisches CRS: Achsenfolge Breite (φ), Länge (λ) in Grad auf WGS84-Ellipsoid.",
  "",
  "Gültig für alle Eingaben dieser Bibliothek; andere EPSG-Codes nur nach expliziter Erweiterung.",
  "CRS-Code als Metadaten-Hinweis exportierbar.",
  "EPSG Geodetic Parameter Dataset.",
)

#begriffskarte(
  "Turn-by-Turn-Navigation",
  "Schrittweise Routenführung entlang von Kanten eines Straßengraphen mit Manöveranweisungen.",
  "",
  "Explizit *nicht* Gegenstand der Peilungskomponente.",
  "—",
  "Allgemeiner Sprachgebrauch; Abgrenzung Projektauftrag.",
)

#begriffskarte(
  "Ist-/Soll-Vergleich (Referenz-App)",
  "Qualitative Gegenüberstellung der Referenz-App mit der Java-Bibliothek ohne pixelgenaue UI-Nachbildung.",
  "",
  "Dient der Motivation und Begriffsableitung, nicht als normative Spezifikation der UI.",
  "—",
  "Apple App Store, Produktseite Kompass Professional (abrufbar unter der im Abstract genannten URL).",
)

#begriffskarte(
  "Maven-Profil (`w3w`)",
  "Optionale Build-Konfiguration, die What3Words-Clientabhängigkeiten aktiviert.",
  "",
  "Standardbuild ohne Profil bleibt offline-fähig.",
  "Aktivierung: `mvn -Pw3w test` (konzeptionell).",
  "Apache Maven Documentation – Profiles.",
)

#begriffskarte(
  "JaCoCo",
  "Code-Coverage-Tool für Java, Integration über Maven-Plugin.",
  "",
  "Messgröße für `/LL150/`.",
  "Report: `target/site/jacoco/index.html`.",
  "https://www.jacoco.org/jacoco/trunk/doc/",
)

#begriffskarte(
  "ArchUnit",
  "Bibliothek zur Überprüfung architektonischer Regeln im JUnit-Test (z. B. keine AWT-Imports).",
  "",
  "Optional zur Absicherung von `/LF430/`.",
  "Regel: `noClasses().that()...`",
  "https://www.archunit.org/",
)

#begriffskarte(
  "Jimfs",
  "In-Memory-Dateisystem-Implementierung für JDK `java.nio.file`, geeignet für Tests.",
  "",
  "Nur Testscope.",
  "Google Jimfs Projekt.",
  "https://github.com/google/jimfs",
)

#begriffskarte(
  "Property \"deterministisch\"",
  "Gleiche Eingaben und gleiche konfigurierte Abhängigkeiten (Clock) erzeugen identische Ausgaben.",
  "",
  "Gilt für Kern-Pfade ohne bewusst randomisierte Algorithmen.",
  "—",
  "/LL190/, /LF340/.",
)

#begriffskarte(
  "Semantische Exception",
  "Fehlerklasse mit maschinenlesbarem `errorCode` und kontextualisierter Message.",
  "",
  "Öffentliche API der Bibliothek.",
  "Feld: `String code`.",
  "/LF090/; Best Practice API Design.",
)

#begriffskarte(
  "Overflow-Modus (Punktbudget)",
  "Definiertes Verhalten bei Erreichen des Hard-Limits: Stopp der Aufzeichnung vs. Downsampling.",
  "",
  "Konfigurationsabhängig /LF180/.",
  "Enum-Kandidat: `STOP`, `DOWNSAMPLE` (Beispiel).",
  "Interne Spezifikation.",
)

#begriffskarte(
  "UTF-8",
  "Byte-Kodierung für Unicode-Zeichen; verbindlich für GPX-XML in diesem Projekt.",
  "",
  "Alle serialisierten GPX-Dokumente.",
  "Kennung in XML-Deklaration optional, Bytes konsistent.",
  "Unicode Standard Annex #15 (normalization optional).",
)

#begriffskarte(
  "Referenzimplementierung (Test)",
  "Unabhängige, minimal gehaltene Berechnung derselben Größe zum Abgleich von Toleranzen.",
  "",
  "Testcode, nicht Produktivpfad.",
  "`ReferenceHaversine` (Bezeichner frei wählbar).",
  "/LL020/ Testpraxis.",
)
]
