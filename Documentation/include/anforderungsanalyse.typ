// Kapitel 2 – ausgelagert zur besseren Wartbarkeit und zur Erreichung des Umfangs
// für die Anforderungsanalyse (klassischer Aufbau nach Muster „Anforderungsanalyse 2019“).

#set par(justify: true)

=== 2.0 Einordnung und Dokumentationskonvention

Dieses Kapitel dokumentiert die *Anforderungsanalyse* für die Java-Peilungs-Komponente. Es folgt bewusst dem formalen Aufbau einer klassischen *Anforderungssammlung* (vgl. Musterdokument „Anforderungsanalyse 2019“): Zielbestimmung, Produkteinsatz, funktionale Anforderungen, Produktdaten, nicht-funktionale Anforderungen, Qualitätsanforderungen, Ergänzungen sowie ein ausführliches Glossar. Ergänzend werden SWE-Artefakte integriert, die in der Vorlesung gefordert sind (Stakeholder, Risiken, OOA-Hinweise, Testbarkeit, Traceability).

*Konvention für IDs:* Funktionale Anforderungen tragen Präfix `/LF…/`, nicht-funktionale `/LL…/`, Produktdaten `/LD…/`. Verweise verbinden zusammengehörige Anforderungen (z. B. „`/LF030/` verweist auf `/LL010/`“).

*SOPHIST-Qualität der Formulierungen:* Jede Anforderung ist als vollständiger Satz formuliert, enthält einen erkennbaren Akteur, eine eindeutige Systemreaktion und ist überprüfbar (Testfall, Messgröße oder Inspektion).

#pagebreak()

=== 2.1 Zielbestimmung

*Hintergrund:* Die iOS-App „Kompass Professional“ demonstriert eine Peilungsfunktion: Sie zeigt *wohin* (Richtung) relativ zur aktuellen Orientierung bzw. Position – ohne Navigation im Sinne einer Turn-by-Turn-Führung. Für Lehr- und Integrationszwecke soll dieselbe *fachliche* Funktionalität als wiederverwendbare Java-Bibliothek bereitgestellt werden.

*Zielbild:* Die Bibliothek ermittelt aus vom Host gelieferten Positions- und Kursdaten die Peilungsgrößen (insbesondere geografischer Azimut und Entfernung) und zeichnet währenddessen einen GPS-Track auf, der als GPX 1.1 exportierbar ist. Optional kann eine What3Words-Auflösung erfolgen.

*Nutzen für den Auftraggeber (Lehre):* Die Analyse ist die verbindliche Referenz für Implementierung, Tests und Abnahme. Sie vermeidet bewusst „User Stories“ und liefert stattdessen normierbare, tabellarische Anforderungen.

*Erfolgskriterien (übergeordnet):*

- Die Komponente ist ohne UI lauffähig und per `mvn test` verifizierbar.
- Alle in diesem Kapitel genannten `/LF…/`-Anforderungen sind durch mindestens einen dokumentierten Testfall abdeckbar.
- GPX-Ausgaben entshalten den GPX-1.1-Namespace und valide Zeitstempel im UTC-ISO-8601-Format.

#pagebreak()

=== 2.2 Produkteinsatz

*Einsatzgebiet:* Integration in beliebige Java-Anwendungen (Desktop, Server, eingebettete JVM), die selbst Sensordaten beschaffen und an die Bibliothek übergeben.

*Typische Host-Rollen:*

- *Outdoor-Applikation* mit eigener Karten-UI (Bibliothek liefert nur Zahlen und GPX).
- *Feld-Dienst* mit periodischen GPS-Fixes; Bibliothek übernimmt Sampling-Policy und Export.
- *Lehre/Labor*: Mock-GPS-Streams treiben deterministische Tests.

*Schnittstelle zur Außenwelt:* Die Bibliothek spricht **keine** Hardware-APIs an. Stattdessen definiert sie eine klare Java-API. Persistenz erfolgt optional über das Dateisystem des Hosts.

*Randbedingungen:* Keine ausführbare „Fat-JAR“-Anwendung als Liefergegenstand; Lieferobjekt ist Quelltext plus Dokumentation. Keine Cloud-Pflicht; W3W nur optional.

#pagebreak()

=== 2.3 Stakeholder, Interessen und Konflikte

==== 2.3.1 Stakeholder-Tabelle

#table(
  columns: (1.1fr, 1.4fr, 1.2fr),
  inset: 6pt,
  stroke: 0.4pt + rgb("#CCCCCC"),
  [*Stakeholder*], [*Primäres Interesse*], [*Konfliktpotenzial*],
  [Dozent / Auftraggeber], [Bewertbarkeit, Vollständigkeit, Lauffähigkeit], [Umfang vs. Zeitbudget],
  [Studententeam], [Klare Scope-Grenzen, machbare API], [Feature-Drift vs. „1+“-Extras],
  [Host-Entwickler], [Stabile API, gute Fehlermeldungen], [Breaking Changes bei API-Revision],
  [Wartende Organisation], [Verständliche Doku, erweiterbare Module], [Dokumentations-Drift],
)

==== 2.3.2 RACI (vereinfacht)

