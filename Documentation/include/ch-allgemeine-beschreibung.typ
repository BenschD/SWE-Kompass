#import "macros.typ": diagramm-box

#let tbl-stroke = 0.45pt + rgb("#9a9a9a")
#let tbl-inset  = 6pt

#let ch-allgemeine-beschreibung-kapitel = [
#set par(justify: true)

Dieses Kapitel betrachtet die Java-Peilungskomponente aus der Übersicht: wie sie sich in ihr technisches Umfeld einfügt, welche Hauptfunktionen sie bietet, welche Stakeholder und Benutzerprofile eine Rolle spielen und welche systemweiten Einschränkungen, Annahmen und Abhängigkeiten gelten. Es entspricht dem Abschnitt „General Description" der IEEE-830-Vorlage.

// ─────────────────────────────────────────────────────────────────────────────
== Einbettung
// ─────────────────────────────────────────────────────────────────────────────

=== Systemsicht und Systemgrenze

Die Java-Peilungskomponente ist eine reine Bibliothek ohne eigene Benutzeroberfläche. Sie wird in den Prozess einer *Host-Anwendung* eingebettet und läuft in deren JVM. Es existiert kein eigener Prozess, kein eigenständiger Server und kein Nachrichtensystem.

Die Systemgrenze umschließt ausschließlich die Java-Peilungskomponente. Sensordaten (GNSS, Kompass) werden nicht direkt gelesen. Die Host-Anwendung ist verantwortlich für Sensorfusion und Gerätezugriff und übergibt fertige Messwerte über die öffentliche API.

Externe Kommunikation findet ausschließlich über zwei optionale Kanäle statt: HTTPS zur W3W-API und Dateisystemzugriffe für den GPX-Export. Beide Kanäle sind abschaltbar; die Kernfunktion (Peilung, Track-Aufzeichnung) läuft ohne Netzwerkverbindung.

#figure(
  caption: [Externe Schnittstellen der Bibliothek und ihre Kommunikationsrichtungen.],
  kind: table,
  align(left, table(
    columns: (4.0cm, 2.9cm, 1fr),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Externe Schnittstelle*], [*Richtung*], [*Zweck*],
    [Host-Anwendung],  [eingehend],          [Steuerung des Session-Lebenszyklus; Übergabe von Positions- und Kursdaten],
    [Listener / Result],[ausgehend],         [Snapshots, Statuswechsel, Fehlerereignisse; GPX-Rückgabe an den Host],
    [Dateisystem],     [ausgehend, optional],[GPX-Persistenz nur bei expliziter Konfiguration durch den Host],
    [W3W-HTTP],        [ausgehend, optional],[Reverse-Lookup mit lokalem Cache; ohne Netzwerk vollständig deaktivierbar],
  ))
)

=== Schichtenarchitektur

Das System ist vertikal in vier Subsysteme gegliedert, die als streng gerichtete Schichten angeordnet sind. Jede Schicht kommuniziert ausschließlich mit der direkt darunterliegenden; ein Überspringen von Schichten ist verboten. Dadurch entstehen keine zyklischen Abhängigkeiten und jede Schicht ist einzeln testbar und austauschbar.

#figure(
  caption: [Subsysteme und ihre Verantwortlichkeiten.],
  kind: table,
  align(left, table(
    columns: (3.9cm, 5.5cm, 1fr),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Subsystem*],              [*Kernverantwortung*],                                              [*Bereitgestellte Dienste*],
    [API / Application Service],[Use-Case-Orchestrierung; Session-Verwaltung; Fehlerbehandlung],   [Session starten, beenden und abbrechen; konsistenten Zustandsschnappschuss liefern],
    [Domain Core],              [Fachlogik ohne I/O-Abhängigkeiten],                              [Azimut, Distanz, Ordinalrichtung; Rohspeicher, Validierung, Segmentierung, Export-Optimierer],
    [Ports],                    [Abstraktion technischer Abhängigkeiten],                          [Stabile Schnittstellen für GPX, Zeitgeber, Dateisystem, Logging und W3W],
    [Infrastruktur / Adapter],  [Konkrete Implementierung der Ports],                             [XML-Serialisierung, Datei-I/O, HTTP-Client, Systemuhr, Logging-Backend],
  ))
)

