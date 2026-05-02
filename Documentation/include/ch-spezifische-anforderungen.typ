#import "macros.typ": diagramm-box

// ─────────────────────────────────────────────────────────────────────────────
// Anforderungskarten-Makros (lokal)
// ─────────────────────────────────────────────────────────────────────────────

#let _req-fill = rgb("#d6e9f8")

#let lf-card(id, funktion, quelle, verweise, akteur, beschreibung) = {
  v(0.7em)
  set text(size: 11pt)
  block(width: 100%, breakable: false)[
    #table(
      columns: (1.9cm, 2.7cm, 1fr, 2.3cm, 1fr),
      stroke: 0.5pt + rgb("#AAAAAA"),
      fill: (x, _y) => if x == 0 or x == 1 { _req-fill } else { white },
      inset: (x: 7pt, y: 6pt),
      align: (x, _y) => if x <= 1 { center + horizon } else { left + top },
      table.cell(rowspan: 4)[
        #set align(center + horizon)
        #text(weight: "bold", size: 10pt)[#id]
      ],
      [Funktion], table.cell(colspan: 3)[#funktion],
      [Quelle], [#quelle], table.cell(fill: _req-fill)[Verweise], [#verweise],
      [Akteur], table.cell(colspan: 3)[#akteur],
      [Beschreibung], table.cell(colspan: 3)[#beschreibung],
    )
  ]
}

#let ll-card(id, funktion, quelle, verweise, beschreibung) = {
  v(0.7em)
  set text(size: 11pt)
  table(
    columns: (1.9cm, 2.7cm, 1fr, 2.3cm, 1fr),
    stroke: 0.5pt + rgb("#AAAAAA"),
    fill: (x, _y) => if x == 0 or x == 1 { _req-fill } else { white },
    inset: (x: 7pt, y: 6pt),
    align: (x, _y) => if x <= 1 { center + horizon } else { left + top },
    table.cell(rowspan: 3)[
      #set align(center + horizon)
      #text(weight: "bold", size: 10pt)[#id]
    ],
    [Funktion], table.cell(colspan: 3)[#funktion],
    [Quelle], [#quelle], table.cell(fill: _req-fill)[Verweise], [#verweise],
    [Beschreibung], table.cell(colspan: 3)[#beschreibung],
  )
}

#let ld-card(id, speicherinhalt, verweise, attribute) = {
  v(0.7em)
  set text(size: 11pt)
  table(
    columns: (1.9cm, 2.7cm, 1fr),
    stroke: 0.5pt + rgb("#AAAAAA"),
    fill: (x, _y) => if x == 0 or x == 1 { _req-fill } else { white },
    inset: (x: 7pt, y: 6pt),
    align: (x, _y) => if x <= 1 { center + horizon } else { left + top },
    table.cell(rowspan: 3)[
      #set align(center + horizon)
      #text(weight: "bold", size: 10pt)[#id]
    ],
    [Speicherinhalt], [#speicherinhalt],
    [Verweise], [#verweise],
    [Attribute], [#attribute],
  )
}

#let tbl-stroke = 0.45pt + rgb("#9a9a9a")
#let tbl-inset  = 6pt

// ─────────────────────────────────────────────────────────────────────────────
// KAPITEL-INHALT
// ─────────────────────────────────────────────────────────────────────────────

#let ch-spezifische-anforderungen-kapitel = [
#set par(justify: true)

Dieses Kapitel bildet den normativen Kern des Dokuments. Es enthält alle verbindlichen Anforderungen der Java-Peilungskomponente, gegliedert nach funktionalen Anforderungen (`/LF…/`), nicht-funktionalen Anforderungen (`/LL…/`), externen Schnittstellen, Performance-Anforderungen und dem Qualitätsmodell. Alle Anforderungen sind SOPHIST-konform formuliert, eindeutig identifizierbar und durch Testfälle abdeckbar.

// ═════════════════════════════════════════════════════════════════════════════
== Funktionale Anforderungen
// ═════════════════════════════════════════════════════════════════════════════

Funktionale Anforderungen beschreiben, *was* das System leisten muss. Sie sind in der SOPHIST-Dreierregel formuliert (Bedingung – Subjekt – Prädikat) und werden durch `/LF…/`-Bezeichner referenziert.

=== Peilung und Session-Lebenszyklus

Der Session-Lebenszyklus definiert die fundamentale Zustandsmaschine der Bibliothek: IDLE → ACTIVE (start) → COMPLETED (complete) oder ABORTED (abort). Übergänge zurück zu IDLE erfolgen durch eine explizite `reset()`-Operation.

#lf-card(
  "/LF010/",
  "Peilung starten",
  "Projektauftrag SWE",
  "–",
  "Host-App",
  "Das System muss eine neue Peilung starten, wenn der Host eine gültige Zielkoordinate und eine gültige Konfiguration übergibt. Die Peilung erhält eine eindeutige UUID und startet im Zustand ACTIVE.",
)

#lf-card(
  "/LF020/",
  "Peilung nur einfach aktiv",
  "Klärungsgespräch",
  "/LF010/",
  "Host-App",
  "Das System muss verhindern, dass parallel mehrere aktive Peilungen stattfinden. Ein erneuter Startaufruf ohne vorheriges Beenden führt zu einer definierten Exception.",
)

#lf-card(
  "/LF030/",
  "Positionsupdate verarbeiten",
  "Projektauftrag SWE",
  "/LF010/, /LL010/",
  "Host-App",
  "Das System muss jeden übergebenen GPS-Punkt validieren und bei Gültigkeit die Ausrichtung der Peilung aktualisieren. Ungültige Positionsdaten werden abgelehnt und führen zu einer semantischen Exception.",
)

#lf-card(
  "/LF040/",
  "Kursupdate verarbeiten",
  "Klärungsgespräch",
  "/LF030/",
  "Host-App",
  "Das System muss optional einen vom Host gelieferten Kurs (0–360°) nutzen, um eine Kursabweichung zur Zielrichtung zu bestimmen. Wird kein Kurs geliefert, entfällt die Kursabweichungsberechnung ohne Fehler.",
)

#lf-card(
  "/LF050/",
  "Peilungsinformationen abfragen",
  "Projektauftrag SWE",
  "/LF030/",
  "Host-App",
  "Die Peilungskomponente muss auf Anfrage die aktuelle Zielrichtung (geografischer Azimut in Grad), die Entfernung zum Ziel in Metern sowie eine diskrete Himmelsrichtung (N, NE, E, SE, S, SW, W, NW) liefern.",
)

#lf-card(
  "/LF060/",
  "Peilung regulär beenden",
  "Projektauftrag SWE",
  "/LF100/, /LF120/",
  "Host-App",
  "Die Peilungskomponente muss beendet werden und im Anschluss daran den GPS-Track in GPX-Form (nach GPX 1.1) zurückgeben. Nach regulärem Abschluss sind keine weiteren Positionsupdates zulässig.",
)

