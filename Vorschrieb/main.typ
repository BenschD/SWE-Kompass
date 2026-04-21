#let titel = "Java-Kompass mit GPX-Track und What3Words-Anbindung"
#let autoren = "Moritz Pfitzenmaier, Marius Müllmaier, Daniel Bensch"
#let autor = autoren  // für Rückwärtskompatibilität mit templates.typ
#let kurzthema = "Softwareengineering – Projektdokumentation"

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

*neu Formulieren*



Diese technische Dokumentation beschreibt die Anforderungsanalyse und Systemspezifikation einer UI-freien Java-Bibliothek zur Peilung (Richtungs- und Distanzangabe zu einem Zielpunkt auf Basis von WGS84-Koordinaten) sowie zur Aufzeichnung und zum Export eines GPS-Tracks im GPX-Format Version 1.1. Ausgangspunkt ist die fachliche Orientierungshilfe der iOS-Referenzanwendung Kompass Professional , jedoch *ohne* Übernahme von UI, Routing oder Hardwarezugriff: Die Bibliothek erhält Positions- und Kursdaten vom Host und liefert berechnete Peilungsgrößen, Ereignisse und serialisierte GPX-Daten.

Der dokumentierte Umfang erfüllt die formalen Anforderungen der Lehrveranstaltung Softwareengineering: SOPHIST-konforme Anforderungen mit Quellen- und Akteursangaben, Produktdaten, nicht-funktionale Kriterien nach ISO/IEC 25010, objektorientierte Analyse und Entwurf, textuelle UML-Aktivitäts- und Sequenzbeschreibungen sowie ein Qualitätssicherungskonzept inklusive Testfällen und Traceability.

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

#import "include/ch-grobentwurf.typ": ch-grobentwurf-kapitel
#ch-grobentwurf-kapitel

// ─────────────────────────────────────────────────────────────────────────────
= Anforderungsanalyse (Lastenheft)
// ─────────────────────────────────────────────────────────────────────────────

Dieses Kapitel dokumentiert die *Anforderungsanalyse* für die Java-Peilungskomponente. Es folgt dem formalen Aufbau einer klassischen Anforderungssammlung: Zielbestimmung, Produkteinsatz, funktionale Anforderungen, Produktdaten, nicht-funktionale Anforderungen sowie Qualitätsanforderungen. Ergänzend werden SWE-Artefakte integriert, die in der Vorlesung gefordert sind.

// ─────────────────────────────────────────────────────────────────────────────
== Zielbestimmung und Produkteinsatz
// ─────────────────────────────────────────────────────────────────────────────

=== Zielbestimmung

*Hintergrund:* Die iOS-App „Kompass Professional" demonstriert eine Peilungsfunktion: Sie zeigt wohin (Richtung) relativ zur aktuellen Orientierung bzw. Position, ohne Navigation im Sinne einer Turn-by-Turn-Führung. Die App zeichnet dabei einen GPS-Track auf, der als GPX exportierbar ist. 

*Zielbild:* Die Bibliothek ermittelt durch vom Host gelieferten Positions- und Kursdaten die Peilungsgrößen (insbesondere geografischer Azimut und Entfernung) und zeichnet währenddessen einen GPS-Track auf, der als GPX 1.1 exportierbar ist. Optional kann eine What3Words-Auflösung erfolgen.

*Erfolgskriterien:*

- Die Komponente ist ohne UI lauffähig und per `mvn test` verifizierbar.
- Alle `/LF…/`-Anforderungen sind durch mindestens einen dokumentierten Testfall abdeckbar.
- GPX-Ausgaben enthalten den GPX-1.1-Namespace und valide Zeitstempel im UTC-ISO-8601-Format. *(Muss in die Funktionale Anforderungen)*

=== Produkteinsatz

*Einsatzgebiet:* Integration in beliebige Java-Anwendungen, die selbst Sensordaten beschaffen und an die Bibliothek übergeben.

- *Outdoor-Applikation* mit eigener Karten-UI (Bibliothek liefert nur Zahlen und GPX).
- *Feld-Dienst* mit periodischen GPS-Fixes; Bibliothek übernimmt Sampling-Policy und Export.
- *Labor:* Mock-GPS-Streams treiben deterministische Tests.

