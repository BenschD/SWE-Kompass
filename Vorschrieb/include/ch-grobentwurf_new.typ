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

#table(
  columns: (2.8cm, 2.9cm, 1fr),
  stroke: tbl-stroke, inset: tbl-inset,
  [*Externe Schnittstelle*], [*Richtung*], [*Zweck*],
  [Host-Anwendung],   [eingehend],          [Steuerung des Session-Lebenszyklus, Übergabe von Positions- und Kursdaten],
  [Listener / Result],[ausgehend],          [Snapshots, Statuswechsel, Fehlerereignisse, GPX-Rückgabe an den Host],
  [Dateisystem],      [ausgehend, optional],[GPX-Persistenz nur bei expliziter Konfiguration durch den Host],
  [W3W-HTTP],         [ausgehend, optional],[Reverse-Lookup mit lokalem Cache; ohne Netzwerk vollständig deaktivierbar],
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
der *hohen Kohäsion*: Alles, was fachlich zusammengehört, landet im selben
Subsystem; technische Abhängigkeiten werden konsequent davon getrennt. Damit
ist sichergestellt, dass eine Änderung in einem Subsystem — z. B. ein anderer
GPX-Writer — keine Fachlogik berührt.

#table(
  columns: (2.7cm, 1fr, 1fr),
  stroke: tbl-stroke, inset: tbl-inset,
  [*Subsystem*],             [*Kernverantwortung*],                                          [*Bereitgestellte Dienste*],
  [API / Application Service],[Orchestrierung der Use Cases; Session-Zustand; Fehler-Mapping],[Session starten, beenden und abbrechen; konsistenten Snapshot liefern],
  [Domain Core],             [Fachregeln ohne jegliche I/O-Kopplung],                        [Azimut, Distanz, Ordinalrichtung; Sampling, Validierung, Segmentierung, Optimierung],
  [Ports (SPI)],             [Abstraktion technischer Abhängigkeiten],                       [Stabile Verträge für GPX, Zeit, Dateisystem, Logging, W3W],
  [Infrastruktur / Adapter], [Konkrete Realisierung der Ports],                              [XML-Serialisierung, Datei-I/O, HTTP-Client, Systemuhr, Logging],
)

=== Schichtenmodell

Die vier Subsysteme sind als streng gerichtete Schichten angeordnet. Jede
Schicht kommuniziert ausschließlich mit der direkt darunterliegenden; ein
Überspringen von Schichten ist verboten. Dadurch entstehen keine zyklischen
Abhängigkeiten, und jede Schicht ist einzeln testbar und austauschbar.

#diagramm-box("Schichten von oben nach unten")[
  *Host-System* (außerhalb der Komponente)\
  Beliebige Java-Anwendung (Desktop, Web, Embedded). Greift ausschließlich
  über die öffentliche API-Fassade zu. Keine direkten Infrastrukturzugriffe.

  ↓ nur über öffentliche API-Aufrufe

  *API / Application Service*\
  Steuert den Session-Lebenszyklus, prüft Vorbedingungen, bildet Fehler auf
  semantische Codes ab und orchestriert die Fachfälle. Kennt die Domain,
  kennt keine Adapter.

  ↓ nur über Domain-Schnittstellen

  *Domain Core*\
  Enthält alle fachlichen Regeln und Berechnungen (Azimut, Distanz,
  Sampling, Filterung, Segmentierung, Optimierung). Vollständig I/O-frei.
  Kein Import von Infrastruktur-Klassen.

  ↓ nur über Port-Interfaces (SPI)

  *Port-Schicht (SPI)*\
  Technologieunabhängige Verträge. Die Domain formuliert, was sie braucht
  (z. B. "schreibe GPX"), aber nicht wie. Dies ermöglicht Mocking im Test
  ohne reale Abhängigkeiten.

  ↓ implementiert durch

  *Infrastruktur / Adapter*\
  Realisiert die Ports: GPX-Serialisierung nach XML, HTTP-Client für W3W,
  Dateisystem-Zugriff, Systemuhr, SLF4J-Logging.
]

=== Kommunikationsregeln

