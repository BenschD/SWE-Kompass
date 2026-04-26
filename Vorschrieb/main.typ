#let titel = "Java-Kompass mit GPX-Track und What3Words-Anbindung"
#let autoren = "Moritz Pfitzenmaier, Marius Müllmaier, Daniel Bensch"
#let autor = autoren  // für Rückwärtskompatibilität mit templates.typ
#let kurzthema = "Softwareengineering - Projektdokumentation"

#let abgabedatum = datetime(
  year: 2026,
  month: 06,
  day: 12,
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

// ─────────────────────────────────────────────────────────────────────────────
// HILFSFUNKTIONEN FÜR ANFORDERUNGSKARTEN
// ─────────────────────────────────────────────────────────────────────────────

#let _req-fill = rgb("#d6e9f8")

/// Karte für funktionale Anforderungen /LF.../
#let lf-card(id, funktion, quelle, verweise, akteur, beschreibung) = {
  v(0.7em)
  set text(size: 11pt)
  block(width: 100%, breakable: false)[
    #table(
      columns: (1.9cm, 2.7cm, 1fr, 2.3cm, 1fr),
      stroke: 0.5pt + rgb("#AAAAAA"),
      fill: (x, _y) => if x == 0 or x == 1 { _req-fill } else { white },
      inset: (x: 7pt, y: 6pt),
      align: (x, _y) => if x <= 1 { center + horizon } else { left + top },
      table.cell(rowspan: 4)[
        #set align(center + horizon)
        #text(weight: "bold", size: 10pt)[#id]
      ],
      [Funktion], table.cell(colspan: 3)[#funktion],
      [Quelle], [#quelle], table.cell(fill: _req-fill)[Verweise], [#verweise],
      [Akteur], table.cell(colspan: 3)[#akteur],
      [Beschreibung], table.cell(colspan: 3)[#beschreibung],
    )
  ]
}

/// Karte für nicht-funktionale Anforderungen /LL.../
#let ll-card(id, funktion, quelle, verweise, beschreibung) = {
  v(0.7em)
  set text(size: 11pt)
  table(
    columns: (1.9cm, 2.7cm, 1fr, 2.3cm, 1fr),
    stroke: 0.5pt + rgb("#AAAAAA"),
    fill: (x, _y) => if x == 0 or x == 1 { _req-fill } else { white },
    inset: (x: 7pt, y: 6pt),
    align: (x, _y) => if x <= 1 { center + horizon } else { left + top },
    table.cell(rowspan: 3)[
      #set align(center + horizon)
      #text(weight: "bold", size: 10pt)[#id]
    ],
    [Funktion], table.cell(colspan: 3)[#funktion],
    [Quelle], [#quelle], table.cell(fill: _req-fill)[Verweise], [#verweise],
    [Beschreibung], table.cell(colspan: 3)[#beschreibung],
  )
}

/// Karte für Produktdaten /LD.../
#let ld-card(id, speicherinhalt, verweise, attribute) = {
  v(0.7em)
  set text(size: 11pt)
  table(
    columns: (1.9cm, 2.7cm, 1fr),
    stroke: 0.5pt + rgb("#AAAAAA"),
    fill: (x, _y) => if x == 0 or x == 1 { _req-fill } else { white },
    inset: (x: 7pt, y: 6pt),
    align: (x, _y) => if x <= 1 { center + horizon } else { left + top },
    table.cell(rowspan: 3)[
      #set align(center + horizon)
      #text(weight: "bold", size: 10pt)[#id]
    ],
    [Speicherinhalt], [#speicherinhalt],
    [Verweise], [#verweise],
    [Attribute], [#attribute],
  )
}

////////////////////////////////
// DECKBLATT
////////////////////////////////

#show: deckblatt.with(
  titel: titel,
  studiengang: "Informatik",
  standort: "Stuttgart",
  autoren: (
    (
      name: autor,
    ),
  ),
  abgabedatum: abgabedatum,
  bearbeitungszeitraum: "April 2026 – Juni 2026",
  martikelnummer: "8829906, 1341874, 5133713",
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
  )[
    #set align(top)
    #set text(11pt)
    #grid(
      columns: (auto, 1fr, auto),
      rows: (4cm),
      align: horizon,
      image("include/images/DHBW_Logo.png", height: 1cm),
      h(1fr),
      box([
        #set align(right)
        #context {
          let headings = query(heading.where(level: 1))
          let current-page = here().page()
          let active-headings = headings.filter(h => h.location().page() <= current-page)
          
          if active-headings.len() > 0 {
            active-headings.last().body
          } else {
            kurzthema
          }
        }
      ])
    )
  ],
  footer: rect(
    height: 100%,
    inset: 0mm,
    stroke: none,
  )[
    #set text(11pt)
    #grid(
      columns: (auto, 1fr, auto),
      rows: (1cm),
      align: horizon,
      box([
        #set align(left)
        #autoren
      ]),
      h(1fr),
      box([
        #set align(right)
        #context { counter(page).display() }
      ]),
    )
  ],
)

#show heading: set text(rgb("#d90000"))
#show heading: set block(below: 1em)

////////////////////////////////
// FRONTMATTER
////////////////////////////////
= Abstract

Die präzise Bestimmung von Richtung und Entfernung zu einem Zielpunkt ist eine alltägliche Aufgabe in der mobilen Navigation. Die iOS-Anwendung Kompass Professional bietet hierfür eine etablierte fachliche Orientierung, doch ihre Peilungslogik ist fest mit der grafischen Oberfläche und der Hardwareanbindung verknüpft. Diese Arbeit löst die Kernfunktionalität aus diesem Gesamtkontext heraus und überführt sie in eine eigenständige, UI-freie Java-Bibliothek.
Im Mittelpunkt steht die robuste Berechnung von Azimut, Distanz und diskreter Himmelsrichtung auf Basis von WGS84-Koordinaten. Die Bibliothek verarbeitet Positions- und Kursdaten, die ein Host-System liefert. Ein kontrollierbarer Session-Lebenszyklus ermöglicht das Aufzeichnen, Unterbrechen und Fortsetzen von Tracks, wobei die Daten durch konfigurierbare Reduktionsstrategien effizient gehalten werden. Der Export erfolgt standardkonform im GPX-Format Version 1.1. Zusätzlich lässt sich auch der What3Words-Dienst anbinden.
Neben der Implementierung als Maven-Projekt legt die Arbeit besonderen Wert auf eine nachvollziehbare Spezifikation: Die Anforderungen sind SOPHIST-konform formuliert und durchgängig prüfbar, nicht-funktionale  und objektorientierte Analyse- sowie Entwurfsartefakte begleiten die Architektur. Ein umfassendes Qualitätssicherungskonzept mit automatisierten Testfällen und Traceability sichert die reproduzierbare Abnahme der Bibliothek.

#pagebreak()

= Inhaltsverzeichnis
#outline(depth: 3, title: none)
#pagebreak()


= Abbildungsverzeichnis
#outline(target: figure.where(kind: image), title: none)
#pagebreak()


= Tabellenverzeichnis
#outline(target: figure.where(kind: table), title: none)
#pagebreak()

= Glossar

#import "include/glossar-begriffe.typ": glossar-begriffe-kapitel
#glossar-begriffe-kapitel

#import "include/ch-mehr-begriffe.typ": ch-mehr-begriffe-kapitel
#ch-mehr-begriffe-kapitel

#pagebreak()
////////////////////////////////

#set heading(numbering: "1.1.1 - ")
#set par(spacing: 2em, justify: true)

#set page(numbering: "1")
#counter(page).update(1)

#show math.equation: set align(center)

////////////////////////////////
// HAUPTTEIL
////////////////////////////////

= Einleitung

#import "include/ch-einleitung.typ": ch-einleitung-kapitel
#ch-einleitung-kapitel

= Grobentwurf

#import "include/ch-grobentwurf_new.typ": ch-grobentwurf-kapitel
#ch-grobentwurf-kapitel

// ─────────────────────────────────────────────────────────────────────────────
= Anforderungsanalyse (Lastenheft)
// ─────────────────────────────────────────────────────────────────────────────

Dieses Kapitel dokumentiert die Anforderungsanalyse für die Java-Peilungskomponente. Es folgt dem formalen Aufbau einer klassischen Anforderungssammlung: Zielbestimmung, Produkteinsatz, funktionale Anforderungen, Produktdaten, Qualitätsanforderungen (ISO/IEC 25010) sowie die daraus abgeleiteten nicht-funktionalen Anforderungen (`/LL…/`).

// ─────────────────────────────────────────────────────────────────────────────
== Zielbestimmung
// ─────────────────────────────────────────────────────────────────────────────



*Hintergrund:* Die iOS-App „Kompass Professional" demonstriert eine Peilungsfunktion: Sie zeigt wohin (Richtung) relativ zur aktuellen Orientierung bzw. Position, ohne Navigation im Sinne einer Turn-by-Turn-Führung. Die App zeichnet dabei einen GPS-Track auf, der als GPX exportierbar ist. 

*Zielbild:* Die Bibliothek ermittelt durch vom Host gelieferten Positions- und Kursdaten die Peilungsgrößen (insbesondere geografischer Azimut und Entfernung) und zeichnet währenddessen einen GPS-Track auf, der als GPX 1.1 exportierbar ist. Optional kann eine What3Words-Auflösung erfolgen.

*Erfolgskriterien:*

- Die Komponente ist ohne UI lauffähig und per `mvn test` verifizierbar.
- Alle `/LF…/`-Anforderungen sind durch mindestens einen dokumentierten Testfall abdeckbar.
- GPX-Ausgaben enthalten den GPX-1.1-Namespace und valide Zeitstempel im UTC-ISO-8601-Format.


#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Funktionale Anforderungen
// ─────────────────────────────────────────────────────────────────────────────

=== Peilung und Session-Lebenszyklus (/LF010/)

#lf-card(
  "/LF010/",
  "Peilung starten",
  "Projektauftrag SWE",
  "–",
  "Host-App",
  "Das System muss eine neue Peilung starten, wenn der Host eine gültige Zielkoordinate und eine gültige Konfiguration übergibt. Die Peilung erhält eine eindeutige UUID und startet im Zustand ACTIVE.",
)