*Schnittstelle zur Außenwelt:* Die Bibliothek spricht keine Hardware-APIs an. Stattdessen definiert sie eine klare Java-API. Persistenz erfolgt optional über das Dateisystem des Hosts.

*Randbedingungen:* Keine ausführbare „Fat-JAR"-Anwendung als Liefergegenstand; Lieferobjekt ist Quelltext plus Dokumentation. Keine Cloud; mit W3W; Optionale Datenminderung durch optimierungs Algorithmen.

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
  "Das System muss auf Anfrage die aktuelle Zielrichtung (geografischer Azimut in Grad), die Entfernung zum Ziel in Metern sowie eine diskrete Himmelsrichtung (N, NE, E, SE, S, SW, W, NW) liefern.",
)

#lf-card(
  "/LF060/",
  "Peilung regulär beenden",
  "Projektauftrag SWE",
  "/LF110/, /LF120/",
  "Host-App",
  "Die Peilungskomponente muss beendet werden und im anschluss daran den GPS-Trak in GPX-Form (nach GPX 1.1) zurückgeben Nach regulärem Abschluss sind keine weiteren Positionsupdates zulässig.",
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
  "Das System muss Ereignisse für Start, Update, Abschluss und Fehler über registrierte Listener veröffentlichen. Die Listener-Benachrichtigung erfolgt synchron oder konfigurierbar serialisiert.",
)

#lf-card(
  "/LF090/",
  "Fehler semantisch klassifizieren",
  "Qualitätsrichtlinie",
  "/LL010/",
  "Host-App",
  "Das System muss Eingabe-, Zustands- und I/O-Fehler über eine klar dokumentierte Exception-Hierarchie unterscheidbar machen. Jede Exception enthält einen maschinenlesbaren Fehlercode.",
)


=== GPS-Track und Sampling (/LF100/)

#lf-card(
  "/LF100/",
  "GPS-Punkte aufzeichnen",
  "Projektauftrag SWE",
  "/LF030/",
  "Host-App",
  "Das System muss während einer aktiven Peilung GPS-Punkte mit Zeitstempel speichern. Jeder gespeicherte Punkt enthält mindestens: Zeitstempel, Breitengrad, Längengrad.",
)

#lf-card(
  "/LF110/",
  "Zeitintervall konfigurieren",
  "Klärungsgespräch",
  "/LF100/",
  "Host-App",
  "Der Nutzer muss das Zeitintervall, in wechem die GPS-Punkte gespeichert werden manuel ändern können. Der konfigurierbare Bereich umfässt dabei 0,5 Sekunden bis 60 Sekunden. Der Defaultwert beträgt 2 Sekunden.",
)

#lf-card(
  "/LF120/",
  "Punktbudget konfigurieren",
  "Klärungsgespräch",
  "/LF100/",
  "Host-App",
  "Die Peilungskomponente muss eine Obergrenze für die Anzahl gespeicherter GPS-Punkte pro Peilung unterstützen. Bei überschreitung des Limits, werden durch werwendung von optimierungs Algorithmen, die Anzahl an GPS-Punkte verringert. Nach möglichkeit ohne das Informationen über die Strecke verlohren gehen. So werden beispielsweiße gerade Strecken mit lediglich zwei GPS-Punkten dargestellt.",
)

#lf-card(
  "/LF130/",
  "HDOP/Satelliten auswerten",
  "Klärungsgespräch",
  "/LF100/, /LL020/",
  "Host-App",
  "Das System muss optional Punkte mit einem HDOP-Wert über einem konfigurierbaren Schwellwert (Standard: HDOP ≤ 5,0) verwerfen oder als unzuverlässig markieren, abhängig von der Konfiguration.",
)

