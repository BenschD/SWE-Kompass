#let titel = "Titel"
#let autor = "Name"
#let kurzthema = "Thema"

#let abgabedatum = datetime(
  year: 2026,
  month: 04,
  day: 20,
)

#set document(title: titel, author: autor, date: abgabedatum)
#set page(
  paper: "a4",
  number-align: right + bottom,
  margin: (inside: 2.5cm, outside: 2.5cm, y: 2cm)
)
#set text(
  size: 14pt,
  lang: "de"
)
#set par(justify: true)

#import "include/templates.typ": deckblatt

////////////////////////////////
// DECKBLATT
////////////////////////////////

#show: deckblatt.with(
  thema: "Thema",
  titel: titel,
  studiengang: "Informatik",
  standort: "Stuttgart",
  autoren: (
    (
      name: autor,
    ),
  ),
  abgabedatum: abgabedatum,
  bearbeitungszeitraum: "01.01.2026 - 20.04.2026",
  martikelnummer: "martikel",
)
////////////////////////////////

// Kopfzeile
#counter(page).update(1)

// ==========================================
// Vorlage für Anforderungstabellen
// ==========================================
#let anforderung(id, titel, typ, prio, beschreibung, kriterien) = {
  block(
    width: 100%,
    breakable: false,
    stroke: 0.5pt + black,
    table(
      columns: (15%, 50%, 15%, 20%),
      stroke: none,
      inset: 10pt,
      fill: (col, row) => if row == 0 { luma(230) } else { white },
      table.hline(y: 0, stroke: 0.5pt + black),
      table.hline(y: 1, stroke: 0.5pt + black),
      [*ID*], [*Titel*], [*Typ*], [*Priorität*],
      [*#id*], [*#titel*], [#typ], [*#prio*],
      table.hline(y: 2, stroke: 0.5pt + luma(180)),
      table.cell(colspan: 4)[
        *Beschreibung (SOPHIST-Schablone):* \
        #beschreibung
      ],
      table.hline(y: 3, stroke: 0.5pt + luma(180)),
      table.cell(colspan: 4)[
        *Überprüfbarkeit / Akzeptanzkriterien:* \
        #kriterien
      ],
      table.hline(y: 4, stroke: 0.5pt + black),
    )
  )
  v(1em)
}
// ==========================================

#align(center)[
  // Platzhalter für optionales Inhaltsverzeichnis
]

#pagebreak()

////////////////////////////////
// HAUPTTEIL
////////////////////////////////

= Einleitung
== Problemstellung
// Text zur Problemstellung hier einfügen...

== Zielsetzung
// Text zur Zielsetzung hier einfügen...

== Abgrenzung und Scope
// Text zur Abgrenzung hier einfügen...


= Grobentwurf
== Schichtendiagramm
_Grobe Darstellung der Systemarchitektur als Bindeglied zwischen Anforderungen und technischer Umsetzung._


= Anforderungsanalyse (Lastenheft)

== Einordnung und Dokumentationskonvention
Dieses Kapitel dokumentiert die *Anforderungsanalyse* für die Java-Peilungs-Komponente. Es folgt bewusst dem formalen Aufbau einer klassischen Anforderungssammlung (vgl. Musterdokument „Anforderungsanalyse 2019“). Ergänzend werden SWE-Artefakte integriert, die in der Vorlesung gefordert sind (Stakeholder, Risiken, OOA-Hinweise, Testbarkeit, Traceability).

*Konvention für IDs:* Funktionale Anforderungen tragen das Präfix `/LF…/`, nicht-funktionale `/LL…/`, Produktdaten `/LD…/`. Verweise verbinden zusammengehörige Anforderungen (z. B. „`/LF030/` verweist auf `/LL010/`“).

*SOPHIST-Qualität:* Jede Anforderung ist als vollständiger Satz formuliert, enthält einen erkennbaren Akteur, eine eindeutige Systemreaktion und ist überprüfbar (Testfall, Messgröße oder Inspektion).

== Zielbestimmung und Produkteinsatz
*Hintergrund:* Die iOS-App „Kompass Professional“ demonstriert eine moderne Peilungsfunktionalität. Die in diesem Projekt entwickelte Java-Bibliothek soll als plattformunabhängige Kernkomponente fungieren, welche die geodätische Kernlogik abbildet, verwaltet und validiert. 

Das System wird in Umgebungen eingesetzt, in denen eine verlässliche Auswertung von GPS-Koordinaten erforderlich ist. Die Bibliothek muss fehlertolerant gegenüber schlechten GPS-Signalen arbeiten und standardisierte Exportformate (GPX) unterstützen.


== Funktionale Anforderungen

#anforderung(
  "/LF010/",
  "Starten der Peilungsaufzeichnung",
  "Funktional",
  "MUSS",
  "Das System MUSS dem Host (aufrufende Applikation) die Möglichkeit bieten, eine neue Peilungsaufzeichnung zu starten und dabei Initialparameter (z.B. Benutzer-ID) zu übergeben.",
  "Ein automatisierter Test ruft die Start-Methode der API auf. Das System muss den Zustand auf 'Recording' setzen und nachfolgende Koordinatenpunkte annehmen."
)

