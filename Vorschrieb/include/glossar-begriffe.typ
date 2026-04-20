#import "macros.typ": begriffskarte

#let glossar-begriffe-kapitel = [
#set par(justify: true)

*Hinweis:* Das Glossar normiert zentrale Fachbegriffe der Peilungskomponente. Jeder Eintrag folgt der Vorgabe _Begriff – Definition – Gültigkeit – Bezeichnung – Quellverweis_, um Prüfbarkeit und Zitationsfähigkeit zu gewährleisten.

#begriffskarte(
  "Peilung (Richtungspeilung)",
  "Bestimmung der horizontalen Zielrichtung von einem Bezugspunkt (Standort) zu einem Zielpunkt, typischerweise als geografischer Azimut relativ zu Nord; keine Turn-by-Turn-Navigation.",
  "Gültig für WGS84-Koordinaten auf der Erdoberfläche; magnetische Peilung ist nicht Bestandteil dieser Komponente, sofern nicht explizit ergänzt.",
  "Synonyme: Zielpeilung; UI: Richtungspfeil in Referenz-Apps.",
  "DIN 18716-1 (Orientierung im Gelände); vergleichende Systembeschreibung: Apple App Store, „Kompass Professional“.",
)

#begriffskarte(
  "Geografischer Azimut",
  "Horizontaler Winkel zwischen der geografischen Nordrichtung (WGS84-Nord) und der Großkreisrichtung zum Ziel, im Uhrzeigersinn von 0° bis unter 360°.",
  "Gültig für Entfernungen > 0 m; am Pol (Singularität) numerisch instabil – Domäne muss durch Mindestentfernung abgesichert werden.",
  "Symbol: α oder `azimuthDeg`; Einheit: ° (Grad).",
  "ISO 19111:2019 (Referenzsysteme); gängige Navigationsliteratur.",
)

#begriffskarte(
  "Kurs (Heading, True Heading)",
  "Orientierung der lokalen Horizontalebene relativ zu geografisch Nord, typischerweise als Winkel 0°–360° aus einer IMU/GNSS-Koppelung.",
  "Gültig, wenn der Host verlässliche Kursinformation liefert; ohne Kurs entfällt die Ableitung einer Kursabweichung.",
  "Symbol: ψ oder `headingDeg`; Einheit: °.",
  "RTCA DO-229 (GNSS); allgemein: Kreisel-/Kompassmesstechnik.",
)

#begriffskarte(
  "Kursabweichung (relative Bearing)",
  "Winkel zwischen aktuellem Kurs und der Zielrichtung, zentriert typischerweise in [−180°, +180°] zur Steuerung von „links/rechts“-Hinweisen.",
  "Nur definiert bei gleichzeitiger Verfügbarkeit von Azimut und Kurs.",
  "Symbol: Δ oder `bearingErrorDeg`; Einheit: °.",
  "Interne Systemdefinition gemäß Lastenheft /LF040/.",
)

#begriffskarte(
  "Großkreisentfernung (orthodrome Distanz)",
  "Kürzeste Distanz zwischen zwei Ellipsoidpunkten entlang einer Großkreislinie auf der Kugelapproximation der Erde.",
  "Gültig für WGS84-Lat/Lon; für kurze Distanzen (< 20 km) ist die sphärische Näherung üblicherweise ausreichend.",
  "Symbol: d oder `distanceM`; Einheit: m (SI).",
  "WGS84 (NIMA TR8350.2); Haversine-Formel als Referenznäherung.",
)

#begriffskarte(
  "Haversine-Formel",
  "Sphärische Formel zur Berechnung der Zentriwinkelspanne und daraus der Großkreisdistanz aus zwei Breiten-/Längengraden.",
  "Gültig für Kugelradius R (hier: mittlerer Erdradius); Ellipsoid-Höhen werden nicht vollständig modelliert.",
  "Implementationsreferenz: `greatCircleDistanceMeters(lat1,lon1,lat2,lon2)`.",
  "R. W. Sinnott, „Virtues of the Haversine“, Sky and Telescope, 1984 (häufig zitierte Herleitung).",
)

#begriffskarte(
  "WGS 84",
  "World Geodetic System 1984: standardisiertes Referenzellipsoid und Lagebezugssystem für GNSS.",
  "Gültig als alleiniges Koordinatensystem dieser Komponente; andere CRS sind außerhalb des Scopes.",
  "EPSG:4326 (Breite vor Länge in Notation und Serialisierung zu beachten).",
  "NIMA TR8350.2; ISO 19111.",
)

