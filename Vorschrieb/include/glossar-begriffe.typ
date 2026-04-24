#import "macros.typ": begriffskarte

#let glossar-begriffe-kapitel = [
#set par(justify: true)

#begriffskarte(
  "Benutzer",
  "Person oder System, das die Peilungskomponente verwendet oder mit ihr interagiert",
  "",
  "Gültig für alle Interaktionen mit der öffentlichen API",
  "Synonym: Nutzer",
  "Allgemeine Softwaretechnik",
)

#begriffskarte(
  "Anforderung",
  "Beschriebene Eigenschaft oder Fähigkeit, die ein System erfüllen muss oder soll",
  "",
  "Gültig für alle /LF…/, /LL…/, /LD…/ Artefakte",
  "Typen: funktional, nicht-funktional",
  "ISO/IEC/IEEE 29148.",
)

#begriffskarte(
  "System (Softwarekomponente)",
  "Abgegrenzter Teil eines Softwaresystems mit klar definierten Schnittstellen und Verantwortlichkeiten",
  "",
  "Hier: die Peilungskomponente als eigenständige Bibliothek",
  "",
  "Softwarearchitektur-Grundlagen",
)

#begriffskarte(
  "Geografische Koordinate",
  "Angabe eines Punktes auf der Erdoberfläche durch Breiten- und Längengrade",
  "",
  "Gültig im WGS84-System",
  "Notation: (lat, lon).",
  "ISO 19111",
)

#begriffskarte(
  "API (Application Programming Interface)",
  "Programmierschnittstelle, über die externe Systeme mit der Peilungskomponente interagieren",
  "",
  "Öffentliche Methoden der Bibliothek",
  "",
  "Software Engineering Standardbegriff",
)

#begriffskarte(
  "Thread-Sicherheit",
  "Eigenschaft eines Systems, bei paralleler Ausführung durch mehrere Threads korrekt zu funktionieren",
  "",
  "Relevant für Observer, Immutability und Eventverarbeitung",
  "",
  "Nebenläufigkeit in Softwaresystemen",
)

#begriffskarte(
  "Genauigkeit",
  "Accuracy beschreibt die Nähe zum wahren Wert, Precision die Wiederholgenauigkeit von Messungen",
  "",
  "Relevant für GPS-Datenbewertung ",
  "",
  "Messtechnik-Grundlagen",
)

#begriffskarte(
  "Peilung (Bearing)",
  "Bestimmung der horizontalen Zielrichtung von einem Bezugspunkt zu einem Zielpunkt.", 
  "Keine Turn-by-Turn-Navigation" ,
  "Gültig für WGS84-Koordinaten auf der Erdoberfläche",
  "",
  "Peter Bohl",
)

#begriffskarte(
  "Geografischer Azimut",
  "Horizontaler Winkel zwischen der geografischen Nordrichtung und der Großkreisrichtung zum Ziel",
  "" ,
  "Gültig für Entfernungen > 0 m",
  "Symbol: α oder `azimuthDeg`; Einheit: ° (Grad).",
  "Gängige Navigationsliteratur.",
)

#begriffskarte(
  "Kurs (Heading)",
  "Orientierung der lokalen Horizontalebene relativ zu geografisch Nord, typischerweise als Winkel 0°–360°",
  "" ,
  "Gültig, wenn der Host verlässliche Kursinformation liefert",
  "Symbol: ψ oder `headingDeg`; Einheit: °.",
  "Kreisel-/Kompassmesstechnik.",
)

#begriffskarte(
  "Kursabweichung (relative Bearing)",
  "Winkel zwischen aktuellem Kurs und der Zielrichtung, zentriert typischerweise in [−180°, +180°]", 
  "" ,
  "",
  "Symbol: Δ oder `bearingErrorDeg`; Einheit: °.",
  "Interne Systemdefinition gemäß Lastenheft /LF040/.",
)

#begriffskarte(
  "Großkreisentfernung",
  "Kürzeste Distanz zwischen zwei Ellipsoidpunkten entlang einer Großkreislinie auf der Kugelapproximation der Erde", 
  "" ,
  "für kurze Distanzen < 20 km ist die sphärische Näherung üblicherweise ausreichend",
  "Symbol: d oder `distanceM`; Einheit: m",
  "Haversine-Formel als Referenznäherung.",
)