#table(
  columns: (3.0cm, 3.0cm, 2.0cm, 1fr),
  stroke: tbl-stroke, inset: tbl-inset,
  [*Von*],          [*Nach*],        [*Erlaubt?*],[*Begründung*],
  [Host],           [API],           [Ja],        [Einziger legaler Einstiegspunkt; kapselt alles dahinter],
  [Host],           [Domain],        [Nein],      [Würde Fachlogik exponieren und Kapselung der API-Fassade unterlaufen],
  [Host],           [Infrastruktur], [Nein],      [Technische Details sind kein Teil der öffentlichen Schnittstelle],
  [API],            [Domain],        [Ja],        [Use-Case-Orchestrierung ohne I/O-Kopplung],
  [API],            [Infrastruktur], [Nein],      [Infrastruktur wird ausschließlich über Ports angesprochen],
  [Domain],         [Ports (SPI)],   [Ja],        [Externe Effekte ausschließlich über abstrakte Verträge],
  [Domain],         [Infrastruktur], [Nein],      [Hält die Fachlogik I/O-frei und testbar],
  [Infrastruktur],  [Domain],        [Nein],      [Keine Rückkopplung; verhindert zyklische Abhängigkeiten],
)

=== Paket- und Modulschnitt

Jedes Subsystem wird als eigenständiges Maven-Modul realisiert. Dadurch
erzwingt das Build-System die Schichtregeln: Ein Modul kann nur importieren,
was als Abhängigkeit deklariert ist.

#table(
  columns: (2.5cm, 3.4cm, 1fr),
  stroke: tbl-stroke, inset: tbl-inset,
  [*Modul*],                  [*Paketbasis*],                            [*Verantwortung*],
  [`bearing-api`],            [`com.example.bearing.api`],               [Öffentliche Fassade, DTOs, Fehlercodes, Session-Konfiguration],
  [`bearing-domain`],         [`com.example.bearing.domain`],            [Fachlogik, Policies, Zustandsmodell, Value Objects],
  [`bearing-spi`],            [`com.example.bearing.spi`],               [Technologieunabhängige Port-Interfaces],
  [`bearing-adapter-gpx`],    [`com.example.bearing.adapter.gpx`],       [GPX-1.1-Writer],
  [`bearing-adapter-w3w`],    [`com.example.bearing.adapter.w3w`],       [Optionaler W3W-HTTP-Client mit Cache],
  [`bearing-adapter-system`], [`com.example.bearing.adapter.system`],    [Dateisystem, Systemuhr, Logging],
)

// UML-Diagramme

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Component_Layers.svg"),
  caption: [UML-Komponentendiagramm: Schichten und Port-Adapter-Kopplung.],
)

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Package_Architecture.svg"),
  caption: [UML-Paketdiagramm: logische Paketabhängigkeiten und Schnittstellenrichtung.],
)

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Composite_BearingSession.svg"),
  caption: [UML-Kompositionsstrukturdiagramm: interne Struktur der zentralen Session-Komponente.],
)

#pagebreak()

// ──────────────────────────────────────────────────────────────────────────
== Dynamische Sicht
// ──────────────────────────────────────────────────────────────────────────

Die dynamische Sicht beschränkt sich auf die drei wesentlichen Laufzeitszenarien.
Vollständige Ablaufdetails auf Methodenebene gehören in den Feinentwurf.

=== Szenario A — Regulärer Positionsupdate

Der Host übergibt einen GPS-Fix an die API. Die API validiert Vorbedingungen
(Session aktiv, Fix nicht null). Der Domain Core prüft den Fix gegen die
Sampling-Policy und die Qualitätsfilter. Bei bestandener Prüfung wird der
Track-Zustand aktualisiert und ein neuer Snapshot bereitgestellt. Bei einem
Qualitätsproblem wird ein semantisches Fehlerereignis an den Listener
weitergeleitet; der Track-Zustand bleibt konsistent.

=== Szenario B — Regulärer Session-Abschluss

