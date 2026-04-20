#let titel = "Titel"
#let autor = "Name"
#let kurzthema = "Thema"

#let abgabedatum = datetime(
  year: 2000,
  month: 01,
  day: 01,
)

#set document(title: titel, author: autor, date: abgabedatum)
#set page(
  paper: "a4",
  number-align: right + bottom,
  margin: (inside: 2.5cm, outside: 2.5cm, y: 2cm)
)
#set text(
  size: 14pt,
  lang: "de"
)

#import "include/templates.typ": deckblatt


////////////////////////////////
// DECKBLATT
////////////////////////////////

#show: deckblatt.with(
  thema: "Thema",
  titel: titel,
  studiengang: "Informatik",
  standort: "Stuttgart",
  autoren: (
    (
      name: autor,
    ),
  ),
  abgabedatum: abgabedatum,
  bearbeitungszeitraum: "01.01.2000 - 01.01.2000",
  martikelnummer: "martikel",
)
////////////////////////////////

// Kopfzeile
#counter(page).update(1)
#set page(
  numbering: "i",
  header: rect(
    height: 100%,
    inset: 0mm,
    stroke: none,
    // fill: red,
  )[
    #set align(top)
    #set text(11pt)
    #grid(
      // fill: blue,
      columns: (auto, 1fr, auto),
      rows: (4cm),
      align: horizon,
      image("include\images\DHBW_Logo.png", height: 1cm),
      h(1fr),
      // text(titel + " " + autor + "\ndfs"),
      box([
        #set align(right)
        #titel #autor \
        #kurzthema
      ])
    )
  ],
)

#show heading: set text(rgb("#d90000"))
#show heading: set block(below: 1em)
// #show heading: set block(below: 2em)

////////////////////////////////
// FRONTMATTER (Abstract)
////////////////////////////////
= Abstract
#pagebreak()


////////////////////////////////
// INHALTS-VERZEICHNIS
////////////////////////////////
#linebreak()
#outline(title: "Inhaltsverzeichnis")
#pagebreak()
////////////////////////////////

////////////////////////////////
// ABBILDUNGS- & TABELLENVERZEICHNIS
////////////////////////////////
#linebreak()

#show cite: it => [#it]

#show outline.where(target: figure.where(kind: image)): it => {
  show outline.entry: it => {
    show cite: it => { }
    it
  }
  it
}

= Abbildungsverzeichnis
#outline(target: figure.where(kind: image), title: "")
#pagebreak()

= Tabellenverzeichnis
#outline(target: figure.where(kind: table), title: "")
#pagebreak()
////////////////////////////////

////////////////////////////////
// GLOSSAR
////////////////////////////////
= Glossar
#pagebreak()
////////////////////////////////

#set heading(numbering: "1.1.1 - ")
#set par(spacing: 2em, justify: true)

#set page(numbering: "1")
#counter(page).update(1)


#show math.equation: set align(center)


////////////////////////////////
// BEGINN
////////////////////////////////

= Einleitung
== Problemstellung
Die bestehende iOS-Applikation „Kompass (Pro)“ verfügt über umfangreiche Peilungs- und Navigationsfunktionen, die historisch bedingt stark mit der grafischen Benutzeroberfläche (UI) gekoppelt sind. Im Rahmen dieser Projektarbeit besteht die Herausforderung darin, die Kernfunktionalität der Peilung aus dieser monolithischen Struktur herauszulösen und in eine strikt systemneutrale, UI-lose Java-Komponente zu überführen. Darüber hinaus fehlt der ursprünglichen Applikation bislang eine effiziente Möglichkeit, die während der Peilung zurückgelegte Strecke ressourcenschonend aufzuzeichnen und als GPX-Datei bereitzustellen.

