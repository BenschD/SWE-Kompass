#import "macros.typ": diagramm-box

#let puml-fig(path) = image(path, width: 100%, height: 15.5cm, fit: "contain")

// ── Hilfsfunktionen ────────────────────────────────────────────────────────
#let tbl-stroke = 0.45pt + rgb("#9a9a9a")
#let tbl-inset  = 6pt

#let ch-grobentwurf-kapitel = [
#set par(justify: true)

Der Grobentwurf legt die Software-Architektur der Java-Peilungskomponente
implementierungsunabhängig fest. Er beschreibt, was das System leistet und wie es strukturiert ist. Er gibt einen groben Überblick und beschreibt nicht, wie einzelne Klassen oder Algorithmen intern
aussehen.

// ──────────────────────────────────────────────────────────────────────────
== Einordnung und Ziel
// ──────────────────────────────────────────────────────────────────────────

Der Grobentwurf beantwortet nach Vorlesung drei grundlegende Fragen: 
- Wie wird das System in überschaubare Einheiten gegliedert? 
- Welche Lösungsstruktur wird gewählt? 
- Wie werden diese Einheiten hierarchisch angeordnet? 
Für die Java-Peilungskomponente ergeben sich daraus vier konkrete Anforderungen:

*Parallele Entwicklung: * Subsysteme müssen so klar abgegrenzt sein, dass
unterschiedliche Teams unabhängig daran arbeiten können, ohne voneinander
Implementierungsdetails kennen zu müssen.

*Testbarkeit: * Fachlogik und technische Adapter dürfen nicht verwoben sein,
damit Unit-Tests ohne externe Abhängigkeiten ausführbar
sind.

*Erweiterbarkeit: * Neue Optimierungsverfahren, zusätzliche externe Dienste
oder alternative Exportformate sollen integrierbar sein, ohne bestehende
Subsysteme zu ändern.

*Nachvollziehbarkeit: * Jede Entwurfsentscheidung wird mit einem
Architekturprinzip aus der Vorlesung begründet, sodass die Architektur
diskutierbar und prüfbar bleibt.

// ──────────────────────────────────────────────────────────────────────────
== Systemsicht
// ──────────────────────────────────────────────────────────────────────────

=== System of Interest und Systemgrenze

Die Systemgrenze umschließt ausschließlich die Java-Peilungskomponente ohne
jegliche Benutzeroberfläche. Sensordaten (GNSS, Kompass) werden nicht direkt
gelesen. Der User ist verantwortlich für Sensorfusion und Gerätezugriff und
übergibt fertige Messwerte über die öffentliche API.

#figure(
  caption: [Externe Schnittstellen der Bibliothek und ihre Kommunikationsrichtungen.],
  kind: table,
  align(left, table(
    columns: (4.0cm, 2.9cm, 1fr),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Externe Schnittstellen*], [*Richtung*], [*Zweck*],
    [User-Anwendung],   [eingehend],          [Steuerung des Session-Lebenszyklus; Übergabe von Positions- und Kursdaten],
    [Listener / Result],[ausgehend],          [Snapshots, Statuswechsel, Fehlerereignisse; GPX-Rückgabe an den Host],
    [Dateisystem],      [ausgehend, optional],[GPX-Persistenz nur bei expliziter Konfiguration durch den Host],
    [W3W-HTTP],         [ausgehend, optional],[Reverse-Lookup mit lokalem Cache; ohne Netzwerk vollständig deaktivierbar],
  ))
)

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Context.svg"),
  caption: [Systemsicht: Systemgrenze und externe Kommunikationspartner.],
)

#pagebreak()

// ──────────────────────────────────────────────────────────────────────────
== Statische Sicht
// ──────────────────────────────────────────────────────────────────────────

=== Subsystem-Spezifikation

Das System wird in vier Subsysteme zerlegt. Die Zerlegung folgt dem Prinzip
der hohen Kohäsion: Alles, was fachlich zusammengehört, landet im selben
Subsystem. Technische Abhängigkeiten werden konsequent davon getrennt, damit
ist sichergestellt, dass eine Änderung in einem Subsystem, z. B. ein anderer
GPX-Writer, keine Fachlogik berührt.