Der Host ruft `complete` auf. Die API delegiert an den Domain Core, der den
Track finalisiert und ggf. eine Segmentgrenze schließt. Anschließend wird
über den GPX-Port die Serialisierung angestoßen. Die Infrastruktur liefert
das GPX-Ergebnis zurück, das die API als `GpxResult` an den Host weitergibt.
Optional schreibt `SafeFileSink` die Daten ins Dateisystem, falls der Host
dies konfiguriert hat.

=== Szenario C — Fehlerpfad: ungültige Koordinate

Der Host übergibt einen Fix mit NaN-Koordinaten. Die API erkennt den Fehler
bereits bei der Eingangsvalidierung und erzeugt eine `ValidationException`.
Es wird kein Domänenzustand verändert, kein GPX-Port aufgerufen und kein
Logging von Trackinformationen ausgelöst. Der Fehler wird dem Listener
gemeldet.

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Activity_PositionUpdate.svg"),
  caption: [UML-Aktivitätsdiagramm: Verarbeitung eines Positionsupdates inkl. Fehlerast.],
)

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Sequence_Complete.svg"),
  caption: [UML-Sequenzdiagramm: regulärer Session-Abschluss mit GPX-Aufbereitung.],
)

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Sequence_ValidationError.svg"),
  caption: [UML-Sequenzdiagramm: Fehlerpfad bei ungültiger Koordinate.],
)

#pagebreak()

// ──────────────────────────────────────────────────────────────────────────
== Physische Sicht
// ──────────────────────────────────────────────────────────────────────────

Die Komponente wird als Bibliothek in den Host-Prozess eingebettet und läuft
in dessen JVM. Es existiert kein eigener Prozess, kein eigenständiger Server
und kein Nachrichtensystem. Externe Kommunikation findet ausschließlich über
zwei optionale Kanäle statt: HTTPS zur W3W-API und Dateisystemzugriffe für
den GPX-Export. Beide Kanäle sind abschaltbar; die Kernfunktion (Peilung,
Track-Aufzeichnung) läuft ohne Netzwerkverbindung.

Diese Entscheidung sichert Offline-Betrieb und vereinfacht Deployment und
Test erheblich: Für Integrationstests reichen lokale Mocks der Ports.

#figure(
  puml-fig("../plantuml/out/SWE_Kompass_Deployment_Runtime.svg"),
  caption: [UML-Verteilungsdiagramm: Laufzeitknoten, Artefakte und Kommunikationspfade.],
)

#pagebreak()

// ──────────────────────────────────────────────────────────────────────────
== Entwurfsprinzipien
// ──────────────────────────────────────────────────────────────────────────

Die folgende Tabelle belegt, wie die Architektur die in der Vorlesung
geforderten Qualitätskriterien erfüllt. Jedes Prinzip ist einer konkreten
Entwurfsentscheidung zugeordnet, damit der Nachweis prüfbar bleibt.

#table(
  columns: (3.0cm, 1fr, 1fr),
  stroke: tbl-stroke, inset: tbl-inset,
  [*Prinzip*],             [*Architekturentscheidung*],                                          [*Messbarer Nutzen*],
  [Hohe Kohäsion],         [Subsysteme entlang fachlicher Verantwortung; kein Technik-Mischmasch],[Änderungen an GPX-Format berühren nur `bearing-adapter-gpx`],
  [Schwache Kopplung],     [Abhängigkeit nur über Port-Interfaces, nie auf konkrete Adapter],     [Adapter austauschbar ohne Domain-Änderung; Mocking für Tests trivial],
  [Information Hiding],    [Domain-Interna hinter API-Fassade; Value Objects ohne Setter],        [Host kann keine interne Darstellung ausnutzen oder versehentlich korrumpieren],
  [Separation of Concerns],[Fachlogik strikt getrennt von XML/HTTP/Datei-I/O],                    [Domain-Tests ohne Infrastruktur; Infrastruktur-Tests ohne Domänenwissen],
  [Wiederverwendung],      [Policies und Optimizer als austauschbare Strategien definiert],        [Neues Optimierungsverfahren erfordert nur eine neue Port-Implementierung],
)

// ──────────────────────────────────────────────────────────────────────────
== Methodische Dekomposition
// ──────────────────────────────────────────────────────────────────────────