== Zielsetzung
Ziel ist die Entwicklung einer eigenständigen, schnittstellenbasierten Java-Komponente, welche die Peilungsfunktionalität kapselt. Die Komponente darf keinerlei Abhängigkeiten zu UI-Frameworks aufweisen, sondern kommuniziert ausschließlich über definierte API-Endpunkte. Kernziele umfassen die systemneutrale Peilungslogik (inkl. What3Words-Integration), das intelligente GPS-Tracking (mit algorithmischer Datenreduktion für Geraden) und den standardisierten GPX-Export.

== Abgrenzung und Scope
**In Scope:**
- Systemanalyse, objektorientiertes Design und Implementierung in reinem Java.
- Algorithmus zur Wegpunkt-Optimierung (z.B. Reduktion von Geraden auf Start- und Endpunkt).
- Abfangen und Ignorieren von ungenauen oder ungültigen GPS-Signalen.
- Bereitstellung von Modultests (Unit-Tests).

**Out of Scope:**
- Entwicklung einer grafischen Benutzeroberfläche (UI).
- Das in der Ursprungs-App geforderte „Telematik-Dashboard“ für Motorradfahrer.
- Turn-by-Turn Routenberechnung über Straßennetzwerke (Navigation).

== Stakeholder-Analyse
- **Auftraggeber (Dozent):** Legt höchsten Wert auf formale Korrektheit (SOPHIST), den Einsatz von Software-Engineering-Methoden (OOA, Entwurfsmuster), Lauffähigkeit des Source-Codes und hohe Testabdeckung.
- **Entwicklerteam:** Verantwortlich für die methodisch saubere Spezifikation und fehlerfreie Implementierung.
- **Integrierende Systeme:** Zukünftige Applikationsentwickler, die diese Bibliothek als Backend für Tracking-Apps einbinden wollen.

#pagebreak()
= Anforderungsanalyse (Business Requirements / Lastenheft)
== Zielbestimmung und Produkteinsatz
Die Java-Komponente wird als universelles Backend-Modul für standortbasierte Dienste konzipiert. Der Einsatzbereich fokussiert sich auf Outdoor-Aktivitäten, bei denen eine reine Richtungsweisung (Peilung) in Kombination mit einer performanten, speicherschonenden Pfadaufzeichnung essenziell ist.

== Funktionale Anforderungen
#table(
  columns: (15%, 85%),
  align: (left, left),
  stroke: 0.5pt,
  [*ID*], [*Spezifikation (SOPHIST)*],
  [/LF010/], [*Funktion:* Empfang von Echtzeit-Positionsdaten \ *Beschreibung:* Das System MUSS dem aufrufenden System die Möglichkeit bieten, kontinuierlich Positionsdaten an die Komponente zu übergeben.],
  [/LF020/], [*Funktion:* Validierung der Positionsdaten \ *Beschreibung:* Das System MUSS empfangene Positionsdaten, deren Genauigkeitswert eine konfigurierte Toleranz überschreitet, selbstständig ignorieren.],
  [/LF030/], [*Funktion:* Start der Peilungsfunktion \ *Beschreibung:* Das System MUSS die Berechnung der Peilung (Azimut und Distanz) starten können, sobald ein Zielort übergeben wurde.],
  [/LF040/], [*Funktion:* Zielortbestimmung via W3W \ *Beschreibung:* Das System MUSS dem aufrufenden System die Möglichkeit bieten, den Zielort in Form einer What3Words-Adresse zu übergeben.],
  [/LF050/], [*Funktion:* Konfiguration der Aufzeichnungs-Limits \ *Beschreibung:* Das System MUSS dem aufrufenden System die Möglichkeit bieten, das Zeitintervall und die Maximalmenge der Datenpunkte einzustellen.],
  [/LF060/], [*Funktion:* Algorithmische Datenreduktion \ *Beschreibung:* Das System MUSS die aufgenommenen Wegpunkte derart optimieren, dass auf einer geraden Strecke lediglich Start- und Endpunkt gespeichert werden.],
  [/LF070/], [*Funktion:* GPX-Datenexport \ *Beschreibung:* Das System MUSS die optimierten Wegpunkte auf Anfrage als GPX 1.1 Standard-Zeichenkette zurückgeben.],
  [/LF080/], [*Funktion:* Datensicherung bei Abbruch \ *Beschreibung:* Das System MUSS im Falle eines Abbruchs gewährleisten, dass alle bis dato verarbeiteten Wegpunkte als GPX-Datensatz abrufbar bleiben.]
)