#lf-card(
  "/LF020/",
  "Peilung nur einfach aktiv",
  "Klärungsgespräch",
  "/LF010/",
  "Host-App",
  "Das System muss verhindern, dass parallel mehrere aktive Peilungen standfinden. Ein erneuter Startaufruf ohne vorheriges Beenden führt zu einer definierten Exception.",
)

#lf-card(
  "/LF030/",
  "Positionsupdate verarbeiten",
  "Projektauftrag SWE",
  "/LF010/, /LL010/",
  "Host-App",
  "Das System muss jeden übergebenen GPS-Punkt validieren und bei Gültigkeit die Ausrichtung der Peilung aktualisieren. Ungültige Positionsdaten werden dabei ignoroert.",
)

#lf-card(
  "/LF040/",
  "Kursupdate verarbeiten",
  "Klärungsgespräch",
  "/LF030/",
  "Host-App",
  "Das System muss optional einen vom Host gelieferten Kurs (0–360°) nutzen, um eine Kursabweichung zur Zielrichtung zu bestimmen. Wird kein Kurs geliefert, entfällt die Kursabweichungsberechnung ohne Fehler.",
)

#lf-card(
  "/LF050/",
  "Peilungsinformationen abfragen",
  "Projektauftrag SWE",
  "/LF030/",
  "Host-App",
  "Die Peilungskomponente muss auf Anfrage die aktuelle Zielrichtung (geografischer Azimut in Grad), die Entfernung zum Ziel in Metern sowie eine diskrete Himmelsrichtung (N, NE, E, SE, S, SW, W, NW) liefern.",
)

