#import "macros.typ": begriffskarte

#let ch-einleitung-kapitel = [
#set par(justify: true)

Dieses Kapitel führt in die Problemstellung, den Zweck und den Einsatzbereich der Java-Peilungskomponente ein. Es legt die terminologische Grundlage über ein normiertes Glossar und schließt mit einem Überblick über den Aufbau dieses Dokuments.

// ─────────────────────────────────────────────────────────────────────────────
== Zweck
// ─────────────────────────────────────────────────────────────────────────────

Ziel dieses Dokuments ist die vollständige, prüfbare Spezifikation einer UI-freien Java-Bibliothek, die Peilungsfunktionalität, GPS-Track-Aufzeichnung und GPX-1.1-Export bereitstellt.

*Konkrete Ziele der Bibliothek:*


//Abändern?
- *(nachdem 3. fertig ist ändern) Anforderungsanalyse und Spezifikation:* SOPHIST-konforme, eindeutig prüfbare Formulierung aller Anforderungen (funktional, nicht-funktional, Datenschnittstellen, Randbedingungen), ergänzt um Qualitäts- und Risikoaspekte sowie objektorientierte Analyse- und Entwurfsartefakte.

- *Implementierung:* UI-freie Java-Komponente mit klaren Eingabeschnittstellen für Positions- und Kursdaten, konfigurierbarer Aufzeichnung, GPX-1.1-konformem Export und optionaler What3Words-Anbindung.

- *Qualitätssicherung:* Nachvollziehbare Testfälle pro fachlichem Modul mit automatisierter Ausführung über Maven und reproduzierbaren Ergebnissen als Grundlage für die Abnahme.

- *Lieferfähigkeit:* Lauffähiger Quellcode ohne ausführbare Fat-JAR als Hauptartefakt sowie eine Test-Suite, die sich direkt mit `mvn test` ausführen lässt.

*Erfolgskriterien dieses Projekts:*

- Die Komponente ist ohne UI lauffähig und per `mvn test` vollständig verifizierbar.
- Alle Anforderungen sind durch mindestens einen dokumentierten Testfall abdeckbar.
- GPX-Ausgaben enthalten den GPX-1.1-Namespace und valide Zeitstempel im UTC-ISO-8601-Format.
- Keine Klassen aus UI-Frameworks werden referenziert.

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Einsatzbereich
// ─────────────────────────────────────────────────────────────────────────────

=== Problemstellung und fachlicher Hintergrund

Im Rahmen der Projektarbeit wird die IOS-Anwendung _Kompass Professional_ als fachliche Referenz analysiert. Der Fokus liegt auf der Peilungsfunktion und nicht auf einer vollständigen Navigationslösung. Unter Peilung wird in dieser Arbeit die Berechnung der Richtung und Entfernung von der aktuellen Position zu einem Zielpunkt verstanden.

*Hintergrund:* Die IOS-App „Kompass Professional" demonstriert eine Peilungsfunktion: Sie zeigt wohin, relativ zur aktuellen Orientierung bzw. Position, ohne Navigation im Sinne einer Turn-by-Turn-Führung. Die App zeichnet dabei einen GPS-Track auf, der als GPX exportierbar ist. Ihre Peilungslogik ist jedoch fest mit der grafischen Oberfläche und der Hardwareanbindung verknüpft.

Die zentrale Problemstellung besteht in der konsistenten und reproduzierbaren Berechnung von Zielrichtung (Azimut), Entfernung und diskreter Ordinalrichtung auf Basis von WGS84-Koordinaten unter klar definierten Eingangs- und Schnittstellenbedingungen. Zusätzlich muss die Verarbeitung als kontinuierlicher Session-Prozess mit Start, Laufzeit und Abbruch konzipiert werden, bei dem Track-Daten trotz Unterbrechungen vollständig exportierbar bleiben.

