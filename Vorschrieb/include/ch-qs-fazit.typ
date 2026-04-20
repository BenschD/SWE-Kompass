#import "macros.typ": diagramm-box

#let ch-qs-fazit-kapitel = [
#set par(justify: true)

Die Qualitätssicherung folgt einem *V-Modell-light*: Zu jedem signifikanten `/LF` existiert mindestens ein dokumentierter Testfall. Nicht-funktionale Anforderungen werden dort, wo messbar, per Mikrobenchmark oder Architekturtest abgesichert.

== Teststrategie

*Ebenen:*

+ *Unit-Tests:* isolierte Klassen mit Mocks für `Clock`, `W3wClient`, Dateisystem (Jimfs oder temporäre Verzeichnisse).
+ *Komponententests:* Interaktion `BearingSession` mit echtem `TrackAggregator`, aber ohne Netzwerk.
+ *Contract-Tests:* GPX-XML gegen XSD (optional im CI-Schritt).
+ *Performance-Mikrotests:* JMH oder einfache `@Timeout`-Tests mit oberen Schranken – dokumentarischer Charakter.

#pagebreak()

== Testfälle (Auszug – tabellarisch)

#table(
  columns: (1.5cm, 1fr, 2.6cm, 2cm),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 5pt,
  [*TC-ID*], [*Vorgehen*], [*Erwartung*], [*`/LF`*],
  [TC-010], [Doppel-`startSession` ohne `complete`], [Exception, Zustand konsistent], [/LF020/],
  [TC-020], [Lat = 91° übergeben], [`IllegalArgumentException`], [/LF300/],
  [TC-030], [HDOP = 9, Schwellwert 5], [Punkt wird verworfen/markiert], [/LF130/],
  [TC-040], [Zeitdelta kleiner Samplingintervall], [kein zusätzlicher Speicherpunkt], [/LF110/],
  [TC-050], [Soft-Limit erreicht], [WARN-Event], [/LF120/],
  [TC-060], [Hard-Limit erreicht], [LIMIT-Event, kontrollierter Stopp], [/LF180/],
  [TC-070], [Abort ohne persist], [GPX-String ≠ leer, keine Datei], [/LF070/, /LF230/],
  [TC-080], [Abort mit persist], [Datei existiert, atomar], [/LF220/],
  [TC-090], [Pfad `../../etc/passwd`], [`SecurityException`], [/LF320/],
  [TC-100], [GPX Namespace prüfen], [Deklaration `http://www.topografix.com/GPX/1/1`], [/LF200/],
  [TC-110], [n-Optimierer n=10, 100 Punkte], [Start/Ende erhalten, Länge reduziert], [/LF240/],
  [TC-120], [Geraden-Heuristik synthetisch], [3 kollineare Punkte → 2], [/LF260/],
  [TC-130], [Douglas–Peucker ε groß], [starke Reduktion ohne Exception], [/LF270/],
  [TC-140], [W3W Fehler API], [Fallback, kein Crash], [/LF280/],
  [TC-150], [W3W Cache TTL], [kein erneuter Netzcall innerhalb TTL], [/LF290/],
  [TC-160], [Clock mock Springe], [deterministische Zeitstempel], [/LF340/],
)

#pagebreak()

== Traceability-Matrix (Auszug)

#table(
  columns: (1.8cm, 2.4cm, 2.4cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 5pt,
  [*`/LF`*], [*Modul*], [*Test-ID*], [*Methode*],
  [/LF010/], [`bearing-core`], [TC-200], [Start Happy Path],
  [/LF050/], [`bearing-core`], [TC-210], [Snapshot gegen Referenz-Haversine],
  [/LF100/], [`gps-tracker`], [TC-040, TC-030], [Sampling/Filter],
  [/LF200/], [`gpx-exporter`], [TC-100], [XML assertions],
  [/LF320/], [`gpx-exporter`], [TC-090], [Path normalization],
)

#pagebreak()

== Fehlermöglichkeits- und Einflussanalyse (FMEA, vereinfacht)

#table(
  columns: (2.2cm, 1fr, 1.2cm, 1.2cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 5pt,
  [*Fehler*], [*Folge*], [*A*], [*E*], [*Maßnahme*],
  [Ungültige Zeit], [falsche Segmentierung], [M], [M], [Validator `/LF310/`],
  [Speicheroverflow], [OOM], [G], [K], [Hard-Limit `/LF180/`],
  [XML Injection], [Sicherheitsrisiko Host], [G], [M], [Escaping `/LL130/`],
  [Race im Listener], [inkonsistente UI], [M], [M], [Thread-Policy `/LF350/`],
)

*Legende A (Auftreten), E (Entdeckung):* S/M/G/K (stark/mittel/gering/katastrophal) – qualitativ, nicht normiert.

#pagebreak()

== Modultests – Zuordnung

Jedes Maven-Modul besitzt einen `src/test/java`-Baum. Mindestanforderung: *pro öffentlicher Klasse der Domäne* mindestens eine Testklasse oder gruppierte Testsuite. Ausnahmen nur für reine Daten-Records mit generierten Tests (equals/hashCode).

#diagramm-box("Abdeckungsziele (JaCoCo)")[
  Kernmodule `bearing-core`, `gps-tracker`, `gpx-exporter`: Zeilenabdeckung ≥ 85 % (`/LL150/`).\
  Kritische Klassen `BearingSession`, `BearingCalculator`: ≥ 90 %.
]

#pagebreak()

= Fazit

== Zusammenfassung der Ergebnisse

Die vorliegende Dokumentation spezifiziert eine UI-freie Java-Komponente, die Peilungsfunktionalität inklusive GPX-1.1-Track-Export bereitstellt. Alle zentralen Begriffe sind im Glossar normiert. Anforderungen sind SOPHIST-konform formuliert, traceable und testbar. Der Grobentwurf definiert Schichten und Muster; das Pflichtenheft verfeinert Abläufe durch Aktivitäts- und Sequenzbeschreibungen sowie ein objektorientiertes Domänenmodell.

*Offene Punkte für spätere Versionen:* Ellipsoidische Distanzberechnung (Vincenty) als präzisere Alternative zur Kugelapproximation; magnetische Deklination als optionales Modul; erweiterte Map-Matching-Filter in Kurven.

#pagebreak()
]