#lf-card(
  "/LF060/",
  "Peilung regulär beenden",
  "Projektauftrag SWE",
  "/LF100/, /LF120/",
  "Host-App",
  "Die Peilungskomponente muss beendet werden und im anschluss daran den GPS-Trak in GPX-Form (nach GPX 1.1) zurückgeben. Nach regulärem Abschluss sind keine weiteren Positionsupdates zulässig.",
)

#lf-card(
  "/LF070/",
  "Peilung abbrechen",
  "Klärungsgespräch",
  "/LF060/, /LF121/",
  "Host-App",
  "Die Peilungskomponente muss vom Nutzer Abgebrochen werden können. Im Falle eines Peilungsabbruch darf der GPS-Track nicht verworfen werden, sondern in GPX-Form (Nach GPX 1.1) zurückgegeben werden.",
)

#lf-card(
  "/LF080/",
  "Listener-Events",
  "Vorlesung SWE (Observer)",
  "/LF030/, /LF060/",
  "Host-App",
  "Die Komponente muss Ereignisse für Start, Update, Abschluss und Fehler über registrierte Listener veröffentlichen. Die Listener-Benachrichtigung erfolgt synchron oder konfigurierbar serialisiert.",
)

#lf-card(
  "/LF090/",
  "Fehler semantisch klassifizieren",
  "Qualitätsrichtlinie",
  "/LL010/",
  "Host-App",
  "Die Komponente muss Eingabe-, Zustands- und I/O-Fehler über eine klar dokumentierte Exception-Hierarchie unterscheidbar machen.",
)


=== GPS-Track (/LF100/)

Die Anforderungen /LF110/, /LF130/, /LF140/ und /LF160/ sind *nicht* Teil des Lieferumfangs dieser Bibliothek (siehe Anhang *Nicht im Lieferumfang*).

#lf-card(
  "/LF100/",
  "GPS-Punkte aufzeichnen",
  "Projektauftrag SWE",
  "/LF030/",
  "Host-App",
  "Das System muss während einer aktiven Peilung jeden validierten GPS-Fix mit Zeitstempel vollständig im Rohspeicher ablegen. Jeder gespeicherte Punkt enthält mindestens: Zeitstempel, Breitengrad, Längengrad.",
)

#lf-card(
  "/LF120/",
  "Punktbudget konfigurieren",
  "Klärungsgespräch",
  "/LF100/",
  "Host-App",
  "Die Peilungskomponente muss eine Obergrenze für die Anzahl gespeicherter GPS-Punkte pro Peilung unterstützen (Soft-Warnung, Hard-Limit mit kontrolliertem Stopp). Eine automatische Punktreduktion durch die Bibliothek beim Einlesen erfolgt nicht; optional können beim GPX-Export `TrackOptimizer`-Strategien registriert werden.",
)

#lf-card(
  "/LF150/",
  "Optionale Felder speichern",
  "Fragenkatalog Team",
  "/LF100/",
  "Host-App",
  "Das System muss optionale Felder wie Höhe (Elevation), HDOP und Geschwindigkeit in GPS-Trackpunkten abbilden können, sofern der Host diese Werte liefert. Fehlende Felder werden in der GPX-Darstellung weggelassen statt mit Nullwerten befüllt.",
)

#lf-card(
  "/LF170/",
  "Segmentierung bei Zeitlücken",
  "Qualitätsrichtlinie",
  "/LF100/",
  "Host-App",
  "Das System muss zeitliche Lücken zwischen aufeinanderfolgenden Punkten, die einen konfigurierbaren Schwellwert überschreiten, als Beginn eines neuen Track-Segments kennzeichnen. Dies ermöglicht korrekte GPX-Segmentierung.",
)

#lf-card(
  "/LF180/",
  "Hard-Limit erzwingen",
  "Fragenkatalog Team",
  "/LF120/, /LL030/",
  "Host-App",
  "Das System muss beim Erreichen des konfigurierten Hard-Limits die Aufzeichnung kontrolliert stoppen oder in einen definierten Overflow-Modus wechseln und den Host über ein dediziertes Limit-Event informieren.",
)


=== GPX-Export, Optimierung und W3W (/LF200/)

#lf-card(
  "/LF200/",
  "GPX 1.1 erzeugen",
  "Klärungsgespräch",
  "/LF100/",
  "Host-App",
  "Die Peilungskomponente muss aus einer abgeschlossenen oder abgebrochenen Peilung, den Aufgezeichneten GPS-Track in Form des GPX 1.1 Standarts erzeugen.",
)

#lf-card(
  "/LF210/",
  "GPX-Metadaten setzen",
  "GPX-Standard",
  "/LF200/",
  "Host-App",
  "Das System muss in der GPX-Ausgabe Metadaten wie Zeitbereich (time-bounds), optionalen Track-Namen und Quelle setzen. Zeitangaben erfolgen normalisiert in UTC gemäß ISO-8601.",
)

#lf-card(
  "/LF220/",
  "Atomares Dateischreiben",
  "IEEE-830-NFR",
  "/LF230/",
  "Host-App",
  "Das System muss beim optionalen Schreiben auf das Dateisystem zuerst eine temporäre Datei anlegen und diese anschließend atomar durch Umbenennen an den Zielort verschieben, um Datenverlust bei Schreibfehlern zu vermeiden.",
)