*Zielbild der Bibliothek:* Die Bibliothek ermittelt durch vom Host gelieferte Positions- und Kursdaten die Peilungsgrößen  und zeichnet währenddessen einen GPS-Track auf, der als GPX 1.1 exportierbar ist. Zusätlich ist eine Auflösung als What3Word möglich.

=== Im Scope

- Geografische Berechnung von Zielrichtung (Azimut), Entfernung und diskreter Ordinalrichtung auf WGS84-Basis mit optionaler Kursabweichung bei verfügbarem Kurswert.
- Klar definierte Integrationsschnittstellen, über die der Host Positionsdaten und weitere Rechnungsdaten (z.B. Zeitstempel, Geschwindigkeit, Genauigkeit) bereitstellt.
- Session-Lebenszyklus mit Start, laufender Aufzeichnung und Abbruch. Bei Abbruch werden die bis dahin erfassten Track-Daten weiterhin exportierbar bereitgestellt.
- Konfigurierbare Aufzeichnungslogik: Punktbudget (Soft-/Hard-Limit), Segmentierung bei Zeitlücken. Die Aufrufhäufigkeit von Positionsupdates steuert der Host.
- GPX-1.1-konformer Export der Track-Daten als String oder Bytefolge.
- Vor dem Export möglich: Erweiterbare Optimierungsverfahren (z.B. n-ter Punkt, Mindestabstand, Geraden-Heuristik, Douglas-Peucker) sowie optionaler What3Words-Bezug inklusive Caching.

=== Außerhalb des Scopes

- Track-Optimierung der eingehenden Rohdaten beim Einlesen.
- Magnetische Peilung inklusive automatischer Deklinationskorrektur.
- Kartendarstellung, Kartenmatching, Routing, Geocoding allgemeiner Adressstrings.
- Hardwareanbindung, da der Host fertige Messwerte liefert.
- Persistenzvorgaben wie ein festes Dateiziel für den GPX-Export, zusätlich liegt die Entscheidung über Speicherort und Dateiverwaltung liegt beim Host.
- Cloud-Persistenz, Benutzerverwaltung, Rechteverwaltung.

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Glossar
// ─────────────────────────────────────────────────────────────────────────────

Das folgende Glossar normiert alle für dieses Dokument relevanten Fachbegriffe. Die Begriffskarten folgen dem SOPHIST-Standard mit den Feldern Definition, Abgrenzung, Gültigkeit, Bezeichnung/Symbol und Quellverweis.

=== Fachbegriffe Navigation und Geografie

#begriffskarte(
  "Peilung (Bearing)",
  "Bestimmung der horizontalen Zielrichtung von einem Bezugspunkt zu einem Zielpunkt.",
  "Keine Turn-by-Turn-Navigation.",
  "Gültig für WGS84-Koordinaten auf der Erdoberfläche.",
  "",
  "Peter Bohl",
)

#begriffskarte(
  "Geografischer Azimut",
  "Horizontaler Winkel zwischen der geografischen Nordrichtung und der Großkreisrichtung zum Ziel.",
  "",
  "Gültig für Entfernungen > 0 m.",
  "Symbol: α oder `azimuthDeg`; Einheit: ° (Grad).",
  "Gängige Navigationsliteratur.",
)

#begriffskarte(
  "Kurs (Heading)",
  "Orientierung der lokalen Horizontalebene relativ zu geografisch Nord, typischerweise als Winkel 0°–360°.",
  "",
  "Gültig, wenn der Host verlässliche Kursinformation liefert.",
  "Symbol: ψ oder `headingDeg`; Einheit: °.",
  "Kreisel-/Kompassmesstechnik.",
)

#begriffskarte(
  "Kursabweichung (relative Bearing)",
  "Winkel zwischen aktuellem Kurs und der Zielrichtung, zentriert typischerweise in [−180°, +180°].",
  "",
  "",
  "Symbol: Δ oder `bearingErrorDeg`; Einheit: °.",
  "Interne Systemdefinition gemäß Lastenheft /LF040/.",
)

