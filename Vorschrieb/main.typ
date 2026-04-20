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
== Zielsetzung
== Abgrenzung und Scope
== Stakeholder-Analyse

= Anforderungsanalyse (Business Requirements / Lastenheft)
== Zielbestimmung und Produkteinsatz
== Funktionale Anforderungen
== Produktdaten
== Nichtfunktionale Anforderungen
=== Leistungs- und Performanceanforderungen
=== Externe Schnittstellen
== Qualitätsanforderungen

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