#lf-card(
  "/LF230/",
  "Export als String oder Bytes",
  "Klärungsgespräch",
  "/LF200/",
  "Host-App",
  "Das System muss GPX-Daten unabhängig vom Dateisystem als `String` oder `byte[]` bereitstellen. Diese Entkopplung ermöglicht GPX-Ausgabe nach Abbruch, ohne eine Datei schreiben zu müssen.",
)

#lf-card(
  "/LF240/",
  "Optimierung: jeder n-te Punkt",
  "Klärungsgespräch",
  "/LF200/",
  "Host-App",
  "Die Peilungskomponente soll einen Reduktionsalgorithmus enthalten, welcher nur jeden n-ten GPS Punkt behält. Der Startpunkt und der Endpunkt, werden dabei immer erhalten.",
)

#lf-card(
  "/LF250/",
  "Optimierung: Mindestabstand",
  "Klärungsgespräch",
  "/LF200/",
  "Host-App",
  "Das System muss eine distanzbasierte Reduktionsstrategie implementieren, die Punkte unterhalb eines konfigurierbaren Mindestabstands (in Metern) zum jeweils letzten akzeptierten Punkt verwirft.",
)

#lf-card(
  "/LF260/",
  "Optimierung: Geraden reduzieren",
  "Klärungsgespräch",
  "/LF200/",
  "Host-App",
  "Die Komponente muss Punkte welche näherungsweiße auf einer Geraden liegen, auf lediglich zwei Punkte Reduzieren können. Um so die Gesamtanzahl an gespeicherten GPS-Punkte zu reduzieren",
)

#lf-card(
  "/LF270/",
  "Optimierung: Douglas-Peucker (optional)",
  "Erweiterungsanforderung (1+)",
  "/LF200/",
  "Host-App",
  "Das System muss optional den Douglas-Peucker-Algorithmus mit konfigurierbarer metrischer Toleranz (Epsilon in Metern) für die Track-Vereinfachung anbieten. Die Strategie ist über die Strategy-Schnittstelle austauschbar.",
)

#lf-card(
  "/LF280/",
  "What3Words auflösen",
  "Klärungsgespräch",
  "/LF050/",
  "Host-App",
  "Die Java-Komponente muss in der Lage seim Koordinaten in eine What3Words-Adresse auflösen, sofern ein gültiger API-Key und Netzwerkzugang vorhanden sind. Bei Fehler oder fehlenden Credentials wird eine Expression ausgelösst.",
)

#lf-card(
  "/LF290/",
  "W3W-Anfragen cachen",
  "Performanceanforderung",
  "/LF280/",
  "Host-App",
  "Das System muss wiederholte What3Words-Anfragen für identische Koordinaten über einen internen Cache reduzieren können. Cache-Einträge können mit einer konfigurierbaren Time-to-Live versehen werden.",
)


=== Validierung, Sicherheit und Betrieb (/LF300/)

#lf-card(
  "/LF300/",
  "Koordinatenbereich prüfen",
  "-",
  "/LL010/",
  "Host-App",
  "Die Peilungs-Komponente muss Breiten- und Längengrade auf den bei WGS84-Zulässigkeitsbereich prüfen (Breitengrad: -90° bis +90°, Längengrad: -180° bis +180°). Ungültige Werte führen zu einer `ValidationException` (`ErrorCode.COORD_RANGE`) und werden nicht im GPX-Format gespeichert.",
)

#lf-card(
  "/LF310/",
  "Zeitstempel validieren",
  "Klärungsgespräch",
  "/LF100/",
  "Host-App",
  "Die Komponente muss Zeitstempel ablehnen, die in der Zukunft liegen oder älter als ein anpassbarer Schwellwert sind (Default: 24 Stunden). GPS-Punkte mit ungültigem Zeitstempel führen zu einer `ValidationException` (`ErrorCode.TIMESTAMP_INVALID`) und werden nicht im GPX-Format gespeichert.",
)

#lf-card(
  "/LF320/",
  "Pfadvalidierung und Path-Traversal-Schutz",
  "Sicherheitsrichtlinie",
  "/LF220/",
  "Host-App",
  "Das System muss Ausgabepfade normalisieren und Path-Traversal-Angriffe (z. B. `../../etc/passwd`) aktiv unterbinden. Ein unzulässiger Pfad führt zu einer SecurityException.",
)

#lf-card(
  "/LF330/",
  "Keine stillen Datenverluste",
  "Qualitätsrichtlinie",
  "/LF180/",
  "Host-App",
  "Die Komponente muss jeden Datenverlust oder jede Aggregation durch strukturierte Log-Einträge (mindestens Level WARN) nachvollziehbar machen. Stille Verwürfe sind nicht zulässig.",
)

#lf-card(
  "/LF340/",
  "Deterministische Testbarkeit",
  "Lehrauftrag",
  "/LL040/",
  "Team",
  "Das System muss Zeit (via `java.time.Clock`) und Zufall über injizierbare Abstraktionen ersetzbar machen, sodass alle zeitabhängigen Tests deterministisch und ohne Schlafpausen laufen.",
)

#lf-card(
  "/LF350/",
  "Thread-Sicherheit dokumentieren",
  "Nebenläufigkeitsrichtlinie",
  "/LF030/",
  "Host-App",
  "Die Komponente muss in der Javadoc klar angeben, welche Methoden thread-sicher sind. Standartmäßig soll ein einzelner Host-Thread die Peilung steuern. Abweichungen müssen gekennzeichnet werden.",
)