#begriffskarte(
  "Ordinalrichtung (Himmelsrichtung)",
  "Vereinfachte 8er-Kompassangabe statt eines exakten Gradwerts.",
  "",
  "Wird aus dem Azimut abgeleitet und für eine leicht verständliche Richtungsanzeige genutzt.",
  "Werte: N, NE, E, SE, S, SW, W, NW.",
  "Kartographie; Anforderung /LF050/.",
)

#begriffskarte(
  "Geografische Koordinate",
  "Angabe eines Punktes auf der Erdoberfläche durch Breiten- und Längengrade.",
  "",
  "Gültig im WGS84-System.",
  "Notation: (lat, lon).",
  "ISO 19111",
)

#begriffskarte(
  "Großkreisentfernung",
  "Kürzeste Distanz zwischen zwei Ellipsoidpunkten entlang einer Großkreislinie auf der Kugelapproximation der Erde.",
  "",
  "Für kurze Distanzen < 20 km ist die sphärische Näherung üblicherweise ausreichend.",
  "Symbol: d oder `distanceM`; Einheit: m.",
  "Haversine-Formel als Referenznäherung.",
)

#begriffskarte(
  "Haversine-Formel",
  "Sphärische Formel zur Berechnung der Zentriwinkelspanne und daraus der Großkreisdistanz aus zwei Breiten-/Längengraden.",
  "",
  "Gültig für Kugelradius R.",
  "Implementationsreferenz: `greatCircleDistanceMeters(lat1,lon1,lat2,lon2)`.",
  "Wikipedia: Haversine-Formel",
)

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

=== Begriffe zu Datenformaten und Protokollen

#begriffskarte(
  "GPX (GPS Exchange Format)",
  "XML-basiertes Austauschformat für Wegpunkte, Routen und Tracks.",
  "",
  "Version 1.1 ist verbindlich für dieses Projekt.",
  "",
  "Topografix GPX 1.1 Schema",
)

#begriffskarte(
  "Trackpunkt",
  "XML-Element innerhalb eines GPX-Tracks, das mindestens Breite, Länge und Zeit trägt.",
  "",
  "Gültig innerhalb eines Tracks.",
  "Attribute: `lat`, `lon`.",
  "GPX 1.1 Spezifikation",
)

#begriffskarte(
  "HDOP (Horizontal Dilution of Precision)",
  "Dimensionsloses Maß für die geometrische Güte der Satellitenkonstellation; niedriger ist typischerweise besser.",
  "",
  "Optional im Datenmodell und in GPX; keine automatische Verwerfung beim Einlesen (/LF130/ Out-of-Scope).",
  "",
  "Herstellerdokumentation GNSS-Empfänger.",
)

#begriffskarte(
  "UTC und `Instant`",
  "UTC ist die einheitliche Zeitbasis ohne Sommerzeit; `java.time.Instant` beschreibt einen exakten Zeitpunkt auf dieser Skala.",
  "",
  "Interne Zeitstempel laufen durchgängig über `Instant`; Ausgabe nach GPX erfolgt als ISO-8601 in UTC.",
  "Im Code: `ClockPort.instant()` und `DateTimeFormatter.ISO_INSTANT`.",
  "ISO 8601; Java SE Date-Time-Package.",
)

#begriffskarte(
  "UTF-8",
  "Byte-Kodierung für Unicode-Zeichen; verbindlich für GPX-XML in diesem Projekt.",
  "",
  "Alle serialisierten GPX-Dokumente.",
  "Kennung in XML-Deklaration optional, Bytes konsistent.",
  "Unicode Standard Annex #15.",
)

=== Begriffe zu Session und Systemverhalten

