// ═════════════════════════════════════════════════════════════════════════════
// lf-sonstiges.typ   Metadaten-Helfer für LF-Karten (SOPHIST Sonstiges-Feld)
// ═════════════════════════════════════════════════════════════════════════════

/// Baut Sonstiges-Feld aus Metadaten (Systemgrenzen, spezielle Anforderungen, Hinweise).
#let lf-sonstiges(systemgrenzen: none, speziell: none, bemerkungen: none) = {
  let sep = [#linebreak()#linebreak()]
  let parts = (
    if systemgrenzen != none { ([*Systemgrenzen:* #systemgrenzen],) } else { () }
  ) + (
    if speziell != none { ([*Spezielle Anforderungen:* #speziell],) } else { () }
  ) + (
    if bemerkungen != none { ([*Hinweise:* #bemerkungen],) } else { () }
  )
  if parts.len() == 0 { none } else { parts.join(sep) }
}