#lf-card(
  "/LF070/",
  "Peilung abbrechen",
  "Klärungsgespräch",
  "/LF060/, /LF230/",
  "Host-App",
  "Die Peilungskomponente muss vom Nutzer abgebrochen werden können. Im Falle eines Abbruchs darf der GPS-Track nicht verworfen werden, sondern muss in GPX-Form (nach GPX 1.1) zurückgegeben werden.",
)

#lf-card(
  "/LF080/",
  "Listener-Events",
  "Vorlesung SWE (Observer)",
  "/LF030/, /LF060/",
  "Host-App",
  "Die Komponente muss Ereignisse für Start, Update, Abschluss und Fehler über registrierte Listener veröffentlichen. Die Listener-Benachrichtigung erfolgt synchron oder konfigurierbar serialisiert.",
)

#lf-card(
  "/LF090/",
  "Fehler semantisch klassifizieren",
  "Qualitätsrichtlinie",
  "/LL010/",
  "Host-App",
  "Die Komponente muss Eingabe-, Zustands- und I/O-Fehler über eine klar dokumentierte Exception-Hierarchie unterscheidbar machen. Jede Exception enthält einen maschinenlesbaren `errorCode`.",
)

=== GPS-Track-Aufzeichnung

Die Anforderungen /LF110/, /LF130/, /LF140/ und /LF160/ sind nicht Teil des Lieferumfangs dieser Bibliotheksversion (siehe Kapitel 1.2).

#lf-card(
  "/LF100/",
  "GPS-Punkte aufzeichnen",
  "Projektauftrag SWE",
  "/LF030/",
  "Host-App",
  "Das System muss während einer aktiven Peilung jeden validierten GPS-Fix mit Zeitstempel vollständig im Rohspeicher ablegen. Jeder gespeicherte Punkt enthält mindestens: Zeitstempel, Breitengrad, Längengrad.",
)

#lf-card(
  "/LF120/",
  "Punktbudget konfigurieren",
  "Klärungsgespräch",
  "/LF100/",
  "Host-App",
  "Die Peilungskomponente muss eine Obergrenze für die Anzahl gespeicherter GPS-Punkte pro Peilung unterstützen (Soft-Warnung, Hard-Limit mit kontrolliertem Stopp). Eine automatische Punktreduktion durch die Bibliothek beim Einlesen erfolgt nicht; optional können beim GPX-Export `TrackOptimizer`-Strategien registriert werden.",
)

#lf-card(
  "/LF150/",
  "Optionale Felder speichern",
  "Fragenkatalog Team",
  "/LF100/",
  "Host-App",
  "Das System muss optionale Felder wie Höhe (Elevation), HDOP und Geschwindigkeit in GPS-Trackpunkten abbilden können, sofern der Host diese Werte liefert. Fehlende Felder werden in der GPX-Darstellung weggelassen statt mit Nullwerten befüllt.",
)

#lf-card(
  "/LF170/",
  "Segmentierung bei Zeitlücken",
  "Qualitätsrichtlinie",
  "/LF100/",
  "Host-App",
  "Das System muss zeitliche Lücken zwischen aufeinanderfolgenden Punkten, die einen konfigurierbaren Schwellwert überschreiten, als Beginn eines neuen Track-Segments kennzeichnen. Dies ermöglicht korrekte GPX-Segmentierung.",
)

#lf-card(
  "/LF180/",
  "Hard-Limit erzwingen",
  "Fragenkatalog Team",
  "/LF120/, /LL050/",
  "Host-App",
  "Das System muss beim Erreichen des konfigurierten Hard-Limits die Aufzeichnung kontrolliert stoppen oder in einen definierten Overflow-Modus wechseln und den Host über ein dediziertes Limit-Event informieren.",
)

=== GPX-Export, Optimierung und What3Words

#lf-card(
  "/LF200/",
  "GPX 1.1 erzeugen",
  "Klärungsgespräch",
  "/LF100/",
  "Host-App",
  "Die Peilungskomponente muss aus einer abgeschlossenen oder abgebrochenen Peilung den aufgezeichneten GPS-Track in Form des GPX-1.1-Standards erzeugen.",
)

#lf-card(
  "/LF210/",
  "GPX-Metadaten setzen",
  "GPX-Standard",
  "/LF200/",
  "Host-App",
  "Das System muss in der GPX-Ausgabe Metadaten wie Zeitbereich (time-bounds), optionalen Track-Namen und Quelle setzen. Zeitangaben erfolgen normalisiert in UTC gemäß ISO-8601.",
)

#lf-card(
  "/LF220/",
  "Atomares Dateischreiben",
  "IEEE-830-NFR",
  "/LF230/",
  "Host-App",
  "Das System muss beim optionalen Schreiben auf das Dateisystem zuerst eine temporäre Datei anlegen und diese anschließend atomar durch Umbenennen an den Zielort verschieben, um Datenverlust bei Schreibfehlern zu vermeiden.",
)

#lf-card(
  "/LF230/",
  "Export als String oder Bytes",
  "Klärungsgespräch",
  "/LF200/",
  "Host-App",
  "Das System muss GPX-Daten unabhängig vom Dateisystem als `String` oder `byte[]` bereitstellen. Diese Entkopplung ermöglicht GPX-Ausgabe nach Abbruch, ohne eine Datei schreiben zu müssen.",
)

#lf-card(
  "/LF240/",
  "Optimierung: jeder n-te Punkt",
  "Klärungsgespräch",
  "/LF200/",
  "Host-App",
  "Die Peilungskomponente soll einen Reduktionsalgorithmus enthalten, welcher nur jeden n-ten GPS-Punkt behält. Der Startpunkt und der Endpunkt werden dabei immer erhalten.",
)

#lf-card(
  "/LF250/",
  "Optimierung: Mindestabstand",
  "Klärungsgespräch",
  "/LF200/",
  "Host-App",
  "Das System muss eine distanzbasierte Reduktionsstrategie implementieren, die Punkte unterhalb eines konfigurierbaren Mindestabstands (in Metern) zum jeweils letzten akzeptierten Punkt verwirft.",
)

#lf-card(
  "/LF260/",
  "Optimierung: Geraden reduzieren",
  "Klärungsgespräch",
  "/LF200/",
  "Host-App",
  "Die Komponente muss Punkte, welche näherungsweise auf einer Geraden liegen, auf lediglich zwei Punkte reduzieren können, um die Gesamtanzahl gespeicherter GPS-Punkte zu verringern.",
)

#lf-card(
  "/LF270/",
  "Optimierung: Douglas-Peucker (optional)",
  "Erweiterungsanforderung (1+)",
  "/LF200/",
  "Host-App",
  "Das System muss optional den Douglas-Peucker-Algorithmus mit konfigurierbarer metrischer Toleranz (Epsilon in Metern) für die Track-Vereinfachung anbieten. Die Strategie ist über die Strategy-Schnittstelle austauschbar.",
)

