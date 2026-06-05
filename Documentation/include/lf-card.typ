// ═════════════════════════════════════════════════════════════════════════════
// lf-card.typ  –  Funktionale Anforderung (/LF…/, /LL…/)
// Layout identisch zu ll-card in ch-spezifische-anforderungen.typ
// ═════════════════════════════════════════════════════════════════════════════

#let _rf     = rgb("#d6e9f8")
#let _stroke = 0.5pt + rgb("#AAAAAA")
#let _ins    = (x: 7pt, y: 6pt)

#let _lf-section(title) = table.cell(
  colspan: 4,
  fill: _rf,
  inset: _ins,
  text(weight: "bold", size: 10pt)[#title],
)

#let _lf-wide(label, body) = (
  [#label],
  table.cell(colspan: 3)[#body],
)

#let _lf-pair(label-a, body-a, label-b, body-b) = (
  [#label-a],
  [#body-a],
  table.cell(fill: _rf)[#label-b],
  [#body-b],
)

/// Normierte Karte für eine funktionale Anforderung /LF…/ bzw. /LL…/.
#let lf-card(
  id: "",
  funktion: "",
  akteur: [],
  verweise: [],
  einbindungen: [---],
  datenzugriffe: [---],
  beschreibung: [],
  ausloeser: [],
  vorbedingung: [],
  nach_erfolg: [],
  nach_fehler: [],
  standardablauf: [],
  alternativablauf: [],
  sonstiges: none,
) = {
  let sonstiges-body = if sonstiges != none { sonstiges } else { [---] }
  let row-count = 14
  v(0.6em)
  table(
    columns: (1.9cm, 2.7cm, 1fr, 2.3cm, 1fr),
    stroke: _stroke,
    fill: (x, _y) => if x == 0 or x == 1 { _rf } else { white },
    inset: _ins,
    align: (x, _y) => if x <= 1 { center + horizon } else { left + top },
    table.cell(rowspan: row-count)[
      #set align(center + horizon)
      #text(weight: "bold", size: 10pt)[#id]
    ],
    _lf-section("Allgemein"),
    .._lf-wide("Funktion", funktion),
    .._lf-pair("Akteur", akteur, "Verweise", verweise),
    .._lf-pair("Include", einbindungen, "Datenzugriffe", datenzugriffe),
    .._lf-wide("Beschreibung", beschreibung),
    _lf-section("Funktionsbedingungen"),
    .._lf-wide("Auslöser", ausloeser),
    .._lf-wide("Vorbedingung", vorbedingung),
    .._lf-wide("Nachbedingungen (Erfolg)", nach_erfolg),
    .._lf-wide("Nachbedingungen (Fehler)", nach_fehler),
    _lf-section("Funktionsablauf"),
    .._lf-wide("Standardablauf", standardablauf),
    .._lf-wide("Alternativablauf", alternativablauf),
    .._lf-wide("Sonstiges", sonstiges-body),
  )
  v(0.4em)
}