#begriffskarte(
  "GPX (GPS Exchange Format)",
  "XML-basiertes Austauschformat für Wegpunkte, Routen und Tracks.",
  "Version 1.1 ist verbindlich für dieses Projekt; ältere 1.0-Dateien sind nicht Ziel der Serialisierung.",
  "Namespace-URI: `http://www.topografix.com/GPX/1/1`.",
  "Topografix GPX 1.1 Schema; https://www.topografix.com/GPX/1/1",
)

#begriffskarte(
  "Trackpunkt (`trkpt`)",
  "XML-Element innerhalb eines GPX-Tracks, das mindestens Breite, Länge und Zeit trägt.",
  "Gültig innerhalb eines `trkseg`; Zeit in UTC nach ISO-8601.",
  "Attribute: `lat`, `lon`; Kinder u. a. `time`, `ele`, `hdop`, `speed`.",
  "GPX 1.1 Spezifikation (Topografix).",
)

#begriffskarte(
  "Sampling (Abtastung)",
  "Regel, nach der aus einem kontinuierlichen oder dichten Positionsstrom diskrete Speicherereignisse entstehen.",
  "Zeitintervall konfigurierbar gemäß /LF110/; Mindestintervall 0,5 s, Maximum 60 s.",
  "Parameter: `samplingIntervalMs`.",
  "Digitale Signalverarbeitung; projektspezifisch /LF100/–/LF110/.",
)

#begriffskarte(
  "HDOP (Horizontal Dilution of Precision)",
  "dimensionsloses Maß für die geometrische Güte der Satellitenkonstellation; niedriger ist typischerweise besser.",
  "Schwellwert standardmäßig ≤ 5,0 gemäß /LF130/; Werte außerhalb sind konfigurationsabhängig zu verwerfen oder zu markieren.",
  "Einheit: dimensionslos; Attribut in GPX: `hdop`.",
  "ICD-GPS-200; Herstellerdokumentation GNSS-Empfänger.",
)

#begriffskarte(
  "Session (Peilungssession)",
  "Lebenszyklusobjekt mit UUID, Zielkoordinate, Konfiguration und Zustand (ACTIVE, COMPLETED, ABORTED).",
  "Genau eine aktive Session pro Komponenteninstanz ohne explizite Finalisierung gemäß /LF020/.",
  "Datenobjekt /LD100/.",
  "Objektorientierte Analyse: Zustandsdiagramm im Pflichtenheft.",
)

#begriffskarte(
  "Observer / Listener",
  "Entwurfsmuster zur Entkopplung: Subjekte benachrichtigen registrierte Beobachter über Zustandsänderungen.",
  "Synchronität gemäß Konfiguration /LF080/; Standard: sequentieller Aufruf im Host-Thread.",
  "Java-Pattern: `java.util.EventListener`-Familie (konzeptionell).",
  "Gamma u. a., _Design Patterns_; /LF080/.",
)

#begriffskarte(
  "Strategy (Trackoptimierung)",
  "Austauschbare Algorithmen hinter gemeinsamer Schnittstelle zur Reduktion oder Vereinfachung von Trackpunkten.",
  "Gültig nach Session-Ende oder vor GPX-Serialisierung; Douglas–Peucker optional /LF270/.",
  "Schnittstelle: `TrackOptimizer` gemäß /LF480/.",
  "Gamma u. a., _Design Patterns_; /LF480/.",
)

#begriffskarte(
  "Builder (Konfigurationsaufbau)",
  "Erzeugungsmuster für schrittweise Konstruktion komplexer unveränderlicher Konfigurationsobjekte.",
  "Gültig vor Sessionstart; nach /LF410/ einfrieren.",
  "`SessionConfig.Builder` (konzeptionell).",
  "Gamma u. a., _Design Patterns_; Joshua Bloch, _Effective Java_ (Builder für Immutables).",
)

#begriffskarte(
  "Immutability (Unveränderlichkeit)",
  "Objektzustand nach Erzeugung nicht änderbar; Änderungen nur durch neues Objekt.",
  "Konfiguration und dominante Wertobjekte (z. B. `GpsPoint`) nach Erzeugung unveränderlich.",
  "Vorteil: Thread-Sicherheit der Datenübertragung zwischen Schichten.",
  "Joshua Bloch, _Effective Java_, Item 17.",
)

#begriffskarte(
  "What3Words (W3W)",
  "Geokodierungssystem, das Erdoberflächenpositionen durch drei Wörter adressiert.",
  "Nur optional; erfordert API-Key und Netzwerk /LF280/; Cache /LF290/.",
  "Rückgabe: drei Wörter, Sprache konfigurierbar.",
  "what3words Limited, öffentliche API-Dokumentation.",
)