#table(
  columns: (2fr, 0.5fr, 0.5fr, 0.5fr, 0.5fr),
  inset: 5pt,
  stroke: 0.4pt + rgb("#CCCCCC"),
  [*Aktivität*], [*R*], [*A*], [*C*], [*I*],
  [Anforderungen freigeben], [Team], [Dozent], [–], [–],
  [API finalisieren], [Team], [Team], [Dozent], [–],
  [Tests schreiben], [Team], [Team], [Dozent], [–],
  [Abnahme], [Dozent], [Dozent], [Team], [–],
)

#pagebreak()

=== 2.4 Funktionale Anforderungen (klassische Tabellenform)

Die folgenden Tabellen folgen dem Muster *ID, Funktion, Quelle, Verweise, Akteur, Beschreibung*.

==== 2.4.1 Peilung, Session-Lebenszyklus, API

#[
  #set text(10.5pt)
  #table(
    columns: (0.55fr, 1.0fr, 0.75fr, 0.65fr, 0.75fr, 2.1fr),
    inset: 4pt,
    stroke: 0.35pt + rgb("#BBBBBB"),
    align: (left, left, left, left, left, left),
    table.header(
      [*ID*], [*Funktion*], [*Quelle*], [*Verweise*], [*Akteur*], [*Beschreibung*],
    ),
    [/LF001/], [Peilung starten], [Projektauftrag SWE], [–], [Host-App], [Das System muss eine neue Peilungssession anlegen, wenn der Host eine gültige Zielkoordinate und eine gültige Konfiguration übergibt.],
    [/LF002/], [Peilung nur einfach aktiv], [Architekturregel], [/LF001/], [Host-App], [Das System muss verhindern, dass parallel mehrere aktive Sessions derselben Komponenteninstanz ohne explizite Finalisierung existieren.],
    [/LF003/], [Positionsupdate verarbeiten], [Projektauftrag SWE], [/LF001/, /LL010/], [Host-App], [Das System muss jedes übergebene Positionsupdate validieren und – bei Gültigkeit – die Peilungsberechnung aktualisieren.],
    [/LF004/], [Kursupdate verarbeiten], [Klärungsgespräch], [/LF003/], [Host-App], [Das System muss optional einen vom Host gelieferten Kurs (0–360°) nutzen, um eine Kursabweichung zur Zielrichtung zu bestimmen.],
    [/LF005/], [Peilungsinformationen abfragen], [Projektauftrag SWE], [/LF003/], [Host-App], [Das System muss auf Anfrage die aktuelle Zielrichtung (geografischer Azimut), die Entfernung zum Ziel sowie eine diskrete Himmelsrichtung liefern.],
    [/LF006/], [Peilung regulär beenden], [Projektauftrag SWE], [/LF020/, /LF030/], [Host-App], [Das System muss eine aktive Session deterministisch beenden, den Status auf „regulär abgeschlossen“ setzen und GPX-Daten erzeugen.],
    [/LF007/], [Peilung abbrechen], [Klärungsgespräch Bohl], [/LF006/, /LF031/], [Host-App], [Das System muss eine Abbruchoperation unterstützen, die die bis dahin aufgezeichneten Daten nicht verwirft und GPX-Daten bereitstellt; automatisches Dateispeichern erfolgt nur, wenn die Konfiguration dies explizit erlaubt oder der Host speichert.],
    [/LF008/], [Listener-Events], [Vorlesung SWE (Observer)], [/LF003/, /LF006/], [Host-App], [Das System muss Ereignisse für Start, Update, Abschluss und Fehler über Listener synchron oder konfigurierbar serialisiert veröffentlichen.],
    [/LF009/], [Fehler semantisch klassifizieren], [Qualität], [/LL010/], [Host-App], [Das System muss Eingabe-, Zustands- und I/O-Fehler über eine klar dokumentierte Exception-Hierarchie unterscheidbar machen.],
    [/LF010/], [Internationalisierbare Fehlertexte], [NFR Wartbarkeit], [/LF009/], [Host-App], [Das System muss Fehlertexte technisch so kapseln, dass ein Host sie lokalisieren kann (z. B. Fehlercodes + Message-Keys).],
  )
]

#pagebreak()

==== 2.4.2 GPS-Track, Sampling, Datenpunkte