#diagramm-box("Schichten von oben nach unten")[
  *Host-System* (außerhalb der Komponente)\
  Beliebige Java-Anwendung (Desktop, Web, Embedded). Greift ausschließlich über die öffentliche API-Fassade zu. Keine direkten Infrastrukturzugriffe.

  ↓ nur über öffentliche API-Aufrufe

  *API / Application Service*\
  Steuert den Session-Lebenszyklus, prüft Vorbedingungen, bildet Fehler auf semantische Codes ab und orchestriert die Fachfälle. Kennt die Domain, kennt keine Adapter.

  ↓ nur über Domain-Schnittstellen

  *Domain Core*\
  Enthält alle fachlichen Regeln und Berechnungen (Azimut, Distanz, Rohspeicher, Segmentierung, Punktbudget; Export-Optimierer als Strategien). Vollständig I/O-frei. Kein Import von Infrastruktur-Klassen.

  ↓ nur über Port-Interfaces

  *Port-Schicht*\
  Technologieunabhängige Verträge. Die Domain formuliert, was sie braucht (z.\ B. „schreibe GPX"), aber nicht wie. Dies ermöglicht Mocking im Test ohne reale Abhängigkeiten.

  ↓ implementiert durch

  *Infrastruktur / Adapter*\
  Realisiert die Ports: GPX-Serialisierung nach XML, HTTP-Client für W3W, Dateisystem-Zugriff, Systemuhr, SLF4J-Logging.
]

=== Kommunikationsregeln

#figure(
  caption: [Erlaubte und verbotene Abhängigkeiten zwischen den Subsystemen.],
  kind: table,
  align(left, table(
    columns: (2.1cm, 2.1cm, 2.3cm, 1fr),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Von*],          [*Nach*],        [*Erlaubt?*], [*Begründung*],
    [Host],           [API],           [Ja],         [Die API-Fassade ist der einzige definierte Einstiegspunkt.],
    [Host],           [Domain],        [Nein],       [Direkter Zugriff würde die Kapselungswirkung der API-Fassade aushebeln.],
    [API],            [Domain],        [Ja],         [Orchestrierung der Fachlogik ist Kernaufgabe der API-Schicht.],
    [API],            [Infrastruktur], [Nein],       [Keine technischen Details im Application Service; nur Port-Interfaces.],
    [Domain],         [Infrastruktur], [Nein],       [Fachlogik bleibt I/O-frei; Infrastruktur wird über Ports entkoppelt.],
    [Infrastruktur],  [Domain],        [Nein],       [Zirkuläre Abhängigkeit würde die Testbarkeit zerstören.],
  ))
)

=== Physische Sicht

Die Komponente wird als Bibliothek in den Host-Prozess eingebettet und läuft in dessen JVM. Für Integrationstests sind lokale Mocks der Ports ausreichend. Die Offline-Fähigkeit sichert den Betrieb auch ohne Netzwerkzugang.

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Funktionen
// ─────────────────────────────────────────────────────────────────────────────

Die folgende Tabelle fasst die Hauptfunktionsgruppen der Bibliothek zusammen. Die genaue Spezifikation der einzelnen Anforderungen folgt in Kapitel 3.

#figure(
  caption: [Hauptfunktionsgruppen der Java-Peilungskomponente mit Verweis auf Anforderungen.],
  kind: table,
  align(left, table(
    columns: (4cm, 1fr, 2.5cm),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Funktionsgruppe*],           [*Beschreibung*],                                                           [*Anforderungen*],
    [Session-Lebenszyklus],        [Start, laufende Aufzeichnung und Abbruch einer Peilungs-Session mit UUID-Identifikation.], [/LF010/–/LF090/],
    [Peilung und Kurs],            [Berechnung von geografischem Azimut, Entfernung (Haversine) und diskreter Himmelsrichtung; optionale Kursabweichung.], [/LF030/–/LF050/],
    [GPS-Track-Aufzeichnung],      [Kontinuierlicher Rohspeicher validierter GPS-Fixes; Segmentierung bei Zeitlücken; zweistufiges Punktbudget.], [/LF100/–/LF130/],
    [GPX-Export],                  [GPX-1.1-konformer Export als `byte[]`; optionales atomares Dateischreiben.], [/LF140/–/LF160/],
    [Track-Optimierung],           [Austauschbare Strategie-Algorithmen: n-ter Punkt, Mindestabstand, Geraden-Heuristik, Douglas-Peucker.], [/LF170/–/LF200/],
    [What3Words-Integration],      [Optionaler Reverse-Lookup mit Cache via `W3wClientPort`.], [/LF210/, /LF220/],
    [Validierung und Sicherheit],  [Koordinaten- und Zeitstempelprüfung; Path-Traversal-Schutz; XML-Escaping.], [/LF230/–/LF250/],
    [Betrieb und Qualität],        [Deterministische Tests, strukturiertes Logging, reproduzierbarer Build.], [/LL010/–/LL080/],
  ))
)