#lf-card(
  "/LF140/",
  "Geschwindigkeits-Sprünge erkennen",
  "Datenqualitätsrichtlinie",
  "/LF100/",
  "Host-App",
  "Das System muss unrealistische Positions-Sprünge erkennen, die physikalisch nicht möglich sind (z. B. mehr als 300 km/h Geschwindigkeitsänderung), und diese gemäß konfigurierter Policy verwerfen.",
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
  "/LF160/",
  "Deduplizierung von Punkten",
  "Qualitätsrichtlinie",
  "/LF100/",
  "Host-App",
  "Das System muss identische Koordinaten mit identischem Zeitstempel nicht mehrfach als separate logische Messung speichern. Duplikate werden erkannt und gelöscht.",
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
  "Das System muss aus einer abgeschlossenen oder abgebrochenen Session einen GPX-1.1-konformen Datenstrom erzeugen können. Die Ausgabe muss den GPX-1.1-Namespace `http://www.topografix.com/GPX/1/1` enthalten.",
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
  "Das System muss eine punktbasierte Reduktionsstrategie implementieren, die nur jeden n-ten Punkt behält. Start- und Endpunkt des Tracks werden dabei stets erhalten.",
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
  "Das System muss nahezu kollineare Punktfolgen innerhalb eines konfigurierbaren Toleranzbandes auf Start- und Endpunkt reduzieren können. Eine Garantie für enge Kurvenradien besteht explizit nicht.",
)

#lf-card(
  "/LF270/",
  "Optimierung: Douglas–Peucker (optional)",
  "Erweiterungsanforderung (1+)",
  "/LF200/",
  "Host-App",
  "Das System muss optional den Douglas–Peucker-Algorithmus mit konfigurierbarer metrischer Toleranz (Epsilon in Metern) für die Track-Vereinfachung anbieten. Die Strategie ist über die Strategy-Schnittstelle austauschbar.",
)

#lf-card(
  "/LF280/",
  "What3Words auflösen",
  "Klärungsgespräch",
  "/LF050/",
  "Host-App",
  "Das System muss optional Koordinaten in eine What3Words-Adresse auflösen, sofern ein gültiger API-Key und Netzwerkzugang vorhanden sind. Bei Fehler oder fehlenden Credentials wird ein definierter Fallback geliefert.",
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
  "Mathematik / Geodäsie",
  "/LL010/",
  "Host-App",
  "Das System muss Breiten- und Längengrade auf den WGS84-Zulässigkeitsbereich prüfen (Breitengrad: −90° bis +90°, Längengrad: −180° bis +180°). Ungültige Werte führen zu einer IllegalArgumentException.",
)

#lf-card(
  "/LF310/",
  "Zeitstempel validieren",
  "GPS-Realität",
  "/LF100/",
  "Host-App",
  "Das System muss Zeitstempel ablehnen, die in der Zukunft liegen oder älter als ein konfigurierbarer Schwellwert sind (Standard: 24 Stunden). Ungültige Zeitstempel werden mit einem semantisch klassifizierten Fehler zurückgewiesen.",
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
  "Das System muss jeden Datenverlust oder jede Aggregation durch strukturierte Log-Einträge (mindestens Level WARN) nachvollziehbar machen. Stille Verwürfe sind nicht zulässig.",
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
  "Das System muss in der Javadoc klar angeben, welche Methoden thread-sicher sind. Der Standardbetrieb sieht vor, dass ein einzelner Host-Thread die Session steuert. Abweichungen sind explizit zu kennzeichnen.",
)


=== Ergänzende funktionale Anforderungen (/LF400/)

#lf-card(
  "/LF400/",
  "Konfiguration beim Start validieren",
  "Robustheitsrichtlinie",
  "/LF010/",
  "Host-App",
  "Das System muss beim Sessionstart prüfen, dass alle Konfigurationswerte zulässig sind (z. B. Intervall > 0, Punktbudget > 0, kein negativer HDOP-Schwellwert). Ungültige Kombinationen führen zu einem Fehler vor Sessionstart.",
)

#lf-card(
  "/LF410/",
  "Konfiguration einfrieren",
  "SWE Best Practice",
  "/LF010/",
  "Host-App",
  "Das System muss die Konfiguration nach dem Start einer Session unveränderlich einfrieren. Nachträgliche Änderungsversuche müssen abgewiesen werden. Dies gewährleistet konsistentes Verhalten über die gesamte Session-Laufzeit.",
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
  "–",
  "Team",
  "Das System darf keinerlei Klassen aus UI-Frameworks (AWT, Swing, JavaFX, Android-UI etc.) referenzieren. Die Bibliothek ist reine Logik- und I/O-Schicht.",
)