#[
  #set text(10.5pt)
  #table(
    columns: (0.55fr, 1.0fr, 0.75fr, 0.65fr, 0.75fr, 2.1fr),
    inset: 4pt,
    stroke: 0.35pt + rgb("#BBBBBB"),
    align: (left, left, left, left, left, left),
    table.header(
      [*ID*], [*Funktion*], [*Quelle*], [*Verweise*], [*Akteur*], [*Beschreibung*],
    ),
    [/LF020/], [Trackpunkte aufzeichnen], [Projektauftrag SWE], [/LF003/], [Host-App], [Das System muss während einer aktiven Session GPS-Punkte mit Zeitstempel speichern, sofern sie die Sampling-Policy erfüllen.],
    [/LF021/], [Zeitintervall konfigurieren], [Klärungsgespräch Bohl], [/LF020/], [Host-App], [Das System muss ein konfigurierbares Mindestintervall zwischen gespeicherten Punkten unterstützen (z. B. 0,5s–60s).],
    [/LF022/], [Punktbudget konfigurieren], [Fragenkatalog Team], [/LF020/], [Host-App], [Das System muss optional eine Obergrenze für die Anzahl gespeicherter Punkte pro Session unterstützen, ohne stillschweigend Daten zu verlieren, ohne dass der Host informiert wird.],
    [/LF023/], [HDOP/Satelliten auswerten], [Fragenkatalog Team], [/LF020/, /LL020/], [Host-App], [Das System muss optional Punkte mit schlechter HDOP oder zu wenigen Satelliten verwerfen oder markieren, abhängig von der Konfiguration.],
    [/LF024/], [Geschwindigkeits-Sprünge erkennen], [Datenqualität], [/LF020/], [Host-App], [Das System muss unrealistische Positions-Sprünge erkennen und gemäß Policy verwerfen oder nur protokollieren.],
    [/LF025/], [Höhe und Genauigkeit speichern], [Fragenkatalog Team], [/LF020/], [Host-App], [Das System muss optionale Felder (Höhe, HDOP, Geschwindigkeit) in GPX-Trackpunkten abbilden, wenn der Host sie liefert.],
    [/LF026/], [Deduplizierung], [Qualität], [/LF020/], [Host-App], [Das System muss identische Koordinaten mit identischem Zeitstempel nicht mehrfach als separate logische Messung führen.],
    [/LF027/], [Segmentierung bei Lücken], [Qualität], [/LF020/], [Host-App], [Das System muss zeitliche Lücken über einem konfigurierbaren Schwellwert als neue Track-Segmente kennzeichnen oder dokumentieren.],
    [/LF028/], [Hard-Limit Punkte], [Fragenkatalog Team], [/LF022/, /LL030/], [Host-App], [Das System muss beim Erreichen eines konfigurierten Hard-Limits die Aufzeichnung kontrolliert stoppen oder in einen definierten Overflow-Modus wechseln und den Host benachrichtigen.],
  )
]

#pagebreak()

==== 2.4.3 GPX-Export, Optimierung, W3W

#[
  #set text(10.5pt)
  #table(
    columns: (0.55fr, 1.0fr, 0.75fr, 0.65fr, 0.75fr, 2.1fr),
    inset: 4pt,
    stroke: 0.35pt + rgb("#BBBBBB"),
    align: (left, left, left, left, left, left),
    table.header(
      [*ID*], [*Funktion*], [*Quelle*], [*Verweise*], [*Akteur*], [*Beschreibung*],
    ),
    [/LF030/], [GPX 1.1 erzeugen], [Klärungsgespräch Bohl], [/LF020/], [Host-App], [Das System muss aus einer abgeschlossenen oder abgebrochenen Session einen GPX-1.1-konformen Datenstrom erzeugen können.],
    [/LF031/], [GPX-Metadaten], [GPX Standard], [/LF030/], [Host-App], [Das System muss Metadaten wie Zeitbereich, Name, optional Beschreibung und Quelle setzen, soweit die Informationen vorliegen.],
    [/LF032/], [Atomares Schreiben], [IEEE-830-NFR], [/LF033/], [Host-App], [Das System muss beim optionalen Schreiben auf das Dateisystem zuerst eine temporäre Datei schreiben und anschließend atomar ersetzen.],
    [/LF033/], [Export als String/Bytes], [Klärungsgespräch Bohl], [/LF030/], [Host-App], [Das System muss GPX unabhängig vom Dateisystem als `String` oder `byte[]` bereitstellen, damit Abbruch ohne Datei möglich ist.],
    [/LF034/], [Optimierung „jeder 10. Punkt“], [Klärungsgespräch Bohl], [/LF030/], [Host-App], [Das System muss eine punktbasierte Reduktion (N-Intervall) implementieren, die Start- und Endpunkt respektiert.],
    [/LF035/], [Optimierung „alle 100 m“], [Klärungsgespräch Bohl], [/LF030/], [Host-App], [Das System muss eine distanzbasierte Reduktion entlang des Tracks implementieren.],
    [/LF036/], [Geraden auf zwei Punkte reduzieren], [Klärungsgespräch Bohl], [/LF030/], [Host-App], [Das System muss nahezu kollineare Punktfolgen in einem Toleranzband auf Start- und Endpunkt reduzieren können; explizit keine Garantie für enge Kurvenradien.],
    [/LF037/], [Douglas–Peucker optional], [1+-Anforderung], [/LF030/], [Host-App], [Das System muss optional Douglas–Peucker mit metrischer Toleranz anbieten.],
    [/LF038/], [What3Words auflösen], [Klärungsgespräch Bohl], [/LF005/], [Host-App], [Das System muss optional Koordinaten in eine What3Words-Adresse auflösen, sofern API-Key und Netzwerk vorhanden sind; bei Fehler ist ein definierter Fallback zu liefern.],
    [/LF039/], [W3W-Cache], [Performance], [/LF038/], [Host-App], [Das System muss wiederholte W3W-Anfragen für identische Koordinaten über einen Cache reduzieren können.],
    [/LF040/], [Konfiguration versionieren], [Wartbarkeit], [/LF001/], [Host-App], [Das System muss Konfigurationsobjekte immutable halten und Änderungen nur über Builder/Factory abbilden.],
  )
]

#pagebreak()

==== 2.4.4 Validierung, Sicherheit, Betrieb