#begriffskarte(
  "Session",
  "Eine Session ist eine zeitlich begrenzte Instanz zur Speicherung von Zustandsinformationen eines Benutzers oder Prozesses.",
  "Abzugrenzen ist die Session von einer einzelnen Anfrage sowie von persistenten Objekten, die dauerhaft gespeichert werden. Eine Session ist temporär und zustandsbehaftet.",
  "Die Gültigkeit einer Session erstreckt sich über die Dauer der Interaktion und endet durch Timeout.",
  "Session-ID",
  "Lehrmaterial Softwareentwicklung",
)

#begriffskarte(
  "Abbruchverhalten (Abort)",
  "Vorzeitiges Beenden einer aktiven Session durch den Host, ohne die bis dahin erfassten Daten zu verlieren.",
  "",
  "Session wechselt auf `ABORTED`; Rückgabe erfolgt als `GpxResult` (UTF-8-Bytes plus String-Zugriff) gemäß /LF070/ und /LF230/.",
  "Persistenz beim Abort erfolgt nur bei aktivem `persistOnAbort`.",
  "Klärungsgespräch; /LF070/",
)

#begriffskarte(
  "Observer / Listener",
  "Benachrichtigen registrierte Beobachter über Zustandsänderungen.",
  "",
  "Synchronität gemäß Konfiguration /LF080/.",
  "Java-Pattern: `java.util.EventListener`-Familie.",
  "/LF080/",
)

#begriffskarte(
  "Trackoptimierung",
  "Austauschbare Algorithmen hinter gemeinsamer Schnittstelle zur Reduktion oder Vereinfachung von Trackpunkten.",
  "",
  "Nur optional vor GPX-Export über `SessionConfig.addOptimizer` (leere Liste = unveränderter Rohtrack); /LF240/-/LF270/.",
  "",
  "/LF480/",
)

#begriffskarte(
  "Soft-Limit / Hard-Limit (Punktbudget)",
  "Zweistufige Begrenzung der gespeicherten Trackpunkte: erst Warnung, dann harter Stopp.",
  "",
  "Konfigurierbar über `softLimitPoints` und `hardLimitPoints`; `0` bedeutet deaktiviert (/LF120/, /LF180/).",
  "Code: `SOFT_LIMIT_WARN`, `HARD_LIMIT_REACHED`.",
  "Ressourcen-Schutz in eingebetteten Systemen; projektspezifisch.",
)

#begriffskarte(
  "Overflow-Modus (Punktbudget)",
  "Definiertes Verhalten bei Erreichen des Hard-Limits: Stopp der Aufzeichnung vs. Downsampling.",
  "",
  "Konfigurationsabhängig /LF180/.",
  "Enum-Kandidat: `STOP`, `DOWNSAMPLE` (Beispiel).",
  "Interne Spezifikation.",
)

=== Begriffe zu Entwurfsmustern und Architektur

#begriffskarte(
  "API (Application Programming Interface)",
  "Programmierschnittstelle, über die externe Systeme mit der Peilungskomponente interagieren.",
  "",
  "Öffentliche Methoden der Bibliothek.",
  "",
  "Software Engineering Standardbegriff",
)

#begriffskarte(
  "Builder (Konfigurationsaufbau)",
  "Muster, mit dem man eine Konfiguration Schritt für Schritt baut statt mit einem langen Konstruktor.",
  "",
  "Im Projekt über `SessionConfig.builder()`, beim Start werden die relevanten Parameter als `RecordingParameters` eingefroren (/LF410/).",
  "Beispiel: `SessionConfig.builder().segmentGapThreshold(java.time.Duration.ofMinutes(5)).build()`",
  "Design Patterns",
)

#begriffskarte(
  "Immutability",
  "Ein Objekt bleibt nach der Erzeugung unverändert; für Änderungen wird ein neues Objekt erstellt.",
  "",
  "Trifft hier u.\ a. auf `SessionConfig` und `GpsPoint` zu.",
  "Hilft bei Nebenläufigkeit, weil Leser keine veränderbaren Zwischenzustände sehen.",
  "Software Engineering Best Practices",
)

