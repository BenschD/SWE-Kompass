// ═════════════════════════════════════════════════════════════════════════════
// uc-card.typ  –  Normierte Use-Case-Karte im ID-Card-Stil
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
//  Farbdefinitionen
// ─────────────────────────────────────────────────────────────────────────────
#let uc-hdr    = rgb("#1a2e45")   // Kopfzeilen-Hintergrund (dunkelblau)
#let uc-label  = rgb("#f0f4f8")   // Hintergrund der Label-Spalte
#let uc-border = rgb("#d0d8e4")   // Rahmen / Zeilentrennlinien
#let uc-stripe = rgb("#f7fafd")   // leichte Zeile (Zebra)
#let uc-white  = rgb("#ffffff")
#let uc-dark   = rgb("#1a2e45")   // Schrift dunkel
#let uc-mid    = rgb("#4a6080")   // Schrift mittel (Labels)
#let uc-desc   = rgb("#e8f0f8")   // Beschreibungs-Streifen
#let uc-warn   = rgb("#fffbeb")   // Fußzeile Hintergrund (gelb-hell)
#let uc-warn-b = rgb("#f59e0b")   // Fußzeile Rand / Badge (amber)
#let uc-warn-t = rgb("#92400e")   // Fußzeile Text (dunkelbraun)

// ─────────────────────────────────────────────────────────────────────────────
//  Hilfsmakros  (alle rein in Code-Modus – kein Markup-Block-Problem)
// ─────────────────────────────────────────────────────────────────────────────

// Prioritäts-Badge
#let _prio-badge(p) = {
  let bg = if lower(p).contains("sehr") { rgb("#e8373d") }
           else if lower(p).contains("hoch") { rgb("#d97706") }
           else { rgb("#4a6080") }
  box(
    inset:  (x: 8pt, y: 3pt),
    radius: 3pt,
    fill:   bg,
    text(fill: white, size: 8pt, weight: "bold", tracking: 0.8pt, upper(p))
  )
}

// Abschnitts-Trennbalken (gibt ein table.cell zurück)
#let uc-section(titel) = table.cell(
  colspan: 2,
  fill:    uc-hdr,
  inset:   (x: 10pt, y: 4pt),
  box(
    inset:  (x: 6pt, y: 1.5pt),
    radius: 2pt,
    fill:   white.transparentize(75%),
    text(fill: white, size: 8pt, weight: "bold", tracking: 1pt, upper(titel))
  )
)

// Eine Zeile: Label (grau) | Wert (weiß / gestreift)
#let uc-row(label, body, zebra: false) = {
  let bg  = if zebra { uc-stripe } else { uc-white }
  let str = (top: 0.5pt + uc-border, bottom: none, left: none, right: none)
  (
    table.cell(fill: uc-label, stroke: str,
      text(fill: uc-mid, size: 8.5pt, weight: "bold", tracking: 0.6pt, upper(label))
    ),
    table.cell(fill: bg, stroke: str,
      text(fill: uc-dark, size: 10pt, body)
    ),
  )
}

// ─────────────────────────────────────────────────────────────────────────────
//  Haupt-Makro: uc-card
//  Strategie: gesamten Innen-Inhalt in Code-Blöcken {…} vorbauen,
//  dann als Argument an block() übergeben → kein Markup-Modus-Problem.
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

  // ── Kopfzeile ─────────────────────────────────────────────────────────────
  let hdr = block(
    width: 100%,
    fill:  uc-hdr,
    inset: 0pt,
    grid(
      columns: (1fr, auto),
      inset:   (x: 14pt, y: 10pt),
      align(left + horizon,
        text(fill: white, size: 13pt, weight: "bold", nummer)
      ),
      align(right + horizon,
        if prioritaet != "" { _prio-badge(prioritaet) }
      ),
    )
  )

  // ── Beschreibungs-Streifen ────────────────────────────────────────────────
  let desc = block(
    width:  100%,
    fill:   uc-desc,
    inset:  (x: 14pt, y: 9pt),
    stroke: (bottom: 0.5pt + uc-border),
    text(fill: uc-dark, size: 10.5pt, style: "italic", beschreibung)
  )

  // ── Priorität-Zeilen-Inhalt ───────────────────────────────────────────────
  let prio-content = {
    if prioritaet != "" { _prio-badge(prioritaet) }
    h(6pt)
    text(size: 10pt, prioritaet)
  }

  // ── Haupttabelle ──────────────────────────────────────────────────────────
  let tbl = table(
    columns: (2.8cm, 1fr),
    stroke:  none,
    inset:   (x: 10pt, y: 7pt),
    align:   left + top,

    ..uc-row("Referenzen", referenzen,  zebra: false),
    ..uc-row("Akteure",    akteure,     zebra: true),
    ..uc-row("Auslöser",   ausloeser,   zebra: false),

    uc-section("Bedingungen"),
    ..uc-row("Vorbedingungen",  vorbedingungen,  zebra: true),
    ..uc-row("Nachbedingungen", nachbedingungen, zebra: false),
    ..uc-row("Systemgrenzen",   systemgrenzen,   zebra: true),

    uc-section("Abläufe"),
    ..uc-row("Standardablauf",      standardablauf, zebra: false),
    ..uc-row("Alternative Abläufe", alternativ,     zebra: true),

    uc-section("Ergebnisse & Anforderungen"),
    ..uc-row("Erwartete Ergebnisse", ergebnisse,              zebra: false),
    ..uc-row("Spez. Anforderungen",  spezielle-anforderungen, zebra: true),

    uc-section("Metadaten"),
    ..uc-row("Häufigkeit", haeufigkeit,  zebra: false),
    ..uc-row("Priorität",  prio-content, zebra: true),
  )

  // ── Fußzeile (Bemerkungen) ────────────────────────────────────────────────
  let footer = if bemerkungen != "" {
    block(
      width:  100%,
      fill:   uc-warn,
      inset:  (x: 12pt, y: 8pt),
      stroke: (top: 1pt + uc-warn-b),
      grid(
        columns:       (auto, 1fr),
        column-gutter: 10pt,
        align:         left + top,
        box(
          inset:  (x: 6pt, y: 2pt),
          radius: 3pt,
          fill:   uc-warn-b,
          text(fill: white, size: 8pt, weight: "bold", [HINWEIS])
        ),
        text(fill: uc-warn-t, size: 10pt, bemerkungen),
      )
    )
  }

  // ── Äußerer Rahmen – Inhalt als Code-Variable übergeben ───────────────────
  let inner = {
    hdr
    desc
    tbl
    footer
  }

  block(
    width:     100%,
    breakable: true,
    stroke:    1pt + uc-border,
    radius:    5pt,
    clip:      true,
    inner,
  )
}