#figure(
  caption: [Subsysteme und ihre Verantwortlichkeiten im Überblick.],
  kind: table,
  align(left, table(
    columns: (3.9cm, 5.5cm, 1fr),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Subsystem*],             [*Kernverantwortung*],                                              [*Bereitgestellte Dienste*],
    [API / Application Service],[Use-Case-Orchestrierung; Session-Verwaltung; Fehlerbehandlung],   [Session starten, beenden und abbrechen; konsistenten Zustandsschnappschuss liefern],
    [Domain Core],             [Fachlogik ohne I/O-Abhängigkeiten],                               [Azimut, Distanz, Ordinalrichtung; Rohspeicher, Validierung, Segmentierung, Export-Optimierer],
    [Ports],                   [Abstraktion technischer Abhängigkeiten],                          [Stabile Schnittstellen für GPX, Zeitgeber, Dateisystem, Logging und W3W],
    [Infrastruktur / Adapter], [Konkrete Implementierung der Ports],                              [XML-Serialisierung, Datei-I/O, HTTP-Client, Systemuhr, Logging-Backend],
  ))
)


#pagebreak()
=== Schichtenmodell nachfragen bei Bohl

Die vier Subsysteme sind als streng gerichtete Schichten angeordnet. Jede
Schicht kommuniziert ausschließlich mit der direkt darunterliegenden. Ein
Überspringen von Schichten ist verboten. Dadurch entstehen keine zyklischen
Abhängigkeiten, und jede Schicht ist einzeln testbar und austauschbar.

#diagramm-box("Schichten von oben nach unten")[
  *Host-System* (außerhalb der Komponente)\
  Beliebige Java-Anwendung (Desktop, Web, Embedded). Greift ausschließlich
  über die öffentliche API-Fassade zu. Keine direkten Infrastrukturzugriffe.
  //greift es auschließlich über die öffentliche API-Fassade zu ? 
  ↓ nur über öffentliche API-Aufrufe

  *API / Application Service*\
  Steuert den Session-Lebenszyklus, prüft Vorbedingungen und orchestriert die Fachfälle.
  Nutzt Ports über `DefaultBearingSession` und kennt keine konkreten Infrastruktur-Details.

  ↓ nur über Domain-Schnittstellen

  *Domain Core*\
  Enthält alle fachlichen Regeln und Berechnungen (Azimut, Distanz,
  Rohspeicher, Segmentierung, Punktbudget; Export-Optimierer als Strategien). Vollständig I/O-frei.
  Kein Import von Infrastruktur-Klassen.

  ↓ nur über Port-Interfaces 

  *Port-Schicht*\
  Technologieunabhängige Verträge. Die Domain formuliert, was sie braucht
  (z. B. "schreibe GPX"), aber nicht wie. Dies ermöglicht Mocking im Test
  ohne reale Abhängigkeiten.

  ↓ implementiert durch

  *Infrastruktur / Adapter*\
  Realisiert die Ports: GPX-Serialisierung nach XML, HTTP-Client für W3W,
  Dateisystem-Zugriff, Systemuhr, SLF4J-Logging.
]

#pagebreak()
=== Kommunikationsregeln

#figure(
  caption: [Kommunikationsregeln: Erlaubte und verbotene Abhängigkeiten zwischen den Subsystemen.],
  kind: table,
  align(left, table(
    columns: (2.1cm, 2.1cm, 2.3cm, 1fr),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Von*],          [*Nach*],        [*Erlaubt?*],[*Begründung*],
    [Host],           [API],           [Ja],        [Die API-Fassade ist der einzige definierte Einstiegspunkt; der Host darf ausschließlich über sie kommunizieren],
    [Host],           [Domain],        [Nein],      [Der direkte Zugriff würde die Fachlogik gegenüber dem Aufrufer exponieren und die Kapselungswirkung der API-Fassade vollständig aushebeln],
    [Host],           [Infrastruktur], [Nein],      [Technische Implementierungsdetails gehören nicht zur öffentlichen Bibliotheksschnittstelle und dürfen dem Host nicht bekannt sein],
    [API],            [Domain],        [Ja],        [Die API-Schicht orchestriert Use Cases, indem sie reine Fachlogik aufruft, ohne dabei I/O-Abhängigkeiten in den Domain Core einzuschleppen],
    [API],            [Infrastruktur], [Nein],      [Die API kommuniziert ausschließlich über die definierten Ports; ein Direktzugriff würde die Austauschbarkeit der Adapter zerstören],
    [Domain],         [Ports],         [Ja],        [Externe Seiteneffekte werden ausschließlich über abstrakte Port-Schnittstellen ausgelöst],
    [Domain],         [Infrastruktur], [Nein],      [Ein direkter Infrastrukturzugriff würde I/O-Abhängigkeiten in die Fachlogik einführen und deren isolierte Testbarkeit zerstören],
    [Infrastruktur],  [Domain],        [Nein],      [Eine Rückkopplung von der Infrastruktur in den Domain Core würde zyklische Abhängigkeiten erzeugen und das Schichtenmodell strukturell verletzen],
  ))
)