=== Ergänzende funktionale Anforderungen (/LF400/)

#lf-card(
  "/LF400/",
  "Konfiguration beim Start validieren",
  "Robustheitsrichtlinie",
  "/LF010/",
  "Host-App",
  "Die Komponente muss beim Start der eilung prüfen, dass alle übergebene Werte der Konfiguration zulässig sind (z. B. Intervall > 0, Punktbudget > 0, kein negativer HDOP-Schwellwert). Ungültige Werte führen zu einem Fehler.",
)

#lf-card(
  "/LF410/",
  "Konfiguration einfrieren",
  "SWE Best Practice",
  "/LF010/",
  "Host-App",
  "Die Komponente muss die Konfiguration nach dem Start einer Peilung unveränderlich einfrieren. Nachträgliche Änderungsversuche müssen abgewiesen werden. Dies gewährleistet ein konsistentes Verhalten über die gesamte Laufzeit der Peilung.",
)

#lf-card(
  "/LF420/",
  "Strukturiertes Logging",
  "Betriebsanforderung",
  "/LF330/",
  "Team",
  "Das System muss strukturierte Log-Felder wie `sessionId` und `phase` in allen relevanten Log-Ausgaben unterstützen, um eine Korrelation von Logs über mehrere Sessions hinweg zu ermöglichen.",
)

#lf-card(
  "/LF430/",
  "Keine UI-Abhängigkeiten",
  "Projektauftrag",
  "-",
  "Team",
  "Die Komponente darf keinerlei Klassen aus UI-Frameworks (AWT, Swing, JavaFX, Android-UI etc.) referenzieren. Die Bibliothek ist reine Logik- und I/O-Schicht.",
)

#lf-card(
  "/LF440/",
  "Java-Version",
  "Rahmenbedingung",
  "-",
  "Team",
  "Die Komponente muss mit Java 11 oder höher kompilierbar sein, ohne Verwendung von APIs, die in späteren Versionen entfernt wurden wie beispielsweiße `sun.*`-Klassen und deprecated APIs.",
)

#lf-card(
  "/LF450/",
  "Build-Tooling",
  "Abgabeanforderung",
  "-",
  "Team",
  "Die Komponente muss per Maven (`mvn test`) ohne manuelle Zwischenschritte vollständig kompilierbar und testbar sein. Alle Abhängigkeiten sind über Maven Central auflösbar. Ist dies nicht der Fall, soll eine ausführliche Anleitung in einer README Datei bereit gestellt werden.",
)

#lf-card(
  "/LF460/",
  "Zeitstempel in UTC normalisieren",
  "GPS-Standard",
  "/LF100/",
  "Host-App",
  "Die Komponente muss alle Zeitstempel intern als `java.time.Instant` (UTC) verarbeiten. Die Konvertierung in lokale Zeitzone ist ausschließlich Aufgabe des Hosts.",
)

#lf-card(
  "/LF470/",
  "Null-sichere öffentliche API",
  "Qualitätsrichtlinie",
  "-",
  "Host-App",
  "Die Komponente muss in der gesamten öffentlichen API die Null-Semantik in Javadoc explizit festlegen. Rückgabewerte, die leer sein können, sind als `Optional<T>` zu deklarieren. Dies ist durch Tests abzusichern.",
)

#lf-card(
  "/LF480/",
  "Optimierer austauschbar halten",
  "Erweiterungsanforderung",
  "/LF240/-/LF270/",
  "Team",
  "Die Komponente muss alle Optimierungsstrategien über eine gemeinsame Strategy-Schnittstelle (`TrackOptimizer`) austauschbar halten, sodass zukünftige Algorithmen ohne Änderung der Kernklassen integrierbar sind.",
)

#lf-card(
  "/LF490/",
  "GPX-Generierung von Post-Processing trennen",
  "Wartbarkeitsrichtlinie",
  "/LF200/",
  "Team",
  "In der Komponente müssen die GPX-Speicherung klar von den optionalen Schritten der Optimierung trennen. Damit beide Bereiche später einfach erweiterbar sind, ohne dass sie sich gegenseitig beeinflussen.",
)

#lf-card(
  "/LF500/",
  "Statistikobjekt nach Abschluss",
  "Erweiterungsanforderung",
  "/LF060/",
  "Host-App",
  "Die Komponente muss nach regulärem oder abgebrochenem Abschluss einer Peilung ein Übersicht über die Peilung bereitstellen, welche mindestens die Gesamtdistanz in Metern, die Gesamtdauer in Sekunden und die Anzahl der gespeicherter Wegpunkte enthält.",
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Produktdaten
// ─────────────────────────────────────────────────────────────────────────────

Die folgenden Produktdaten beschreiben die persistenten bzw. transportierten Datenstrukturen der Bibliothek. Der Begriff „Persistenz" bezieht sich sowohl auf GPX-Exportartefakte als auch auf temporäre Dateien beim atomaren Schreibvorgang.

#ld-card(
  "/LD100/",
  "Peilungs-Session (`DefaultBearingSession`)",
  "/LF010/, /LF070/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [sessionId], [UUID],
      [lifecycle], [Enum: IDLE, ACTIVE, COMPLETED, ABORTED],
      [target], [GeoCoordinate],
      [frozenConfig], [SessionConfig],
      [aggregator], [TrackAggregator],
      [courseDeg], [Optional\<Double\>],
      [startedAt], [Instant],
      [lastFix], [Optional\<GpsFix\>],
      [listenerSerialized], [boolean],
    )
    #v(0.35em)
    #text(size: 9.5pt, style: "italic")[
      `endedAt` ist kein gespeichertes Session-Feld; der Endzeitpunkt wird in `complete()`/`abort()` nur lokal aus der Clock ermittelt und in `SessionStatistics` verwendet.
    ]
  ],
)

