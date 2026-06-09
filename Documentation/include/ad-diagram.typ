// ═════════════════════════════════════════════════════════════════════════════
// ad-diagram.typ   Mehrstufige Aktivitätsdiagramme in reinem Typst
// Keine externen Pakete — kompiliert offline ohne Typst Universe.
//
// Knoten werden als Dictionaries übergeben und vertikal verkettet:
//   (start: [Label])                       runder Startknoten
//   (ende:  [Label])                        runder Endknoten
//   (aktion: [Label])                       Aktionsrechteck im Hauptstrang
//   (optional: [Label], wenn: [Bedingung])  bedingter Schritt (gestrichelt)
//   (frage: [Label], abbruch: [Label],      Entscheidung mit Abbruch-Seitenast;
//      raus: [nein], weiter: [ja])            Hauptstrang läuft im "weiter"-Zweig
//   (frage: [Label], zweig: [Label],        Entscheidung mit Nebeneffekt-Seitenast;
//      raus: [ja], weiter: [nein])           Hauptstrang läuft unverändert weiter
// ═════════════════════════════════════════════════════════════════════════════

#let _ad-line   = 0.8pt + rgb("#2a2a2a")
#let _ad-term   = rgb("#23272e")
#let _ad-dec    = rgb("#eaf1f8")
#let _ad-opt    = rgb("#f7f7f4")
#let _ad-stop   = rgb("#f3dede")
#let _ad-arrowc = rgb("#2a2a2a")
#let _ad-w      = 6.6cm

#let _ad-pill(body, fill: rgb("#e8e8e8"), text-fill: black) = box(
  inset: (x: 12pt, y: 5pt),
  stroke: _ad-line,
  fill: fill,
  radius: 999pt,
)[#align(center)[#text(fill: text-fill, weight: "bold", size: 9pt, body)]]

#let _ad-rect(body, fill: white, dash: none) = box(
  width: _ad-w,
  inset: (x: 10pt, y: 7pt),
  stroke: (paint: rgb("#2a2a2a"), thickness: 0.8pt, dash: dash),
  fill: fill,
  radius: 2pt,
)[#align(center)[#text(size: 9pt, body)]]

#let _ad-diamond(body) = {
  let w = 3.7cm
  let inner = 2.3cm
  box(width: w, height: inner)[
    #place(center + horizon)[
      #rotate(45deg, reflow: false)[
        #box(width: inner, height: inner, stroke: _ad-line, fill: _ad-dec, radius: 2pt)[]
      ]
    ]
    #place(center + horizon)[
      #box(width: w - 6pt)[#align(center)[#text(size: 8pt, body)]]
    ]
  ]
}

// kompakter Seitenast-Knoten (Abbruch bzw. Nebeneffekt) mit fester Breite
#let _ad-side-node(body, fill: white, pill: false) = box(
  width: 3.6cm,
  inset: (x: 8pt, y: 5pt),
  stroke: _ad-line,
  fill: fill,
  radius: if pill { 6pt } else { 2pt },
)[#align(center)[#text(size: 8pt, body)]]

#let _ad-down(label: none) = {
  set align(center)
  v(2pt)
  if label != none {
    text(size: 7.5pt, fill: rgb("#555555"), label)
    v(0pt)
  }
  text(size: 13pt, fill: _ad-arrowc)[\u{2193}]
  v(2pt)
}

// horizontaler Seitenast nach rechts: → Label → Knoten
#let _ad-side(label, ziel) = {
  set align(left + horizon)
  stack(
    dir: ltr,
    spacing: 4pt,
    text(size: 13pt, fill: _ad-arrowc)[\u{2192}],
    stack(
      dir: ttb,
      spacing: 1pt,
      if label != none { text(size: 7.5pt, fill: rgb("#555555"), label) } else { [] },
      ziel,
    ),
  )
}