#begriffskarte(
  "Thread-Sicherheit",
  "Eigenschaft eines Systems, bei paralleler Ausführung durch mehrere Threads korrekt zu funktionieren.",
  "",
  "Relevant für Observer, Immutability und Eventverarbeitung.",
  "",
  "Nebenläufigkeit in Softwaresystemen",
)

#begriffskarte(
  "Semantische Exception",
  "Fehlerklasse mit maschinenlesbarem `errorCode` und kontextualisierter Message.",
  "",
  "Öffentliche API der Bibliothek.",
  "Feld: `String code`.",
  "/LF090/; Best Practice API Design.",
)

=== Begriffe zu Sicherheit

#begriffskarte(
  "Path Traversal",
  "Sicherheitsproblem, bei dem ein Pfad absichtlich aus dem erlaubten Zielordner ausbricht (z.\ B. mit `..`).",
  "",
  "Beim Export verpflichtend zu verhindern (/LF320/).",
  "Umsetzung in `SafeFileSink`: Pfad normalisieren und gegen erlaubtes Basisverzeichnis prüfen.",
  "OWASP Path Traversal",
)

#begriffskarte(
  "XXE (XML External Entity)",
  "Angriffsklasse beim XML-Parsing über externe Entities.",
  "",
  "Die Komponente erzeugt XML selbst und escaped Inhalte (/LL130/); das XXE-Risiko liegt vor allem bei fremden Parsern, die diese XML später lesen.",
  "Empfehlung: DTD/External-Entity-Verarbeitung im konsumierenden Parser deaktivieren.",
  "W3C XML Recommendation",
)

#begriffskarte(
  "Atomares Schreiben",
  "Datei wird zuerst temporär geschrieben und dann in den Zielpfad verschoben, um halbfertige Dateien zu vermeiden.",
  "",
  "Wichtig für die Konsistenz bei Exporten.",
  "Temporäre Datei (`*.tmp`).",
  "Anforderung /LF220/.",
)

=== Begriffe zu Algorithmen

#begriffskarte(
  "Douglas–Peucker-Algorithmus",
  "Algorithmus zur Linienvereinfachung: Punkte mit geringer Abweichung von der Verbindungslinie werden rekursiv entfernt.",
  "",
  "Im Projekt mit metrischer Toleranz in Metern und lokaler Tangentialebene als Näherung (/LF270/).",
  "Parameter im Code: `epsilonM`.",
  "D. Douglas, T. Peucker, Algorithms for the reduction of the number of points required to represent a digitized line or its caricature, 1973.",
)

#begriffskarte(
  "Kollinearitätsreduktion",
  "Reduktion fast kollinearer Punktfolgen auf Start- und Endpunkt innerhalb eines Winkel-/Seitenbandes.",
  "",
  "Explizit keine Garantie für enge Kurvenradien /LF260/.",
  "Heuristikparameter: Toleranzband.",
  "Klärungsgespräch Peter Bohl; /LF260/.",
)

=== Begriffe zu Methodik und Qualitätssicherung

#begriffskarte(
  "Anforderung",
  "Beschriebene Eigenschaft oder Fähigkeit, die ein System erfüllen muss oder soll.",
  "",
  "Gültig für alle /LF…/, /LL…/, /LD…/ Artefakte.",
  "Typen: funktional, nicht-funktional.",
  "ISO/IEC/IEEE 29148.",
)

#begriffskarte(
  "SOPHIST-Regeln",
  "Regelsatz, um Anforderungen klar, überprüfbar und ohne Widersprüche zu formulieren.",
  "",
  "Dient als Qualitätsmaßstab für die Formulierung der `/LF…/`, `/LL…/` und `/LD…/`-Artefakte.",
  "Wird in Reviews als kompakte Checkliste eingesetzt.",
  "Software Engineering Vorlesung, SOPHIST-Regeln",
)

