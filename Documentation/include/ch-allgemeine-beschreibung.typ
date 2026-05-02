#import "macros.typ": diagramm-box

#let tbl-stroke = 0.45pt + rgb("#9a9a9a")
#let tbl-inset  = 6pt

#let ch-allgemeine-beschreibung-kapitel = [
#set par(justify: true)

Dieses Kapitel beschreibt die Java-Peilungskomponente aus übergeordneter Perspektive: ihre Einbettung in das technische Umfeld, ihre Hauptfunktionen, die relevanten Benutzerprofile und Stakeholder, systemweite Einschränkungen sowie grundlegende Annahmen und Abhängigkeiten. Es entspricht dem Abschnitt „General Description" der IEEE-830-Vorlage.

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

Die folgende Tabelle gibt einen strukturierten Überblick über die Hauptfunktionsgruppen der Bibliothek. Die genaue Spezifikation der Einzelanforderungen folgt in Kapitel 3.

#figure(
  caption: [Hauptfunktionsgruppen der Java-Peilungskomponente mit Verweis auf Anforderungen.],
  kind: table,
  align(left, table(
    columns: (4cm, 1fr, 2.5cm),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Funktionsgruppe*],           [*Beschreibung*],                                                           [*Anforderungen*],
    [Session-Lebenszyklus],        [Start, laufende Aufzeichnung und Abbruch einer Peilungs-Session mit UUID-Identifikation.], [/LF010/–/LF090/],
    [Peilung und Kurs],            [Berechnung von geografischem Azimut, Entfernung (Haversine) und diskreter Himmelsrichtung; optionale Kursabweichung.], [/LF030/–/LF050/],
    [GPS-Track-Aufzeichnung],      [Kontinuierlicher Rohspeicher validierter GPS-Fixes; Segmentierung bei Zeitlücken; zweistufiges Punktbudget.], [/LF100/–/LF180/],
    [GPX-Export],                  [GPX-1.1-konformer Export des Tracks als String oder `byte[]`; optionales atomares Dateischreiben.], [/LF200/–/LF230/],
    [Track-Optimierung],           [Austauschbare Strategie-Algorithmen: n-ter Punkt, Mindestabstand, Geraden-Heuristik, Douglas-Peucker.], [/LF240/–/LF270/],
    [What3Words-Integration],      [Optionaler Reverse-Lookup von Koordinaten mit konfiguriertem Cache und TTL.], [/LF280/, /LF290/],
    [Validierung und Sicherheit],  [Koordinaten- und Zeitstempelprüfung; Path-Traversal-Schutz; XML-Escaping.], [/LF300/–/LF350/],
    [Betrieb und Qualität],        [Deterministische Testbarkeit via Clock-Injection; strukturiertes Logging; Build-Reproduzierbarkeit.], [/LF340/–/LF500/],
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
- Verwaltung des What3Words-API-Keys (sofern genutzt).
- Registrierung von Listenern für Ereignisbenachrichtigungen.

=== Sekundärer Akteur: Externe Dienste

Als optionaler sekundärer Akteur fungiert der *What3Words-Dienst* (W3W): Er beantwortet HTTPS-Reverse-Lookup-Anfragen, die die Bibliothek über ihren konfigurierten HTTP-Adapter stellt. Die Bibliothek greift nie direkt auf GNSS-Hardware zu.

=== Use-Case-Übersicht

#figure(
  caption: [Use-Case-Übersicht der Java-Peilungskomponente.],
  kind: table,
  align(left, table(
    columns: (1.6cm, 2.8cm, 1fr, 2.6cm),
    stroke: tbl-stroke, inset: 5pt,
    [*ID*], [*Name*], [*Kurzbeschreibung*], [*Anforderungsverweis*],
    [UC-01], [Session starten],     [Ziel setzen, Konfiguration validieren, Zustand ACTIVE.],          [/LF010/, /LF400/],
    [UC-02], [Positionsupdate],     [Validieren, Track aktualisieren, Snapshot ableitbar.],             [/LF030/, /LF100/],
    [UC-03], [Peilungswerte lesen], [Azimut, Distanz, Ordinalrichtung, optionaler Kursfehler.],         [/LF050/],
    [UC-04], [Regulär beenden],     [Zustand COMPLETED, GPX erzeugen.],                                [/LF060/],
    [UC-05], [Abbrechen],           [Zustand ABORTED, GPX-Daten ohne Pflichtdatei.],                   [/LF070/, /LF230/],
    [UC-06], [Optimieren + Export], [Strategiewahl, Serialisierung, optionales Dateischreiben.],        [/LF200/–/LF270/, /LF490/],
    [UC-07], [W3W auflösen],        [Optionaler Reverse-Lookup mit Cache.],                            [/LF280/, /LF290/],
    [UC-08], [W3W-Key fehlt],       [Fallback-String, kein Netzwerkaufruf.],                           [/LF280/],
    [UC-09], [Netzwerk-Timeout W3W],[WARN-Log, Fallback ohne Crash.],                                  [/LF280/],
    [UC-10], [GPX als Bytes],       [`byte[]` UTF-8 ohne BOM.],                                        [/LF230/],
    [UC-11], [Listener wirft],      [Exception gefangen, Session bleibt konsistent.],                  [/LF080/],
    [UC-12], [Reset nach Fehler],   [IDLE erreichbar nach ABORTED.],                                   [/LL160/],
  ))
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Einschränkungen
// ─────────────────────────────────────────────────────────────────────────────

Dieser Abschnitt dokumentiert die systemweiten Einschränkungen und Randbedingungen, die den Lösungsraum für Entwurf und Implementierung begrenzen.

=== Technische Randbedingungen

- *Laufzeitumgebung:* Java 17 LTS oder höher. Keine Verwendung von `sun.*`-APIs oder als deprecated markierten APIs (/LF440/).
- *Build-System:* Apache Maven; vollständige Kompilierung und Testausführung per `mvn test` ohne manuelle Zwischenschritte. Alle Abhängigkeiten über Maven Central auflösbar (/LF450/).
- *Keine UI-Abhängigkeiten:* Keinerlei Klassen aus AWT, Swing, JavaFX oder Android-UI-Frameworks (/LF430/).
- *Plattformunabhängigkeit:* Keine plattformspezifischen Pfade, Zeilentrennzeichen oder `sun.*`-APIs. Kompilierbar und ausführbar auf Windows, macOS und Linux (/LL110/).
- *Abhängigkeitslizenzierung:* Im Standard-Build nur permissiv lizenzierte Bibliotheken (Apache 2.0, MIT, BSD). Die W3W-Client-Abhängigkeit ist optional und nur im Maven-Profil `w3w` aktiviert (/LL200/).

=== Fachliche Einschränkungen

- Die Bibliothek führt *keine automatische Datenreduktion* beim Einlesen durch. Track-Optimierung erfolgt ausschließlich optional vor dem GPX-Export.
- *Magnetische Deklination* ist explizit ausgeschlossen (Host-Verantwortung).
- Die Bibliothek besitzt *keinen Sensorstack*: Der Host liefert fertige GNSS-Messwerte.
- *Persistenzvorgaben* obliegen dem Host: Die Bibliothek schreibt keine feste Datei, sondern liefert GPX als String oder `byte[]`.
- Standardmäßig steuert *ein einziger Host-Thread* die Peilung. Abweichungen müssen in der Javadoc gekennzeichnet werden (/LF350/).

=== Sicherheitstechnische Einschränkungen

- *Path-Traversal-Angriffe* müssen aktiv verhindert werden; ein unzulässiger Pfad führt zu einer `SecurityException` (/LF320/).
- *XML-Injection* ist durch konsequentes Escaping aller Nutzerdaten zu verhindern (/LL130/).
- Die Komponente darf *keine dynamische Code-Ausführung* aus GPX-Eingaben ermöglichen (XXE-Schutz).

=== Security Engineering: Sicherheitsanforderungsklassen

Sicherheitsanforderungen werden in drei Klassen eingeteilt: Risikovermeidung (Schwachstelle gar nicht erst einbauen), Risikoerkennung (Angriff neutralisieren, bevor Schaden entsteht) und Risikominderung (Schaden nach Angriff begrenzen).

#figure(
  caption: [Sicherheitsanforderungen: Risiken und Maßnahmen.],
  kind: table,
  align(left, table(
    columns: (2.8cm, 1.8cm, 1fr, 1fr),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Risiko*],                          [*Klasse*],   [*Architekturmaßnahme*],                                              [*Ort im Entwurf*],
    [Pfadmanipulation beim GPX-Export],  [Vermeidung], [Whitelisting erlaubter Basisverzeichnisse; Host konfiguriert Pfad explizit.], [Data Access Layer],
    [XML-Injection in GPX],              [Vermeidung], [Konsequentes Escaping aller Nutzerdaten bei der Serialisierung.],      [Data Access Layer],
    [Ausfall des W3W-Dienstes],          [Minderung],  [Timeout-Limit, begrenzte Retry-Anzahl, Fallback ohne W3W-Daten.],     [Service Layer + Data Access Layer],
    [Unkontrollierter Speicherverbrauch],[Vermeidung], [Punktbudget und Segmentierungs-Schwelle im Domain Core.],             [Business Rules Layer],
    [Unklare Fehlerbehandlung],          [Erkennung],  [Semantische Exception-Hierarchie; jeder Fehler hat eindeutigen Code.],[Service Layer],
  ))
)