== Produktdaten
- **/LD010/ Wegpunkt-Datensatz:** Kapselt geographische Rohdaten (Latitude, Longitude, Elevation, Timestamp, Accuracy, Speed).
- **/LD020/ Konfigurationsparameter:** Speicher für Toleranzwerte der Geradenerkennung und Intervall-Limits.

== Nichtfunktionale Anforderungen
=== Leistungs- und Performanceanforderungen
- **/LL010/ Systemneutralität:** Die Komponente MUSS vollständig entkoppelt von jeglichen GUI-Bibliotheken programmiert sein.
- **/LL020/ Ausführbarkeit:** Der Sourcecode MUSS ohne Build-Tools (wie Maven/Gradle) direkt kompilierbar sein.

=== Externe Schnittstellen
- **/LS010/ W3W-API:** Kommunikation über HTTPS mit der What3Words REST-API.
- **/LS020/ Java-API:** Bereitstellung öffentlicher Interfaces für das integrierende System.

== Qualitätsanforderungen
- **/LQ010/ Erweiterbarkeit:** Die Architektur MUSS den Einsatz neuer Datenreduktions-Algorithmen ohne Änderung der Kernlogik zulassen.
- **/LQ020/ Robustheit:** Ungültige API-Keys für W3W dürfen keinen Systemabsturz provozieren, sondern lediglich W3W-Peilungen ablehnen.

#pagebreak()
= Systemspezifikation (System Requirements / Pflichtenheft)
== Einleitung und allgemeine Beschreibung
Während das Lastenheft das "Was" definiert, spezifiziert das Pflichtenheft das "Wie" der technischen Umsetzung. Die fachlichen Anforderungen werden hier in objektorientierte Modelle und Systemschnittstellen übersetzt.

== Funktionale Spezifikation
=== Use Cases
1. **UC01: Konfiguration:** Das UI übergibt Initialisierungsparameter (Intervall, Max-Punkte, Toleranz).
2. **UC02: Peilung starten:** Übergabe einer Koordinate/W3W-Adresse. System wechselt auf `ACTIVE`.
3. **UC03: Tracken:** UI injiziert GPS-Punkte. System filtert, berechnet neue Peilung und führt die Datenreduktion *on-the-fly* aus.
4. **UC04: GPX Export:** UI sendet Abbruch-Signal. System parst die Wegpunkte in eine XML/GPX-Struktur.

=== Einzelanforderungen
- **/SR10/ (Basis: LF020):** Die Klasse `GpsFilter` verwirft `GpsData`-Objekte, wenn `accuracy > config.maxAccuracy`.
- **/SR20/ (Basis: LF030):** Implementierung der Haversine-Formel zur Distanzberechnung auf der Sphäre.
- **/SR30/ (Basis: LF060):** Implementierung eines `PathOptimizer` mittels *Strategy-Pattern* für austauschbare Reduktionsalgorithmen (z.B. Douglas-Peucker vs. Winkel-Prüfung).

== Datenspezifikation
=== Data Dictionary
#table(
  columns: (25%, 75%),
  align: (left, left),
  stroke: 0.5pt,
  [*Klasse / Interface*], [*Bedeutung / Struktur*],
  [`Coordinate`], [Kapselt `lat` (-90 bis 90) und `lon` (-180 bis 180). Wirft Exception bei Grenzverletzung.],
  [`BearingResult`], [Immutable DTO mit `distanceInMeters` (Double) und `azimuthInDegrees` (0-359.9).],
  [`ComponentState`], [Zustandsmaschine (Enum): `IDLE`, `TRACKING`, `TERMINATED`.]
)