#lf-card(
  "/LF280/",
  "What3Words auflösen",
  "Klärungsgespräch",
  "/LF050/",
  "Host-App",
  "Die Java-Komponente muss in der Lage sein, Koordinaten in eine What3Words-Adresse aufzulösen, sofern ein gültiger API-Key und Netzwerkzugang vorhanden sind. Bei Fehler oder fehlenden Credentials wird eine Exception ausgelöst bzw. ein definierter Fallback-String zurückgegeben.",
)

#lf-card(
  "/LF290/",
  "W3W-Anfragen cachen",
  "Performanceanforderung",
  "/LF280/",
  "Host-App",
  "Das System muss wiederholte What3Words-Anfragen für identische Koordinaten über einen internen Cache reduzieren können. Cache-Einträge können mit einer konfigurierbaren Time-to-Live versehen werden.",
)

=== Validierung, Sicherheit und Betrieb

#lf-card(
  "/LF300/",
  "Koordinatenbereich prüfen",
  "Qualitätsrichtlinie",
  "/LL010/",
  "Host-App",
  "Die Peilungskomponente muss Breiten- und Längengrade auf den WGS84-Zulässigkeitsbereich prüfen (Breitengrad: −90° bis +90°, Längengrad: −180° bis +180°). Ungültige Werte werden mit einer dedizierten Exception abgelehnt.",
)

#lf-card(
  "/LF310/",
  "Zeitstempel validieren",
  "Klärungsgespräch",
  "/LF100/",
  "Host-App",
  "Die Komponente muss Zeitstempel ablehnen, die in der Zukunft liegen oder älter als ein anpassbarer Schwellwert sind (Standard: 24 Stunden). GPS-Punkte mit ungültigem Zeitstempel werden ignoriert und nicht im GPX-Format zurückgegeben.",
)

#lf-card(
  "/LF320/",
  "Pfadvalidierung und Path-Traversal-Schutz",
  "Sicherheitsrichtlinie",
  "/LF220/",
  "Host-App",
  "Das System muss Ausgabepfade normalisieren und Path-Traversal-Angriffe (z.\ B. `../../etc/passwd`) aktiv unterbinden. Ein unzulässiger Pfad führt zu einer `SecurityException`.",
)

#lf-card(
  "/LF330/",
  "Keine stillen Datenverluste",
  "Qualitätsrichtlinie",
  "/LF180/",
  "Host-App",
  "Die Komponente muss jeden Datenverlust oder jede Aggregation durch strukturierte Log-Einträge (mindestens Level WARN) nachvollziehbar machen. Stille Verwürfe sind nicht zulässig.",
)

#lf-card(
  "/LF340/",
  "Deterministische Testbarkeit",
  "Lehrauftrag",
  "/LL170/",
  "Team",
  "Das System muss Zeit (via `java.time.Clock`) und Zufall über injizierbare Abstraktionen ersetzbar machen, sodass alle zeitabhängigen Tests deterministisch und ohne Schlafpausen laufen.",
)

#lf-card(
  "/LF350/",
  "Thread-Sicherheit dokumentieren",
  "Nebenläufigkeitsrichtlinie",
  "/LF030/",
  "Host-App",
  "Die Komponente muss in der Javadoc klar angeben, welche Methoden thread-sicher sind. Standardmäßig soll ein einziger Host-Thread die Peilung steuern. Abweichungen müssen gekennzeichnet werden.",
)

=== Ergänzende funktionale Anforderungen

#lf-card(
  "/LF400/",
  "Konfiguration beim Start validieren",
  "Robustheitsrichtlinie",
  "/LF010/",
  "Host-App",
  "Die Komponente muss beim Start der Peilung prüfen, dass alle übergebenen Werte der Konfiguration zulässig sind (z.\ B. Intervall > 0, Punktbudget > 0, kein negativer HDOP-Schwellwert). Ungültige Werte führen zu einem Fehler.",
)

#lf-card(
  "/LF410/",
  "Konfiguration einfrieren",
  "SWE Best Practice",
  "/LF010/",
  "Host-App",
  "Die Komponente muss die Konfiguration nach dem Start einer Peilung unveränderlich einfrieren. Nachträgliche Änderungsversuche müssen abgewiesen werden. Dies gewährleistet ein konsistentes Verhalten über die gesamte Laufzeit der Peilung.",
)

#lf-card(
  "/LF420/",
  "Strukturiertes Logging",
  "Betriebsanforderung",
  "/LF330/",
  "Team",
  "Das System muss strukturierte Log-Felder wie `sessionId` und `phase` in allen relevanten Log-Ausgaben unterstützen, um eine Korrelation von Logs über mehrere Sessions hinweg zu ermöglichen.",
)

#lf-card(
  "/LF430/",
  "Keine UI-Abhängigkeiten",
  "Projektauftrag",
  "–",
  "Team",
  "Die Komponente darf keinerlei Klassen aus UI-Frameworks (AWT, Swing, JavaFX, Android-UI etc.) referenzieren. Die Bibliothek ist reine Logik- und I/O-Schicht.",
)

#lf-card(
  "/LF440/",
  "Java-Version",
  "Rahmenbedingung",
  "–",
  "Team",
  "Die Komponente muss mit Java 17 oder höher kompilierbar sein, ohne Verwendung von APIs, die in späteren Versionen entfernt wurden, wie beispielsweise `sun.*`-Klassen und als deprecated markierte APIs.",
)

#lf-card(
  "/LF450/",
  "Build-Tooling",
  "Abgabeanforderung",
  "–",
  "Team",
  "Die Komponente muss per Maven (`mvn test`) ohne manuelle Zwischenschritte vollständig kompilierbar und testbar sein. Alle Abhängigkeiten sind über Maven Central auflösbar. Ist dies nicht der Fall, soll eine ausführliche Anleitung in einer README-Datei bereitgestellt werden.",
)

#lf-card(
  "/LF460/",
  "Zeitstempel in UTC normalisieren",
  "GPS-Standard",
  "/LF100/",
  "Host-App",
  "Die Komponente muss alle Zeitstempel intern als `java.time.Instant` (UTC) verarbeiten. Die Konvertierung in lokale Zeitzone ist ausschließlich Aufgabe des Hosts.",
)

#lf-card(
  "/LF470/",
  "Null-sichere öffentliche API",
  "Qualitätsrichtlinie",
  "–",
  "Host-App",
  "Die Komponente muss in der gesamten öffentlichen API die Null-Semantik in Javadoc explizit festlegen. Rückgabewerte, die leer sein können, sind als `Optional<T>` zu deklarieren. Dies ist durch Tests abzusichern.",
)

#lf-card(
  "/LF480/",
  "Optimierer austauschbar halten",
  "Erweiterungsanforderung",
  "/LF240/–/LF270/",
  "Team",
  "Die Komponente muss alle Optimierungsstrategien über eine gemeinsame Strategy-Schnittstelle (`TrackOptimizer`) austauschbar halten, sodass zukünftige Algorithmen ohne Änderung der Kernklassen integrierbar sind.",
)