#anforderung(
  "/LF020/",
  "Verarbeitung von GPS-Punkten",
  "Funktional",
  "MUSS",
  "Das System MUSS vom Host empfangene GPS-Punkte entgegennehmen, deren Gültigkeit (anhand von Koordinatensystem-Grenzen und HDOP-Werten) validieren und gültige Punkte in den aktuellen Aufzeichnungs-Puffer aufnehmen.",
  "Es werden iterativ gültige und ungültige (z.B. HDOP zu groß) Koordinaten übergeben. Das System darf nur die gültigen Punkte im internen Speicher ablegen."
)

#anforderung(
  "/LF030/",
  "Export als GPX-String",
  "Funktional",
  "MUSS",
  "Das System MUSS nach Beendigung der Aufzeichnung die gesammelten, validierten Wegpunkte als wohlgeformten GPX-String (gemäß offiziellem XML-Schema) exportieren können.",
  "Die Export-Schnittstelle wird aufgerufen. Der Rückgabewert wird durch einen XML-Validator gegen das offizielle GPX 1.1 Schema geprüft (Szenario A)."
)


== Produktdaten

#anforderung(
  "/LD010/",
  "Wegpunkt-Datensatz",
  "Daten",
  "MUSS",
  "Das System MUSS für jeden validierten Wegpunkt zwingend Längengrad (Longitude), Breitengrad (Latitude), Zeitstempel (UTC) sowie den HDOP-Wert (Genauigkeit) persistent im Arbeitsspeicher vorhalten.",
  "Inspektion des internen Datenmodells (Klassendiagramm) und Prüfung der Getter-Methoden auf Vollständigkeit der Attribute."
)


== Nichtfunktionale Anforderungen

=== Leistungs- und Performanceanforderungen
#anforderung(
  "/LL010/",
  "Verarbeitungsgeschwindigkeit",
  "Performance",
  "MUSS",
  "Die Bibliothek MUSS in der Lage sein, eingehende GPS-Punkte in einem Intervall von 2 Sekunden ohne spürbare Latenz (Verarbeitungszeit < 50ms pro Punkt) zu verarbeiten.",
  "Lasttest, bei dem über 5 Minuten alle 2 Sekunden ein Punkt simuliert wird. Die gemessene Ausführungszeit der API-Methode muss konstant unter 50ms bleiben."
)

=== Externe Schnittstellen und Stabilität
#anforderung(
  "/LL020/",
  "Toleranz bei Signalverlust",
  "Robustheit",
  "SOLL",
  "Die Bibliothek SOLL bei einem temporären Ausfall der GPS-Datenlieferung durch den Host (Szenario C) den internen Peilungs-Zustand stabil halten und nicht mit einer unkontrollierten Exception abbrechen.",
  "Simulation von Aussetzern in der Datenübergabe. Der Aufzeichnungsstatus darf sich nicht ungefragt ändern, das System muss auf den nächsten gültigen Punkt warten."
)

== Qualitätsanforderungen & Szenarien für Akzeptanztests
Folgende textuelle Storyboards (Szenarien) definieren die primären Akzeptanzkriterien für den Gesamtprozess:

* **Szenario A – Happy Path:** Host startet Peilung, liefert alle 2 s gültige Punkte, beendet die Aufzeichnung regulär und exportiert einen validen GPX-String, der erfolgreich gegen das Schema geprüft wird.
* **Szenario B – Abbruch:** Der Host bricht die Aufzeichnung frühzeitig (z.B. nach drei Punkten) ab. Erhält dennoch einen formatierten GPX-String der bisherigen Punkte, den er optional speichern kann.
* **Szenario C – Schlechte GPS-Qualität:** Der Host liefert Koordinaten mit zu hohem HDOP-Wert. Die Bibliothek verwirft diese Punkte gemäß interner Policy laut `/LF020/`; die Peilungsaufzeichnung bleibt dabei stabil.
* **Szenario D – Hard-Limit:** Der Host überschreitet das definierte Hard-Limit an maximalen Wegpunkten. Die Bibliothek signalisiert dem Host proaktiv das Ende der Aufzeichnung.

== Verweise auf PlantUML-Modelle
Die detaillierten grafischen Modelle liegen unter `Documentation/plantuml/` und sind in der `README.md` beschrieben. Für das Verständnis der Architektur und der Abläufe sind insbesondere das *Anwendungsfalldiagramm* (`07_usecase_diagramm.puml`) sowie das *Aktivitätsdiagramm* (`04_aktivitaetsdiagramm_peilung.puml`) relevant. Diese belegen die beschriebenen Akteure und Kontrollflüsse.


= Systemspezifikation und Feinentwurf (Pflichtenheft)
== Einleitung und allgemeine Beschreibung
== Funktionale Spezifikation
=== Use Cases
=== Einzelanforderungen (Sophist-Schablonen)

== Datenmodellierung und technischer Feinentwurf
_In diesem Abschnitt werden die Datenstrukturen zusammen mit dem technischen Klassendesign definiert, um eine redundanzfreie Abbildung der Systemlogik zu gewährleisten._

=== Klassendiagramm (Struktureller Feinentwurf)

== Nichtfunktionale Spezifikation
=== Qualitätsanforderungen nach ISO/IEC 25010
=== Mengengerüst und Sicherheitsanforderungen
== Angestrebte Eigenschaften & Qualitätscheck

= Qualitätssicherung
_Die Qualitätssicherung erfolgt prozessbegleitend durch automatisierte Tests direkt auf Code-Ebene, basierend auf den definierten Akzeptanzszenarien (A-D) sowie der festgelegten Traceability (Anforderung ↔ Test ↔ Code)._

= Fazit
== Zusammenfassung der Ergebnisse

#pagebreak()