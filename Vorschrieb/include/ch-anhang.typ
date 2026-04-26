#let ch-anhang-kapitel = [
#set par(justify: true)

== Nicht im Lieferumfang (Out of Scope)

Die folgenden ehemals formulierten funktionalen Anforderungen werden in dieser Bibliotheksversion *nicht* umgesetzt. Begründung: Die Komponente speichert jeden validierten GNSS-Fix unverändert im Roh-Track; Qualitätsfilterung, Abtastlogik und Dublettenbereinigung obliegen der *Host-Anwendung* oder einem späteren Release. Die IDs bleiben zur Nachverfolgbarkeit gegenüber älteren Dokumentversionen erhalten.

#table(
  columns: (1.6cm, 2.4cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*ID*], [*Kurztitel*], [*Hinweis*],
  [/LF110/], [Zeitintervall / Abtastung], [Kein konfigurierbares Speicherintervall in der Bibliothek; Host steuert Aufrufhäufigkeit von `onPositionUpdate`.],
  [/LF130/], [HDOP / Satelliten], [HDOP-Felder werden in GPX durchgereicht, keine automatische Verwerfung beim Einlesen.],
  [/LF140/], [Geschwindigkeitssprünge], [Keine implizite Geschwindigkeitsprüfung im Rohspeicher.],
  [/LF160/], [Duplikate], [Identische Messungen werden nicht still entfernt.],
)

#pagebreak()

== Vorlesungs-Themen-Matrix (Abdeckung SWE)

Die folgende Matrix ordnet typische Inhalte der Softwareengineering-Vorlesung (beide Semester, zusammenfassend) den Dokumentations- und Implementationsartefakten dieses Projekts zu. Sie dient der expliziten Abdeckung der in der Aufgabenstellung genannten Anforderung, *alle* Themengebiete sinnvoll einzubringen.

#table(
  columns: (3.2cm, 1fr, 2.6cm),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 5pt,
  [*Themenfeld*], [*Projektbezug*], [*Artefakt/Ort*],
  [Requirements Engineering], [SOPHIST-Regeln, `/LF`/`/LL`/`/LD`, Traceability], [Kap. Analyse, Matrixen],
  [Lastenheft/Pflichtenheft], [Zielhierarchie, Spezifikation], [Kap. Analyse, Kap. Spezifikation],
  [Use-Case-Modellierung], [UC-01–UC-12, Narrative], [Pflichtenheft],
  [Aktivitätsdiagramme], [textuelle UML-Abbilder], [Pflichtenheft],
  [Sequenzdiagramme], [Export- und Fehlerpfade], [Pflichtenheft],
  [Zustandsdiagramme], [Session-Lebenszyklus], [Pflichtenheft],
  [OOA/OOD], [Domänenmodell, Klassentabelle], [Pflichtenheft],
  [Entwurfsmuster], [Strategy, Observer, Builder, Factory], [Grobentwurf, Code],
  [Schichtenarchitektur], [API, Domain, Infrastructure], [Grobentwurf],
  [Qualitätsmodelle], [ISO/IEC 25010 Gewichtung], [Analyse],
  [Nicht-funktionale Anforderungen], [Performance, Sicherheit, Portabilität], [Analyse `/LL`],
  [Testen], [JUnit, Coverage, FMEA], [Kap. QS],
  [Konfigurationsmanagement], [Maven, Profile], [Anhang, `/LF450/`],
  [Risikomanagement], [FMEA-Tabelle], [Kap. QS],
  [Dokumentationsstandards], [IEEE/ISO Bezug, Javadoc-Pflicht], [Analyse, `/LL100/`],
  [Sicherheit], [Path Traversal, XML-Escaping], [Analyse `/LF320/`, `/LL130/`],
  [Performance Engineering], [Mikrobenchmark-Vorgaben], [Analyse `/LL030/`, `/LL040/`],
)

#pagebreak()

== Literatur- und Normenverweise (Auswahl)

Die folgende Liste erschöpft nicht alle im Text genannten URLs, bildet aber die *primären* technischen Anker für Prüfung und Weiterentwicklung ab.

#table(
  columns: (2.4cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 6pt,
  [*Quelle*], [*Kontext im Projekt*],
  [ISO/IEC/IEEE 29148:2018], [Requirements Engineering, Traceability],
  [ISO/IEC 25010:2011], [Produktqualitätsmodell],
  [IEEE 830-1998], [Software Requirements Specifications (historisch)],
  [GPX 1.1 Schema], [XML-Export, Namespace `http://www.topografix.com/GPX/1/1`],
  [WGS84 / EPSG:4326], [Koordinatenreferenz],
  [What3words API Docs], [optionales Reverse-Lookup],
  [OWASP], [Path Traversal, XML-Sicherheit],
  [Gamma et al.: Design Patterns], [Strategy, Observer, Builder],
  [Bloch: Effective Java], [Immutability, Exceptions, API-Design],
  [JUnit 5 User Guide], [Teststrategie],
  [SLF4J Manual], [Beobachtbarkeit],
)