#begriffskarte(
  "Lastenheft vs. Pflichtenheft",
  "Lastenheft: fachliche, wirtschaftliche und politische Zielsetzung aus Auftraggebersicht. Pflichtenheft: technische Umsetzungsvorgaben aus Entwicklersicht.",
  "",
  "In dieser Arbeit: Kapitel „Allgemeine Beschreibung\" ≈ Lastenheft-Teile; Kapitel „Spezifische Anforderungen\" ≈ Pflichtenheft.",
  "IEEE 830-1998",
  "Software Engineering Vorlesung",
)

#begriffskarte(
  "Traceability (Rückverfolgbarkeit)",
  "Nachvollziehbare Verbindung zwischen Anforderung, Design, Code und Test.",
  "",
  "Wichtig über den gesamten Lebenszyklus, besonders bei `/LF…/` und `/TC…/`.",
  "Im Projekt als Matrix in `implementation/TRACEABILITY.md`.",
  "Software Engineering Vorlesung",
)

#begriffskarte(
  "Property \"deterministisch\"",
  "Gleiche Eingaben und gleiche konfigurierte Abhängigkeiten (Clock) erzeugen identische Ausgaben.",
  "",
  "Gilt für Kern-Pfade ohne bewusst randomisierte Algorithmen.",
  "—",
  "/LL190/, /LF340/.",
)

=== Begriffe zu Werkzeugen und Frameworks

#begriffskarte(
  "JVM (Java Virtual Machine)",
  "Laufzeitumgebung, die Java-Bytecode plattformunabhängig ausführt; die Bibliothek setzt eine JVM voraus, stellt selbst jedoch keine bereit.",
  "",
  "Ziel-Kompatibilität: Java 17 LTS; die Bibliothek wird als reines Source-Artefakt ohne ausführbares JAR ausgeliefert.",
  "Die JVM-Version des Host-Projekts muss ≥ 17 sein; niedrigere Versionen werden nicht unterstützt.",
  "Systemvoraussetzungen; /LF000/",
)

#begriffskarte(
  "Maven",
  "Standardwerkzeug für Build, Testlauf und Abhängigkeitsverwaltung in Java-Projekten.",
  "",
  "Im Projekt zentraler Einstieg für Build und Tests (`mvn test`, /LF450/).",
  "Artefakte werden über `groupId:artifactId:version` aufgelöst.",
  "Apache Maven Project Dokumentation, Software Engineering Vorlesung",
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
  "SLF4J (Simple Logging Facade for Java)",
  "Einheitliche Logging-Schnittstelle, die konkrete Logger-Backends austauschbar macht.",
  "",
  "Die Komponente bindet Logging über den Adapter `Slf4jLoggerAdapter` ein (/LL140/).",
  "Typischer Einstieg: `LoggerFactory.getLogger(...)`.",
  "https://www.slf4j.org/",
)

#begriffskarte(
  "JUnit 5",
  "Modernes Java-Testframework für Unit- und Integrationsnahe Tests.",
  "",
  "In diesem Projekt Grundlage der Modul-Tests; aktuell vor allem mit `@Test`.",
  "Bietet u.\ a. Assertions, Lifecycle-Hooks und Erweiterungen.",
  "https://junit.org/junit5/",
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
  "Checkstyle",
  "Werkzeug für statische Stil- und Strukturprüfungen im Java-Code.",
  "",
  "Im Build integriert; die aktuelle Projektkonfiguration ist bewusst schlank gehalten.",
  "Konfiguration in `implementation/checkstyle.xml`.",
  "https://checkstyle.org/",
)

