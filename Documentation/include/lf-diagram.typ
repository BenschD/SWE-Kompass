// ═════════════════════════════════════════════════════════════════════════════
// lf-diagram.typ   Aktivitäts-/Zustandsdiagramme als vorbereitete SVG
// Quellen: Documentation/diagrams/mermaid/*.mmd
// Rendern: pwsh Documentation/diagrams/render-diagrams.ps1
// ═════════════════════════════════════════════════════════════════════════════

#let _svg-dir = "../diagrams/svg"

#let _diagram-svg(name) = {
  _svg-dir + "/" + name + ".svg"
}

#let _svg-figure(caption, name, width: 100%, height: auto) = {
  v(0.4em)
  figure(
    caption: caption,
    kind: image,
    block(breakable: false, width: 100%)[
      #align(center)[
        #image(_diagram-svg(name), width: width, height: height, fit: "contain")
      ]
    ],
  )
  v(0.4em)
}

/// Aktivitätsdiagramm für /LF…/ (SVG-Dateistamm ohne Endung).
/// Standard `width: 100%`. Kleiner: `#lf-flowchart("/LF020/", "lf_020", width: 50%)`.
#let lf-flowchart(id, svg-name, width: 100%, height: auto) = {
  _svg-figure([Aktivitätsdiagramm #id], svg-name, width: width, height: height)
}

/// Beliebiges Mermaid-Diagramm (SVG-Dateistamm ohne Endung).
#let mermaid-figure(caption, svg-name, width: 100%, height: auto) = {
  _svg-figure(caption, svg-name, width: width, height: height)
}

/// Zustandsdiagramm Session-Lebenszyklus.
#let zustandsdiagramm-session(
  caption: [Zustandsdiagramm des Session-Lebenszyklus.],
  svg-name: "session_state",
  width: 100%,
  height: auto,
) = {
  _svg-figure(caption, svg-name, width: width, height: height)
}