#[
  #set text(10.5pt)
  #table(
    columns: (0.55fr, 1.0fr, 0.75fr, 0.65fr, 0.75fr, 2.1fr),
    inset: 4pt,
    stroke: 0.35pt + rgb("#BBBBBB"),
    align: (left, left, left, left, left, left),
    table.header(
      [*ID*], [*Funktion*], [*Quelle*], [*Verweise*], [*Akteur*], [*Beschreibung*],
    ),
    [/LF050/], [Koordinatenbereich prüfen], [Mathematik/Geodäsie], [/LL010/], [Host-App], [Das System muss Breiten- und Längengrade auf den WGS84-Zulässigkeitsbereich prüfen.],
    [/LF051/], [Zeitvalidierung], [GPS-Realität], [/LF020/], [Host-App], [Das System muss Zeitstempel ablehnen, die in der Zukunft liegen oder älter als ein konfigurierbarer Schwellwert sind.],
    [/LF052/], [Pfadvalidierung], [Sicherheit], [/LF032/], [Host-App], [Das System muss Ausgabepfade normalisieren und Path-Traversal-Angriffe unterbinden.],
    [/LF053/], [Keine stillen Datenverluste], [Qualität], [/LF028/], [Host-App], [Das System muss jeden Datenverlust oder jede Aggregation durch Log-Einträge nachvollziehbar machen.],
    [/LF054/], [Deterministische Tests], [Lehre], [/LL040/], [Team], [Das System muss Zeit und Zufall über injizierbare Abstraktionen ersetzbar machen.],
    [/LF055/], [Thread-Sicherheit dokumentieren], [Nebenläufigkeit], [/LF003/], [Host-App], [Das System muss klar angeben, welche Methoden thread-sicher sind; Standard ist „ein Host-Thread steuert die Session“.],
  )
]

#pagebreak()

=== 2.5 Produktdaten (logisches Datenmodell)

Die folgende Tabelle beschreibt persistente bzw. transportierte Daten ähnlich dem Abschnitt „Produktdaten“ der Musteranalyse. Hier bezieht sich Persistenz auch auf *Exportartefakte* und temporäre Dateien.

#[
  #set text(10.5pt)
  #table(
    columns: (0.55fr, 1.1fr, 1.0fr, 2.0fr),
    inset: 5pt,
    stroke: 0.35pt + rgb("#BBBBBB"),
    table.header(
      [*ID*], [*Speicherinhalt / Datenobjekt*], [*Verweise*], [*Attribute (Auszug)*],
    ),
    [/LD001/], [Peilungs-Session], [/LF001/, /LF007/], [`sessionId:UUID`, `status:Enum`, `target:Geo`, `startedAt:Instant`],
    [/LD002/], [Konfiguration], [/LF040/], [`interval`, `maxPoints`, `softLimit`, `hardLimit`, `persistOnAbort:boolean`, `w3wApiKey:Optional`],
    [/LD003/], [GPS-Track], [/LF020/], [`segments[]`, `points[]` mit Zeit, lat, lon, optional ele, hdop, speed],
    [/LD004/], [Peilungs-Snapshot], [/LF005/], [`azimuthDeg`, `distanceM`, `compassOrdinal`, `bearingErrorDeg`],
    [/LD005/], [GPX-Dokument], [/LF030/], [`metadata`, `trk`, XML-Namespace GPX 1.1],
    [/LD006/], [Optimierungsergebnis], [/LF034–037/], [`originalCount`, `optimizedCount`, `appliedStrategies[]`],
    [/LD007/], [W3W-Cache-Eintrag], [/LF039/], [`lat`, `lon`, `words`, `ttl`],
    [/LD008/], [Fehlerprotokoll], [/LF053/], [`timestamp`, `code`, `context`, optional `stacktrace`],
    [/LD009/], [Test-Fixture-Katalog], [/LL040/], [`Szenario-ID`, `Eingaben[]`, `Erwartung`],
    [/LD010/], [Abnahme-Trace], [Dozent], [`Requirement-ID`, `Testfall-ID`, `Ergebnis`],
  )
]

#pagebreak()

=== 2.6 Nicht-funktionale Anforderungen