#begriffskarte(
  "Haversine-Formel",
  "Sphärische Formel zur Berechnung der Zentriwinkelspanne und daraus der Großkreisdistanz aus zwei Breiten-/Längengraden.","" ,
  "Gültig für Kugelradius R",
  "Implementationsreferenz: `greatCircleDistanceMeters(lat1,lon1,lat2,lon2)`.",
  "Wikipedia: Haversine-Formel",
)

#begriffskarte(
  "GPX (GPS Exchange Format)",
  "XML-basiertes Austauschformat für Wegpunkte, Routen und Tracks.", 
  "" ,
  "Version 1.1 ist verbindlich für dieses Projekt",
  "",
  "Topografix GPX 1.1 Schema",
)

#begriffskarte(
  "Trackpunkt",
  "XML-Element innerhalb eines GPX-Tracks, das mindestens Breite, Länge und Zeit trägt", 
  "" ,
  "Gültig innerhalb eines Tracks",
  "Attribute: `lat`, `lon`",
  "GPX 1.1 Spezifikation",
)



#begriffskarte(
  "HDOP (Horizontal Dilution of Precision)",
  "dimensionsloses Maß für die geometrische Güte der Satellitenkonstellation; niedriger ist typischerweise besser","" ,
  "Optional im Datenmodell und in GPX; keine automatische Verwerfung beim Einlesen (/LF130/ Out-of-Scope).",
  "",
  "Herstellerdokumentation GNSS-Empfänger.",
)

#begriffskarte(
  "Session",
  "Eine Session ist eine zeitlich begrenzte Instanz zur Speicherung von Zustandsinformationen eines Benutzers oder Prozesses",
  "Abzugrenzen ist die Session von einer einzelnen Anfrage, die nur einen einmaligen Zugriff beschreibt, sowie von persistenten Objekten, die dauerhaft gespeichert werden. Eine Session ist temporär und zustandsbehaftet.",
  "Die Gültigkeit einer Session erstreckt sich über die Dauer der Interaktion und endet durch Timeout",
  "Session-ID ",
  "Lehrmaterial Softwareentwicklung"
)

#begriffskarte(
  "Observer / Listener",
  "Benachrichtigen registrierte Beobachter über Zustandsänderungen",
  "" ,
  "Synchronität gemäß Konfiguration /LF080/;",
  "Java-Pattern: `java.util.EventListener`-Familie ",
  "/LF080/",
)

#begriffskarte(
  "Trackoptimierung",
  "Austauschbare Algorithmen hinter gemeinsamer Schnittstelle zur Reduktion oder Vereinfachung von Trackpunkten",
  "" ,
  "Nur optional vor GPX-Export über `SessionConfig.addOptimizer` (leere Liste = unveränderter Rohtrack); /LF240/-/LF270/.",
  "",
  "/LF480/",
)

//bis hier 

#begriffskarte(
  "Builder (Konfigurationsaufbau)",
  "Muster, mit dem man eine Konfiguration Schritt für Schritt baut statt mit einem langen Konstruktor.","" ,
  "Im Projekt über `SessionConfig.builder()`, beim Start werden die relevanten Parameter als `RecordingParameters` eingefroren (/LF410/).",
  "Beispiel: `SessionConfig.builder().segmentGapThreshold(java.time.Duration.ofMinutes(5)).build()`",
  "Design Patterns",
)

#begriffskarte(
  "Immutability",
  "Ein Objekt bleibt nach der Erzeugung unverändert, für Änderungen wird ein neues Objekt erstellt","" ,
  "Trifft hier u. a. auf `SessionConfig` und `GpsPoint` zu.",
  "Hilft bei Nebenläufigkeit, weil Leser keine veränderbaren Zwischenzustände sehen",
  "Software Engineering Best Practices",
)

#begriffskarte(
  "What3Words (W3W)",
  "Dienst, der Koordinaten in ein Drei-Wort-Format umwandelt","" ,
  "Optionaler Teil des Systems (/LF280/), Ergebnisse werden gecacht (/LF290/).",
  "",
  "what3words Limited, Peter Bohl",
)