#ld-card(
  "/LD110/",
  "Konfiguration (`SessionConfig`)",
  "/LF400/, /LF410/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [softLimitPoints], [int (>= 0; 0 = deaktiviert)],
      [hardLimitPoints], [int (>= 0; 0 = deaktiviert)],
      [overflowMode], [OverflowMode (Standard: STOP)],
      [segmentGapThreshold], [Duration (Standard: 5 min)],
      [maxFixAge], [Duration (Standard: 24 h)],
      [persistOnAbort], [boolean (Standard: false)],
      [allowedBaseDir], [Optional\<Path\>],
      [completePersistPath], [Optional\<Path\>],
      [abortPersistPath], [Optional\<Path\>],
      [listenerSerialized], [boolean],
      [optimizers], [List\<TrackOptimizer\>],
      [w3wApiKey], [Optional\<String\>],
    )
    #v(0.35em)
    #text(size: 9.5pt, style: "italic")[
      Build-Regeln in `SessionConfig.Builder`: Persistenzpfade erfordern `allowedBaseDir`; Limits < 0 sind unzulässig.
    ]
  ],
)

#ld-card(
  "/LD120/",
  "GPS-Track (`Track` + `TrackSegment`)",
  "/LF100/, /LF170/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [Track.segments], [List\<TrackSegment\> (immutable copy)],
      [Track.totalPoints()], [int (abgeleitet aus Segmentpunkten)],
      [TrackSegment.points], [List\<GpsPoint\>],
    )
    #v(0.35em)
    #text(size: 9.5pt, style: "italic")[
      Ein eigenes Feld `timeRange` existiert nicht auf `Track`; Zeitgrenzen werden bei Bedarf aus Punkten berechnet (z. B. `GpxExportMapper.metadataFor`).
    ]
  ],
)

#ld-card(
  "/LD130/",
  "GPS-Punkt (`GpsPoint`, Eingabe: `GpsFix`)",
  "/LF100/, /LF150/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [time], [Instant (Pflicht)],
      [latitudeDeg], [double (-90 bis +90)],
      [longitudeDeg], [double (-180 bis +180)],
      [elevationM], [Optional\<Double\>],
      [hdop], [Optional\<Double\>],
      [speedMps], [Optional\<Double\>],
    )
    #v(0.35em)
    #text(size: 9.5pt, style: "italic")[
      `GpsFix` und `GpsPoint` haben dieselbe Datenstruktur; `GpsPoint.fromFix(fix)` überführt Eingaben in die Track-Repräsentation.
    ]
  ],
)

#ld-card(
  "/LD140/",
  "Peilungs-Snapshot (`BearingSnapshot`)",
  "/LF050/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [azimuthDeg], [double],
      [distanceM], [double],
      [compassOrdinal], [CompassOrdinal (N, NE, E, SE, S, SW, W, NW)],
      [bearingErrorDeg], [Optional\<Double\>],
    )
  ],
)

#ld-card(
  "/LD150/",
  "GPX-Dokument (`GpxDocument`, SPI-Modell)",
  "/LF200/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [GPX_11_NAMESPACE], [Konstante `String`: `http://www.topografix.com/GPX/1/1`],
      [metadata], [GpxMetadata],
      [segments], [List\<GpxTrackSegment\>],
      [GpxTrackSegment.points], [List\<GpxTrackPoint\>],
      [GpxTrackPoint], [lat, lon, time, elevationM, hdop, speedMps],
    )
    #v(0.35em)
    #text(size: 9.5pt, style: "italic")[
      UTF-8 ist kein Feld von `GpxDocument`; die Kodierung entsteht bei der Serialisierung (`GpxXmlWriter`) und im Rückgabeobjekt (`GpxResult`).
    ]
  ],
)

#ld-card(
  "/LD160/",
  "GPX-Metadaten (`GpxMetadata`)",
  "/LF210/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [name], [Optional\<String\>],
      [description], [Optional\<String\>],
      [author], [Optional\<String\>],
      [timeStart], [Optional\<Instant\>],
      [timeEnd], [Optional\<Instant\>],
    )
  ],
)

#ld-card(
  "/LD170/",
  "Export-Ergebnis (`GpxResult` + `SessionStatistics`)",
  "/LF230/, /LF240/–/LF270/, /LF500/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [GpxResult.utf8Bytes], [byte[] (defensiv geklont)],
      [GpxResult.statistics], [SessionStatistics],
      [GpxResult.appliedOptimizers], [List\<String\>],
      [SessionStatistics.totalDistanceM], [double],
      [SessionStatistics.totalDuration], [Duration],
      [SessionStatistics.storedPointCount], [int],
    )
    #v(0.35em)
    #text(size: 9.5pt, style: "italic")[
      Es gibt keine eigene Klasse mit `originalCount`/`optimizedCount`/`epsilonMeters`; diese Werte werden in der Implementierung nicht als separates Produktdatenobjekt persistiert.
    ]
  ],
)

#ld-card(
  "/LD180/",
  "W3W-Cache (`W3wHttpClient`, intern)",
  "/LF290/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [cache], [Map\<String, CacheEntry\> (LRU via `LinkedHashMap`)],
      [cacheKey], [gerundete Koordinate als String (`roundKey`)],
      [CacheEntry.words], [String],
      [CacheEntry.resolvedAt], [Instant],
      [ttl], [Duration (Client-Parameter, nicht Eintragsfeld)],
      [maxEntries], [int (Client-Parameter)],
      [timeout], [Duration (Client-Parameter)],
    )
  ],
)