#pagebreak()
=== Paket- und Modulschnitt

Jedes Subsystem wird als eigenständiges Maven-Modul realisiert. Dadurch
erzwingt das Build-System die Schichtregeln: Ein Modul kann nur importieren,
was als Abhängigkeit deklariert ist.

#figure(
  caption: [Paket- und Modulschnitt: Jedes Subsystem als eigenständiges Maven-Modul mit klarer Verantwortungszuweisung.],
  kind: table,
  align(left, table(
    columns: (2.2cm, 6cm, auto),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Modul*],                  [*Paketbasis*],                            [*Verantwortung*],
    [`bearing-api`],            [`com.example.bearing.api`],               [Öffentliche Fassade, DTOs, Fehlercodes, Session-Konfiguration],
    [`bearing-domain`],         [`com.example.bearing.domain`],            [Fachlogik, Policies, Zustandsmodell, Value Objects],
    [`bearing-spi`],            [`com.example.bearing.spi`],               [Technologieunabhängige Port-Interfaces],
    [`bearing-adapter-gpx`],    [`com.example.bearing.adapter.gpx`],       [GPX-1.1-Writer],
    [`bearing-adapter-w3w`],    [`com.example.bearing.adapter.w3w`],       [Optionaler W3W-HTTP-Client mit Cache],
    [`bearing-adapter-system`], [`com.example.bearing.adapter.system`],    [Dateisystem, Systemuhr, Logging],
  ))
)

// UML-Diagramme
// Rausnehmen? 
#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Component_Layers.svg"),
  caption: [UML-Komponentendiagramm: Schichten und Port-Adapter-Kopplung.],
)

#pagebreak()

// ──────────────────────────────────────────────────────────────────────────
== Dynamische Sicht
// ──────────────────────────────────────────────────────────────────────────

Die dynamische Sicht beschreibt die drei wesentlichen Laufzeitszenarien der Komponente: reguläre Positionsupdates, regulären Session-Abschluss und Fehlerpfade bei ungültigen Eingaben. In jedem Szenario werden die beteiligten Subsysteme, die Kommunikationspfade und die Auswirkungen auf den Systemzustand beschrieben.

=== Szenario A: Regulärer Positionsupdate

Der Host übergibt einen GPS-Fix an die API. Diese validiert den Fix und aktualisiert den Track-Zustand.
Ist der Fix ungültig, wird eine `ValidationException` geworfen; der Track-Zustand bleibt konsistent.

=== Szenario B: Regulärer Session-Abschluss

Der Host ruft `complete` auf. Die API delegiert an den Domain Core, der den
Track finalisiert und ggf. eine Segmentgrenze schließt. Anschließend wird
über den GPX-Port die Serialisierung angestoßen. Die Infrastruktur liefert
das GPX-Ergebnis zurück, das die API als `GpxResult` an den Host weitergibt.
Optional schreibt `SafeFileSink` die Daten ins Dateisystem, falls der Host
dies konfiguriert hat.

=== Szenario C: Fehlerpfad: ungültige Koordinate

Der Host übergibt einen Fix mit ungültigen Koordinaten. Die API erkennt den Fehler
bereits bei der Eingangsvalidierung und erzeugt eine `ValidationException`.
Es wird kein Domänenzustand verändert und kein GPX-Port aufgerufen.
Der Fehler wird als Exception an den Host propagiert.

#pagebreak()

#block(breakable: false)[
== Physische Sicht

Die Komponente wird als Bibliothek in den Host-Prozess eingebettet und läuft
in dessen JVM. Es existiert kein eigener Prozess, kein eigenständiger Server
und kein Nachrichtensystem. Externe Kommunikation findet ausschließlich über
zwei optionale Kanäle statt: HTTPS zur W3W-API und Dateisystemzugriffe für
den GPX-Export. Beide Kanäle sind abschaltbar, die Kernfunktion (Peilung,
Track-Aufzeichnung) läuft ohne Netzwerkverbindung.

Diese Entscheidung sichert Offline-Betrieb und vereinfacht Deployment und
Test erheblich. Außerdem sind für Integrationstests lokale Mocks der Ports
ausreichend.

#figure(
  scale(80%, reflow: true,
    box(width: 100%,
      puml-fig("../plantuml/out/SWE_Kompass_Deployment_Runtime.svg")
    )
  ),
  caption: [UML-Verteilungsdiagramm: Laufzeitknoten, Artefakte und Kommunikationspfade.],
)
]

#pagebreak()