#begriffskarte(
  "UTC und `Instant`",
  "UTC ist die einheitliche Zeitbasis ohne Sommerzeit; `java.time.Instant` beschreibt einen exakten Zeitpunkt auf dieser Skala","" ,
  "Interne Zeitstempel laufen durchgängig über `Instant`; Ausgabe nach GPX erfolgt als ISO-8601 in UTC.",
  "Im Code: `ClockPort.instant()` und `DateTimeFormatter.ISO_INSTANT`.",
  "ISO 8601; Java SE Date-Time-Package.",
)

#begriffskarte(
  "Ordinalrichtung (Himmelsrichtung)",
  "Vereinfachte 8er-Kompassangabe statt eines exakten Gradwerts.","" ,
  "Wird aus dem Azimut abgeleitet und für eine leicht verständliche Richtungsanzeige genutzt.",
  "Werte: N, NE, E, SE, S, SW, W, NW.",
  "Kartographie; Anforderung /LF050/.",
)

#begriffskarte(
  "Path Traversal",
  "Sicherheitsproblem, bei dem ein Pfad absichtlich aus dem erlaubten Zielordner ausbricht (z. B. mit `..`).","" ,
  "Beim Export verpflichtend zu verhindern (/LF320/).",
  "Umsetzung in `SafeFileSink`: Pfad normalisieren und gegen erlaubtes Basisverzeichnis prüfen.",
  "OWASP Path Traversal",
)

#begriffskarte(
  "XXE (XML External Entity)",
  "Angriffsklasse beim XML-Parsing über externe Entities", "" ,
  "Die Komponente erzeugt XML selbst und escaped Inhalte (/LL130/); das XXE-Risiko liegt vor allem bei fremden Parsern, die diese XML später lesen",
  "Empfehlung: DTD/External-Entity-Verarbeitung im konsumierenden Parser deaktivieren",
  "W3C XML Recommendation",
)

#begriffskarte(
  "Atomares Schreiben",
  "Datei wird zuerst temporär geschrieben und dann in den Zielpfad verschoben, um halbfertige Dateien zu vermeiden","" ,
  "Wichtig für die Konsistenz bei Exporten",
  "temporäre Datei (`*.tmp`)",
  "Anforderung /LF220/.",
)

#begriffskarte(
  "Soft-Limit / Hard-Limit (Punktbudget)",
  "Zweistufige Begrenzung der gespeicherten Trackpunkte: erst Warnung, dann harter Stopp.","" ,
  "Konfigurierbar über `softLimitPoints` und `hardLimitPoints`; `0` bedeutet deaktiviert (/LF120/, /LF180/).",
  "Code: `SOFT_LIMIT_WARN`, `HARD_LIMIT_REACHED`",
  "Ressourcen-Schutz in eingebetteten Systemen; projektspezifisch.",
)

#begriffskarte(
  "Douglas–Peucker-Algorithmus",
  "Algorithmus zur Linienvereinfachung: Punkte mit geringer Abweichung von der Verbindungslinie werden rekursiv entfernt.","" ,
  "Im Projekt mit metrischer Toleranz in Metern und lokaler Tangentialebene als Näherung (/LF270/).",
  "Parameter im Code: `epsilonM`.",
  "D. Douglas, T. Peucker, Algorithms for the reduction of the number of points required to represent a digitized line or its caricature76, 1973.",
)

#begriffskarte(
  "Kollinearitätsreduktion",
  "Reduktion fast kollinearer Punktfolgen auf Start- und Endpunkt innerhalb eines Winkel-/Seitenbandes.","" ,
  "Explizit keine Garantie für enge Kurvenradien /LF260/.",
  "Heuristikparameter: Toleranzband.",
  "Klärungsgespräch Peter Bohl; /LF260/.",
)

#begriffskarte(
  "SOPHIST-Regeln",
  "Regelsatz, um Anforderungen klar, überprüfbar und ohne Widersprüche zu formulieren.", "" ,
  "Dient als Qualitätsmaßstab für die Formulierung der `/LF…/`, `/LL…/` und `/LD…/`-Artefakte.",
  "Wird in Reviews als kompakte Checkliste eingesetzt.",
  "Software Engineering Vorlesung, SOPHIST-Regeln",
)

