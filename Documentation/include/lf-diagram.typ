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
  // Ganze Abbildung (Bild + Bildunterschrift) als untrennbare Einheit, damit sie
  // auch bei `show figure: set block(breakable: true)` nicht über Seiten zerreißt.
  block(breakable: false, width: 100%)[
    #v(0.5em)
    #figure(
      caption: caption,
      kind: image,
      align(center)[
        #image(_diagram-svg(name), width: 90%, height: height, fit: "contain")
      ],
    )
    #v(0.5em)
  ]
}

/// Aktivitätsdiagramm für /LF…/ (SVG-Dateistamm ohne Endung).
/// Breite Flussdiagramme: kompakte Standardbreite (68%) bei `height: auto`, damit
/// keine Leerhöhe reserviert wird. Hohe Flussdiagramme erhalten am Aufrufort eine
/// Höhenbegrenzung, z. B. `#lf-flowchart("/LF030/", "lf_030", height: 13cm)`.
#let lf-flowchart(id, svg-name, width: 68%, height: auto) = {
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