#lf-card(
  "/LF440/",
  "Java-Version",
  "Rahmenbedingung",
  "–",
  "Team",
  "Das System muss mit Java 11 oder höher kompilierbar sein, ohne Verwendung von APIs, die in späteren Versionen entfernt wurden (`sun.*`-Klassen, deprecated APIs).",
)

#lf-card(
  "/LF450/",
  "Build-Tooling",
  "Abgabeanforderung",
  "–",
  "Team",
  "Das System muss per Maven (`mvn test`) ohne manuelle Zwischenschritte vollständig kompilierbar und testbar sein. Alle Abhängigkeiten sind über Maven Central auflösbar.",
)

#lf-card(
  "/LF460/",
  "Zeitstempel in UTC normalisieren",
  "GPS-Standard",
  "/LF100/",
  "Host-App",
  "Das System muss alle Zeitstempel intern als `java.time.Instant` (UTC) verarbeiten. Die Konvertierung in lokale Zeitzone ist ausschließlich Aufgabe des Hosts.",
)

#lf-card(
  "/LF470/",
  "Null-sichere öffentliche API",
  "Qualitätsrichtlinie",
  "–",
  "Host-App",
  "Das System muss in der gesamten öffentlichen API die Null-Semantik in Javadoc explizit festlegen. Rückgabewerte, die leer sein können, sind als `Optional<T>` zu deklarieren. Dies ist durch Tests abzusichern.",
)

#lf-card(
  "/LF480/",
  "Optimierer austauschbar halten",
  "Erweiterungsanforderung (1+)",
  "/LF240/–/LF270/",
  "Team",
  "Das System muss alle Optimierungsstrategien über eine gemeinsame Strategy-Schnittstelle (`TrackOptimizer`) austauschbar halten, sodass zukünftige Algorithmen ohne Änderung der Kernklassen integrierbar sind.",
)

#lf-card(
  "/LF490/",
  "GPX-Generierung von Post-Processing trennen",
  "Wartbarkeitsrichtlinie",
  "/LF200/",
  "Team",
  "Das System muss die GPX-Serialisierung von optionalen Post-Processing-Schritten (Optimierung, Metadaten-Anreicherung) strukturell trennen, um unabhängige Erweiterbarkeit beider Aspekte zu gewährleisten.",
)

#lf-card(
  "/LF500/",
  "Statistikobjekt nach Abschluss",
  "Erweiterungsanforderung (1+)",
  "/LF060/",
  "Host-App",
  "Das System muss nach regulärem oder abgebrochenem Abschluss einer Session ein Statistikobjekt bereitstellen, das mindestens Gesamtdistanz in Metern, Gesamtdauer und Anzahl gespeicherter Punkte enthält.",
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Produktdaten
// ─────────────────────────────────────────────────────────────────────────────

Die folgenden Produktdaten beschreiben die persistenten bzw. transportierten Datenstrukturen der Bibliothek. Der Begriff „Persistenz" bezieht sich sowohl auf GPX-Exportartefakte als auch auf temporäre Dateien beim atomaren Schreibvorgang.

#ld-card(
  "/LD100/",
  "Peilungs-Session",
  "/LF010/, /LF070/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [sessionId], [UUID (36 Zeichen)],
      [status], [Enum: ACTIVE, COMPLETED, ABORTED],
      [target], [GeoCoordinate (Zielposition)],
      [startedAt], [Instant (UTC)],
      [endedAt], [Optional\<Instant\>],
      [config], [SessionConfig (immutable)],
    )
  ],
)

#ld-card(
  "/LD110/",
  "Konfiguration (SessionConfig)",
  "/LF400/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [samplingIntervalMs], [long (Standard: 2000 ms)],
      [softLimitPoints], [int (Optional, 0 = deaktiviert)],
      [hardLimitPoints], [int (Optional, 0 = deaktiviert)],
      [hdopThreshold], [double (Standard: 5.0)],
      [persistOnAbort], [boolean (Standard: false)],
      [w3wApiKey], [Optional\<String\>],
    )
  ],
)

