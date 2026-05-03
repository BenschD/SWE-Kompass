// ═════════════════════════════════════════════════════════════════════════════
// uc-card.typ  –  Normierte Use-Case-Karte im ID-Card-Stil
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
//  Farbdefinitionen (ohne führende Unterstriche)
// ─────────────────────────────────────────────────────────────────────────────
#let uc-hdr    = rgb("#1a2e45")   // Kopfzeilen-Hintergrund
#let uc-accent = rgb("#e8373d")   // ID-Pill und Prioritäts-Badge
#let uc-label  = rgb("#f0f4f8")   // Hintergrund der Label-Spalte
#let uc-border = rgb("#d0d8e4")   // Rahmen
#let uc-stripe = rgb("#f7fafd")   // leichte Zeile (Zebra)
#let uc-white  = rgb("#ffffff")
#let uc-dark   = rgb("#1a2e45")   // Schrift dunkel
#let uc-mid    = rgb("#4a6080")   // Schrift mittel (Labels)
#let uc-code   = rgb("#e8f0f8")   // Inline-Code-Hintergrund

// ─────────────────────────────────────────────────────────────────────────────
//  Hilfsmakros
// ─────────────────────────────────────────────────────────────────────────────

// Kompakter Inline-Tag (z. B. für Priorität, Status)
#let uc-badge(txt, bg: rgb("#e8373d"), fg: white) = box(
  inset: (x: 6pt, y: 2pt),
  radius: 3pt,
  fill: bg,
)[#text(fill: fg, weight: "bold", size: 9pt)[#txt]]

// Schmale Trennlinie zwischen Abschnitten
#let uc-divider = line(length: 100%, stroke: 0.5pt + uc-border)

// Eine Zeile im Body: Label links (grau), Inhalt rechts
#let uc-row(label, body, zebra: false) = {
  let bg = if zebra { uc-stripe } else { uc-white }
  ( 
    table.cell(fill: uc-label)[
      #set text(fill: uc-mid, size: 9.5pt, weight: "bold")
      #upper(label)
    ],
    table.cell(fill: bg)[
      #set text(fill: uc-dark, size: 10pt)
      #body
    ]
  )
}

// ─────────────────────────────────────────────────────────────────────────────
//  Haupt-Makro: uc-card
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

  // ── Äußerer Rahmen ────────────────────────────────────────────────────────
  block(
    width:  100%,
    breakable: true,
    stroke: 1pt + uc-border,
    radius: 5pt,
    clip:   true,
  )[

    // ── KOPFZEILE ─────────────────────────────────────────────────────────
    block(width: 100%, fill: uc-hdr, inset: 0pt)[ 
      #grid(
        columns: (1fr, auto),
        rows:    (auto),
        inset:   (x: 12pt, y: 10pt),

        // Links: UC-Nummer und Name
        align(left + horizon)[
          #text(
            fill:   white,
            size:   13pt,
            weight: "bold",
            font:   "Helvetica Neue",
          )[#nummer]
        ],

        // Rechts: Prioritäts-Badge
        align(right + horizon)[
          #if prioritaet != "" {
            let bg = if lower(prioritaet).contains("sehr") { rgb("#e8373d") }
                     else if lower(prioritaet).contains("hoch") { rgb("#d97706") }
                     else { rgb("#4a6080") }
            box(
              inset: (x: 8pt, y: 3pt),
              radius: 3pt,
              fill:  bg,
            )[#text(fill: white, size: 9pt, weight: "bold")[#upper(prioritaet)]]
          }
        ],
      )
    ]

    // ── BESCHREIBUNGS-STREIFEN ─────────────────────────────────────────────
    block(
      width: 100%,
      fill: rgb(232, 240, 248),
      inset: (x: 12pt, y: 8pt),
    )[
      #set text(fill: uc-dark, size: 10.5pt, style: "italic")
      #beschreibung
    ]

    // ── HAUPTTABELLE ──────────────────────────────────────────────────────
    set text(size: 10pt)
    table(
      columns: (3.4cm, 1fr),
      stroke:  none,
      inset:   (x: 10pt, y: 7pt),
      align:   (x, ) => if x == 0 { right + top } else { left + top },

      ..uc-row("Referenzen",   referenzen,  zebra: false),
      ..uc-row("Akteure",      akteure,      zebra: true),
      ..uc-row("Auslöser",     ausloeser,    zebra: false),

      // ── Trennbalken: Vor-/Nachbedingungen ─────────────────────────────
      table.cell(colspan: 2, fill: uc-hdr, inset: (x: 10pt, y: 4pt))[
        #text(fill: white, size: 9pt, weight: "bold")[
          #box(
            inset: (x: 5pt, y: 1pt),
            radius: 2pt,
            fill: white.transparentize(80%),
          )[BEDINGUNGEN]
        ]
      ],

      ..uc-row("Vorbedingungen",  vorbedingungen,  zebra: true),
      ..uc-row("Nachbedingungen", nachbedingungen, zebra: false),
      ..uc-row("Systemgrenzen",   systemgrenzen,   zebra: true),

      // ── Trennbalken: Abläufe ──────────────────────────────────────────
      table.cell(colspan: 2, fill: uc-hdr, inset: (x: 10pt, y: 4pt))[
        #text(fill: white, size: 9pt, weight: "bold")[
          #box(
            inset: (x: 5pt, y: 1pt),
            radius: 2pt,
            fill: white.transparentize(80%),
          )[ABLÄUFE]
        ]
      ],

      ..uc-row("Standardablauf",      standardablauf, zebra: false),
      ..uc-row("Alternative Abläufe", alternativ,     zebra: true),

      // ── Trennbalken: Ergebnisse & Anforderungen ───────────────────────
      table.cell(colspan: 2, fill: uc-hdr, inset: (x: 10pt, y: 4pt))[
        #text(fill: white, size: 9pt, weight: "bold")[
          #box(
            inset: (x: 5pt, y: 1pt),
            radius: 2pt,
            fill: white.transparentize(80%),
          )[ERGEBNISSE & ANFORDERUNGEN]
        ]
      ],

      ..uc-row("Erwartete Ergebnisse",       ergebnisse,              zebra: false),
      ..uc-row("Spezielle Anforderungen",    spezielle-anforderungen, zebra: true),

      // ── Trennbalken: Metadaten ────────────────────────────────────────
      table.cell(colspan: 2, fill: uc-hdr, inset: (x: 10pt, y: 4pt))[
        #text(fill: white, size: 9pt, weight: "bold")[
          #box(
            inset: (x: 5pt, y: 1pt),
            radius: 2pt,
            fill: white.transparentize(80%),
          )[METADATEN]
        ]
      ],

      ..uc-row("Häufigkeit",  haeufigkeit, zebra: false),
      ..uc-row("Referenzen",  referenzen,  zebra: true),
    )

    // ── FUSSZEILE: Bemerkungen ─────────────────────────────────────────────
    if bemerkungen != "" and bemerkungen != [] {
      block(
        width: 100%,
        fill:  rgb(255, 251, 235),
        inset: (x: 12pt, y: 8pt),
        stroke: (top: 0.5pt + rgb(245, 158, 11)),
      )[
        #grid(
          columns: (auto, 1fr),
          column-gutter: 8pt,
          align: left + top,
          // Hinweis-Symbol
          box(
            inset: (x: 5pt, y: 2pt),
            radius: 3pt,
            fill: rgb("#f59e0b"),
          )[#text(fill: white, size: 9pt, weight: "bold")[HINWEIS]],
          text(fill: rgb("#92400e"), size: 9.5pt)[#bemerkungen],
        )
      ]
    }
  ]
}