#let _ad-render-node(node) = {
  if "start" in node {
    _ad-pill(node.start, fill: _ad-term, text-fill: white)
  } else if "ende" in node {
    _ad-pill(node.ende, fill: _ad-term, text-fill: white)
  } else if "aktion" in node {
    _ad-rect(node.aktion)
  } else if "optional" in node {
    _ad-rect(
      [#text(size: 7pt, fill: rgb("#777777"), style: "italic")[#node.wenn] \ #node.optional],
      fill: _ad-opt, dash: "dashed",
    )
  } else if "frage" in node {
    let ziel = if "abbruch" in node {
      _ad-side-node(node.abbruch, fill: _ad-stop, pill: true)
    } else {
      _ad-side-node(node.zweig, fill: _ad-opt)
    }
    let raus-label = node.at("raus", default: none)
    grid(
      columns: (1fr, auto, 1fr),
      align: (right + horizon, center + horizon, left + horizon),
      column-gutter: 2pt,
      [],
      _ad-diamond(node.frage),
      _ad-side(raus-label, ziel),
    )
  }
}

/// Vertikales Aktivitätsdiagramm aus einer Knotenliste.
#let ad-diagramm(titel: none, caption: none, ..nodes) = {
  let ns = nodes.pos()
  v(0.4em)
  figure(
    caption: if caption != none { caption } else { [Aktivitätsdiagramm #titel] },
    kind: image,
    block(breakable: false, width: 100%)[
      #align(center)[
        #stack(
          dir: ttb,
          spacing: 0pt,
          ..ns
            .enumerate()
            .map(((i, node)) => {
              let arrow = if i == 0 {
                []
              } else {
                // Label am Pfeil: bei Entscheidung der "weiter"-Zweig
                let prev = ns.at(i - 1)
                _ad-down(label: prev.at("weiter", default: none))
              }
              stack(dir: ttb, spacing: 0pt, arrow, _ad-render-node(node))
            }),
        )
      ]
    ],
  )
  v(0.4em)
}

// ─────────────────────────────────────────────────────────────────────────────
// Zustandsdiagramm des Session-Lebenszyklus (spezifisch, parameterlos)
// ─────────────────────────────────────────────────────────────────────────────

#let _st-line  = 0.9pt + rgb("#2a2a2a")
#let _st-fill  = rgb("#eef2f7")
#let _st-state(body) = box(
  inset: (x: 14pt, y: 8pt), radius: 7pt, stroke: _st-line, fill: _st-fill,
)[#text(weight: "bold", size: 10pt, font: "DejaVu Sans Mono", body)]
#let _st-trans(label) = {
  set align(center)
  v(1pt)
  text(size: 8pt, style: "italic", fill: rgb("#444444"))[#label]
  v(-1pt)
  text(size: 14pt, fill: rgb("#2a2a2a"))[\u{2193}]
  v(1pt)
}

/// Fertiges Zustandsdiagramm des Session-Lebenszyklus (/LF010/, /LF060/, /LF070/, /LL160/).
#let zustandsdiagramm-session(caption: [Zustandsdiagramm des Session-Lebenszyklus.]) = {
  v(0.4em)
  figure(
    caption: caption,
    kind: image,
    block(breakable: false, width: 100%)[
      #align(center)[
        #stack(
          dir: ttb,
          spacing: 4pt,
          box(circle(radius: 5pt, fill: black)),
          text(size: 14pt)[\u{2193}],
          _st-state[IDLE],
          _st-trans[startSession()],
          grid(
            columns: (1fr, auto, 1fr),
            align: (right + horizon, center + horizon, left + horizon),
            column-gutter: 8pt,
            [],
            _st-state[ACTIVE],
            box[#text(size: 13pt, fill: rgb("#2a2a2a"))[\u{21BA}] #text(size: 8pt, style: "italic", fill: rgb("#444444"))[onPositionUpdate()\ onHeadingUpdate()]],
          ),
          box(width: 9.5cm)[#grid(
            columns: (1fr, 1fr),
            align: center,
            _st-trans[complete()], _st-trans[abort()],
            _st-state[COMPLETED], _st-state[ABORTED],
          )],
          text(size: 14pt, fill: rgb("#2a2a2a"))[\u{2193}],
          text(size: 8pt, style: "italic", fill: rgb("#444444"))[reset()],
          box(inset: (x: 10pt, y: 5pt), stroke: (paint: rgb("#888888"), thickness: 0.8pt, dash: "dashed"), radius: 4pt)[
            #text(size: 8.5pt, style: "italic", fill: rgb("#444444"))[führt beide Endzustände zurück nach] #text(weight: "bold", size: 9pt, font: "DejaVu Sans Mono")[IDLE]
          ],
        )
      ]
    ],
  )
  v(0.4em)
}