#pagebreak()

// ─────────────────────────────────────────────────────────────────────────────
== Annahmen und Abhängigkeiten
// ─────────────────────────────────────────────────────────────────────────────

=== Annahmen über das Host-System

- Der Host beschafft GNSS-Fixes und reicht sie als fertige Messwerte weiter; die Bibliothek besitzt keinen Sensorstack.
- Die Aufrufhäufigkeit von `onPositionUpdate` liegt ausschließlich beim Host. Der Host soll vermeiden, unnötig dichte Fix-Ströme zu erzeugen, da die Bibliothek beim Einlesen nicht stillschweigend reduziert (/LL180/).
- Falls What3Words genutzt wird, stellt der Host einen gültigen API-Key bereit; fehlende Credentials werden von der Bibliothek durch einen Fallback abgefangen.
- Der Host verwaltet den Dateipfad für den GPX-Export und ist für die Verzeichnisstruktur verantwortlich.

=== Technische Abhängigkeiten

#figure(
  caption: [Externe Abhängigkeiten der Bibliothek im Maven-Build.],
  kind: table,
  align(left, table(
    columns: (3cm, 1fr, 2.5cm),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Abhängigkeit*],      [*Zweck*],                                                         [*Scope*],
    [JUnit 5],             [Unit- und Komponententests.],                                     [test],
    [SLF4J API],           [Logging-Abstraktion ohne konkretes Backend zu binden.],           [compile],
    [JaCoCo Maven Plugin], [Messung der Testabdeckung.],                                      [build],
    [Checkstyle Plugin],   [Statische Code-Analyse; Javadoc-Vollständigkeit erzwingen.],      [build],
    [W3W-Client],          [HTTP-Reverse-Lookup (nur aktiv im Maven-Profil `w3w`).],          [optional],
    [Jimfs (Test)],        [In-Memory-Dateisystem für dateisystemabhängige Tests.],            [test],
  ))
)

=== Abhängigkeit von externen Diensten

Die Bibliothek ist im Kern offline-fähig. Die What3Words-HTTP-API ist die einzige optionale externe Abhängigkeit zur Laufzeit. Ist kein Netzwerkzugang vorhanden oder kein API-Key konfiguriert, greift der definierte Fallback ohne Exception.

=== Umgebungsvoraussetzungen

- JDK 17 oder höher muss auf dem Entwicklungsrechner und im CI-System installiert sein.
- Maven 3.8 oder höher.
- Für den GPX-Export in Dateiform: Schreibrechte im konfigurierten Basisverzeichnis.
- Für den W3W-Lookup: Netzwerkzugang zu `https://api.what3words.com`.

#pagebreak()
]
