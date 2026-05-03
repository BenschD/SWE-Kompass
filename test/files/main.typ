// ═════════════════════════════════════════════════════════════════════════════
// Java-Kompass mit GPX-Track und What3Words-Anbindung
// Softwareengineering-Projektdokumentation
// DHBW Stuttgart – Informatik
// Autoren: Moritz Pfitzenmaier, Marius Müllmaier, Daniel Bensch
// ═════════════════════════════════════════════════════════════════════════════

#let titel             = "Java-Kompass mit GPX-Track und What3Words-Anbindung"
#let autoren           = "Moritz Pfitzenmaier, Marius Müllmaier, Daniel Bensch"
#let autor             = autoren
#let kurzthema         = "Softwareengineering – Projektdokumentation"

#let abgabedatum = datetime(
  year:  2026,
  month: 06,
  day:   12,
)

#set document(title: titel, author: autor, date: abgabedatum)
#set page(
  paper:        "a4",
  number-align: right + bottom,
  margin:       (inside: 2.5cm, outside: 2.5cm, y: 2cm),
)
#set text(size: 14pt, lang: "de")

// ─────────────────────────────────────────────────────────────────────────────
// DECKBLATT
// ─────────────────────────────────────────────────────────────────────────────

#import "templates.typ": deckblatt

#show: deckblatt.with(
  titel:               titel,
  studiengang:         "Informatik",
  standort:            "Stuttgart",
  autoren:             ((name: autor),),
  abgabedatum:         abgabedatum,
  bearbeitungszeitraum:"April 2026 – Juni 2026",
  martikelnummer:      "8829906, 1341874, 5133713",
)

// ─────────────────────────────────────────────────────────────────────────────
// KOPF- UND FUSSZEILE
// ─────────────────────────────────────────────────────────────────────────────

#counter(page).update(1)
#set page(
  numbering: "i",
  header: rect(height: 100%, inset: 0mm, stroke: none)[
    #set align(top)
    #set text(11pt)
    #grid(
      columns: (auto, 1fr, auto),
      rows:    (4cm),
      align:   horizon,
      //image("images/DHBW_Logo.png", height: 1cm),
      h(1fr),
      box([
        #set align(right)
        #context {
          let headings      = query(heading.where(level: 1))
          let current-page  = here().page()
          let active        = headings.filter(h => h.location().page() <= current-page)
          if active.len() > 0 { active.last().body } else { kurzthema }
        }
      ])
    )
  ],
  footer: rect(height: 100%, inset: 0mm, stroke: none)[
    #set text(11pt)
    #grid(
      columns: (auto, 1fr, auto),
      rows:    (1cm),
      align:   horizon,
      box([#set align(left); #autoren]),
      h(1fr),
      box([#set align(right); #context { counter(page).display() }]),
    )
  ],
)

#show heading: set text(rgb("#d90000"))
#show heading: set block(below: 1em)

// ═════════════════════════════════════════════════════════════════════════════
// FRONTMATTER
// ═════════════════════════════════════════════════════════════════════════════

= Abstract

Die präzise Bestimmung von Richtung und Entfernung zu einem Zielpunkt ist eine alltägliche Aufgabe in der mobilen Navigation. Die iOS-Anwendung _Kompass Professional_ bietet hierfür eine etablierte fachliche Orientierung, doch ihre Peilungslogik ist fest mit der grafischen Oberfläche und der Hardwareanbindung verknüpft. Diese Arbeit löst die Kernfunktionalität aus diesem Gesamtkontext heraus und überführt sie in eine eigenständige, UI-freie Java-Bibliothek.

Im Mittelpunkt steht die robuste Berechnung von Azimut, Distanz und diskreter Himmelsrichtung auf Basis von WGS84-Koordinaten. Die Bibliothek verarbeitet Positions- und Kursdaten, die ein Host-System liefert. Ein kontrollierbarer Session-Lebenszyklus ermöglicht das Aufzeichnen, Unterbrechen und Fortsetzen von Tracks, wobei die Daten durch konfigurierbare Reduktionsstrategien effizient gehalten werden. Der Export erfolgt standardkonform im GPX-Format Version 1.1. Zusätzlich lässt sich der What3Words-Dienst optional anbinden.

Neben der Implementierung als Maven-Projekt legt die Arbeit besonderen Wert auf eine nachvollziehbare Spezifikation nach IEEE 830: Die Anforderungen sind SOPHIST-konform formuliert und durchgängig prüfbar. Nicht-funktionale sowie objektorientierte Analyse- und Entwurfsartefakte begleiten die Architektur. Ein umfassendes Qualitätssicherungskonzept mit automatisierten Testfällen und vollständiger Traceability sichert die reproduzierbare Abnahme der Bibliothek.

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

// ═════════════════════════════════════════════════════════════════════════════
// HAUPTTEIL – Nummerierung und Absatzformatierung
// ═════════════════════════════════════════════════════════════════════════════

#set heading(numbering: "1.1.1 ")
#set par(spacing: 2em, justify: true)

#set page(numbering: "1")
#counter(page).update(1)
#show math.equation: set align(center)

// ═════════════════════════════════════════════════════════════════════════════
// KAPITEL 1 – EINLEITUNG
// ═════════════════════════════════════════════════════════════════════════════

= Einleitung

#import "ch-einleitung.typ": ch-einleitung-kapitel
#ch-einleitung-kapitel

// ═════════════════════════════════════════════════════════════════════════════
// KAPITEL 2 – ALLGEMEINE BESCHREIBUNG
// ═════════════════════════════════════════════════════════════════════════════

= Allgemeine Beschreibung

#import "ch-allgemeine-beschreibung.typ": ch-allgemeine-beschreibung-kapitel
#ch-allgemeine-beschreibung-kapitel

// ═════════════════════════════════════════════════════════════════════════════
// KAPITEL 3 – SPEZIFISCHE ANFORDERUNGEN
// ═════════════════════════════════════════════════════════════════════════════

= Spezifische Anforderungen

#import "ch-spezifische-anforderungen.typ": ch-spezifische-anforderungen-kapitel
#ch-spezifische-anforderungen-kapitel

// ═════════════════════════════════════════════════════════════════════════════
// ANHANG
// ═════════════════════════════════════════════════════════════════════════════

= Anhang

#import "ch-anhang.typ": ch-anhang-kapitel
#ch-anhang-kapitel