=== Detaillierte Produktdaten
Das finale Exportformat entspricht strikt dem XML-Schema `http://www.topografix.com/GPX/1/1`. Ein generierter Track (`<trk>`) enthält ein Track-Segment (`<trkseg>`), in welchem die bereinigten `Coordinate`-Objekte als `<trkpt lat="..." lon="...">` mit den Sub-Tags `<ele>` (Höhe) und `<time>` (ISO 8601) abgelegt werden.

== Nichtfunktionale Spezifikation
=== Qualitätsanforderungen nach ISO/IEC 25010
- **Wartbarkeit (Maintainability):** Sichergestellt durch strikte Einhaltung der SOLID-Prinzipien. Die Nutzung eines `Facade`-Patterns verbirgt die komplexe W3W- und GPX-Logik vor dem aufrufenden System.
- **Zuverlässigkeit (Reliability):** Verbindungsabbrüche zur W3W-API werden intern durch ein Retry-Muster abgefangen.

=== Mengengerüst
Der Path-Optimizer ist auf O(1) Speicherkomplexität ausgelegt: Er vergleicht eingehende Punkte direkt mit dem aktuellen Vektor und verwirft redundante Punkte sofort. Selbst bei einer 10-stündigen Peilung überschreitet der RAM-Verbrauch der Wegpunkt-Liste nicht ~2 MB (max. 10.000 relevante Wegpunkte).

=== Sicherheitsanforderungen
- **API-Key Handling:** Der W3W API-Schlüssel darf nicht fest im Code verdrahtet (Hardcoded) sein, sondern muss durch das integrierende System zur Laufzeit injiziert werden.
- **Thread Safety:** Da Positionsdaten potenziell asynchron (von GPS-Sensoren-Threads) injiziert werden, müssen die internen Listenstrukturen der Komponente threadsicher (z.B. via `CopyOnWriteArrayList` oder `synchronized` Blöcken) implementiert sein.

== Angestrebte Eigenschaften & Qualitätscheck
Zur Sicherstellung der geforderten akademischen "1+ Qualität" gelten folgende Check-Kriterien für die Implementierung:
1. **Code-Qualität:** Keine statischen Code-Analyse-Warnungen (z.B. in SonarLint).
2. **Testabdeckung:** Mindestens 85% Line-Coverage für die Business-Logik (`PathOptimizer` und `HaversineDistanceCalculator`). Die Tests müssen die Erkennung von Geraden aktiv verifizieren.
3. **Plattformunabhängigkeit:** Der Code darf unter keinen Umständen Pakete wie `java.awt.*`, `javafx.*` oder `android.*` importieren.
= Systemspezifikation (System Requirements / Pflichtenheft)
== Einleitung und allgemeine Beschreibung
== Funktionale Spezifikation
=== Use Cases
=== Einzelanforderungen
== Datenspezifikation
=== Data Dictionary
=== Detaillierte Produktdaten
== Nichtfunktionale Spezifikation
=== Qualitätsanforderungen nach ISO/IEC 25010
=== Mengengerüst
=== Sicherheitsanforderungen
== Angestrebte Eigenschaften & Qualitätscheck

= Systemarchitektur und Entwurf (Design)
== Grobentwurf (Makro-Architektur)
=== Systemarchitektur
=== Komponentendiagramm & Schnittstellendesign
== Feinentwurf (Mikro-Architektur)
=== Klassendiagramme
=== Aktivitätsdiagramme
=== Datenflussdiagramme

= Implementierung
== Beschreibung der Dateistruktur
== Ausgewählte Implementierungsdetails

= Qualitätssicherung und Testing
== Teststrategie
== Testfälle
== Testergebnisse

= Fazit und Ausblick
== Zusammenfassung der Ergebnisse
== Offene Punkte und Ausblick

#pagebreak()
////////////////////////////////

////////////////////////////////
// ANHANG
////////////////////////////////
#linebreak()

= Anhang

////////////////////////////////