*Weitere Entwurfsprinzipien:*

#figure(
  caption: [Entwurfsprinzipien und deren messbarer Nutzen.],
  kind: table,
  align(left, table(
    columns: (3.2cm, 1fr, 1fr),
    stroke: tbl-stroke,
    inset: tbl-inset,
    [*Prinzip*], [*Entwurfsentscheidung*], [*Messbarer Nutzen*],

    [Hohe Kohäsion],
    [Module sind strikt nach fachlicher Verantwortung getrennt.],
    [Anpassungen am GPX-Format bleiben lokal auf den `bearing-adapter-gpx` begrenzt.],

    [Schwache Kopplung],
    [Komponenten kommunizieren ausschließlich über APIs statt über konkrete Implementierungen.],
    [Unterkomponenten lassen sich flexibler austauschen, was Mocking für Unit-Tests vereinfacht.],

    [Information Hiding],
    [Domänen-Logik wird hinter einer Fassade gekapselt. Daten fließen als unveränderliche Value Objects.],
    [Die interne Struktur ist geschützt; externe Aufrufer können den Systemzustand nicht schädigen.],

    [Separation of Concerns],
    [Saubere Trennung zwischen Kernlogik und Infrastruktur (Dateizugriff, Netzwerk-I/O).],
    [Fachlogik lässt sich ohne Infrastruktur-Overhead testen und umgekehrt.],

    [Wiederverwendbarkeit],
    [Einsatz des Strategy-Patterns für Policies und Optimizer.],
    [Neue Algorithmen lassen sich ohne Eingriffe in den bestehenden Kontrollfluss integrieren.],
  ))
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Benutzerprofile
// ─────────────────────────────────────────────────────────────────────────────

Als Bibliothek ohne eigene Benutzeroberfläche kennt die Peilungskomponente keine direkte Endnutzer-Interaktion. Stattdessen werden Stakeholder und Benutzerrollen im Sinne der IEEE-830-Norm definiert.

=== Stakeholder und Einflussmatrix

#figure(
  caption: [Stakeholder der Java-Peilungskomponente mit Erwartungen und Einfluss.],
  kind: table,
  align(left, table(
    columns: (2.8cm, 1fr, 2.5cm),
    stroke: tbl-stroke,
    inset: tbl-inset,
    [*Rolle*], [*Erwartung / Interesse*], [*Einfluss*],
    [Dozent / Prüfer],      [Nachweis der Vorlesungsinhalte, lauffähiger Code, formal saubere Dokumentation nach IEEE-/SOPHIST-Standard.], [hoch],
    [Studierendenteam],     [Wartbare, erweiterbare Architektur; klare Testbarkeit; nachvollziehbare Anforderungen.], [mittel],
    [Host-Entwickler/in],   [Stabile, vollständig dokumentierte API; klare Fehlersemantik über maschinenlesbare Exception-Codes.], [hoch],
    [Endnutzer/in (indirekt)],[Zuverlässige Peilungswerte und korrekte GPX-Ausgabe in der Host-Anwendung.], [mittel],
    [Betrieb],              [Strukturiertes Logging auf WARN-Level; keine stillen Fehler; deterministisches Verhalten.], [niedrig–mittel],
  ))
)

=== Primärer Akteur: Host-Anwendung

Der primäre Akteur ist die *Host-Anwendung*. Sie ruft die öffentliche Java-API der Bibliothek auf und übernimmt folgende Aufgaben:

- Bereitstellung von GNSS-Fixes (lat, lon, Zeitstempel, optional HDOP, Geschwindigkeit, Elevation).
- Steuerung des Session-Lebenszyklus (Start, Update, Complete/Abort).
- Entscheidung über Speicherort und Dateiverwaltung beim GPX-Export.
- Injektion des What3Words-Clients via `BearingBootstrap` (sofern genutzt).
- Registrierung von Listenern für Ereignisbenachrichtigungen.