#ld-card(
  "/LD120/",
  "GPS-Track",
  "/LF100/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [segments], [List\<TrackSegment\>],
      [totalPoints], [int (abgeleitete Kennzahl)],
      [timeRange], [Optional\<Duration\>],
    )
  ],
)

#ld-card(
  "/LD130/",
  "GPS-Punkt (GpsPoint)",
  "/LF100/, /LF150/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [lat], [double (−90° bis +90°)],
      [lon], [double (−180° bis +180°)],
      [time], [Instant (UTC, Pflichtfeld)],
      [ele], [Optional\<Double\> (Höhe in m)],
      [hdop], [Optional\<Double\>],
      [speed], [Optional\<Double\> (m/s)],
    )
  ],
)

#ld-card(
  "/LD140/",
  "Peilungs-Snapshot (BearingSnapshot)",
  "/LF050/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [azimuthDeg], [double (0° bis 360°)],
      [distanceM], [double (Meter)],
      [compassOrdinal], [Enum: N, NE, E, SE, S, SW, W, NW],
      [bearingErrorDeg], [Optional\<Double\>],
    )
  ],
)

#ld-card(
  "/LD150/",
  "GPX-Dokument",
  "/LF200/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [xmlNamespace], [GPX 1.1 URI (Pflicht)],
      [metadata], [GpxMetadata],
      [trk], [Liste von trkpt-Elementen],
      [encoding], [UTF-8 (fest)],
    )
  ],
)

#ld-card(
  "/LD160/",
  "GPX-Metadaten (GpxMetadata)",
  "/LF210/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [name], [Optional\<String\> (200 Zeichen)],
      [desc], [Optional\<String\>],
      [author], [Optional\<String\>],
      [timeBounds], [Optional (start/end Instant)],
    )
  ],
)

#ld-card(
  "/LD170/",
  "Optimierungsergebnis",
  "/LF240/–/LF270/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [originalCount], [int],
      [optimizedCount], [int],
      [appliedStrategies], [List\<String\>],
      [epsilonMeters], [Optional\<Double\>],
    )
  ],
)

#ld-card(
  "/LD180/",
  "W3W-Cache-Eintrag",
  "/LF290/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [lat], [double],
      [lon], [double],
      [words], [String (drei Wörter)],
      [resolvedAt], [Instant],
      [ttl], [Duration],
    )
  ],
)

#ld-card(
  "/LD190/",
  "Fehlerprotokoll-Eintrag",
  "/LF330/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [timestamp], [Instant],
      [errorCode], [String (maschinenlesbar)],
      [context], [String (menschenlesbar)],
      [sessionId], [Optional\<UUID\>],
      [stacktrace], [Optional\<String\>],
    )
  ],
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Nichtfunktionale Anforderungen
// ─────────────────────────────────────────────────────────────────────────────

=== Leistungs- und Performanceanforderungen (/LL010/)

#ll-card(
  "/LL010/",
  "Robustheit und Eingabevalidierung",
  "Qualitätsrichtlinie",
  "/LF300/, /LF310/",
  "Ungültige Eingaben dürfen keine undefinierten Zustände erzeugen. Alle Fehlerpfade werden durch negative Testfälle und optional durch Mutationstests (PIT) abgesichert.",
)

#ll-card(
  "/LL020/",
  "Genauigkeit der Peilungsberechnung",
  "Fachanforderung",
  "/LF050/",
  "Für Distanzen über 10 m darf der berechnete Azimut maximal ±1° von einer Referenzimplementierung (Haversine-Formel) abweichen. Die Überprüfung erfolgt anhand definierter Referenzpunkte (Äquator, Polnähe, Stuttgart).",
)

#ll-card(
  "/LL030/",
  "Performance der Peilungsberechnung",
  "Echtzeit-Anforderung",
  "/LF030/",
  "Ein vollständiger Update-Zyklus (Positionsupdate → Azimut/Distanz berechnen) soll auf üblicher Laptop-Hardware typischerweise deutlich unter 1 ms liegen. Der dokumentierte Worst-Case-Grenzwert beträgt 100 ms ohne GC-Pause.",
)

