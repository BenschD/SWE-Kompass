// ═════════════════════════════════════════════════════════════════════════════
// Java-Kompass mit GPX-Track und What3Words-Anbindung
// Softwareengineering-Projektdokumentation
// DHBW Stuttgart - Informatik
// Autoren: Moritz Pfitzenmaier, Marius Müllmaier, Daniel Bensch
// ═════════════════════════════════════════════════════════════════════════════

#let titel             = "Java-Kompass mit GPX-Track"
#let autoren           = "Moritz Pfitzenmaier, Marius Müllmaier, Daniel Bensch"
#let autor             = autoren
#let kurzthema         = "Softwareengineering - Projektdokumentation"

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
#set text(
  font:    ("New Computer Modern", "Libertinus Serif"),
  size:    11pt,
  lang:    "de",
  hyphenate: true,
)
#show raw: set text(font: "DejaVu Sans Mono", size: 0.92em)

// ─────────────────────────────────────────────────────────────────────────────
// DECKBLATT
// ─────────────────────────────────────────────────────────────────────────────

#import "include/templates.typ": deckblatt

#show: deckblatt.with(
  titel:               titel,
  studiengang:         "Informatik",
  standort:            "Stuttgart",
  autoren:             ((name: autor),),
  abgabedatum:         abgabedatum,
  bearbeitungszeitraum:"April 2026 - Juni 2026",
  matrikelnummer:      "8829906, 1341874, 5133713",
)

// ─────────────────────────────────────────────────────────────────────────────
// KOPF- UND FUSSZEILE
// ─────────────────────────────────────────────────────────────────────────────

#counter(page).update(1)
#set page(
  numbering: "i",
  header: rect(height: 100%, inset: 0mm, stroke: none)[
    #set align(top)
    #set text(9.5pt, fill: rgb("#444444"))
    #grid(
      columns: (auto, 1fr, auto),
      rows:    (4cm),
      align:   horizon,
      image("images/DHBW_Logo.png", height: 1cm),
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
    #set text(9.5pt, fill: rgb("#444444"))
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

#let dhbw-rot   = rgb("#c1121f")
#let anthrazit  = rgb("#23272e")

#show heading: set block(above: 1.4em, below: 0.9em)
#show heading.where(level: 1): set text(fill: dhbw-rot,  size: 18pt, weight: "bold")
#show heading.where(level: 2): set text(fill: anthrazit, size: 13.5pt, weight: "bold")
#show heading.where(level: 3): set text(fill: anthrazit, size: 11.5pt, weight: "bold")

// ═════════════════════════════════════════════════════════════════════════════
// FRONTMATTER
// ═════════════════════════════════════════════════════════════════════════════

= Abstract

Richtung und Entfernung zu einem Ziel zu bestimmen, gehört zu den Grundaufgaben der mobilen Navigation. Die iOS-Anwendung _Kompass Professional_ zeigt diese Peilung anschaulich, verzahnt ihre Berechnungslogik aber fest mit der Benutzeroberfläche und der Sensorhardware. Die vorliegende Arbeit löst diese Logik heraus und überführt sie in eine eigenständige Java-Bibliothek ohne Benutzeroberfläche.

Den Kern bildet die Berechnung von Azimut, Distanz und Himmelsrichtung aus WGS84-Koordinaten. Positions- und Kursdaten erhält die Bibliothek von einem Host-System, eigene Sensoren liest sie nicht. Über einen steuerbaren Session-Lebenszyklus lassen sich Tracks aufzeichnen, unterbrechen und beenden, wobei konfigurierbare Reduktionsverfahren die Datenmenge begrenzen. Den aufgezeichneten Track exportiert sie im Format GPX 1.1, optional bindet sie den Dienst What3Words an nach dem hinzufügen eines API-keys.

Neben der Implementierung als Maven-Projekt enthält die Arbeit eine Spezifikation nach IEEE 830. Alle Anforderungen sind nach den SOPHIST-Regeln formuliert und auf konkrete Testfälle rückführbar. Hinzu kommen nicht-funktionale Anforderungen, ein objektorientiertes Analyse- und Entwurfsmodell sowie automatisierte Tests, deren Bezug zu den Anforderungen eine Traceability-Matrix festhält.

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
// HAUPTTEIL - Nummerierung und Absatzformatierung
// ═════════════════════════════════════════════════════════════════════════════

#set heading(numbering: "1.1.1 ")
#set par(spacing: 1.25em, leading: 0.72em, justify: true)

#set page(numbering: "1")
#counter(page).update(1)
#show math.equation: set align(center)

// ═════════════════════════════════════════════════════════════════════════════
// KAPITEL 1 - EINLEITUNG
// ═════════════════════════════════════════════════════════════════════════════

= Einleitung

#import "include/ch-einleitung.typ": ch-einleitung-kapitel
#ch-einleitung-kapitel

// ═════════════════════════════════════════════════════════════════════════════
// KAPITEL 2 - ALLGEMEINE BESCHREIBUNG
// ═════════════════════════════════════════════════════════════════════════════

= Allgemeine Beschreibung

#import "include/ch-allgemeine-beschreibung.typ": ch-allgemeine-beschreibung-kapitel
#ch-allgemeine-beschreibung-kapitel

// ═════════════════════════════════════════════════════════════════════════════
// KAPITEL 3 - SPEZIFISCHE ANFORDERUNGEN
// ══════════════════════════════════════════════════════════════════════════════

= Spezifische Anforderungen

#import "include/ch-spezifische-anforderungen.typ": ch-spezifische-anforderungen-kapitel
#ch-spezifische-anforderungen-kapitel

// ═════════════════════════════════════════════════════════════════════════════
// ANHANG
// ═════════════════════════════════════════════════════════════════════════════

= Anhang

#import "include/ch-anhang.typ": ch-anhang-kapitel
#ch-anhang-kapitel
