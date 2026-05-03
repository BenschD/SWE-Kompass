// ═════════════════════════════════════════════════════════════════════════════
// uc-card.typ  –  Normierte Use-Case-Karte im ID-Card-Stil
// Fixes: keine _-Bezeichner, rgb() nur mit dezimalen Werten (kein "#…")
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
//  Farbpalette  (alle als rgb(R, G, B) — kein Hex-String)
// ─────────────────────────────────────────────────────────────────────────────
#let uc-col-hdr    = rgb(26,  46,  69)   // Nachtblau  — Header / Trennbalken
#let uc-col-accent = rgb(232, 55,  61)   // Signal-Rot — Priorität sehr hoch
#let uc-col-warn   = rgb(217, 119, 6)    // Amber      — Priorität hoch
#let uc-col-muted  = rgb(74,  96,  128)  // Grau-Blau  — Priorität sonstige
#let uc-col-label  = rgb(240, 244, 248)  // Hellgrau   — Label-Spalte
#let uc-col-stripe = rgb(247, 250, 253)  // Sehr hell  — Zebrastreifen
#let uc-col-desc   = rgb(232, 240, 248)  // Eisblau    — Beschreibungsband
#let uc-col-note   = rgb(255, 251, 235)  // Amber-Tint — Hinweis-Fußzeile
#let uc-col-amber  = rgb(245, 158, 11)   // Amber      — Hinweis-Badge
#let uc-col-brown  = rgb(146, 64,  14)   // Dunkelbraun— Hinweis-Text
#let uc-col-dark   = rgb(26,  46,  69)   // Schrift dunkel
#let uc-col-mid    = rgb(74,  96,  128)  // Schrift Labels
#let uc-col-border = rgb(208, 216, 228)  // Rahmenfarbe
#let uc-col-rowsep = rgb(225, 232, 242)  // Zeilen-Trennlinie

// ─────────────────────────────────────────────────────────────────────────────
//  Hilfsfunktion: eine Tabellenzeile -> gibt Array (label-cell, value-cell)
// ─────────────────────────────────────────────────────────────────────────────
#let uc-row(label, body, zebra: false) = {
  let bg = if zebra { uc-col-stripe } else { white }
  (
    table.cell(fill: uc-col-label, inset: (x: 9pt, y: 7pt))[
      #set align(right + top)
      #set text(fill: uc-col-mid, size: 9pt, weight: "bold")
      #upper(label)
    ],
    table.cell(fill: bg, inset: (x: 10pt, y: 7pt))[
      #set align(left + top)
      #set text(fill: uc-col-dark, size: 10pt)
      #body
    ],
  )
}

// ─────────────────────────────────────────────────────────────────────────────
//  Hilfsfunktion: Abschnitts-Trennbalken (volle Breite, colspan 2)
// ─────────────────────────────────────────────────────────────────────────────
#let uc-section(label) = table.cell(
  colspan: 2,
  fill: uc-col-hdr,
  inset: (x: 10pt, y: 5pt),
)[
  #set align(left + horizon)
  #box(
    fill: rgb(255, 255, 255, 30),
    inset: (x: 6pt, y: 2pt),
    radius: 2pt,
  )[#text(fill: white, size: 8.5pt, weight: "bold", tracking: 0.8pt)[#upper(label)]]
]

// ─────────────────────────────────────────────────────────────────────────────
//  Hilfsfunktion: Prioritäts-Badge für den Header
// ─────────────────────────────────────────────────────────────────────────────
#let uc-priority-badge(prio) = {
  if prio == "" { return none }
  let p = lower(prio)
  let bg = if p.contains("sehr")  { uc-col-accent }
      else if p.contains("hoch")  { uc-col-warn   }
      else                        { uc-col-muted   }
  box(
    fill: bg,
    inset: (x: 8pt, y: 3pt),
    radius: 3pt,
  )[#text(fill: white, size: 8.5pt, weight: "bold", tracking: 0.5pt)[#upper(prio)]]
}

