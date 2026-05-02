#let project(title: "", subtitle: "", authors: (), body) = {
  // Metadaten
  set document(author: authors, title: title)
  
  // Seitenlayout
  set page(
    paper: "a4",
    margin: (inside: 2.5cm, outside: 2.5cm, top: 2.5cm, bottom: 3cm),
    numbering: "1",
    number-align: right + bottom,
    header: align(right)[#text(size: 9pt, fill: luma(120))[#title]]
  )
  
  // Typografie
  set text(font: "Linux Libertine", lang: "de", size: 11pt)
  set par(justify: true, leading: 0.7em)
  set heading(numbering: "1.1")
  
  // Überschriften-Styling
  show heading: it => {
    v(1.5em)
    it
    v(0.5em)
  }

  // Deckblatt
  align(center)[
    #v(6em)
    #text(size: 26pt, weight: "bold")[#title] \
    #v(1em)
    #text(size: 16pt, fill: luma(80))[#subtitle] \
    #v(4em)
    #text(size: 12pt)[Vorgelegt von: #authors.join(", ")]
    #v(1fr)
    #text(size: 10pt)[Stand: #datetime.today().display("[day].[month].[year]")]
  ]
  
  pagebreak()
  
  // Inhaltsverzeichnis
  outline(depth: 3, title: [Inhaltsverzeichnis])
  pagebreak()

  // Hauptinhalt
  body
}