#ll-card(
  "/LL040/",
  "Performance des GPX-Exports",
  "Performanceanforderung",
  "/LF200/",
  "Der GPX-Export für 10.000 Punkte ohne Douglas–Peucker-Optimierung soll auf Laptop-Hardware in unter 2 Sekunden erfolgen. Dieser Richtwert ist zu dokumentieren und in einem Benchmark-Test zu messen.",
)

#ll-card(
  "/LL050/",
  "Speicherverbrauch",
  "Ressourcenanforderung",
  "/LF180/",
  "Für einen Track mit 10.000 Punkten soll der Heap-Zuwachs der Bibliothek typischerweise unter 50 MB bleiben. Dieser Richtwert ist durch einen Profiling-Test zu validieren.",
)



=== Externe Schnittstellen (/LL100/)

#ll-card(
  "/LL100/",
  "Wartbarkeit und Dokumentationsqualität",
  "Vorlesung SWE",
  "–",
  "Die gesamte öffentliche API muss vollständig mit Javadoc dokumentiert sein. Ein Checkstyle-Plugin im Maven-Build prüft die Einhaltung der Dokumentationsregeln. Fehlende Javadoc führen zu einem Build-Fehler.",
)

#ll-card(
  "/LL110/",
  "Portabilität",
  "Projektauftrag",
  "–",
  "Die Bibliothek darf keine plattformspezifischen Pfade, Zeilentrennzeichen oder `sun.*`-APIs verwenden. Sie muss auf Windows, macOS und Linux ohne Anpassungen kompilierbar und ausführbar sein.",
)

#ll-card(
  "/LL120/",
  "Übertragbarkeit / Build-Reproduzierbarkeit",
  "Projektauftrag",
  "–",
  "Der Maven-Build muss auf einem frisch geklonten Repository ohne manuelle Schritte außer einer JDK-Installation (Java 11+) erfolgreich durchlaufen. Kein Zugriff auf lokale Systemkonfigurationen ist erlaubt.",
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
  "Lehrauftrag",
  "/LF340/",
  "Die Kernmodule (bearing-core, gps-tracker, gpx-exporter) müssen gemäß Spezifikation eine Zeilenabdeckung von mindestens 85 % erreichen. Für kritische Domänenklassen (Session-Lebenszyklus, Peilungsberechnung) gilt ein Mindestwert von 90 %.",
)

#ll-card(
  "/LL160/",
  "Wiederanlauf nach Exception",
  "Betriebsanforderung",
  "–",
  "Nach einer unerwarteten Exception muss die Komponenteninstanz in einen definierten Leerlaufzustand zurückkehren können, ohne dass ein Neustart der JVM erforderlich ist. Der Zustand IDLE muss erreichbar sein.",
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
  "Energieeffizienz des Samplings",
  "Betriebsanforderung",
  "–",
  "Das Sampling-Intervall soll so gestaltet sein, dass keine unnötig hohen Punktmengen erzeugt werden, die die Batterie des Host-Geräts belasten. Der Standardwert von 2 Sekunden stellt einen Kompromiss aus Genauigkeit und Effizienz dar.",
)

#ll-card(
  "/LL190/",
  "Determinismus bei gleichen Eingaben",
  "Qualitätsanforderung",
  "–",
  "Gleiche Eingabesequenzen mit festem `Clock`-Mock führen stets zum selben Track und denselben GPX-Ausgaben. Nicht-deterministische Verhaltensweisen in Kernpfaden sind nicht zulässig.",
)

#ll-card(
  "/LL200/",
  "Abhängigkeitslizenzierung",
  "Rechtliche Anforderung",
  "–",
  "Im Standard-Build dürfen nur permissiv lizenzierte Bibliotheken (Apache 2.0, MIT, BSD) verwendet werden. Die W3W-Client-Abhängigkeit ist optional und nur im Maven-Profil `w3w` aktiviert.",
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Qualitätsanforderungen
// ─────────────────────────────────────────────────────────────────────────────

Die Qualitätskriterien wurden in Anlehnung an die ISO/IEC 9126 / ISO/IEC 25010 ausgewählt und gewichtet. Die Gewichtung spiegelt den Schwerpunkt der Bibliothek als reine Logik-Komponente ohne eigene UI wider.
#let category-rows = (1, 8, 13, 19, 23, 29)

#table(
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