#lf-card(
  "/LF490/",
  "GPX-Generierung von Post-Processing trennen",
  "Wartbarkeitsrichtlinie",
  "/LF200/",
  "Team",
  "In der Komponente muss die GPX-Speicherung klar von den optionalen Schritten der Optimierung getrennt sein, damit beide Bereiche später einfach erweiterbar sind, ohne sich gegenseitig zu beeinflussen.",
)

#lf-card(
  "/LF500/",
  "Statistikobjekt nach Abschluss",
  "Erweiterungsanforderung",
  "/LF060/",
  "Host-App",
  "Die Komponente muss nach regulärem oder abgebrochenem Abschluss einer Peilung eine Übersicht bereitstellen, die mindestens die Gesamtdistanz in Metern, die Gesamtdauer in Sekunden und die Anzahl der gespeicherten Wegpunkte enthält.",
)

#pagebreak()

// ═════════════════════════════════════════════════════════════════════════════
== Nicht-funktionale Anforderungen
// ═════════════════════════════════════════════════════════════════════════════

Nicht-funktionale Anforderungen beschreiben *wie* das System seine Aufgaben erfüllt. Sie sind als messbare Qualitätsmerkmale formuliert und werden durch `/LL…/`-Bezeichner referenziert. Die vollständige Qualitätsgewichtung nach ISO/IEC 25010 findet sich in Abschnitt 3.5.

=== Korrektheit und Validierung

#ll-card(
  "/LL010/",
  "Eingabevalidierung",
  "Qualitätsrichtlinie",
  "/LF300/, /LF310/",
  "Ungültige Eingaben dürfen keine undefinierten Zustände erzeugen. Alle Fehlerpfade werden durch Testfälle abgesichert.",
)

#ll-card(
  "/LL020/",
  "Genauigkeit der Peilungsberechnung",
  "Fachanforderung",
  "/LF050/",
  "Für Distanzen von über 10 m darf der berechnete Azimut maximal ±1° von einer Referenz (Haversine-Formel) abweichen. Die Überprüfung erfolgt anhand definierter Referenzpunkte (Äquator, Polnähe, Stuttgart).",
)

=== Wartbarkeit und Dokumentation

#ll-card(
  "/LL100/",
  "Wartbarkeit und Dokumentationsqualität",
  "Vorlesung SWE",
  "–",
  "Die gesamte öffentliche API der Komponente muss vollständig mit Javadoc dokumentiert sein. Ein Checkstyle-Plugin im Maven-Build prüft die Einhaltung der Dokumentationsregeln. Fehlende Javadoc führen zu einem Build-Fehler.",
)

=== Portabilität und Übertragbarkeit

#ll-card(
  "/LL110/",
  "Portabilität",
  "Projektauftrag",
  "–",
  "Die Komponente darf keine plattformspezifischen Pfade, Zeilentrennzeichen oder `sun.*`-APIs verwenden. Sie muss auf Windows, macOS und Linux ohne Anpassungen kompilierbar und ausführbar sein. Ist dies nicht realisierbar, muss eine ausführliche Anleitung in einer README-Datei bereitgestellt werden.",
)

#ll-card(
  "/LL120/",
  "Übertragbarkeit / Build-Reproduzierbarkeit",
  "Projektauftrag",
  "–",
  "Der Maven-Build muss auf einem frisch geklonten Repository ohne manuelle Schritte außer einer JDK-Installation (Java 17+) erfolgreich durchlaufen. Kein Zugriff auf lokale Systemkonfigurationen ist erlaubt.",
)

=== Sicherheit

#ll-card(
  "/LL130/",
  "Sicherheit der XML-Ausgabe",
  "Sicherheitsrichtlinie",
  "/LF320/",
  "Die Bibliothek darf keine dynamische Code-Ausführung aus GPX-Eingaben ermöglichen (XXE-Schutz). Alle in XML-Ausgaben eingebetteten Strings müssen korrekt escaped werden (Entity-Injection-Prävention).",
)

=== Beobachtbarkeit und Logging

#ll-card(
  "/LL140/",
  "Beobachtbarkeit über SLF4J",
  "Betriebsanforderung",
  "/LF330/",
  "Alle Warn- und Fehlerereignisse werden über SLF4J protokolliert. Log-Einträge auf WARN-Level und höher müssen die `sessionId` als strukturiertes Feld enthalten, um eine Korrelation über mehrere Sessions zu ermöglichen.",
)

=== Testabdeckung und Qualitätssicherung

#ll-card(
  "/LL150/",
  "Testabdeckung",
  "Vorlesung SWE",
  "/LF340/",
  "Die Kernmodule (bearing-core, gps-tracker, gpx-exporter) müssen gemäß Spezifikation eine Zeilenabdeckung von mindestens 85 % erreichen. Für kritische Domänenklassen (Session-Lebenszyklus, Peilungsberechnung) gilt ein Mindestwert von 90 %.",
)

#ll-card(
  "/LL160/",
  "Wiederanlauf nach Exception",
  "Betriebsanforderung",
  "–",
  "Nach einer unerwarteten Exception muss die Komponente in einen definierten Leerlaufzustand zurückkehren können, ohne dass ein Neustart der JVM erforderlich ist. Der Zustand IDLE muss erreichbar sein.",
)

#ll-card(
  "/LL170/",
  "Determinismus der Tests",
  "Testbarkeitsanforderung",
  "/LF340/",
  "Alle zeitabhängigen Tests verwenden ausschließlich `Clock`-Injection statt `System.currentTimeMillis()`. Kein Test darf von externem Netzwerkzustand oder Dateisystemzustand abhängen.",
)

=== Ressourcenverhalten

#ll-card(
  "/LL180/",
  "Energieeffizienz der Positionsaufrufe",
  "Betriebsanforderung",
  "–",
  "Die Aufrufhäufigkeit von `onPositionUpdate` liegt beim Host. Der Host soll vermeiden, unnötig dichte Fix-Ströme zu erzeugen, die Speicher und Batterie belasten; die Bibliothek reduziert beim Einlesen nicht stillschweigend.",
)

#ll-card(
  "/LL190/",
  "Determinismus bei gleichen Eingaben",
  "Qualitätsanforderung",
  "–",
  "Gleiche Eingabesequenzen mit festem `Clock`-Mock müssen stets zum selben Track und derselben GPX-Ausgabe führen. Die wichtigsten Funktionen müssen stets zum gleichen Ergebnis führen.",
)

=== Lizenzen

#ll-card(
  "/LL200/",
  "Abhängigkeitslizenzierung",
  "Rechtliche Anforderung",
  "–",
  "Im Standard-Build dürfen nur permissiv lizenzierte Bibliotheken (Apache 2.0, MIT, BSD) verwendet werden. Die W3W-Client-Abhängigkeit ist optional und nur im Maven-Profil `w3w` aktiviert.",
)

