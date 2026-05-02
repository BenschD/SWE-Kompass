// ─────────────────────────────────────────────────────────────────────────────
// Makros: Begriffskarten (Definition, Gültigkeit, Bezeichnung, Quellverweis)
// ─────────────────────────────────────────────────────────────────────────────

#let _b-fill   = rgb("#f4f7fb")
#let _b-stroke = rgb("#c8d4e6")

/// Normierte Begriffskarte für Glossar und Haupttext.
#let begriffskarte(
  begriff,
  definition,
  abgrenzung,
  gueltigkeit,
  bezeichnung,
  quelle,
) = {
  v(1em)
  set text(size: 11pt)
  block(breakable: false, width: 100%)[
    #table(
      columns: (auto, 1fr),
      stroke: 0.5pt + _b-stroke,
      fill: (x, _y) => if x == 0 { _b-fill } else { white },
      inset: (x: 10pt, y: 8pt),
      align: (left + top),
      [*Begriff*],              [*#begriff*],
      [*Definition*],           [#definition],
      [*Abgrenzung*],           [#abgrenzung],
      [*Gültigkeit*],           [#gueltigkeit],
      [#box[*Bezeichnung / Symbol*]], [#bezeichnung],
      [*Quellverweis*],         [#quelle],
    )
  ]
}

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
