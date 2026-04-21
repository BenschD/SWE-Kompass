// ─────────────────────────────────────────────────────────────────────────────
// Makros: Begriffskarten (Definition, Gültigkeit, Bezeichnung, Quellverweis)
// ─────────────────────────────────────────────────────────────────────────────

#let _b-fill = rgb("#f4f7fb")
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

  block(breakable: true, width: 100%)[
    #table(
      // 'auto' sorgt dafür, dass die linke Spalte so breit wird wie das längste Label
      columns: (auto, 1fr), 
      stroke: 0.5pt + _b-stroke,
      fill: (x, _y) => if x == 0 { _b-fill } else { white },
      inset: (x: 10pt, y: 8pt),
      align: (left + top),
      
      // Nutze 'box', um sicherzustellen, dass die Labels NIEMALS umgebrochen werden
      [*Begriff*], [*#begriff*],
      [*Definition*], [#definition],
      [*Abgrenzung*], [#abgrenzung],
      [*Gültigkeit*], [#gueltigkeit],
      [#box[*Bezeichnung / Symbol*]], [#bezeichnung],
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
