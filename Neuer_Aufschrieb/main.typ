#import "template.typ": project

#show: project.with(
  title: "Software Engineering Projekt",
  subtitle: "Systemspezifikation und Anforderungsanalyse der Peilungskomponente",
  authors: ("Max Mustermann", "Erika Musterfrau")
)

// Hier werden die ausgelagerten Kapitel eingebunden
#include "01-einleitung.typ"
#include "02-allgemeine_beschreibung.typ"
#include "03-spezifische_anforderungen.typ"