Die Vorlesung fordert drei Schritte. Sie werden hier auf die
Peilungskomponente angewandt.

=== Schritt 1: Subsystem-Identifikation

Operationen werden nach ihrem fachlichen Zweck zu Diensten gruppiert; Dienste
mit gemeinsamer Verantwortung bilden ein Subsystem.

#table(
  columns: (2.8cm, 3.1cm, 1fr),
  stroke: tbl-stroke, inset: tbl-inset,
  [*Operation*],         [*Dienst*],                             [*Ziel-Subsystem*],
  [Session starten],     [Session-Anlage, Zustandsinitialisierung],[API / Application Service],
  [Positionsupdate],     [Validierung, Track-Aktualisierung],    [Domain Core],
  [Kursupdate],          [Kursabweichungsberechnung],            [Domain Core],
  [Session abschließen], [Track-Finalisierung, Export-Trigger],  [API + Domain + Ports],
  [GPX exportieren],     [Serialisierung, optionale Persistenz], [Ports + Infrastruktur],
  [W3W auflösen],        [Reverse-Lookup, Caching],              [Ports + Infrastruktur],
)

=== Schritt 2: Dienstspezifikation

Jeder Dienst wird mit seinem Vertrag beschrieben — was muss beim Aufruf
gelten (Vorbedingung), was gilt danach (Nachbedingung), welche Fehlerfälle
sind definiert. Konkrete Parameternamen und Rückgabetypen auf Klassenebene
werden im Feinentwurf festgelegt.

#table(
  columns: (2.8cm, 1fr, 1fr),
  stroke: tbl-stroke, inset: tbl-inset,
  [*Dienst*],            [*Vertrag (Kurzbeschreibung)*],                              [*Fehlerfälle*],
  [Session starten],     [Legt genau eine aktive Session an; liefert Session-ID zurück],  [Bereits aktive Session; ungültiges Ziel],
  [Positionsupdate],     [Verarbeitet validen Fix gemäß Sampling-Policy; aktualisiert Track],[Ungültige Koordinaten; keine aktive Session],
  [Kursupdate],          [Optionaler Kursbezug für Abweichungsberechnung],             [Ungültiger Kurswert; keine aktive Session],
  [Session abschließen], [Finalisiert Session; liefert GPX-Ergebnis],                  [Keine aktive Session; Serialisierungsfehler],
  [Session abbrechen],   [Bricht ab; liefert bis dahin erfasste GPX-Daten],            [Keine aktive Session; Serialisierungsfehler],
  [Snapshot abrufen],    [Liefert konsistente Momentaufnahme des laufenden Tracks],     [Keine aktive Session],
)

=== Schritt 3: Subsystem-Anordnung

Die Subsysteme werden als Schichten angeordnet: Host → API → Domain → Ports
→ Adapter. Es existieren keine zyklischen Abhängigkeiten. Optionale Dienste
(W3W, Dateipersistenz) sind als Adapter realisiert und beeinflussen die
Kernlogik nicht. Schichten kommunizieren ausschließlich über definierte
Interfaces, nie über konkrete Klassen der Nachbarschicht.

#pagebreak()

// ──────────────────────────────────────────────────────────────────────────
== Security Engineering im Grobentwurf
// ──────────────────────────────────────────────────────────────────────────

Sicherheitsanforderungen werden laut Vorlesung in drei Klassen eingeteilt:
Risikovermeidung (Schwachstelle gar nicht erst einbauen), Risikoerkennung
(Angriff neutralisieren bevor Schaden entsteht) und Risikominderung
(Schaden nach Angriff begrenzen). Die folgende Tabelle wendet diese
Klassifizierung auf die relevanten Risiken der Peilungskomponente an.

