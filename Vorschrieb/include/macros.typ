// ─────────────────────────────────────────────────────────────────────────────
// Makros: Begriffskarten (Definition, Gültigkeit, Bezeichnung, Quellverweis)
// ─────────────────────────────────────────────────────────────────────────────

#let _b-fill = rgb("#f4f7fb")
#let _b-stroke = rgb("#c8d4e6")

/// Normierte Begriffskarte für Glossar und Haupttext.
/// bezeichnung: fachliche Kurzbezeichnung / Symbol / Einheit
#let begriffskarte(
  begriff,
  definition,
  gueltigkeit,
  bezeichnung,
  quelle,
) = {
  v(0.55em)
  set text(size: 11pt)
  block(breakable: true)[
    #text(weight: "bold", size: 12pt)[#begriff]
    #v(0.35em)
    #table(
      columns: (2.35cm, 1fr),
      stroke: 0.45pt + _b-stroke,
      fill: (_x, y) => if y == 0 { _b-fill } else { white },
      inset: (x: 8pt, y: 6pt),
      align: (left + top, left + top),
      [*Definition*], [#definition],
      [*Gültigkeit / Domäne*], [#gueltigkeit],
      [*Bezeichnung / Symbol*], [#bezeichnung],
      [*Quellverweis*], [#quelle],
    )
  ]
}

/// Kompakte Begriffskarte (eine Zeile Quelle) für Tabellenanhang.
#let begriff-inline(begriff, kurzdef, quelle) = [
  #strong(begriff): #kurzdef #h(0.5em) _(#quelle)_
]

/// Rahmen für UML-/Diagramm-Beschreibungen ohne externes Rendering.
#let diagramm-box(titel, body) = {
  block(
    breakable: true,
    inset: 10pt,
    stroke: 0.6pt + rgb("#666666"),
    radius: 3pt,
    width: 100%,
  )[
    #set text(size: 10.5pt)
    #text(weight: "bold")[#titel]
    #v(0.4em)
    #body
  ]
}