#pagebreak()

== Vollständige Use-Case-Liste (Erweiterung)

Die tabellarische Kurzfassung im Pflichtenheft wird hier um narrative Akzeptanzkriterien ergänzt.

#table(
  columns: (1.5cm, 2.4cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 5pt,
  [*UC*], [*Trigger*], [*Akzeptanzkriterien*],
  [UC-08], [W3W-Key fehlt], [Fallback-String, kein Netzwerkaufruf],
  [UC-09], [Netzwerk timeout W3W], [WARN-Log, Fallback],
  [UC-10], [GPX nur Bytes], [`byte[]` UTF-8 ohne BOM optional dokumentiert],
  [UC-11], [Listener wirft], [Exception wird gefangen, Session konsistent],
  [UC-12], [Reset nach Fehler], [IDLE erreichbar, /LL160/],
)

#pagebreak()

== Haversine- und Azimutberechnung (Referenzalgorithmus)

*Eingabe:* Breite/Länge Standort und Ziel (in Radiant für die trigonometrischen Funktionen).\
*Zwischenschritte:* Differenzen der Breiten- und Längengrade; Haversine-Formel für den Zentriwinkel; Multiplikation mit dem Erdradius $R$ für die Distanz $d$.\
*Azimut:* `atan2`-Formel aus Längendifferenz und Breiten, anschließend Normalisierung auf den Bereich von 0° bis unter 360°.

*Hinweis zur Dokumentation:* Die Darstellung dient der Übereinstimmung mit `/LL020/` (Referenzabweichung). Die Implementierung nutzt `double` und muss Grenzfälle (identische Punkte, Polnähe) explizit absichern.

#pagebreak()

== Douglas–Peucker auf Kugeloberfläche (Hinweis für 1+-Erweiterung)

Klassisches Douglas–Peucker arbeitet in der Ebene. Für lange Tracks auf der Erdkugel sollte die Metrik entweder in *lokaler Tangentialebene* (ECEF-Projektion pro Segment) oder über *Chordal-Distanzen* approximiert werden. Die Spezifikation `/LF270/` verlangt eine *metrische Toleranz in Metern* – die Implementierung muss daher die Parametrisierung dokumentieren (z. B. Epsilon als geodätische Näherung).

#pagebreak()

== Review-Checkliste „Bohl-Kriterien“ (Selbstaudit)

+ Keine User Stories als Ersatz für normierte Anforderungen.
+ Anforderungen sichtbar: `/LF`, `/LL`, `/LD` durchgängig.
+ Spezifikation präziser als Analyse: Use Cases, Zustände, Sequenzen.
+ Objektorientierte Analyse: Domänenmodell separat von Technik.
+ Aktivitätsdiagramm-Material vorhanden (textuell oder grafisch).
+ Testfälle abgegeben, nachvollziehbar benannt.
+ Quellcode per Maven ohne manuelle Schritte.
+ Keine UI in Bibliothek.
+ Abbruch liefert GPX-Daten (nicht zwingend Datei).

#pagebreak()

== Erweiterte Traceability-Matrix (Auszug 2)

#table(
  columns: (1.8cm, 2.2cm, 3cm, 1fr),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 5pt,
  [*`/LF`*], [*OOA-Konzept*], [*OOD-Klasse*], [*Test-Cluster*],
  [/LF060/], [`Export`], [`GpxExportMapper` + `GpxXmlWriter`], [TC-GPX-01..03],
  [/LF100/], [`Standortfolge`], [`TrackAggregator`], [TC-TRACK-01..05],
  [/LF280/], [externe Referenz], [`W3wClientPort` / `W3wHttpClient`], [TC-W3W-01..03],
)

#pagebreak()

== Glossar-Index (Schlagwort → Abschnitt)

#table(
  columns: (3cm, 4cm),
  stroke: 0.45pt + rgb("#9a9a9a"),
  inset: 5pt,
  [*Begriff*], [*Vorkommen*],
  [Peilung], [Glossar; Lastenheft /LF010/–/LF050/],
  [GPX 1.1], [Glossar; /LF200/; Anhang Normen],
  [SOPHIST], [Lastenheft Einleitung; Pflichtenheft Schablonen],
  [Strategy], [Grobentwurf; /LF480/],
  [Abort], [UC-05; /LF070/],
)

#pagebreak()

== Versionshinweis Dokument

*Version:* 1.0-Draft für Abgabe.\
*Werkzeugkette:* Typst-Quelle (`main.typ`) erzeugt PDF; Maven erzeugt Java-Artefakte.\
*Hinweis Seitenzahl:* Die Mindestvorgabe von 50 Seiten setzt voraus, dass die PDF-Ausgabe vollständig gerendert wird; bei Abweichungen Schriftgrad oder Anhänge anpassen.

#pagebreak()
]