#pagebreak()

// ═════════════════════════════════════════════════════════════════════════════
== Externe Schnittstellen
// ═════════════════════════════════════════════════════════════════════════════

Dieser Abschnitt beschreibt alle Ein- und Ausgabeschnittstellen der Java-Peilungskomponente vollständig. Da die Bibliothek keine grafische Benutzeroberfläche besitzt, sind sämtliche Schnittstellen programmatischer Natur (Java-API) oder standardisierte Datenformate (GPX, JSON via W3W).

=== Java-API: Öffentliche Schnittstellen (Eingabe)

Die Host-Anwendung steuert die Bibliothek ausschließlich über die öffentliche Java-API. Alle Methoden sind in Javadoc vollständig beschrieben (/LL100/).

#figure(
  caption: [Öffentliche API-Methoden der Java-Peilungskomponente (Auszug).],
  kind: table,
  align(left, table(
    columns: (4.5cm, 1fr, 2.5cm),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Methode*], [*Beschreibung*], [*Vorbedingung*],
    [`startSession(target, config)`], [Startet eine neue Peilung; gibt Session-UUID zurück.], [Kein ACTIVE-State],
    [`onPositionUpdate(fix)`],        [Verarbeitet einen GPS-Fix; aktualisiert Track und Peilungsgrößen.], [Session ACTIVE],
    [`onHeadingUpdate(headingDeg)`],  [Optionaler Kursupdate für Kursabweichungsberechnung.], [Session ACTIVE],
    [`getSnapshot()`],                [Gibt aktuellen Peilungsschnappschuss zurück (`BearingSnapshot`).], [Min. 1 gültiger Fix],
    [`complete()`],                   [Beendet Session regulär; gibt GPX-Ergebnis zurück.], [Session ACTIVE],
    [`abort()`],                      [Bricht Session ab; gibt GPX-Ergebnis zurück.], [Session ACTIVE],
    [`reset()`],                      [Setzt Session auf IDLE zurück.], [COMPLETED oder ABORTED],
    [`resolveW3w(coordinate)`],       [Löst Koordinate in W3W-Adresse auf (optional).], [API-Key konfiguriert],
  ))
)

=== Datentypen der Schnittstellen

#figure(
  caption: [Zentrale Datentypen der öffentlichen API.],
  kind: table,
  align(left, table(
    columns: (3.5cm, 1fr, 2cm),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Typ*], [*Beschreibung*], [*Stereotyp*],
    [`GeoCoordinate`],    [WGS84-Koordinate (lat, lon), validiert.],                             [Value Object],
    [`GpsFix`],           [Zeit + Position + optionale HDOP/Speed/Elevation.],                   [Value Object],
    [`SessionConfig`],    [Immutable Konfiguration (Budgets, Schwellwerte, API-Key).],            [Value Object],
    [`BearingSnapshot`],  [Azimut, Distanz, Ordinalrichtung, optionale Kursabweichung.],         [Value Object],
    [`GpxResult`],        [GPX-Dokument als `String` und `byte[]` (UTF-8).],                     [Value Object],
    [`SessionStats`],     [Statistikobjekt: Gesamtdistanz, Dauer, Punktanzahl.],                 [Value Object],
    [`TrackOptimizer`],   [Strategy-Interface für Track-Optimierungsalgorithmen.],               [Interface],
    [`BearingListener`],  [Observer-Interface für Session-Ereignisse.],                          [Interface],
  ))
)

=== Java-API: Listener-Events (Ausgabe)

#figure(
  caption: [Listener-Ereignisse (Observer-Pattern, /LF080/).],
  kind: table,
  align(left, table(
    columns: (4cm, 1fr),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Ereignis*], [*Beschreibung*],
    [`onSessionStarted(sessionId)`],    [Session wurde erfolgreich gestartet.],
    [`onPositionProcessed(snapshot)`],  [Fix verarbeitet; Snapshot mit aktuellen Peilungsgrößen.],
    [`onSoftLimitReached(count)`],      [Soft-Limit der Trackpunkte überschritten (WARN).],
    [`onHardLimitReached(count)`],      [Hard-Limit erreicht; Aufzeichnung gestoppt.],
    [`onSessionCompleted(result, stats)`],[Session regulär beendet mit GPX-Ergebnis und Statistik.],
    [`onSessionAborted(result, stats)`],  [Session abgebrochen mit GPX-Ergebnis und Statistik.],
    [`onError(exception)`],             [Fehler mit semantischer Exception-Klassifikation.],
  ))
)

=== GPX 1.1-Ausgabeformat

Die GPX-Ausgabe ist vollständig standardkonform nach GPX 1.1 (Namespace: `http://www.topografix.com/GPX/1/1`). Die XML-Struktur ist UTF-8-kodiert. Alle eingebetteten Nutzerstrings werden escaped (/LL130/).

#diagramm-box("GPX-Schemastruktur (vereinfacht)")[
  ```
  <gpx version="1.1" xmlns="http://www.topografix.com/GPX/1/1">
    <metadata>
      <name>...</name>
      <time>2026-06-12T10:00:00Z</time>
      <bounds minlat="..." minlon="..." maxlat="..." maxlon="..."/>
    </metadata>
    <trk>
      <name>...</name>
      <trkseg>
        <trkpt lat="48.7758" lon="9.1829">
          <ele>248.0</ele>
          <time>2026-06-12T10:01:00Z</time>
          <hdop>1.2</hdop>
        </trkpt>
        ...
      </trkseg>
    </trk>
  </gpx>
  ```
]

=== What3Words-HTTP-Schnittstelle (optional)

Die W3W-Schnittstelle ist über den Port `W3wClient` abstrahiert. Die konkrete Implementierung kommuniziert per HTTPS mit der What3Words-REST-API. Bei fehlendem API-Key oder Netzwerkfehler greift ein definierter Fallback (/LF280/).

=== Use-Case-Spezifikationen (Auszug)

*UC-01: Session starten*

_Primärer Akteur:_ Host-App.\
_Vorbedingungen:_ Instanz im Zustand IDLE; Konfiguration konsistent.\
_Nachbedingungen Erfolg:_ Session existiert mit UUID; Zustand ACTIVE; Konfiguration eingefroren.\
_Nachbedingungen Fehlschlag:_ Keine Session; semantische Exception mit Fehlercode.

_Hauptablauf:_
+ Host übergibt `SessionConfig` und `GeoCoordinate target`.
+ System validiert Wertebereiche (/LF300/, /LF400/).
+ System erzeugt UUID, setzt `startedAt = clock.instant()`, registriert Listener-Basis.
+ System sendet `onSessionStarted` (/LF080/).

_Sonderfälle:_ Doppelstart ohne Finalisierung → /LF020/.

*UC-05: Abbruch*