// ─────────────────────────────────────────────────────────────────────────────
//  HAUPT-MAKRO: uc-card
// ─────────────────────────────────────────────────────────────────────────────
#let uc-card(
  nummer:                  "",
  referenzen:              "",
  beschreibung:            [],
  akteure:                 [],
  ausloeser:               [],
  vorbedingungen:          [],
  standardablauf:          [],
  alternativ:              [],
  ergebnisse:              [],
  nachbedingungen:         [],
  systemgrenzen:           [],
  spezielle-anforderungen: [],
  haeufigkeit:             "",
  prioritaet:              "",
  bemerkungen:             "",
) = {
  v(1em)

  block(
    width:     100%,
    breakable: true,
    stroke:    1pt + uc-col-border,
    radius:    5pt,
    clip:      true,
  )[

    // ── KOPFZEILE ─────────────────────────────────────────────────────────
    block(width: 100%, fill: uc-col-hdr, inset: 0pt)[
      #grid(
        columns: (1fr, auto),
        inset:   (x: 14pt, y: 10pt),
        align(left + horizon)[
          #text(fill: white, size: 12.5pt, weight: "bold")[#nummer]
        ],
        align(right + horizon)[
          #uc-priority-badge(prioritaet)
        ],
      )
    ]

    // ── BESCHREIBUNGSBAND ─────────────────────────────────────────────────
    block(
      width:  100%,
      fill:   uc-col-desc,
      inset:  (x: 14pt, y: 9pt),
      stroke: (bottom: 0.5pt + uc-col-border),
    )[
      #set text(fill: uc-col-dark, size: 10.5pt, style: "italic")
      #beschreibung
    ]

    // ── HAUPTTABELLE ──────────────────────────────────────────────────────
    table(
      columns: (3.5cm, 1fr),
      stroke:  (x: none, y: 0.5pt + uc-col-rowsep),
      inset:   0pt,
      align:   left + top,

      // — Abschnitt 1: Allgemein ——————————————————————————————————————————
      ..uc-row("Referenzen", referenzen,  zebra: false),
      ..uc-row("Akteure",    akteure,     zebra: true),
      ..uc-row("Auslöser",   ausloeser,   zebra: false),

      // — Abschnitt 2: Bedingungen ————————————————————————————————————————
      uc-section("Bedingungen"),
      ..uc-row("Vorbedingungen",  vorbedingungen,  zebra: true),
      ..uc-row("Nachbedingungen", nachbedingungen, zebra: false),
      ..uc-row("Systemgrenzen",   systemgrenzen,   zebra: true),

      // — Abschnitt 3: Abläufe ————————————————————————————————————————————
      uc-section("Abläufe"),
      ..uc-row("Standardablauf",      standardablauf, zebra: false),
      ..uc-row("Alternative Abläufe", alternativ,     zebra: true),

      // — Abschnitt 4: Ergebnisse & Anforderungen —————————————————————————
      uc-section("Ergebnisse & Anforderungen"),
      ..uc-row("Erwartete Ergebnisse", ergebnisse,              zebra: false),
      ..uc-row("Spez. Anforderungen",  spezielle-anforderungen, zebra: true),

      // — Abschnitt 5: Metadaten ——————————————————————————————————————————
      uc-section("Metadaten"),
      ..uc-row("Häufigkeit", haeufigkeit, zebra: false),
      ..uc-row("Priorität",  prioritaet,  zebra: true),
      ..uc-row("Referenzen", referenzen,  zebra: false),
    )

    // ── FUßZEILE: Bemerkungen ─────────────────────────────────────────────
    if type(bemerkungen) == str and bemerkungen != "" [
      #block(
        width:  100%,
        fill:   uc-col-note,
        inset:  (x: 14pt, y: 9pt),
        stroke: (top: 1pt + uc-col-amber),
      )[
        #grid(
          columns:       (auto, 1fr),
          column-gutter: 9pt,
          align:         left + top,
          box(
            fill:   uc-col-amber,
            inset:  (x: 6pt, y: 2pt),
            radius: 3pt,
          )[#text(fill: white, size: 8.5pt, weight: "bold")[HINWEIS]],
          text(fill: uc-col-brown, size: 9.5pt)[#bemerkungen],
        )
      ]
    ]
  ]
}