#begriffskarte(
  "UTC und `Instant`",
  "UTC ist die einheitliche astronomische/kivilzeitbasis ohne Sommerzeit; `java.time.Instant` modelliert einen Zeitpunkt auf der UTC-Skala.",
  "Alle internen Zeitstempel in UTC; lokale Darstellung nur im Host.",
  "ISO-8601 in GPX `time`-Elementen.",
  "ISO 8601; Java SE Date-Time-Package.",
)

#begriffskarte(
  "Ordinalrichtung (Himmelsrichtung)",
  "Diskretisierte Kompassrose mit acht Sekundärhimmelsrichtungen.",
  "Gültig für alle Azimute; Grenzfälle an Oktantgrenzen per definierter Rundung.",
  "Werte: N, NE, E, SE, S, SW, W, NW.",
  "Kartographie; Anforderung /LF050/.",
)

#begriffskarte(
  "Path Traversal",
  "Angriffsform, bei der relative Pfadsegmente (`..`) unerlaubt außerhalb eines Zielverzeichnisses referenzieren.",
  "Muss unterbunden werden /LF320/ bei Dateiexport.",
  "Mitigation: Normalisierung, Canonicalisierung, Basispfad-Prüfung.",
  "OWASP Path Traversal; CWE-22.",
)

#begriffskarte(
  "XXE (XML External Entity)",
  "Klasse von XML-Verarbeitungsangriffen über externe Entities.",
  "Export generiert XML – Parser im Host sollten sicher konfiguriert sein; Bibliothek vermeidet externe Entities /LL130/.",
  "Deaktivierung von DTDs/Entities in konsumierenden Parsern.",
  "OWASP XML Security; W3C XML Recommendation.",
)

#begriffskarte(
  "Atomares Schreiben (write-rename)",
  "Schreiben in temporäre Datei mit anschließendem umbenanntem Commit an Zielpfad zur Vermeidung korrupt halbgeschriebener Dateien.",
  "Gültig auf POSIX und Windows NTFS (rename-overwrite semantik beachten).",
  "Pattern: `*.tmp` → `rename()`.",
  "POSIX.1-2008 `rename`; Anforderung /LF220/.",
)

#begriffskarte(
  "Soft-Limit / Hard-Limit (Punktbudget)",
  "Zwei Stufen der Punktmengenbegrenzung: Warnung vs. kontrollierter Stopp/Overflow-Modus.",
  "Konfigurierbar /LF120/, /LF180/; `0` deaktiviert Limit.",
  "Ereignisse: WARN vs. LIMIT_REACHED.",
  "Ressourcen-Schutz in eingebetteten Systemen (allgemein); projektspezifisch.",
)

#begriffskarte(
  "Douglas–Peucker-Algorithmus",
  "Linienvereinfachung durch rekursive Entfernung von Punkten unterhalb einer metrischen Toleranz ε.",
  "Gültig für planare oder projizierte Geometrie; auf Kugeloberfläche nur approximativ, in Kurven keine Garantie minimale Kurvenapproximation.",
  "Parameter: `epsilonMeters` /LF270/.",
  "D. Douglas, T. Peucker, _Algorithms for the reduction of the number of points required to represent a digitized line or its caricature_, 1973.",
)

#begriffskarte(
  "Kollinearitätsreduktion (Geraden-Heuristik)",
  "Reduktion fast kollinearer Punktfolgen auf Start- und Endpunkt innerhalb eines Winkel-/Seitenbandes.",
  "Explizit keine Garantie für enge Kurvenradien /LF260/.",
  "Heuristikparameter: Toleranzband.",
  "Klärungsgespräch Projektbetreuer; /LF260/.",
)

#begriffskarte(
  "SOPHIST-Regeln",
  "Qualitätskriterien für einzelne Anforderungen: eindeutig, vollständig, konsistent, überprüfbar, notwendig, realisierbar, wirksam, adressatengerecht, verständlich, mehrdeutigkeitsfrei, umsetzungsneutral.",
  "Gelten für die Formulierung sämtlicher `/LF…/`, `/LL…/`, `/LD…/`-Artefakte.",
  "Checkliste in Reviews und Selbstinspektion.",
  "SOPHIST GmbH, _Requirements Engineering nach SOPHIST_ (Lehrbuch).",
)

#begriffskarte(
  "Lastenheft vs. Pflichtenheft",
  "Lastenheft: fachliche, wirtschaftliche und politische Zielsetzung aus Auftraggebersicht. Pflichtenheft: technische Umsetzungsvorgaben aus Entwicklersicht.",
  "In dieser Arbeit: Kapitel „Anforderungsanalyse“ ≈ Lastenheft; Kapitel „Systemspezifikation“ ≈ Pflichtenheft.",
  "IEEE 830-1998 unterscheidet ähnliche Begriffe (SRS).",
  "IEEE Std 830-1998 (superseded, historisch); aktuell: ISO/IEC/IEEE 29148.",
)