=== Sekundärer Akteur: Externe Dienste

Als optionaler sekundärer Akteur fungiert der *What3Words-Dienst* (W3W): Er beantwortet HTTPS-Reverse-Lookup-Anfragen, die die Bibliothek über ihren konfigurierten HTTP-Adapter stellt. Die Bibliothek greift nie direkt auf GNSS-Hardware zu.

=== Funktionale Anforderungen – Übersicht

Die normativen Detail-Spezifikationen stehen in *Kapitel 3.1* (`/LF010/` … `/LF250/`, lückenlos). Vollständiger Katalog:

#import "requirement-catalog.typ": catalog-lf-table

#figure(
  caption: [Funktionaler Anforderungskatalog /LF010/ … /LF250/.],
  kind: table,
  catalog-lf-table,
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Einschränkungen
// ─────────────────────────────────────────────────────────────────────────────


Kapitel 1.2 hat den Funktionsumfang bereits umrissen. Die folgende Auflistung hält ihn als verbindliche Abgrenzung fest und ergänzt die Aspekte Validierung und Qualitätssicherung.

=== Im Scope
- Berechnung von Zielrichtung (Azimut), Entfernung und Himmelsrichtung (Ordinalrichtung) auf WGS84-Basis, bei verfügbarem Kurswert auch der Kursabweichung.
- Klar definierte Integrationsschnittstellen, über die der Host Positionsdaten und zugehörige Metadaten (z. B. Zeitstempel, Geschwindigkeit, Genauigkeit) bereitstellt.
- Verwaltung des Session-Lebenszyklus aus Start, laufender Aufzeichnung und Abbruch. Nach einem Abbruch bleiben die bis dahin erfassten Track-Daten für den Export erhalten.
- Konfigurierbare Aufzeichnung: Punktbudget (Soft-/Hard-Limit), Segmentierung bei Zeitlücken und Validierung der Eingaben (Koordinaten, Zeit). Wie oft Positionsupdates eintreffen, steuert der Host.
- Export der Track-Daten als GPX 1.1, wahlweise als String oder Bytefolge.
- Wählbare Optimierungsverfahren vor dem Export (n-ter Punkt, Mindestabstand, Geraden-Heuristik, Douglas-Peucker) sowie eine optionale What3Words-Auflösung mit lokalem Caching.
- Qualitätssicherung durch automatisierte Unit-Tests der Kernfunktionen — insbesondere der geografischen Berechnungen, der Optimierungsalgorithmen und der GPX-Serialisierung.

=== Außerhalb des Scopes
- Optimierung der eingehenden Track-Daten während der laufenden Aufzeichnung.
- Magnetische Peilung sowie die automatische Korrektur der magnetischen Deklination.
- Kartendarstellung, Map-Matching, Routing und Geocoding allgemeiner Adressen (ausgenommen die genannte What3Words-Integration).
- Direkte Hardwareanbindung (z. B. GNSS-Treiber, Sensorfusion); die rohen Messwerte liefert ausschließlich der Host.
- Feste Persistenzvorgaben wie ein vorgegebenes Dateiziel für den GPX-Export; über Speicherort und Dateiverwaltung entscheidet der Host.
- Cloud-Persistenz, Benutzer- und Rechteverwaltung.

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Annahmen und Abhängigkeiten
// ─────────────────────────────────────────────────────────────────────────────

Dieses Kapitel beschreibt die Annahmen und externen Abhängigkeiten, auf denen die definierten Anforderungen basieren. Änderungen an diesen Faktoren können Auswirkungen auf Anforderungen, Schnittstellen und das Systemverhalten haben.

=== Annahmen