#begriffskarte(
  "Lastenheft vs. Pflichtenheft",
  "Lastenheft: fachliche, wirtschaftliche und politische Zielsetzung aus Auftraggebersicht. Pflichtenheft: technische Umsetzungsvorgaben aus Entwicklersicht","" ,
  "In dieser Arbeit: Kapitel „Anforderungsanalyse“ ≈ Lastenheft; Kapitel „Systemspezifikation“ ≈ Pflichtenheft.",
  "IEEE 830-1998",
  "Software Engineering Vorlesung",
)

#begriffskarte(
  "Traceability (Rückverfolgbarkeit)",
  "Nachvollziehbare Verbindung zwischen Anforderung, Design, Code und Test.","" ,
  "Wichtig über den gesamten Lebenszyklus, besonders bei `/LF…/` und `/TC…/`.",
  "Im Projekt als Matrix in `implementation/TRACEABILITY.md`.",
  "Software Engineering Vorlesung",
)

#begriffskarte(
  "SLF4J (Simple Logging Facade for Java)",
  "Einheitliche Logging-Schnittstelle, die konkrete Logger-Backends austauschbar macht.","" ,
  "Die Komponente bindet Logging über den Adapter `Slf4jLoggerAdapter` ein (/LL140/).",
  "Typischer Einstieg: `LoggerFactory.getLogger(...)`.",
  "https://www.slf4j.org/",
)

#begriffskarte(
  "JUnit 5",
  "Modernes Java-Testframework für Unit- und Integrationsnahe Tests.","" ,
  "In diesem Projekt Grundlage der Modul-Tests; aktuell vor allem mit `@Test`.",
  "Bietet u. a. Assertions, Lifecycle-Hooks und Erweiterungen.",
  "https://junit.org/junit5/",
)

#begriffskarte(
  "Mutationstest (PIT)",
  "Testtechnik, bei der kleine Codeänderungen (Mutanten) erzeugt werden, um die Schärfe der Tests zu prüfen.","" ,
  "Als Qualitätsvertiefung möglich, aber nicht Teil des Standard-Builds.",
  "Kennzahl: Mutations-Score.",
  "Software Engineering Vorlesung",
)

#begriffskarte(
  "Property-Based Testing (jqwik)",
  "Testansatz, bei dem allgemeine Eigenschaften statt einzelner Beispiele geprüft werden.","" ,
  "Sinnvoll für Invarianten wie Distanzsymmetrie oder Grenzfälle bei Winkeln.",
  "Kann optional mit jqwik umgesetzt werden.",
  "https://jqwik.net/",
)

#begriffskarte(
  "Checkstyle",
  "Werkzeug für statische Stil- und Strukturprüfungen im Java-Code.","" ,
  "Im Build integriert; die aktuelle Projektkonfiguration ist bewusst schlank gehalten.",
  "Konfiguration in `implementation/checkstyle.xml`.",
  "https://checkstyle.org/",
)

#begriffskarte(
  "Maven",
  "Standardwerkzeug für Build, Testlauf und Abhängigkeitsverwaltung in Java-Projekten.","" ,
  "Im Projekt zentraler Einstieg für Build und Tests (`mvn test`, /LF450/).",
  "Artefakte werden über `groupId:artifactId:version` aufgelöst.",
  "Apache Maven Project Dokumentation, Software Engineering Vorlesung",
)



#begriffskarte(
  "Abbruchverhalten (Abort)",
  "Vorzeitiges Beenden einer aktiven Session durch den Host, ohne die bis dahin erfassten Daten zu verlieren","" ,
  "Session wechselt auf `ABORTED`; Rückgabe erfolgt als `GpxResult` (UTF-8-Bytes plus String-Zugriff) gemäß /LF070/ und /LF230/",
  "Persistenz beim Abort erfolgt nur bei aktivem `persistOnAbort`",
  "Klärungsgespräch; /LF070/",
)

#begriffskarte(
  "JVM (Java Virtual Machine)",
  "Laufzeitumgebung, die Java-Bytecode plattformunabhängig ausführt; die Bibliothek setzt eine JVM voraus, stellt selbst jedoch keine bereit",
  "",
  "Ziel-Kompatibilität: Java 17 LTS; die Bibliothek wird als reines Source-Artefakt ohne ausführbares JAR ausgeliefert",
  "Die JVM-Version des Host-Projekts muss ≥ 17 sein; niedrigere Versionen werden nicht unterstützt",
  "Systemvoraussetzungen; /LF000/",
)

]
