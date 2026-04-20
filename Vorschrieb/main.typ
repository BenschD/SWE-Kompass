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
  )[
    #set align(top)
    #set text(11pt)
    #grid(
      columns: (auto, 1fr, auto),
      rows: (4cm),
      align: horizon,
      image("include\images\DHBW_Logo.png", height: 1cm),
      h(1fr),
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

////////////////////////////////
// FRONTMATTER
////////////////////////////////
= Abstract
#pagebreak()

#outline(title: "Inhaltsverzeichnis")
#pagebreak()

= Abbildungsverzeichnis
#outline(target: figure.where(kind: image), title: "")
#pagebreak()

= Tabellenverzeichnis
#outline(target: figure.where(kind: table), title: "")
#pagebreak()

= Glossar
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
== Problemstellung
== Zielsetzung
== Abgrenzung und Scope

= Grobentwurf
== Schichtendiagramm
_Grobe Darstellung der Systemarchitektur als Bindeglied zwischen Anforderungen und technischer Umsetzung._

= Anforderungsanalyse (Lastenheft)
== Zielbestimmung und Produkteinsatz
== Funktionale Anforderungen
== Produktdaten
== Nichtfunktionale Anforderungen
=== Leistungs- und Performanceanforderungen
=== Externe Schnittstellen
== Qualitätsanforderungen

= Systemspezifikation und Feinentwurf (Pflichtenheft)
== Einleitung und allgemeine Beschreibung
== Funktionale Spezifikation
=== Use Cases
=== Einzelanforderungen (Sophist-Schablonen)

== Datenmodellierung und technischer Feinentwurf
_In diesem Abschnitt werden die Datenstrukturen zusammen mit dem technischen Klassendesign definiert, um eine redundanzfreie Abbildung der Systemlogik zu gewährleisten._

=== Klassendiagramm (Struktureller Feinentwurf)

== Nichtfunktionale Spezifikation
=== Qualitätsanforderungen nach ISO/IEC 25010
=== Mengengerüst und Sicherheitsanforderungen
== Angestrebte Eigenschaften & Qualitätscheck

= Qualitätssicherung
_Die Qualitätssicherung erfolgt prozessbegleitend durch automatisierte Tests direkt auf Code-Ebene._

= Fazit
== Zusammenfassung der Ergebnisse

#pagebreak()

////////////////////////////////
// ANHANG
////////////////////////////////
= Anhang