#show figure: set block(breakable: true)
#figure(
  caption: [Übersicht der getroffenen Systemannahmen],
  kind: table,
  align(left, table(
    columns: (1.15cm, 4.2cm, 1fr, 1fr),
    stroke: tbl-stroke, inset: tbl-inset,
    [*ID*], [*Annahme*], [*Einfluss auf Anforderungen und Verhalten*], [*Folge bei Verletzung*],
    [A1], [Der Host liefert fertige Positions- und Kursdaten über die öffentliche API; die Bibliothek liest keine Sensoren und führt keine Sensorfusion aus.], [Systemgrenze und Funktionsumfang (Peilung und Track aus bereitgestellten Messwerten) bleiben definiert.], [Ohne valide Host-Daten sind Peilung und Aufzeichnung nicht sinnvoll nutzbar; dies liegt außerhalb der Verantwortung der Bibliothek.],
    [A2], [Nur der Host steuert die Aufruffrequenz; die Bibliothek dünnt den eingehenden Datenstrom nicht von sich aus aus.], [Roh-Trackfüllung, Punktbudget und Segmentierung folgen der vom Host gewählten Updatefrequenz.], [Andere Taktungsmodelle würden die dokumentierten Erwartungen verletzen und Anpassungen am SRS nach sich ziehen.],
    [A3], [Geografische Berechnungen und Eingaben beziehen sich auf WGS84-konforme Koordinaten, wie in der Spezifikation vorausgesetzt.], [Azimut, Distanz und Exportformate bleiben konsistent zur fachlichen Definition.], [Abweichende Bezugssysteme erfordern eine Überarbeitung der Anforderungen und Algorithmen.],
    [A4], [Die Host-JVM unterstützt mindestens Java~11.], [Bytecode, APIs und Tooling der Bibliothek sind darauf ausgelegt.], [Ältere JVMs werden nicht unterstützt; ein Wechsel der Mindestversion wäre eine SRS-Änderung.],
    [A5], [Integratoren und Tests können eine `Clock` injizieren, um zeitabhängiges Verhalten deterministisch abzusichern.], [Reproduzierbare Tests und nachvollziehbare Session-Zeitlogik.], [Ohne geeignete Zeitquelle können zeitbasierte Regeln in Tests schwer stabil gehalten werden.],
  ))
)

=== Abhängigkeiten

#figure(
  caption: [Übersicht der Systemabhängigkeiten und externen Voraussetzungen],
  kind: table,
  align(left, table(
    columns: (2.6cm, 3.4cm, 1fr),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Kategorie*], [*Abhängigkeit*], [*Details und Konsequenz*],
    [Host], [Konfiguration (W3W)], [API-Schlüssel und Adapter-Konfiguration bei Nutzung von What3Words. Ohne Schlüssel oder Netz gelten dokumentierte Fallbacks; volle W3W-Funktionalität entfällt.],
    [Host], [Dateisystem (GPX)], [Zielpfade, ggf. `SafeFileSink` und Schreibrechte. Bei Verletzung schlägt GPX-Persistenz fehl oder wird abgelehnt; Fehler über definierte Mechanismen sichtbar.],
    [Host], [Logging], [SLF4J-API der Bibliothek; konkretes Backend bindet der Host. Ohne Binding keine oder unerwartete Logausgabe; Fachlogik unberührt.],
    [Host], [Netzwerk], [HTTPS zur W3W-API nur bei aktivierter Nutzung; Erreichbarkeit und TLS-Vertrauen im Host-Umfeld. Eingeschränkter oder ausgefallener Reverse-Lookup und Cache-Update.],
    [Laufzeit], [Java SE], [Version 11 oder höher; Ausführungsumgebung im Host-Prozess.],
    [Build], [Apache Maven], [Projekt unter `implementation/`; Abhängigkeiten über Maven Central. Kompilieren, Testen, Packen; Änderungen am Build können das SRS ergänzen lassen.],
    [Laufzeit], [`slf4j-api`], [2.0.12 (Parent-POM). Fassade für Logging; Versionwechsel kann Integrationshinweise betreffen.],
    [Test], [JUnit~5, AssertJ, Mockito, Jimfs], [Versionen 5.10.2, 3.25.3, 5.11.0, 1.3.0. Nur für automatisierte Tests; nicht Teil der Host-Laufzeit.],
    [Extern], [What3Words-API], [Optional über HTTPS. Profil `w3w` steuert optionale Integrationstests im Build. Verfügbarkeit und API-Änderungen liegen außerhalb der Bibliothek.],
    [Architektur], [Eingebetteter Betrieb], [Kein eigener Serverprozess der Bibliothek; keine Abhängigkeit von einem separaten, von der Komponente bereitgestellten Dienst.],
  ))
)

#pagebreak()
]