_Auslöser:_ Host bricht Feldaktion ab.\
_Hauptablauf:_
+ `abort()` wird aufgerufen.
+ System setzt ABORTED, `endedAt`.
+ System materialisiert GPX-Datenstruktur im Speicher.
+ Wenn `persistOnAbort = true`, atomares Schreiben (/LF220/); sonst nur Rückgabeobjekt (/LF230/).
+ Listener `onSessionAborted` mit Statistik (/LF500/).

=== Sequenzbeschreibung: complete() bis GPX-String

#diagramm-box("Sequenz: `complete()` bis GPX-String")[
  `Host` → `BearingSession`: `complete()`\
  `BearingSession` → `TrackRepository`: `immutableView()`\
  `BearingSession` → `OptimizationPipeline`: `apply(config.strategies)`\
  `OptimizationPipeline` → `TrackOptimizer`: `optimize(points)`\
  `BearingSession` → `GpxSerializer`: `toDocument(track, metadata)`\
  `GpxSerializer` → `XmlEscaper`: `escape(textFields)`\
  `GpxSerializer` → `Host`: `GpxResult(bytes, stats)`\
  _Hinweis:_ Reihenfolge der Optimierer ist konfigurationsabhängig.
]

#diagramm-box("Sequenz: Fehlerpfad ungültige Koordinate")[
  `Host` → `BearingSession`: `onPositionUpdate(fix)`\
  `BearingSession` → `Validator`: `validate(fix)`\
  `Validator` → `BearingSession`: `throws ValidationException(errorCode=COORD_RANGE)`\
  `BearingSession` → `Logger`: `warn(sessionId, code)`\
  `BearingSession` → `Host`: *propagate*
]

#pagebreak()

// ═════════════════════════════════════════════════════════════════════════════
== Anforderungen an die Performance
// ═════════════════════════════════════════════════════════════════════════════

Dieser Abschnitt konkretisiert die Leistungs- und Ressourcenanforderungen der Java-Peilungskomponente mit messbaren Grenzen. Die Werte wurden auf Grundlage typischer Laptop-Hardware (Referenz-CI-Umgebung) festgelegt.

=== Leistungskennwerte

#figure(
  caption: [Quantitative Performance-Anforderungen der Java-Peilungskomponente.],
  kind: table,
  align(left, table(
    columns: (3.8cm, 1fr, 2.5cm),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Kennwert*], [*Anforderung / Grenzwert*], [*Anforderung*],
    [Max. Punkte im Speicher],  [10.000 (Richtwert); über Hard-Limit konfigurierbar.], [/LL050/],
    [GPX-Exportdauer],          [Unter 2 s für 10.000 Punkte auf Referenz-Laptop (ohne Optimierung).], [/LL040/],
    [Peilungszyklus],           [Worst-Case ohne GC unter 100 ms; typisch deutlich unter 1 ms.], [/LL030/],
    [Heap-Zuwachs (10k Punkte)],[Typischerweise unter 50 MB; durch Test zu validieren.], [/LL050/],
    [XML-Größe],                [Kein hartes Limit; Host kann Hard-Limit über Punktbudget erzwingen.], [/LF180/],
    [Dateipfad],                [Muss innerhalb konfigurierbarem Basisverzeichnis liegen.], [/LF320/],
  ))
)

=== Detaillierte Performance-Anforderungen (/LL030/–/LL050/)

#ll-card(
  "/LL030/",
  "Performance der Peilungsberechnung",
  "Echtzeit-Anforderung",
  "/LF030/",
  "Ein vollständiger Update-Zyklus (Positionsupdate → Azimut/Distanz berechnen) soll auf üblicher Laptop-Hardware typischerweise deutlich unter 1 ms liegen. Der Worst-Case-Grenzwert beträgt dabei 100 ms ohne GC-Pause.",
)

#ll-card(
  "/LL040/",
  "Performance des GPX-Exports",
  "Performanceanforderung",
  "/LF200/",
  "Der GPX-Export für 10.000 Punkte ohne Douglas-Peucker-Optimierung soll auf Laptop-Hardware in unter 2 Sekunden erfolgen. Dieser Richtwert ist zu dokumentieren und in einem Benchmark-Test zu messen.",
)

#ll-card(
  "/LL050/",
  "Speicherverbrauch",
  "Ressourcenanforderung",
  "/LF180/",
  "Für einen Track mit 10.000 Punkten soll der Heap-Zuwachs der Bibliothek typischerweise unter 50 MB bleiben. Dieser Richtwert ist durch einen Test zu validieren.",
)

=== Aktivitätsbeschreibung: Positionsupdate-Performance

#diagramm-box("Aktivität: Positionsupdate (`onPositionUpdate`)")[
  *Startknoten* → *Eingangsparameter prüfen* (nicht `null`, Lat/Lon in WGS84, Zeit plausibel /LF310/).

  *Entscheidung:* ungültig? → *Exception werfen* (/LF090/, /LF300/) → *Endknoten (Fehler)*.

  *Aktion:* *Segmentierung prüfen* – große Zeitlücke → neues `trkseg` (/LF170/).

  *Aktion:* *Punktbudget prüfen* – Soft-Limit → WARN-Event; Hard-Limit → kontrollierter Stopp (/LF180/).

  *Aktion:* *Fix in Rohspeicher übernehmen*.

  *Aktion:* *Haversine + Azimut* berechnen, optional Kursabweichung (/LF030/, /LF040/, /LF050/).

  *Aktion:* *Listener feuern* (/LF080/).

  *Endknoten (Erfolg)*.
]

=== Aktivitätsbeschreibung: GPX-Export mit Optimierungspipeline

#diagramm-box("Aktivität: GPX-Export mit Optimierungspipeline")[
  *Start* → *Rohtrack klonen / immutabel halten*.

  *Entscheidung:* Sind `TrackOptimizer` in der Session-Konfiguration registriert?
  → *Fork (sequentiell):* n-ter Punkt (/LF240/) → Mindestabstand (/LF250/) → Geraden-Heuristik (/LF260/) → optional Douglas-Peucker (/LF270/).

  *Sonst:* Rohpunkte unverändert übernehmen.

  *Merge* → *Metadaten anreichern* (/LF210/) → *XML erzeugen + escapen* (/LF200/, /LL130/) → *String/Bytes* (/LF230/).

  *Ende*.
]

#pagebreak()

// ═════════════════════════════════════════════════════════════════════════════
== Qualitäts-Anforderungen
// ═════════════════════════════════════════════════════════════════════════════

=== Qualitätsmodell nach ISO/IEC 25010

Die Qualitätskriterien wurden in Anlehnung an ISO/IEC 25010 ausgewählt und gewichtet. Die Gewichtung spiegelt den Schwerpunkt der Bibliothek als reine Logik-Komponente ohne eigene UI wider.

#let category-rows = (1, 8, 13, 19, 23, 29)

