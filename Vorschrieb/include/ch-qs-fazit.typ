#import "macros.typ": diagramm-box

#let ch-qs-fazit-kapitel = [
#set par(justify: true)

Die Qualitätssicherung folgt einem *V-Modell-light*: Für die zentral implementierten `/LF`-Anforderungen existieren dokumentierte Testfälle; nicht abgedeckte Anforderungen sind in der Traceability als Review-/Restpunkt gekennzeichnet. Nicht-funktionale Anforderungen werden dort, wo messbar, per Mikrobenchmark oder Architekturtest abgesichert.

== Teststrategie

*Ebenen:*

+ *Unit-Tests:* isolierte Klassen mit Mocks/Fakes für `ClockPort`, `W3wClientPort`, Dateisystem (Jimfs oder temporäre Verzeichnisse).
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
  [TC-010], [Doppel-`start` ohne `complete`], [`IllegalStateException`, Zustand konsistent], [/LF020/],
  [TC-020], [Lat = 91° übergeben], [`ValidationException`], [/LF300/],
  [TC-030], [Happy Path `start` → Updates → `complete`], [GPX-Namespace vorhanden, Statistik gefüllt], [/LF010/, /LF030/, /LF060/, /LF200/],
  [TC-040], [Listener registrieren + Positionsupdate], [Start-/Update-Callback wird ausgelöst], [/LF080/],
  [TC-050], [`complete` + `reset` + erneutes `start`], [Wiederanlauf in ACTIVE], [/LL160/],
  [TC-090], [Pfad `../../etc/passwd` bei Persistenz], [`SecurityException`], [/LF320/],
  [TC-100], [GPX-Namespace direkt am Writer prüfen], [Deklaration `http://www.topografix.com/GPX/1/1`], [/LF200/],
  [TC-110], [n-Optimierer `n=10`, 100 Punkte], [Optimierername enthalten, Punktanzahl reduziert], [/LF240/],
  [TC-120], [SafeFileSink in Jimfs schreibt relativ zu Base], [Dateiinhalt entspricht Nutzlast], [/LF220/],
  [TC-130], [Haversine-Referenzpunkte], [Distanz/Ordinal plausibel], [/LL020/],
)

#pagebreak()

== Traceability-Matrix (Auszug)

#table(
  columns: (1.8cm, 2.4cm, 2.4cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 5pt,
  [*`/LF`*], [*Modul*], [*Test-ID*], [*Methode*],
  [/LF010/], [`bearing-api`], [TC-030], [`happyPathCompleteProducesGpx`],
  [/LF020/], [`bearing-api`], [TC-010], [`tc010_doubleStartThrows`],
  [/LF080/], [`bearing-api`], [TC-040], [`listenerInvoked`],
  [/LF200/], [`bearing-adapter-gpx`], [TC-100], [`containsGpx11Namespace`],
  [/LF220/], [`bearing-adapter-system`], [TC-120], [`writesInsideBase`],
  [/LF320/], [`bearing-api`], [TC-090], [`tc090_pathTraversalSecurity`],
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

Nicht jedes Maven-Modul besitzt aktuell einen `src/test/java`-Baum. Tests liegen derzeit schwerpunktmäßig in `bearing-api` und `bearing-domain`; adapter-spezifische Checks sind punktuell in API-nahen Tests enthalten.

#diagramm-box("Abdeckungsziele (JaCoCo)")[
  Kernmodule `bearing-api`, `bearing-domain`, `bearing-adapter-gpx`: Zeilenabdeckung ≥ 85 % (`/LL150/`).\
  Kritische Klassen `BearingSession`, `BearingCalculator`: ≥ 90 %.
]

#pagebreak()

= Fazit

== Zusammenfassung der Ergebnisse

Die vorliegende Dokumentation spezifiziert eine UI-freie Java-Komponente, die Peilungsfunktionalität inklusive GPX-1.1-Track-Export bereitstellt. Alle zentralen Begriffe sind im Glossar normiert. Anforderungen sind SOPHIST-konform formuliert, traceable und testbar. Der Grobentwurf definiert Schichten und Muster; das Pflichtenheft verfeinert Abläufe durch Aktivitäts- und Sequenzbeschreibungen sowie ein objektorientiertes Domänenmodell.

*Offene Punkte für spätere Versionen:* Ellipsoidische Distanzberechnung (Vincenty) als präzisere Alternative zur Kugelapproximation; magnetische Deklination als optionales Modul; erweiterte Map-Matching-Filter in Kurven.

#pagebreak()
]