#table(
  columns: (2.8cm, 1.8cm, 1fr, 1fr),
  stroke: tbl-stroke, inset: tbl-inset,
  [*Risiko*],                   [*Klasse*],        [*Architekturmaßnahme*],                                    [*Ort im Entwurf*],
  [Pfadmanipulation beim GPX-Export],[Vermeidung], [Whitelisting erlaubter Basisverzeichnisse; Host konfiguriert Pfad explizit],[API + FileSinkPort + SafeFileSink],
  [XML-Injection in GPX],       [Vermeidung],      [Konsequentes Escaping aller Nutzerdaten bei der Serialisierung],[GpxWriterPort + GpxXmlWriter],
  [Ausfall des W3W-Dienstes],   [Minderung],       [Timeout-Limit, begrenzte Retry-Anzahl, Fallback ohne W3W-Daten],[W3wClientPort + W3wHttpClient],
  [Unkontrollierter Speicherverbrauch],[Vermeidung],[Punktbudget, Sampling-Intervall und Segmentierungslimit im Domain Core],[Domain Core],
  [Unklare Fehlerbehandlung],   [Erkennung],       [Semantische Exception-Hierarchie; jeder Fehler hat eindeutigen Code],[API / Application Service],
)

// ──────────────────────────────────────────────────────────────────────────
== Soll-Ist-Abdeckungsmatrix
// ──────────────────────────────────────────────────────────────────────────

Die Matrix weist nach, dass alle Inhalte des Foliensatzes 07 adressiert sind.

#table(
  columns: (3.0cm, 2.5cm, 1.8cm, 1fr),
  stroke: tbl-stroke, inset: tbl-inset,
  [*Forderung (Foliensatz)*],     [*Soll*],                           [*Status*],[*Nachweis*],
  [Subsystem-Spezifikation],      [Zerlegung in handhabbare Einheiten],[Erfüllt], [Abschnitt Statische Sicht — Subsystem-Spezifikation],
  [Schnittstellen-Spezifikation], [Dienste nach außen präzisieren],   [Erfüllt], [Abschnitt Methodische Dekomposition — Schritt 2],
  [Systemsicht],                  [Systemgrenze + externe Schnittstellen],[Erfüllt],[Abschnitt Systemsicht + Kontextdiagramm],
  [Statische Sicht],              [Komponentenstruktur + Abhängigkeiten],[Erfüllt],[Schichtenmodell, Kommunikationsregeln, Paket-/Kompositionssicht],
  [Dynamische Sicht],             [Laufzeitzusammenwirken],           [Erfüllt], [Szenarien A–C + Aktivitäts-/Sequenzdiagramme],
  [Physische Sicht],              [Verteilung auf Knoten],            [Erfüllt], [Abschnitt Physische Sicht + Verteilungsdiagramm],
  [Hohe Kohäsion],                [Starker innerer Zusammenhalt],     [Erfüllt], [Entwurfsprinzipien — Kohäsion-Zeile],
  [Schwache Kopplung],            [Geringe Kopplung zwischen Modulen],[Erfüllt], [Ports/SPI + Kommunikationsregeln],
  [Information Hiding / SoC],     [Klare Trennung fachlich/technisch],[Erfüllt], [Domain vs. Infrastruktur + Port-Schicht],
  [Wiederverwendung],             [Gemeinsamkeiten nutzen],           [Erfüllt], [Strategien und Adapter],
  [Dekomposition Schritt 1],      [Subsystem-Identifikation],         [Erfüllt], [Methodische Dekomposition — Schritt 1],
  [Dekomposition Schritt 2],      [Dienstspezifikation],              [Erfüllt], [Methodische Dekomposition — Schritt 2],
  [Dekomposition Schritt 3],      [Subsystem-Anordnung],              [Erfüllt], [Methodische Dekomposition — Schritt 3],
  [UML-Komponentendiagramm],      [Bausteine + Abhängigkeiten],       [Erfüllt], [SWE_Kompass_Component_Layers],
  [UML-Paketdiagramm],            [Hierarchische Organisation],       [Erfüllt], [SWE_Kompass_Package_Architecture],
  [UML-Kompositionsstruktur],     [Interne Struktur einer Komponente],[Erfüllt], [SWE_Kompass_Composite_BearingSession],
  [UML-Verteilungsdiagramm],      [Architektur zur Laufzeit],         [Erfüllt], [SWE_Kompass_Deployment_Runtime],
  [Security Engineering],         [Sicherheitsanforderungen im Entwurf],[Erfüllt],[Abschnitt Security Engineering],
)

#pagebreak()
]