#{
  show figure: set block(breakable: true)
  figure(
    caption: [Gewichtung der Qualitätsmerkmale nach ISO/IEC 25010 (Relevanzstufen je Unterkriterium).],
    kind: table,
    table(
      columns: (2.5fr, 0.9fr, 0.9fr, 0.9fr, 1.1fr),
      stroke: 0.5pt + rgb("#AAAAAA"),
      fill: (x, y) => {
        if y == 0 {
          rgb("#4a4a4a")
        } else if y in category-rows {
          rgb("#9ab8cc")
        } else if calc.even(y) {
          rgb("#f2f2f2")
        } else {
          white
        }
      },
      inset: (x: 7pt, y: 5pt),
      align: (x, y) => if x == 0 { left + horizon } else { center + horizon },
      table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[Produktqualität]],
      table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[sehr wichtig]],
      table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[wichtig]],
      table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[normal]],
      table.cell(fill: rgb("#888787"))[#text(fill: white, weight: "bold")[nicht relevant]],

      [*Funktionalität*], [], [], [], [],
      [Angemessenheit], [x], [], [], [],
      [Sicherheit], [], [], [x], [],
      [Interoperabilität], [], [], [x], [],
      [Konformität], [], [x], [], [],
      [Ordnungsmäßigkeit], [], [], [x], [],
      [Richtigkeit], [], [x], [], [],

      [*Zuverlässigkeit*], [], [], [], [],
      [Fehlertoleranz], [], [], [x], [],
      [Konformität], [], [], [x], [],
      [Reife], [], [x], [], [],
      [Wiederherstellbarkeit], [], [x], [], [],

      [*Benutzbarkeit*], [], [], [], [],
      [Attraktivität], [x], [], [], [],
      [Bedienbarkeit], [], [x], [], [],
      [Erlernbarkeit], [x], [], [], [],
      [Konformität], [], [], [x], [],
      [Verständlichkeit], [], [x], [], [],

      [*Effizienz*], [], [], [], [],
      [Konformität], [], [], [x], [],
      [Zeitverhalten], [], [], [x], [],
      [Verbrauchsverhalten], [], [], [], [x],

      [*Änderbarkeit*], [], [], [], [],
      [Analysierbarkeit], [], [], [x], [],
      [Konformität], [], [], [x], [],
      [Modifizierbarkeit], [], [x], [], [],
      [Stabilität], [], [x], [], [],
      [Testbarkeit], [], [], [x], [],

      [*Übertragbarkeit*], [], [], [], [],
      [Anpassbarkeit], [], [], [], [x],
      [Austauschbarkeit], [], [x], [], [],
      [Installierbarkeit], [], [], [x], [],
      [Koexistenz], [], [x], [], [],
      [Konformität], [], [], [x], [],
    ),
  )
}

=== Ableitung der messbaren Qualitätsanforderungen

Die Gewichtung der Matrix wird in den folgenden messbaren nicht-funktionalen Anforderungen konkretisiert:

- *Sicherheit:* XXE-Schutz und Pfadtraversal-Prävention (/LL130/, /LF320/).
- *Wartbarkeit:* Javadoc vollständig öffentliche API; Checkstyle-Prüfung (/LL100/).
- *Performance:* Benchmark-Tests für Peilungszyklus und GPX-Export (/LL030/, /LL040/).
- *Zuverlässigkeit:* Exception-Hierarchie, Wiederanlauf nach Fehler (/LF090/, /LL160/).
- *Testbarkeit:* Zeilenabdeckung ≥ 85 % (Kernmodule), ≥ 90 % (kritische Klassen) (/LL150/).

=== Produktdaten (/LD…/)

Die folgenden Produktdaten beschreiben die persistenten bzw. transportierten Datenstrukturen der Bibliothek.

#ld-card(
  "/LD100/",
  "Peilungs-Session",
  "/LF010/, /LF070/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [sessionId], [UUID (36 Zeichen)],
      [status], [Enum: ACTIVE, COMPLETED, ABORTED],
      [target], [GeoCoordinate (Zielposition)],
      [startedAt], [Instant (UTC)],
      [endedAt], [Optional\<Instant\>],
      [config], [SessionConfig (immutable)],
    )
  ],
)

#ld-card(
  "/LD110/",
  "Konfiguration (SessionConfig)",
  "/LF400/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [softLimitPoints], [int (Optional, 0 = deaktiviert)],
      [hardLimitPoints], [int (Optional, 0 = deaktiviert)],
      [segmentGapThreshold], [Duration (Standard: 5 min)],
      [maxFixAge], [Duration (Validierung, Standard: 24 h)],
      [persistOnAbort], [boolean (Standard: false)],
      [w3wApiKey], [Optional\<String\>],
    )
  ],
)

#ld-card(
  "/LD120/",
  "GPS-Track",
  "/LF100/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [segments], [List\<TrackSegment\>],
      [totalPoints], [int (abgeleitete Kennzahl)],
      [timeRange], [Optional\<Duration\>],
    )
  ],
)

#ld-card(
  "/LD130/",
  "GPS-Punkt (GpsPoint)",
  "/LF100/, /LF150/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [lat], [double (−90° bis +90°)],
      [lon], [double (−180° bis +180°)],
      [time], [Instant (UTC, Pflichtfeld)],
      [ele], [Optional\<Double\> (Höhe in m)],
      [hdop], [Optional\<Double\>],
      [speed], [Optional\<Double\> (m/s)],
    )
  ],
)

#ld-card(
  "/LD140/",
  "Peilungs-Snapshot (BearingSnapshot)",
  "/LF050/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [azimuthDeg], [double (0° bis 360°)],
      [distanceM], [double (Meter)],
      [compassOrdinal], [Enum: N, NE, E, SE, S, SW, W, NW],
      [bearingErrorDeg], [Optional\<Double\>],
    )
  ],
)

#ld-card(
  "/LD150/",
  "GPX-Dokument",
  "/LF200/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [xmlNamespace], [GPX 1.1 URI (Pflicht)],
      [metadata], [GpxMetadata],
      [trk], [Liste von trkpt-Elementen],
      [encoding], [UTF-8 (fest)],
    )
  ],
)

#ld-card(
  "/LD160/",
  "GPX-Metadaten (GpxMetadata)",
  "/LF210/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [name], [Optional\<String\> (max. 200 Zeichen)],
      [desc], [Optional\<String\>],
      [author], [Optional\<String\>],
      [timeBounds], [Optional (start/end Instant)],
    )
  ],
)

#ld-card(
  "/LD170/",
  "Optimierungsergebnis",
  "/LF240/–/LF270/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [originalCount], [int],
      [optimizedCount], [int],
      [appliedStrategies], [List\<String\>],
      [epsilonMeters], [Optional\<Double\>],
    )
  ],
)

#ld-card(
  "/LD180/",
  "W3W-Cache-Eintrag",
  "/LF290/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [lat], [double],
      [lon], [double],
      [words], [String (drei Wörter)],
      [resolvedAt], [Instant],
      [ttl], [Duration],
    )
  ],
)