// ──────────────────────────────────────────────────────────────────────────
== Entwurfsprinzipien
// ──────────────────────────────────────────────────────────────────────────

Die Tabelle ordnet den geforderten Qualitätskriterien die entsprechenden Entwurfsentscheidungen der Architektur zu. Diese direkte Verknüpfung dient als prüfbarer Nachweis für die Erfüllung der Vorgaben.

#figure(
  caption: [Entwurfsprinzip: Ordnung der Architekturentscheidungen nach Prinzipien der Software-Architektur.],
  kind: table,
  align(left, table(
  columns: (3.2cm, 1fr, 1fr),
  stroke: tbl-stroke, 
  inset: tbl-inset,
  [*Prinzip*], [*Entwurfsentscheidung*], [*Messbarer Nutzen*],
  
  [Hohe Kohäsion], 
  [Module sind strikt nach fachlicher Verantwortung getrennt, statt technische Schichten zu vermischen.], 
  [Anpassungen am GPX-Format bleiben lokal auf den `bearing-adapter-gpx` begrenzt.],

  [Schwache Kopplung], 
  [Komponenten kommunizieren ausschließlich über APIs statt über konkrete Implementierungen.], 
  [Unterkomponenten lassen sich flexibler austauschen, was wiederum das Mocking für Unit-Tests vereinfacht.],

  [Information Hiding], 
  [Domänen-Logik wird hinter einer Fassade gekapselt. Daten fließen als unveränderliche Value Objects.], 
  [Die interne Struktur ist geschützt, spricht externe Aufrufer können den Systemzustand nicht schädigen.],

  [Separation of Concerns], 
  [Saubere Trennung zwischen Kernlogik und Infrastruktur (wie Dateizugriff oder Netzwerk-I/O).], 
  [Fachlogik lässt sich ohne Infrastruktur-Overhead testen und umgekehrt.],

  [Wiederverwendbarkeit], 
  [Einsatz des Strategy-Patterns für Policies und Optimizer, um Logik austauschbar zu machen.], 
  [Neue Algorithmen lassen sich ohne Eingriffe in den bestehenden Kontrollfluss integrieren.],
)))

#pagebreak()
// ──────────────────────────────────────────────────────────────────────────
== Subsystem-Dekomposition
// ──────────────────────────────────────────────────────────────────────────
Um das Peilungssystem von einem monolithischen Ansatz in eine modulare, wartbare Architektur zu überführen, folgt der Entwurf einem zweistufigen Prozess: der Identifikation funktionaler Einheiten und deren anschließender struktureller Anordnung.

=== Erster Schritt: Subsystem-Identifikation

Der erste Schritt konzentriert sich darauf, die fachlichen Operationen sinnvoll zu Diensten zu bündeln und diese den jeweiligen Subsystemen zuzuordnen. Dabei bilden Typen mit verwandter Verantwortung die logischen Grenzen der Subsystem-Schnittstellen.

Die folgende Übersicht gruppiert die Operationen und definiert die Verträge der daraus resultierenden Dienste. Diese Verträge legen fest, welches Verhalten nach außen garantiert wird und wie die Komponente auf ungültige Zustände reagiert, während technische Implementierungsdetails dem Feinentwurf vorbehalten bleiben.

#figure(
  caption: [Subsystem-Identifikation: Zuordnung von Operationen zu Diensten und Definition von Verträgen mit Fehlerfällen.],
  kind: table,
  align(left, table(
columns: (2.5cm, 1.8fr, 1fr),
stroke: tbl-stroke,
inset: tbl-inset,
[Dienst], [Verhalten], [Fehlerfälle],

[Session-Management],
[Steuert den Lebenszyklus einer Peilung im API-Layer (`start`, `complete`, `abort`, `reset`).],
[Die Peilung ist bereits aktiv, Zielkoordinaten sind ungültig],

[Tracking-Logik],
[Wendet im Domain-Layer Validierungsvorschriften auf GPS-Daten an und berechnet Fortschritte.],
[Ungültige Koordinaten, Zeitstempel außerhalb `maxFixAge`],

[Kurs-Analyse],
[Berechnet Abweichungen basierend auf fachlichen Vorgaben im Domain-Layer.],
[Kurswert liegt außerhalb des Wertebereichs, fehlende Datenbasis],

[Export- & Abbruch-Dienst],
[Koordiniert über API+Domain die Finalisierung und startet die GPX-Serialisierung über Ports.],
[Peilung nicht aktiv, SecurityException bei unzulässigem Pfad],

[Port-/Adapter-Zugriff],
[Kapselt Persistenz von GPX-Daten und optionales W3W-Caching über SPI-Ports und Adapter.],
[Schreib- oder Lesefehler, W3W API nicht erreichbar],

[Host-API],
[Stellt öffentliche Java-Schnittstellen für den Host bereit.],
[Ungültiger API-Aufruf],
)))
#pagebreak()