#begriffskarte(
  "Traceability (Rückverfolgbarkeit)",
  "Nachweisbare Verknüpfung zwischen Anforderung, Entwurfselement, Code und Testfall.",
  "Über gesamten Lebenszyklus; besonders für `/LF…/` und `/TC…/`.",
  "Matrix: Anforderung × Modul × Test-ID.",
  "ISO/IEC/IEEE 29148:2018, Abschnitt zu traceability.",
)

#begriffskarte(
  "SLF4J (Simple Logging Facade for Java)",
  "Fassaden-API für Logging-Frameworks (Logback, Log4j2).",
  "Bibliothek loggt nur über SLF4J-Schnittstelle /LL140/.",
  "Logger-Factory: `LoggerFactory.getLogger(...)`.",
  "https://www.slf4j.org/",
)

#begriffskarte(
  "JUnit 5",
  "Testframework für Java mit Extension Model, parametrierten Tests und Assertions.",
  "Alle modularen Unit-Tests; ArchUnit optional für Architekturregeln.",
  "Annotationen: `@Test`, `@ParameterizedTest`, …",
  "https://junit.org/junit5/",
)

#begriffskarte(
  "Mutationstest (PIT)",
  "Verfahren, das Mutanten des Produktcodes erzeugt und prüft, ob Tests diese töten.",
  "Optional für `/LL010/` Nachweis; nicht Pflicht des Minimal-Builds.",
  "Metrik: Mutations-Score.",
  "PITest Dokumentation; akademisch: DeMillo et al., Mutation Testing.",
)

#begriffskarte(
  "Property-Based Testing (jqwik)",
  "Testen gegen universelle Eigenschaften statt Einzelbeispiele.",
  "Einsatz für Koordinateninvarianten (Symmetrie Distanz, Grenzen Azimut).",
  "Framework: jqwik (optional).",
  "Claessen & Hughes, _QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs_, ICFP 2000.",
)

#begriffskarte(
  "Checkstyle",
  "Statisches Analysewerkzeug für Kodierungsstandards inkl. Javadoc-Pflicht.",
  "Build-Integration gemäß /LL100/.",
  "Konfiguration via `checkstyle.xml`.",
  "https://checkstyle.org/",
)

#begriffskarte(
  "Maven",
  "Build- und Abhängigkeitsmanagement für Java-Projekte.",
  "Standardkommando: `mvn test` /LF450/.",
  "Artefakt-Koordinaten: `groupId:artifactId:version`.",
  "Apache Maven Project Dokumentation.",
)

#begriffskarte(
  "ISO/IEC 25010",
  "System- und Softwareproduktqualitätsmodell mit acht Hauptmerkmalen und Untermerkmalen.",
  "Dient der Gewichtung in der Qualitätsmatrix dieses Dokuments.",
  "Merkmale u. a.: Funktionalität, Zuverlässigkeit, Performance, Sicherheit, Wartbarkeit, Portabilität.",
  "ISO/IEC 25010:2011 (aktualisierte Fassungen beachten).",
)

#begriffskarte(
  "FMEA (Fehlermöglichkeits- und Einflussanalyse)",
  "Systematische Risikoanalyse: Fehlerart, Folge, Auftretenswahrscheinlichkeit, Entdeckung, Maßnahmen.",
  "Angewandt auf Datenpfade GPS → Track → GPX.",
  "Bewertung in RPZ oder qualitativ.",
  "AIAG/VDA FMEA Handbuch (Industrie); Lehradaptation im QS-Kapitel.",
)

#begriffskarte(
  "Abbruchverhalten (Abort)",
  "Beendigung der Session durch Host vor regulärem Abschluss bei Beibehaltung der bisherigen Trackdaten.",
  "Status ABORTED; GPX als String/Bytes verfügbar /LF070/, /LF230/; Dateischreiben nur wenn konfiguriert.",
  "Kein stiller Datenverlust.",
  "Klärungsgespräch; /LF070/.",
)

#begriffskarte(
  "Deklination (magnetische Missweisung)",
  "Winkel zwischen magnetischem und geografischem Nord – hier nicht automatisiert, da magnetische Peilung außerhalb des Kernumfangs liegt.",
  "Wenn Host magnetische Nord verwendet, muss er die Deklination selbst modellieren.",
  "Symbol: δ; regional variabel.",
  "IAGA World Magnetic Model (WMM) – externe Quelle.",
)
]