#ld-card(
  "/LD190/",
  "Fehlerprotokoll-Eintrag",
  "/LF330/",
  [
    #table(
      columns: (1fr, 1fr),
      stroke: 0.3pt + gray,
      inset: 5pt,
      [timestamp], [Instant],
      [errorCode], [String (maschinenlesbar)],
      [context], [String (menschenlesbar)],
      [sessionId], [Optional\<UUID\>],
      [stacktrace], [Optional\<String\>],
    )
  ],
)

=== Qualitätssicherung: Teststrategie

Die Qualitätssicherung folgt einem V-Modell-light: Zu jedem signifikanten `/LF` existiert mindestens ein dokumentierter Testfall. Nicht-funktionale Anforderungen werden, wo messbar, per Mikrobenchmark oder Architekturtest abgesichert.

*Testebenen:*

+ *Unit-Tests:* Isolierte Klassen mit Mocks für `Clock`, `W3wClient`, Dateisystem (Jimfs oder temporäre Verzeichnisse).
+ *Komponententests:* Interaktion `BearingSession` mit echtem `TrackAggregator`, aber ohne Netzwerk.
+ *Contract-Tests:* GPX-XML gegen XSD (optional im CI-Schritt).
+ *Performance-Mikrotests:* JMH oder einfache `@Timeout`-Tests mit oberen Schranken.

=== Testfälle (Auszug)

#figure(
  caption: [Dokumentierte Testfälle der Java-Peilungskomponente (Auszug).],
  kind: table,
  align(left, table(
    columns: (1.5cm, 1fr, 2.6cm, 2cm),
    stroke: tbl-stroke, inset: 5pt,
    [*TC-ID*], [*Vorgehen*], [*Erwartung*], [*`/LF`*],
    [TC-010], [Doppel-`startSession` ohne `complete`], [Exception, Zustand konsistent], [/LF020/],
    [TC-020], [Lat = 91° übergeben], [`IllegalArgumentException`], [/LF300/],
    [TC-050], [Soft-Limit erreicht], [WARN-Event], [/LF120/],
    [TC-060], [Hard-Limit erreicht], [LIMIT-Event, kontrollierter Stopp], [/LF180/],
    [TC-070], [Abort ohne persist], [GPX-String ≠ leer, keine Datei], [/LF070/, /LF230/],
    [TC-080], [Abort mit persist], [Datei existiert, atomar geschrieben], [/LF220/],
    [TC-090], [Pfad `../../etc/passwd`], [`SecurityException`], [/LF320/],
    [TC-100], [GPX Namespace prüfen], [Deklaration `http://www.topografix.com/GPX/1/1`], [/LF200/],
    [TC-110], [n-Optimierer n=10, 100 Punkte], [Start/Ende erhalten, Länge reduziert], [/LF240/],
    [TC-120], [Geraden-Heuristik synthetisch], [3 kollineare Punkte → 2], [/LF260/],
    [TC-130], [Douglas–Peucker ε groß], [Starke Reduktion ohne Exception], [/LF270/],
    [TC-140], [W3W Fehler API], [Fallback, kein Crash], [/LF280/],
    [TC-150], [W3W Cache TTL], [Kein erneuter Netzwerkaufruf innerhalb TTL], [/LF290/],
    [TC-160], [Clock-Mock-Sprünge], [Deterministische Zeitstempel], [/LF340/],
    [TC-200], [Start Happy Path], [Session ACTIVE, UUID vorhanden], [/LF010/],
    [TC-210], [Snapshot gegen Referenz-Haversine], [Azimut-Abweichung ≤ ±1°], [/LF050/],
  ))
)

=== Traceability-Matrix (Auszug)

#figure(
  caption: [Rückverfolgbarkeit von Anforderungen zu Modulen und Testfällen.],
  kind: table,
  align(left, table(
    columns: (1.8cm, 2.4cm, 2.4cm, 1fr),
    stroke: tbl-stroke, inset: 5pt,
    [*`/LF`*], [*Modul*], [*Test-ID*], [*Beschreibung*],
    [/LF010/], [`bearing-core`],   [TC-200],       [Start Happy Path],
    [/LF050/], [`bearing-core`],   [TC-210],       [Snapshot gegen Referenz-Haversine],
    [/LF100/], [`bearing-domain`], [TC-050, TC-060],[Rohspeicher, Soft-/Hard-Limit],
    [/LF200/], [`gpx-exporter`],   [TC-100],       [XML assertions],
    [/LF320/], [`gpx-exporter`],   [TC-090],       [Path normalization],
    [/LF060/], [`bearing-core`],   [TC-GPX-01..03],[GPX-Serialisierung],
    [/LF280/], [`w3w-adapter`],    [TC-W3W-01..03],[W3W-Fallback und Cache],
  ))
)

=== FMEA: Fehlermöglichkeits- und Einflussanalyse

#figure(
  caption: [FMEA (vereinfacht): Fehlermodi, Folgen und Gegenmaßnahmen.],
  kind: table,
  align(left, table(
    columns: (2.2cm, 1fr, 1.2cm, 1.2cm, 1fr),
    stroke: tbl-stroke, inset: 5pt,
    [*Fehler*], [*Folge*], [*A*], [*E*], [*Maßnahme*],
    [Ungültige Zeit],       [Falsche Segmentierung],   [M], [M], [Validator /LF310/],
    [Speicheroverflow],     [OOM],                     [G], [K], [Hard-Limit /LF180/],
    [XML-Injection],        [Sicherheitsrisiko Host],  [G], [M], [Escaping /LL130/],
    [Race im Listener],     [Inkonsistente UI],        [M], [M], [Thread-Policy /LF350/],
    [W3W-Ausfall],          [Fehlender W3W-Wert],      [G], [G], [Fallback + Cache /LF280/],
    [Path Traversal],       [Datei-Sicherheitslücke],  [G], [M], [Pfadnormalisierung /LF320/],
  ))
)

*Legende A (Auftreten), E (Entdeckung):* S/M/G/K (stark/mittel/gering/katastrophal) – qualitativ, nicht normiert.

=== Abdeckungsziele (JaCoCo)

#diagramm-box("Abdeckungsziele (JaCoCo)")[
  Kernmodule `bearing-core`, `gps-tracker`, `gpx-exporter`: Zeilenabdeckung ≥ 85 % (/LL150/).\
  Kritische Klassen `BearingSession`, `BearingCalculator`: ≥ 90 %.
]

=== Checkliste vor Abgabe

+ Alle Anforderungen von /LF010/ bis /LF500/ sind referenziert durch mindestens einen Testfall oder expliziten Review-Nachweis.
+ `mvn -q test` grün auf Windows/Linux/macOS CI-Matrix (empfohlen: GitHub Actions).
+ Javadoc vollständig für öffentliche API (/LL100/).
+ Keine UI-Imports (/LF430/).
+ GPX-Beispieldatei validiert gegen XSD 1.1 (optional).

#pagebreak()
]