=== Zweiter Schritt: Subsystem-Anordnung

Die Anordnung der Subsysteme folgt einer streng hierarchischen Struktur, um die Komplexität zu beherrschen und die Austauschbarkeit einzelner Ebenen zu gewährleisten.

*Strukturierung:* Das System ist vertikal in Schichten gegliedert:\ - Host\ - API\ - Domain\ - Ports (SPI)\ - Adapter/Infrastruktur\ Jede Schicht hat eine klar definierte Aufgabe und bildet eine logische Partition des Gesamtsystems.

*Interaktionsmodell:* Die Kommunikation erfolgt strikt einseitig von oben nach unten. Ein Subsystem nutzt ausschließlich die Dienste der unmittelbar darunterliegenden Schicht. Ein direkter Zugriff von der Präsentationsebene auf den Datenzugriff wird zur Vermeidung von Kopplung unterbunden.

*Software-Architektur:* Durch die Auslagerung der Logik in den Domain-Layer bleibt die Fachlogik unabhängig vom Host. Die Port-Schicht abstrahiert technische Details (Dateisystem, HTTP, Uhr, Logging), sodass Änderungen an Adaptern keine Auswirkungen auf die Geschäftsregeln haben.

#pagebreak()


== Security Engineering im Grobentwurf
Das Security Engineering der Peilungskomponente stellt sicher, dass das System durch sein Design böswilligen Angriffen auf die Logik und die erfassten Geodaten widersteht. Der Fokus liegt hierbei auf der *Application Security*: Das System wird so konstruiert, dass es inhärent sicher ist, anstatt sich allein auf externe Infrastruktur-Sicherheitsmaßnahmen zu verlassen. Sicherheit wird dabei als fundamentale Voraussetzung für die Zuverlässigkeit und Verfügbarkeit der Peilungsdaten betrachtet.

Die Sicherheitsarchitektur stützt sich auf drei zentrale Dimensionen:

/ Vertraulichkeit: Schutz der sensiblen Bewegungsdaten und Ziele vor unbefugter Offenlegung.
/ Integrität: Sicherstellung, dass GPS-Tracks und Kursberechnungen nicht unbemerkt manipuliert oder korrumpiert werden können.
/ Verfügbarkeit: Gewährleistung, dass die Peilungsfunktion und der Datenexport auch unter Last oder bei Ausfällen externer Dienste (wie W3W) erhalten bleiben.

=== Sicherheitsanforderungen
Sicherheitsanforderungen werden laut Vorlesung in drei Klassen eingeteilt:
Risikovermeidung (Schwachstelle gar nicht erst einbauen), Risikoerkennung
(Angriff neutralisieren bevor Schaden entsteht) und Risikominderung
(Schaden nach Angriff begrenzen). Die folgende Tabelle wendet diese
Klassifizierung auf die relevanten Risiken der Peilungskomponente an.

#figure(
  caption: [Sicherheitsanforderungen: Identifikation von Risiken und Zuordnung von Maßnahmen zur Vermeidung, Erkennung oder Minderung.],
  kind: table,
  align(left, table(
  columns: (2.8cm, 1.8cm, 1fr, 1fr),
  stroke: tbl-stroke, inset: tbl-inset,
  [*Risiko*],                   [*Klasse*],        [*Architekturmaßnahme*],                                    [*Ort im Entwurf*],
  [Pfadmanipulation beim GPX-Export],[Vermeidung], [Whitelisting erlaubter Basisverzeichnisse und explizite Host-Konfiguration],[API + Adapter (`SafeFileSink`)],
  [XML-Injection in GPX],       [Vermeidung],      [Konsequentes Escaping aller Nutzerdaten bei der Serialisierung],[Adapter (`GpxXmlWriter`)],
  [Ausfall des W3W-Dienstes],   [Minderung],       [Timeout-Limit und Fallback ohne W3W-Daten],[Adapter (`W3wHttpClient`)],
  [Unkontrollierter Speicherverbrauch],[Vermeidung],[Punktbudget und Segmentierungs-Schwelle im Domain Core],[Domain-Layer],
  [Unklare Fehlerbehandlung],   [Erkennung],       [Semantische Exception-Hierarchie; jeder Fehler hat eindeutigen Code],[API-Layer],
)))
#pagebreak()
]