#ld-card(
  "/LD190/",
  "Protokollierungsdaten (`LoggerPort` / `Slf4jLoggerAdapter`)",
  "/LF330/, /LF420/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [phase], [String],
      [sessionId], [UUID],
      [message], [String],
      [errorCode], [String (für warn/error)],
      [cause], [Optional\<Throwable\> (überladene warn/error-Methoden)],
    )
    #v(0.35em)
    #text(size: 9.5pt, style: "italic")[
      Es existiert kein persistiertes Log-Entity-Objekt mit festen Feldern wie `timestamp` oder `stacktrace` als String; die Ausgabe erfolgt direkt über SLF4J.
    ]
  ],
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Qualitätsanforderungen
// ─────────────────────────────────────────────────────────────────────────────

Die Qualitätskriterien wurden in Anlehnung an die ISO/IEC 9126 ausgewählt und gewichtet. Die Gewichtung spiegelt den Schwerpunkt der Bibliothek als reine Logik-Komponente ohne eigene UI wider.

#let category-rows = (1, 8, 13, 19, 23, 29)


#{
  show figure: set block(breakable: true)
  figure(
    caption: [Gewichtung der Qualitätsmerkmale nach ISO/IEC 9126 (Relevanzstufen je Unterkriterium).],
    kind: table,
    table(
  columns: (2.5fr, 0.9fr, 0.9fr, 0.9fr, 1.1fr),
  stroke: 0.5pt + rgb("#AAAAAA"),

  fill: (x, y) => {
    if y == 0 {
      rgb("#4a4a4a")
    } else if y in category-rows {
      rgb("#9ab8cc")
    } else if calc.even(y) {
      rgb("#f2f2f2") // Zebra-Streifen
    } else {
      white
    }
  },

  inset: (x: 7pt, y: 5pt),
  align: (x, y) => if x == 0 { left + horizon } else { center + horizon },

  // Header
  table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[Produktqualität]],
  table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[sehr wichtig]],
  table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[wichtig]],
  table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[normal]],
  table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[nicht relevant]],

  // Funktionalität
  [*Funktionalität*], [], [], [], [],
  [Angemessenheit], [x], [], [], [],
  [Sicherheit], [], [], [x], [],
  [Interoperabilität], [], [], [x], [],
  [Konformität], [], [x], [], [],
  [Ordnungsmäßigkeit], [], [], [x], [],
  [Richtigkeit], [], [x], [], [],

  // Zuverlässigkeit
  [*Zuverlässigkeit*], [], [], [], [],
  [Fehlertoleranz], [], [], [x], [],
  [Konformität], [], [], [x], [],
  [Reife], [], [x], [], [],
  [Wiederherstellbarkeit], [], [x], [], [],

  // Benutzbarkeit
  [*Benutzbarkeit*], [], [], [], [],
  [Attraktivität], [x], [], [], [],
  [Bedienbarkeit], [], [x], [], [],
  [Erlernbarkeit], [x], [], [], [],
  [Konformität], [], [], [x], [],
  [Verständlichkeit], [], [x], [], [],

  // Effizienz
  [*Effizienz*], [], [], [], [],
  [Konformität], [], [], [x], [],
  [Zeitverhalten], [], [], [x], [],
  [Verbrauchsverhalten], [], [], [], [x],

  // Änderbarkeit
  [*Änderbarkeit*], [], [], [], [],
  [Analysierbarkeit], [], [], [x], [],
  [Konformität], [], [], [x], [],
  [Modifizierbarkeit], [], [x], [], [],
  [Stabilität], [], [x], [], [],
  [Testbarkeit], [], [], [x], [],

  // Übertragbarkeit
  [*Übertragbarkeit*], [], [], [], [],
  [Anpassbarkeit], [], [], [], [x],
  [Austauschbarkeit], [], [x], [], [],
  [Installierbarkeit], [], [], [x], [],
  [Koexistenz], [], [x], [], [],
  [Konformität], [], [], [x], [],
    ),
  )
}

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Nichtfunktionale Anforderungen
// ─────────────────────────────────────────────────────────────────────────────

Die folgenden Anforderungen konkretisieren die priorisierten Qualitätsmerkmale aus der vorstehenden Matrix mess- und testbar.

=== Leistungs- und Performanceanforderungen (/LL010/)

#ll-card(
  "/LL010/",
  "Eingabevalidierung",
  "Qualitätsrichtlinie",
  "/LF300/, /LF310/",
  "Ungültige Eingaben dürfen keine undefinierten Zustände erzeugen. Alle Fehlerpfade werden durch Testfälle abgesichert.",
)

#ll-card(
  "/LL020/",
  "Genauigkeit der Peilungsberechnung",
  "Fachanforderung",
  "/LF050/",
  "Für Distanzen von über 10 m darf der berechnete Azimut maximal ±1° von einer Referenz (Haversine-Formel) abweichen. Die Überprüfung erfolgt anhand definierter Referenzpunkte (Äquator, Polnähe, Stuttgart).",
)

#ll-card(
  "/LL030/",
  "Performance der Peilungsberechnung",
  "Echtzeit-Anforderung",
  "/LF030/",
  "Ein vollständiger Update-Zyklus (Positionsupdate -> Azimut/Distanz berechnen) soll auf üblicher Laptop-Hardware typischerweise deutlich unter 1 ms liegen. Der  Worst-Case-Grenzwert beträgt dabei 100 ms ohne GC-Pause.",
)

#ll-card(
  "/LL040/",
  "Performance des GPX-Exports",
  "Performanceanforderung",
  "/LF200/",
  "Der GPX-Export für 10.000 Punkte ohne Douglas-Peucker-Optimierung soll auf Laptop-Hardware in unter 2 Sekunden erfolgen. Dieser Richtwert ist zu dokumentieren und in einem Benchmark-Test zu messen.",
)

