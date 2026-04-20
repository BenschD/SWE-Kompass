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
Die aktuelle iOS-App „Kompass (Pro)“ verfügt über umfangreiche Peilungs- und Navigationsfunktionen[cite: 9, 23]. Im Rahmen der Projektarbeit besteht die Herausforderung darin, die Kernfunktionalität der Peilung aus der bestehenden App-Architektur herauszulösen und in eine systemneutrale, UI-lose Java-Komponente zu überführen. Dabei fehlt der ursprünglichen App bislang eine Möglichkeit, die während der Peilung zurückgelegte Strecke ressourcenschonend aufzuzeichnen und als standardisiertes Datenformat für nachgelagerte Auswertungen bereitzustellen. 

== Zielsetzung
Ziel ist die Entwicklung einer eigenständigen, schnittstellenbasierten Java-Komponente, welche die Peilungsfunktionalität (Berechnung von Richtung und Distanz) kapselt und über definierte API-Endpunkte Positions- sowie Berechnungsdaten entgegennimmt. Eine zentrale Zusatzfunktion ist die Aufzeichnung eines GPS-Tracks während der aktiven Peilung, der abschließend als optimierte GPX-Datei exportiert werden kann. Dabei sollen redundante Datenpunkte (z.B. auf Geraden) algorithmisch reduziert werden, um die Datenmenge zu minimieren. Die Umsetzung muss strikt nach objektorientierten Paradigmen und den Prinzipien des Software Engineerings (inklusive Testbarkeit) erfolgen.

== Abgrenzung und Scope
**In Scope:**
- Entwicklung einer UI-losen Java-Bibliothek/Komponente.
- Implementierung der Peilungslogik (Berechnung von Richtung und Entfernung zum Ziel)[cite: 27].
- Integration der What3Words (W3W) Funktionalität zur alternativen Zielbestimmung[cite: 26].
- Aufzeichnung von GPS-Daten (Koordinaten, Höhe, Zeitstempel, Genauigkeit, Geschwindigkeit).
- Algorithmus zur Wegpunkt-Optimierung (z.B. Reduktion einer Geraden auf Start- und Endpunkt, einstellbare Aufzeichnungsintervalle).
- Generierung strukturierter GPX-Daten (auch bei vorzeitigem Abbruch der Peilung).

**Out of Scope:**
- Entwicklung einer grafischen Benutzeroberfläche (UI).
- Umsetzung der Telematik-Dashboard-Funktionen für Motorradfahrer (Schräglage, G-Kräfte, Kurvenbeschleunigung) aus dem ursprünglichen iOS-Lastenheft[cite: 12, 25].
- Eine Turn-by-Turn-Navigation (die Peilung gibt lediglich die Richtung per Vektor/Pfeil vor).

== Stakeholder-Analyse
- **Auftraggeber / Dozent (Herr Bohl):** Legt höchsten Wert auf die formale Korrektheit der Anforderungen (SOPHIST-Regelwerk), die Anwendung von Software-Engineering-Methoden (OOA, OOD, Diagramme), fehlerfreie Kompilierbarkeit und lauffähigen Source-Code sowie detaillierte Test-Cases.
- **Entwicklerteam:** Zuständig für die Systemanalyse, die systemneutrale Implementierung in Java und die Bereitstellung der Architektur-Dokumentation.
- **Integrierende Systeme (Nutzer):** Zukünftige Java-Applikationen oder Frontends, die diese Komponente als Backend-Logik für Navigations- und Trackingzwecke einbinden.

= Anforderungsanalyse (Business Requirements / Lastenheft)
== Zielbestimmung und Produkteinsatz
Das Produkt wird als universell einsetzbare Backend-Komponente in Java konzipiert. Sie richtet sich an Softwareentwickler, die Peilungsfunktionen und GPS-Tracking in ihre eigenen Anwendungen integrieren möchten[cite: 22], ohne sich an ein spezifisches UI-Framework binden zu müssen. Der Einsatz erfolgt plattformunabhängig und fokussiert sich auf die performante, im Hintergrund ablaufende Verarbeitung von Standortdaten in unkartiertem Gelände[cite: 29].

== Funktionale Anforderungen
*Hinweis: Die funktionale Spezifikation erfolgt nach den linguistischen Regeln des SOPHIST-Regelwerks, um Eindeutigkeit und Prüfbarkeit zu garantieren.*