#begriffskarte(
  "ArchUnit",
  "Bibliothek zur Überprüfung architektonischer Regeln im JUnit-Test (z.\ B. keine AWT-Imports).",
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
  "Mutationstest (PIT)",
  "Testtechnik, bei der kleine Codeänderungen (Mutanten) erzeugt werden, um die Schärfe der Tests zu prüfen.",
  "",
  "Als Qualitätsvertiefung möglich, aber nicht Teil des Standard-Builds.",
  "Kennzahl: Mutations-Score.",
  "Software Engineering Vorlesung",
)

#begriffskarte(
  "Property-Based Testing (jqwik)",
  "Testansatz, bei dem allgemeine Eigenschaften statt einzelner Beispiele geprüft werden.",
  "",
  "Sinnvoll für Invarianten wie Distanzsymmetrie oder Grenzfälle bei Winkeln.",
  "Kann optional mit jqwik umgesetzt werden.",
  "https://jqwik.net/",
)

#begriffskarte(
  "Referenzimplementierung (Test)",
  "Unabhängige, minimal gehaltene Berechnung derselben Größe zum Abgleich von Toleranzen.",
  "",
  "Testcode, nicht Produktivpfad.",
  "`ReferenceHaversine` (Bezeichner frei wählbar).",
  "/LL020/ Testpraxis.",
)

#begriffskarte(
  "What3Words (W3W)",
  "Dienst, der Koordinaten in ein Drei-Wort-Format umwandelt.",
  "",
  "Optionaler Teil des Systems (/LF280/); Ergebnisse werden gecacht (/LF290/).",
  "",
  "what3words Limited, Peter Bohl",
)

#begriffskarte(
  "System (Softwarekomponente)",
  "Abgegrenzter Teil eines Softwaresystems mit klar definierten Schnittstellen und Verantwortlichkeiten.",
  "",
  "Hier: die Peilungskomponente als eigenständige Bibliothek.",
  "",
  "Softwarearchitektur-Grundlagen",
)

#begriffskarte(
  "Ist-/Soll-Vergleich (Referenz-App)",
  "Qualitative Gegenüberstellung der Referenz-App mit der Java-Bibliothek ohne pixelgenaue UI-Nachbildung.",
  "",
  "Dient der Motivation und Begriffsableitung, nicht als normative Spezifikation der UI.",
  "—",
  "Apple App Store, Produktseite Kompass Professional.",
)

#begriffskarte(
  "Genauigkeit",
  "Accuracy beschreibt die Nähe zum wahren Wert, Precision die Wiederholgenauigkeit von Messungen.",
  "",
  "Relevant für GPS-Datenbewertung.",
  "",
  "Messtechnik-Grundlagen",
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Überblick
// ─────────────────────────────────────────────────────────────────────────────

Dieses Dokument gliedert sich gemäß IEEE 830 in drei Hauptkapitel:

*Kapitel 1 Einleitung* definiert Zweck und Einsatzbereich der Bibliothek, normiert die Terminologie im Glossar und gibt den Überblick über die Dokumentstruktur.

*Kapitel 2 Allgemeine Beschreibung* stellt die Einbettung der Bibliothek in ihr System-Umfeld dar (Systemsicht, physische Sicht, externe Kommunikationspartner), benennt die Hauptfunktionen, formuliert systemweite Einschränkungen und listet Annahmen und Abhängigkeiten auf.


//änderungen
*(neu formulieren wenn kapittel 3 fertig ist) Kapitel 3 Spezifische Anforderungen* enthält die normativ bindenden Anforderungsartefakte: funktionale Anforderungen (`/LF…/`), nicht-funktionale Anforderungen (`/LL…/`), externe Schnittstellenbeschreibungen, Performance-Anforderungen sowie das vollständige Qualitätsmodell nach ISO/IEC 25010.


//optional? maybe entfernen
Der *Anhang* ergänzt das Dokument um Traceability-Matrizen, Review-Checklisten, Normreferenzen, erweiterte Use-Case-Beschreibungen sowie algorithmische Hinweise.

#pagebreak()
]