#ll-card(
  "/LL050/",
  "Speicherverbrauch",
  "Ressourcenanforderung",
  "/LF180/",
  "Für einen Track mit 10.000 Punkten soll der Heap-Zuwachs der Bibliothek typischerweise unter 50 MB bleiben. Dieser Richtwert ist durch einen Test zu validieren.",
)



=== Externe Schnittstellen (/LL100/)

#ll-card(
  "/LL100/",
  "Wartbarkeit und Dokumentationsqualität",
  "Vorlesung SWE",
  "-",
  "Die gesamte öffentliche API der Komponente muss vollständig mit Javadoc dokumentiert sein. Ein Checkstyle-Plugin im Maven-Build prüft die Einhaltung der Dokumentationsregeln. Fehlende Javadoc führen zu einem Build-Fehler.",
)

#ll-card(
  "/LL110/",
  "Portabilität",
  "Projektauftrag",
  "-",
  "Die Komponente darf keine plattformspezifischen Pfade, Zeilentrennzeichen oder `sun.*`-APIs verwenden. Sie muss auf Windows, macOS und Linux ohne Anpassungen kompilierbar und ausführbar sein. Ist dies nicht realisierbar sein, muss eine ausführliche Anleitung in einer README Datei zur verfügung gestelt werden",
)

#ll-card(
  "/LL120/",
  "Übertragbarkeit / Build-Reproduzierbarkeit",
  "Projektauftrag",
  "-",
  "Der Maven-Build muss auf einem frisch geklonten Repository ohne manuelle Schritte außer einer JDK-Installation (Java 11+) erfolgreich durchlaufen. Kein Zugriff auf lokale Systemkonfigurationen ist erlaubt. st dies nicht realisierbar sein, muss eine ausführliche Anleitung in einer README Datei zur verfügung gestelt werden",
)

#ll-card(
  "/LL130/",
  "Sicherheit der XML-Ausgabe",
  "Sicherheitsrichtlinie",
  "/LF320/",
  "Die Bibliothek darf keine dynamische Code-Ausführung aus GPX-Eingaben ermöglichen (XXE-Schutz). Alle in XML-Ausgaben eingebetteten Strings müssen korrekt escaped werden (Entity-Injection-Prävention).",
)

#ll-card(
  "/LL140/",
  "Beobachtbarkeit über SLF4J",
  "Betriebsanforderung",
  "/LF330/",
  "Alle Warn- und Fehlerereignisse werden über SLF4J protokolliert. Log-Einträge auf WARN-Level und höher müssen die `sessionId` als strukturiertes Feld enthalten, um eine Korrelation über mehrere Sessions zu ermöglichen.",
)

#ll-card(
  "/LL150/",
  "Testabdeckung",
  "Vorlesung SWE",
  "/LF340/",
  "Die Kernmodule (`bearing-api`, `bearing-domain`, `bearing-adapter-gpx`) müssen gemäß Spezifikation eine Zeilenabdeckung von mindestens 85 % erreichen. Für kritische Domänenklassen (Session-Lebenszyklus, Peilungsberechnung) gilt ein Mindestwert von 90 %.",
)

#ll-card(
  "/LL160/",
  "Wiederanlauf nach Exception",
  "Betriebsanforderung",
  "-",
  "Nach einer unerwarteten Exception muss die Komponente in einen definierten Leerlaufzustand zurückkehren können, ohne dass ein Neustart der JVM erforderlich ist. Der Zustand IDLE muss erreichbar sein.",
)

#ll-card(
  "/LL170/",
  "Determinismus der Tests",
  "Testbarkeitsanforderung",
  "/LF340/",
  "Alle zeitabhängigen Tests verwenden ausschließlich `Clock`-Injection statt `System.currentTimeMillis()`. Kein Test darf von externem Netzwerkzustand oder Dateisystemzustand abhängen.",
)

#ll-card(
  "/LL180/",
  "Energieeffizienz der Positionsaufrufe",
  "Betriebsanforderung",
  "-",
  "Die Aufrufhäufigkeit von `onPositionUpdate` liegt beim Host. Der Host soll vermeiden, unnötig dichte Fix-Ströme zu erzeugen, die Speicher und Batterie belasten; die Bibliothek reduziert beim Einlesen nicht stillschweigend.",
)

#ll-card(
  "/LL190/",
  "Determinismus bei gleichen Eingaben",
  "Qualitätsanforderung",
  "-",
  "Gleiche Eingabesequenzen mit festem `Clock`-Mock müssen stets zum selben Track und denselben GPX-Ausgabe führen. Die wichtigsten Funktionen müssen stehts immer zum gleichen Ergebnis führen.",
)

#ll-card(
  "/LL200/",
  "Abhängigkeitslizenzierung",
  "Rechtliche Anforderung",
  "-",
  "Im Standard-Build dürfen nur permissiv lizenzierte Bibliotheken (Apache 2.0, MIT, BSD) verwendet werden. Die W3W-Client-Abhängigkeit ist optional und nur im Maven-Profil `w3w` aktiviert.",
)

#pagebreak()

= Systemspezifikation und Feinentwurf (Pflichtenheft)

#import "include/ch-spezifikation.typ": ch-spezifikation-kapitel
#ch-spezifikation-kapitel

= Qualitätssicherung

#import "include/ch-qs-fazit.typ": ch-qs-fazit-kapitel
#ch-qs-fazit-kapitel

#pagebreak()

////////////////////////////////
// ANHANG
////////////////////////////////
= Anhang

#import "include/ch-anhang.typ": ch-anhang-kapitel
#ch-anhang-kapitel
