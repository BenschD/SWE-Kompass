// ═════════════════════════════════════════════════════════════════════════════
// lf-diagram.typ    Aktivitätsdiagramme für /LF…/-Anforderungen (reines Typst)
// Keine externen Pakete — kompiliert offline ohne Typst Universe.
// ═════════════════════════════════════════════════════════════════════════════

#let _node-stroke = 0.8pt + rgb("#1a1a1a")
#let _pill-fill  = rgb("#e8e8e8")
#let _err-fill   = rgb("#f0f0f0")

#let _lf-pill(body, fill: _pill-fill, width: 2.4cm) = box(
  width: width,
  inset: (x: 8pt, y: 5pt),
  stroke: _node-stroke,
  fill: fill,
  radius: 999pt,
)[#align(center)[#body]]

#let _lf-rect(body, width: 5.2cm) = box(
  width: width,
  inset: (x: 8pt, y: 6pt),
  stroke: _node-stroke,
  fill: white,
  radius: 0pt,
)[#align(center)[#body]]

#let _lf-diamond(body, width: 3.4cm) = {
  let inner = 2.1cm
  box(width: width)[
    #align(center)[
      #rotate(45deg, reflow: true)[
        #box(
          width: inner,
          height: inner,
          stroke: _node-stroke,
          fill: white,
        )[]
      ]
      #place(center + horizon)[
        #box(width: width - 6pt)[#align(center)[#body]]
      ]
    ]
  ]
}

/// Einzelner Content-Block oder Tupel → immer iterierbares Array.
#let _coerce-steps(xs) = {
  if type(xs) == array { xs } else { (xs,) }
}

#let _lf-arrow(label: none) = {
  v(1pt)
  if label != none {
    align(center)[#text(size: 7pt)[#label]]
    v(1pt)
  }
  align(center)[#text(size: 11pt, fill: rgb("#1a1a1a"))[↓]]
  v(1pt)
}

#let _lf-step-chain(steps) = {
  for step in _coerce-steps(steps) {
    _lf-arrow()
    _lf-rect(step)
  }
}

#let _lf-linear(steps) = stack(
  dir: ttb,
  spacing: 0.35em,
  _lf-pill([Start]),
  _lf-step-chain(steps),
  _lf-arrow(),
  _lf-pill([Ende]),
)

#let _lf-end-decision(steps, decision, error-label) = stack(
  dir: ttb,
  spacing: 0.35em,
  _lf-pill([Start]),
  _lf-step-chain(steps),
  _lf-arrow(),
  _lf-diamond(decision),
  grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 10pt,
    row-gutter: 0pt,
    align: center + horizon,
    stack(
      dir: ttb,
      spacing: 0.2em,
      text(size: 7pt)[#error-label],
      _lf-pill([Abbruch], fill: _err-fill, width: 2cm),
    ),
    [],
    stack(
      dir: ttb,
      spacing: 0.2em,
      text(size: 7pt)[ja],
      _lf-pill([Ende]),
    ),
  ),
)

#let _lf-mid-decision(steps, decision, steps-after, error-label, branch-fail) = stack(
  dir: ttb,
  spacing: 0.35em,
  _lf-pill([Start]),
  _lf-step-chain(steps),
  _lf-arrow(),
  _lf-diamond(decision),
  grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 10pt,
    align: center + horizon,
    stack(
      dir: ttb,
      spacing: 0.2em,
      text(size: 7pt)[#error-label],
      _lf-pill(branch-fail, fill: _err-fill, width: 2.4cm),
    ),
    [],
    stack(
      dir: ttb,
      spacing: 0.35em,
      text(size: 7pt)[ja],
      _lf-step-chain(steps-after),
      _lf-arrow(),
      _lf-pill([Ende]),
    ),
  ),
)

/// Linearer Aktivitätsdiagramm-Wrapper (Standardablauf + optionale Entscheidung).
#let lf-flowchart(
  id,
  steps,
  decision: none,
  error-label: [Fehler],
  steps-after: (),
  branch-fail: none,
) = {
  let steps-n = _coerce-steps(steps)
  let after-n = _coerce-steps(steps-after)
  v(0.6em)
  figure(
    caption: [Aktivitätsdiagramm #id],
    kind: image,
    align(center)[
      #set text(size: 8pt)
      #if decision != none and after-n.len() > 0 and branch-fail != none {
        _lf-mid-decision(steps-n, decision, after-n, error-label, branch-fail)
      } else if decision != none {
        _lf-end-decision(steps-n, decision, error-label)
      } else {
        _lf-linear(steps-n)
      }
    ],
  )
  v(0.4em)
}

/// Explizites Diagramm: Schritte als Inhalts-Liste (ohne Fletcher-Syntax).
#let lf-flowchart-custom(id: "", ..steps) = {
  lf-flowchart(id: id, steps: steps.pos())
}

/// Baut Sonstiges-Feld aus Metadaten (Systemgrenzen, spezielle Anforderungen, Hinweise).
#let lf-sonstiges(systemgrenzen: none, speziell: none, bemerkungen: none) = {
  let sep = [#linebreak(), #linebreak()]
  let parts = (
    if systemgrenzen != none { ([*Systemgrenzen:* #systemgrenzen],) } else { () }
  ) + (
    if speziell != none { ([*Spezielle Anforderungen:* #speziell],) } else { () }
  ) + (
    if bemerkungen != none { ([*Hinweise:* #bemerkungen],) } else { () }
  )
  if parts.len() == 0 { none } else { parts.join(sep) }
}
