// Kompakte LF-Karte für überschaubare Anforderungen (Optimierer, Validierung, …)

#import "lf-card.typ": lf-card
#import "lf-diagram.typ": lf-sonstiges

#let lf-compact(id, funktion, beschreibung, verweise: (), code: "") = {
  lf-card(
    id: id,
    funktion: funktion,
    akteur: [Host-App (Primär).],
    verweise: verweise,
    beschreibung: beschreibung,
    ausloeser: [Siehe Standardablauf; Aufruf über Session-API oder Domain-Service.],
    vorbedingung: [Session `ACTIVE` sofern Session-bezogen; sonst keine.],
    nach_erfolg: [Anforderung erfüllt; kein undefinierter Zustand.],
    nach_fehler: [Fachliche Ausnahme gemäß API (`ValidationException`, `IllegalStateException`, `SecurityException`).],
    standardablauf: [
      1. Host oder Export-Pipeline ruft die zugehörige Komponente auf.\
      2. System führt die in der Beschreibung genannte Logik aus.\
      3. Ergebnis wird zurückgegeben oder persistiert.
    ],
    alternativablauf: [Ungültige Eingabe: passende `ValidationException` oder `IllegalStateException`.],
    sonstiges: lf-sonstiges(
      systemgrenzen: [Kein UI; kein direkter Hardwarezugriff.],
      speziell: if code != "" { [Implementierung: `#code`.] } else { [Siehe Traceability-Matrix.] },
      bemerkungen: [Normiert in `requirement-catalog.typ`.],
    ),
  )
}