- **/LF010/ Empfang von Positionsdaten:** Die Komponente MUSS die Möglichkeit bieten, Positionsdaten (bestehend aus Längen- und Breitengrad, Höhe, Zeitstempel, Genauigkeit und Geschwindigkeit) über eine definierte Schnittstelle entgegenzunehmen.
- **/LF020/ Umgang mit invaliden Daten:** Die Komponente MUSS ungültige oder unvollständige GPS-Koordinaten bei der Verarbeitung selbstständig ignorieren, ohne einen Systemabbruch herbeizuführen.
- **/LF030/ Starten der Peilung:** Die Komponente MUSS die Peilungsfunktion zu einem durch das aufrufende System übergebenen Zielort starten können.
- **/LF040/ W3W-Integration:** Die Komponente MUSS die Zielbestimmung der Peilung durch die Verarbeitung von What3Words (W3W)-Adressen unterstützen[cite: 26].
- **/LF050/ GPS-Track Aufzeichnung:** Die Komponente MUSS während einer aktiven Peilung die eingehenden GPS-Datenpunkte fortlaufend aufzeichnen.
- **/LF060/ Intervallkonfiguration:** Die Komponente MUSS dem aufrufenden System die Möglichkeit bieten, das Zeit- und Distanzintervall der GPS-Aufzeichnung sowie die maximale Gesamtmenge der aufzuzeichnenden Punkte zu konfigurieren.
- **/LF070/ Wegpunkt-Optimierung:** Die Komponente MUSS die aufzuzeichnenden Datenpunkte algorithmisch optimieren (z. B. Beibehaltung von nur zwei Punkten bei einer geraden Strecke), um die Gesamtdatenmenge zu reduzieren.
- **/LF080/ GPX-Export:** Die Komponente MUSS die aufgezeichneten und optimierten GPS-Daten als strukturierte GPX-Zeichenkette zurückgeben.
- **/LF090/ Datenexport bei Abbruch:** Die Komponente MUSS sicherstellen, dass bei einem Abbruch der Peilung durch das aufrufende System alle bis zum Abbruchzeitpunkt aufgezeichneten Daten erfolgreich als GPX-Format ausgegeben werden.

== Produktdaten
- **/LD010/ GPX-Datenbestand:** Die Komponente speichert temporär Positionsdaten-Objekte. Ein Objekt umfasst zwingend die Attribute Breitengrad, Längengrad, Höhe, Zeitstempel, Genauigkeit und Geschwindigkeit.
- **/LD020/ W3W-Koordinaten-Mapping:** Die Komponente verarbeitet 3-Wort-Adressen (z.B. ///apfel.baum.haus) und hält die dazugehörigen, aufgelösten WGS84-Geokoordinaten im Speicher.
- **/LD030/ Konfigurationsparameter:** Speicherung der vom aufrufenden System übergebenen Toleranzwerte für den Optimierungsalgorithmus (z.B. Abweichungstoleranz in Metern für die Geraden-Erkennung).

== Nichtfunktionale Anforderungen
=== Leistungs- und Performanceanforderungen
- **/LL010/ Systemneutralität:** Die Komponente MUSS vollständig UI-los (ohne grafische Benutzeroberfläche) und architektonisch unabhängig in reinem Java implementiert sein.
- **/LL020/ Ausführbarkeit:** Der Quellcode der Komponente MUSS ohne komplexe Build-Systeme (keine fertigen `.jar`-Dateien) direkt über einen Java-Compiler lauffähig und ausführbar sein.
- **/LL030/ Speicher-Effizienz:** Der Datenbereinigungs-Algorithmus MUSS sicherstellen, dass die im Arbeitsspeicher gehaltenen Wegpunkte in Echtzeit optimiert werden, um bei sehr langen Peilungen den Memory-Footprint minimal zu halten.

=== Externe Schnittstellen
- **/LS010/ W3W API:** Die Komponente MUSS über eine REST-Schnittstelle mit der externen What3Words API kommunizieren, um 3-Wort-Eingaben aufzulösen.
- **/LS020/ Java API:** Die Komponente MUSS öffentliche Methodenaufrufe (Public Interfaces) bereitstellen, über die externe Systeme die Peilung steuern und die generierten GPX-Daten abgreifen können.

== Qualitätsanforderungen
- **/LQ010/ Wartbarkeit:** Die Architektur MUSS strikt nach Prinzipien der Objektorientierten Analyse und des Designs (OOA/OOD) strukturiert sein und Entwurfsmuster nutzen, wo diese sinnvoll sind.
- **/LQ020/ Testabdeckung:** Alle kritischen Module (insbesondere der Wegpunkt-Optimierungsalgorithmus und die GPX-Struktur-Generierung) MÜSSEN durch isolierte Modultests abgedeckt und dokumentiert sein.

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