#[
  #set text(10.5pt)
  #table(
    columns: (0.55fr, 1.0fr, 0.75fr, 2.3fr),
    inset: 5pt,
    stroke: 0.35pt + rgb("#BBBBBB"),
    table.header(
      [*ID*], [*Funktion / Qualitätsperspektive*], [*Verweise*], [*Beschreibung / Messidee*],
    ),
    [/LL010/], [Robustheit / Eingabevalidierung], [/LF050/, /LF051/], [Ungültige Eingaben dürfen keine undefinierten Zustände erzeugen; Messung über negative Tests + Mutationstests (optional).],
    [/LL020/], [Genauigkeit Peilung], [/LF005/], [Für Distanzen > 10 m darf der Azimut maximal ±1° von einer Referenzimplementierung (Haversine) abweichen.],
    [/LL030/], [Performance Peilung], [/LF003/], [Ein vollständiger Update-Zyklus (ohne I/O) soll auf üblicher Laptop-Hardware typischerweise deutlich unter 1 ms liegen; Obergrenze laut Spezifikation 100 ms im Worst Case ohne GC-Pause.],
    [/LL031/], [Performance Export], [/LF030/], [GPX-Export für 10.000 Punkte ohne Douglas–Peucker soll in \< 2 s auf Laptop-Hardware erfolgen (Richtwert, nicht verbindlich wenn dokumentiert).],
    [/LL032/], [Speicher], [/LF028/], [Für 10.000 Punkte soll der Heap-Zuwachs der Bibliothek ohne Duplikate typischerweise \< 50 MB bleiben (Richtwert).],
    [/LL033/], [Wartbarkeit], [Vorlesung], [Öffentliche API vollständig mit Javadoc; Checkstyle im Build.],
    [/LL034/], [Portabilität], [Projektauftrag], [Keine plattformspezifischen Pfade oder `sun.*`-APIs.],
    [/LL035/], [Übertragbarkeit], [Projektauftrag], [Maven-Build ohne manuelle Schritte außer JDK-Installation.],
    [/LL036/], [Sicherheit], [/LF052/], [Keine dynamische Code-Ausführung aus GPX-Eingaben; XML-Escape strikt.],
    [/LL037/], [Beobachtbarkeit], [/LF053/], [SLF4J-Logs für Warn/Fehler mit Korrelation über `sessionId`.],
    [/LL038/], [Testbarkeit], [/LF054/], [Mind. 85 % Zeilenabdeckung in Kernmodulen laut Spezifikation; kritische Domäne ≥ 90 %.],
    [/LL039/], [Wiederanlauf], [Betrieb], [Nach Exception muss die Instanz in einen definierten Leerlaufzustand zurückkehren können.],
    [/LL040/], [Determinismus Tests], [/LF054/], [Alle zeitabhängigen Tests verwenden `Clock`-Injection.],
  )
]

#pagebreak()

=== 2.7 Qualitätsanforderungen (ISO/IEC 25010 Kurzmatrix)

Die Tabelle stellt eine kompakte Priorisierung dar (sehr wichtig / wichtig / normal). Sie ersetzt nicht die detaillierte Spezifikation, visualisiert aber die Gewichtung wie im Musterdokument zur ISO 9126/25010.

#table(
  columns: (2.0fr, 0.55fr, 0.55fr, 0.55fr),
  inset: 5pt,
  stroke: 0.4pt + rgb("#CCCCCC"),
  table.header(
    [*Produktqualität / Unterkriterium*], [*sehr wichtig*], [*wichtig*], [*normal*],
  ),
  [funktionale Vollständigkeit (Peilung + GPX)], [x], [ ], [ ],
  [Zuverlässigkeit (Fehlerzustände, Recovery)], [x], [ ], [ ],
  [Performance (Echtzeit-Update)], [ ], [x], [ ],
  [Wartbarkeit (Modularität, Lesbarkeit)], [x], [ ], [ ],
  [Sicherheit (I/O, Injection)], [ ], [x], [ ],
  [Kompatibilität (Java-Versionen, GPX)], [x], [ ], [ ],
  [Benutzbarkeit der API (Klarheit)], [ ], [x], [ ],
  [Übertragbarkeit (Build ohne UI)], [x], [ ], [ ],
)

#pagebreak()

=== 2.8 Ergänzungen und bewusste Nicht-Ziele

- *Keine* Turn-by-Turn-Navigation, *keine* Routing-Engine.
- *Keine* Kartendarstellung.
- *Keine* eigenständige Sensor-Hardwareanbindung.
- *Keine* Cloud-Pflicht; W3W nur optional.

#pagebreak()

=== 2.9 Glossar (Auszug aus der Anforderungsanalyse)

#table(
  columns: (0.9fr, 2.5fr, 1.6fr),
  inset: 5pt,
  stroke: 0.35pt + rgb("#CCCCCC"),
  [*Begriff*], [*Definition*], [*Abgrenzung / Gültigkeit*],
  [Peilung], [Angabe von Richtung und Entfernung zu einem Zielpunkt relativ zur aktuellen Position, ohne Navigation entlang eines Graphen.], [Kein Routing.],
  [Azimut], [Horizontalwinkel relativ zu geografisch Nord, im Uhrzeigersinn 0–360°.], [Nicht identisch mit magnetischem Nord ohne Modell.],
  [GPX Track], [Folge von Trackpoints unterhalb eines `trk`-Elements, ggf. segmentiert.], [Kein automatischer Fotowegpunkt-Export.],
  [Sampling], [Auswahlregel, welche Rohpunkte gespeichert werden.], [Unabhängig von der Sensorfrequenz des Hosts.],
  [Host], [Die einbettende Anwendung, liefert Messwerte und entscheidet über UI.], [Nicht Teil der Bibliothek.],
  [W3W], [What3Words-Adressierung als optionale Zusatzinformation.], [Kein Ersatz für offizielle Koordinaten.],
)

#pagebreak()

=== 2.10 Objektorientierte Analyse (OOA) – Verbindung zu UML

Die OOA identifiziert *Klassenkandidaten* aus Substantiven der Anforderungen und ordnet Verantwortlichkeiten zu:

- *BearingSession* kapselt den Lebenszyklus und referenziert den *GpsTrack*.
- *GeoCoordinate* /*GpsPoint* sind Wertobjekte (unveränderlich).
- *BearingCalculator* ist ein domänennaher Dienst ohne I/O.
- *GpxSerializer* ist ein technischer Dienst (Infrastructure), der über Schnittstellen angebunden wird.

Die Diagramme in `Documentation/plantuml/` (insbesondere `01_klassendiagramm.puml`, `04_aktivitaetsdiagramm_peilung.puml`, `05_zustandsdiagramm_session.puml`, `07_usecase_diagramm.puml`) sind die grafische Verdichtung dieser Analyse. Änderungen an der API müssen immer in Diagramm und Text gleichzeitig gepflegt werden.

#pagebreak()

=== 2.11 Risiken und Gegenmaßnahmen

#table(
  columns: (0.35fr, 1.3fr, 1.3fr, 1.3fr),
  inset: 5pt,
  stroke: 0.35pt + rgb("#CCCCCC"),
  [*R*], [*Risiko*], [*Auswirkung*], [*Maßnahme*],
  [R1], [GPS-Rauschen groß], [Falsche Peilung nahe am Ziel], [Filter + optional Kalman; Hinweise in Doku],
  [R2], [W3W API ausfallend], [Fehler in Host-UI], [Fallback + Timeout + Circuit Breaker optional],
  [R3], [Große Tracks], [Speicher/Export langsam], [Streaming-Writer, Limits, Optimierungen],
  [R4], [Inkonsistenz Doku/Code], [Abzug in Bewertung], [Traceability-Tabelle + Reviews],
)

#pagebreak()

=== 2.12 Traceability: Anforderung → Testartefakt

#table(
  columns: (0.55fr, 1.2fr, 1.6fr, 1.2fr),
  inset: 5pt,
  stroke: 0.35pt + rgb("#CCCCCC"),
  [*ID*], [*Testart*], [*Abstrakter Testfall*], [*Erwartung*],
  [/LF001/], [Unit], [`StartRequiresValidTarget`], [Exception bei ungültigem Ziel],
  [/LF003/], [Unit], [`UpdateRequiresActiveSession`], [Exception im falschen Zustand],
  [/LF006–007/], [Integration], [`ExportAfterAbortAndComplete`], [GPX wohlgeformt, Status korrekt],
  [/LF030/], [Golden-File], [`GpxMatchesSchema`], [Namespace + Pflichtelemente],
  [/LF034–036/], [Property/Beispiel], [`OptimizerKeepsEnds`], [Erster/letzter Punkt erhalten],
  [/LF038/], [Integration (Mock)], [`W3wFallback`], [Fallback ohne Key],
)

#pagebreak()

=== 2.13 Fazit der Anforderungsanalyse

Die Anforderungsbasis ist damit in klassischer, gut prüfbarer Form dokumentiert: Ziele und Kontext sind klar, funktionale und nicht-funktionale Anforderungen sind eindeutig identifiziert, Daten sind modelliert, Qualität ist gewichtet und Risiken sind adressiert. Die nachfolgende Spezifikation (IEEE 830) verfeinert Schnittstellen und Verhaltensdetails; sie darf diese Anforderungen nicht widersprechen, sondern nur präzisieren.

#pagebreak()

=== 2.14 Klärungsprotokoll (Referenz iOS-App und Gespräch mit Bohl)

Die folgenden Festlegungen verdichten mündliche Rückmeldungen und den Projektauftrag, ohne normative Kraft jenseits dieser dokumentierten Version zu beanspruchen.

- *Peilung vs. Navigation:* Peilung bedeutet hier ausschließlich die *Richtungs- und Distanzinformation* „wohin vom aktuellen Stand“, vergleichbar mit einer Pfeilanzeige, nicht jedoch eine kartenbasierte Routenführung.
- *GPX-Version:* Es wird *GPX 1.1* als Austauschformat verwendet; Zeitangaben in UTC gemäß ISO-8601.
- *Optimierung für Präsentation/Export:* Es sind Strategien vorgesehen, die Punktmengen reduzieren: *jeder n-te Punkt*, *Mindestabstand in Metern*, *Geraden auf zwei Punkte*, optional *Douglas–Peucker*. Für enge Kurven ist eine starke Reduktion fachlich nicht immer sinnvoll; dies ist dokumentiert statt verschwiegen.
- *Abbruch:* Es müssen GPX-Daten erzeugt werden können; eine automatische Datei ist nicht zwingend. Damit werden Rückmeldungen aus dem 3. Semester adressiert („keine GPX-Datei“ im Sinne von „kein stiller Export“) und gleichzeitig die Anforderung erfüllt, GPX-Daten zu erhalten.
- *W3W:* What3Words ist als optionale Zusatzinformation vorgesehen, inklusive klarer Fehler- und Offline-Fallbacks.

#pagebreak()

=== 2.15 Anforderungsinspektion nach SOPHIST (Checkliste)

Die Tabelle dient der Selbstprüfung vor Abgabe und spiegelt typische Review-Fragen aus der Vorlesung wider.

#table(
  columns: (0.35fr, 1.2fr, 2.0fr, 0.55fr),
  inset: 5pt,
  stroke: 0.35pt + rgb("#CCCCCC"),
  [*Nr.*], [*Kriterium*], [*Frage an die Anforderung*], [*OK*],
  [C1], [Spezifisch], [Ist genau ein Systemverhalten beschrieben?], [ ],
  [C2], [Messbar], [Gibt es eine nachprüfbare Bedingung oder Testidee?], [ ],
  [C3], [Eindeutig], [Gibt es keine doppelte Interpretation?], [ ],
  [C4], [Konsistent], [Widerspricht die Anforderung keiner anderen?], [ ],
  [C5], [Realistisch], [Ist die Umsetzung mit Java-Standardmitteln möglich?], [ ],
  [C6], [Traceable], [Ist die Quelle (Auftrag, Interview) erkennbar?], [ ],
  [C7], [Vollständig], [Sind Vorbedingungen und Nachbedingungen klar?], [ ],
)

#pagebreak()

=== 2.16 Produktdaten – Detailattribute (Orientierung am Musterdokument)

Die folgende Darstellung orientiert sich formal an „Speicherinhalt … / Attribute …“ der Musteranalyse. Hier beziehen sich Attribute auf das fachliche Datenmodell der Bibliothek, nicht auf eine SQL-Datenbank.

#table(
  columns: (0.55fr, 1.2fr, 2.4fr),
  inset: 5pt,
  stroke: 0.35pt + rgb("#CCCCCC"),
  [*ID*], [*Speicherinhalt*], [*Attribute (Auszug, Kardinalität / Typ)*],
  [/LD200/], [GeoCoordinate], [`lat: double`, `lon: double`, `ele: Optional`, `time: Instant`, `hdop: Optional`, `speed: Optional`],
  [/LD201/], [BearingSnapshot], [`azimuthDeg`, `distanceM`, `bearingErrorDeg`, `ordinalDirection`],
  [/LD202/], [TrackSegment], [`points: List<GpsPoint>`, `segmentIndex`, `gapBefore: Duration?`],
  [/LD203/], [GpxMetadata], [`name`, `desc`, `author`, `timeBounds`],
  [/LD204/], [OptimizationReport], [`strategy`, `removedCount`, `epsilonMeters?`],
  [/LD205/], [W3wResolution], [`words`, `language`, `rawJson?`, `resolvedAt`],
)

#pagebreak()

=== 2.17 Ergänzende funktionale Anforderungen (Detailausbuchung)

#[
  #set text(10.5pt)
  #table(
    columns: (0.55fr, 1.0fr, 0.75fr, 0.65fr, 0.75fr, 2.1fr),
    inset: 4pt,
    stroke: 0.35pt + rgb("#BBBBBB"),
    align: (left, left, left, left, left, left),
    table.header(
      [*ID*], [*Funktion*], [*Quelle*], [*Verweise*], [*Akteur*], [*Beschreibung*],
    ),
    [/LF060/], [Konfiguration validieren], [Robustheit], [/LF040/], [Host-App], [Das System muss beim Start prüfen, dass Konfigurationskombinationen (z. B. Intervall 0, negatives Punktbudget) abgelehnt werden.],
    [/LF061/], [Konfiguration immutable ausliefern], [SWE Best Practice], [/LF040/], [Host-App], [Das System muss nach dem Start einer Session die Konfiguration unveränderlich einfrieren.],
    [/LF062/], [Logging-Kontext], [Betrieb], [/LF053/], [Team], [Das System muss strukturierte Log-Felder (`sessionId`, `phase`) unterstützen.],
    [/LF063/], [Keine UI-Abhängigkeiten], [Projektauftrag], [–], [Team], [Das System darf keine Klassen aus UI-Frameworks referenzieren.],
    [/LF064/], [Java-Version], [Rahmenbedingung], [–], [Team], [Das System muss mit Java 11 oder höher kompilierbar sein.],
    [/LF065/], [Build-Tooling], [Abgabe], [–], [Team], [Das System muss per Maven ohne manuelle Zwischenschritte testbar sein.],
    [/LF066/], [Internationale Zeitzonen], [GPS], [/LF020/], [Host-App], [Das System muss Zeitstempel normalisiert als `Instant` verarbeiten; Anzeige in Lokalzeit ist Sache des Hosts.],
    [/LF067/], [Null-sichere API], [Qualität], [–], [Host-App], [Das System muss in der öffentlichen API `null`-Semantik in Javadoc explizit festlegen und durch Tests absichern.],
    [/LF068/], [Erweiterbarkeit Optimierer], [1+], [/LF034–037/], [Team], [Das System muss Optimierer über Strategy-Schnittstellen austauschbar halten.],
    [/LF069/], [Erweiterbarkeit Export], [Wartung], [/LF030/], [Team], [Das System muss GPX-Generierung von optionalen Post-Processing-Schritten trennen.],
    [/LF070/], [Statistikobjekt], [1+], [/LF030/], [Host-App], [Das System muss nach Abschluss Kennzahlen (Distanz, Dauer, Punktzahl) bereitstellen können.],
  )
]

#pagebreak()

=== 2.18 Ergänzende nicht-funktionale Anforderungen

#table(
  columns: (0.55fr, 1.1fr, 2.5fr),
  inset: 5pt,
  stroke: 0.35pt + rgb("#CCCCCC"),
  [*ID*], [*Thema*], [*Beschreibung / Messidee*],
  [/LL050/], [Energieeffizienz Host], [Sampling soll große Punktmengen vermeiden, um Host-Batterie zu schonen (Richtwert, Host-seitig messbar).],
  [/LL051/], [Determinismus], [Gleiche Eingabesequenz führt zu gleichem Track bei festem `Clock` und festem Seed.],
  [/LL052/], [Lizenz & Abhängigkeiten], [Nur permissive Bibliotheken im Default-Build; W3W-Client optional im Profil `w3w`.],
)

#pagebreak()

=== 2.19 Domänenregeln (Policy-Tabelle)

#table(
  columns: (0.45fr, 1.2fr, 2.5fr),
  inset: 5pt,
  stroke: 0.35pt + rgb("#CCCCCC"),
  [*Regel*], [*Trigger*], [*Systemreaktion*],
  [R-PEIL-01], [Keine aktive Session], [`updatePosition` löst definierten Fehler aus.],
  [R-PEIL-02], [Ziel unverändert], [Zielkoordinate ist während Session immutable.],
  [R-TRK-01], [Punkt ungültig], [Verwerfen + Log, keine stille Korrektur außer konfiguriert.],
  [R-TRK-02], [Hard-Limit erreicht], [Event + kontrollierter Stop oder Overflow-Policy.],
  [R-GPX-01], [Leerer Track], [Export erzeugt syntaktisch valide GPX-Struktur mit 0 Segmentpunkten oder Fehlercode – Verhalten ist in IEEE-Kapitel fixiert.],
)

#pagebreak()

=== 2.20 Mess- und Abnahmeplan (ohne Aufwandsschätzung)

Die folgende Liste definiert *Messpunkte*, nicht jedoch Personalaufwand:

- *MP-Genauigkeit:* Vergleich Haversine gegen Referenzpunkte (Äquator, Polnähe, Stuttgart).
- *MP-Performance:* JUnit `@Timeout` + Mikrobenchmarks (optional JMH) für Kernfunktionen.
- *MP-GPX:* Golden-File-Tests gegen XSD (optional) und gegen bekannte Referenzdateien.
- *MP-Abbruch:* Szenario mit zwei Punkten, Abbruch, Prüfung auf GPX-String und optional fehlende Datei.

#pagebreak()

=== 2.21 Erweitertes Glossar (Domäne Software Engineering)

#table(
  columns: (0.95fr, 2.55fr, 1.5fr),
  inset: 5pt,
  stroke: 0.35pt + rgb("#CCCCCC"),
  [*Begriff*], [*Definition*], [*Hinweis*],
  [SOPHIST], [Qualitätskriterien für formulierte Anforderungen (u. a. spezifisch, testbar).], [Kein Ersatz für Vertragsrecht.],
  [IEEE 830], [Strukturvorgabe für Software Requirements Specifications.], [Wird in Kapitel 3 angewendet.],
  [Facade], [Vereinfachte Schnittstelle auf ein Subsystem.], [`BearingComponent`.],
  [Observer], [Entkopplung durch Listener.], [Events für Host-Integration.],
  [Strategy], [Austauschbares Verhalten.], [Optimierer, Distanzberechnung.],
  [Value Object], [Identität über Wert, immutable.], [`GeoCoordinate`.],
  [Aggregate], [Konsistenzgrenze im Domänenmodell.], [`BearingSession` + `GpsTrack`.],
  [Port/Adapter], [Architekturstil für I/O und externe APIs.], [W3W, Dateisystem.],
  [Haversine], [Großkreisformel für Entfernungen auf Kugelapproximation.], [Für kurze Distanzen ausreichend genau.],
  [GPX trkpt], [Trackpunkt mit lat/lon/time und optionalen Erweiterungen.], [Muss UTF-8 XML sein.],
  [HDOP], [Horizontal Dilution of Precision.], [Qualitätsindikator, nicht „Meter“.],
  [UTC], [Koordinierte Weltzeit.], [Pflicht für GPX-Zeiten.],
  [Abnahme], [Formale oder halbformale Prüfung gegen Anforderungen.], [Durch Dozenten/Team.],
  [Traceability], [Nachverfolgbarkeit Anforderung ↔ Test ↔ Code.], [Pflege in Tabellen.],
  [Anti-Pattern], [Strukturen, die bewusst vermieden werden.], [z. B. UI in Bibliothek.],
)

#pagebreak()

=== 2.22 Szenarien für Akzeptanztests (textuelle Storyboards, keine User Stories)

*Szenario A – Happy Path:* Host startet Peilung, liefert alle 2 s gültige Punkte, beendet regulär, exportiert GPX-String, validiert gegen Schema.

*Szenario B – Abbruch:* Host bricht nach drei Punkten ab, erhält GPX-String, speichert optional.

*Szenario C – Schlechte GPS-Qualität:* Host liefert HDOP groß; Bibliothek verwirft Punkte gemäß Policy; Peilung bleibt stabil.

*Szenario D – Limit:* Host überschreitet Hard-Limit; Bibliothek signalisiert Ende der Aufzeichnung.

#pagebreak()

=== 2.23 Verweise auf PlantUML-Modelle

Die Modelle liegen unter `Documentation/plantuml/` und sind in `README.md` beschrieben. Für die Anforderungsanalyse sind insbesondere das Anwendungsfalldiagramm (`07_usecase_diagramm.puml`) und das Aktivitätsdiagramm (`04_aktivitaetsdiagramm_peilung.puml` relevant, um Akteure und Kontrollflüsse zu belegen.

#pagebreak()

=== 2.24 Offene Punkte (bewusst in die Spezifikation verschoben)

- Exakte Signatur der öffentlichen API (Methodennamen) wird in Kapitel 6 normiert.
- Entscheidung, ob `Optional` oder Annotation-basierte Nullity verwendet wird, ist ein Implementierungsdetail im Rahmen der Java-Version.

// Ende Kapitel 2 Include
