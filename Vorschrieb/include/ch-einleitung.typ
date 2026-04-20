#let ch-einleitung-kapitel = [
#set par(justify: true)

== Problemstellung

Mobile Outdoor-Anwendungen unterstützen Nutzerinnen und Nutzer bei der Orientierung im Gelände. Die im App Store veröffentlichte Anwendung _Kompass Professional_ demonstriert eine Peilungsfunktion: Ausgehend von der aktuellen Position wird die Richtung zu einem gewählten Ziel als Richtungsangabe präsentiert – ohne eine vollständige Navigation entlang eines Routengraphs. Im Rahmen der Lehrveranstaltung Softwareengineering soll diese fachliche Idee analysiert und in eine systemneutrale, UI-freie Java-Bibliothek überführt werden, die sich in beliebige Oberflächen integrieren lässt.

Die Problemstellung umfasst drei eng verzahnte Teilprobleme:

+ *Fachliche Korrektheit:* Peilungsgrößen müssen reproduzierbar und geometrisch nachvollziehbar aus Positions- und optionalen Kursdaten abgeleitet werden.
+ *Datenintegrität:* Während einer Peilungssession ist ein GPS-Track aufzuzeichnen, der trotz begrenzter Ressourcen (Speicher, CPU, Energie) den Weg hinreichend genau abbildet und dennoch exportierbar ist.
+ *Engineering-Disziplin:* Die Lösung ist nicht nur „Code“, sondern das Ergebnis einer nachvollziehbaren Kette aus Analyse, Spezifikation, Entwurf, Implementierung und testgetriebener Qualitätssicherung – entsprechend den in der Vorlesung behandelten Artefakten.

== Zielsetzung

Das übergeordnete Ziel ist eine *vollständige technische Dokumentation* zusammen mit einer *referenzimplementierung* als Maven-Projekt. Konkret:

- *Analyse und Spezifikation:* Formalisierte Anforderungen (funktional, nicht-funktional, Daten) inklusive Qualitätsmodell, Risikoanalyse, objektorientierter Analyse- und Entwurfsartefakte sowie Testbarkeit.
- *Implementierung:* Java-Bibliothek ohne UI, konfigurierbare Aufzeichnung, GPX-1.1-konformer Export als Zeichenkette oder Bytes, optionaler W3W-Bezug, austauschbare Optimierungsstrategien.
- *Abnahmefähigkeit:* `mvn test` als Mindestkriterium; Quelltext als Lieferobjekt (keine ausführbare Fat-JAR als Hauptartefakt).

Die Arbeit adressiert explizit das in der Aufgabenstellung genannte Mindestformat von *mindestens 50 Druckseiten* (A4, Fließtext und tabellarische Anforderungsdokumente) und berücksichtigt das Semester-3-Feedback zu *Inhaltsverzeichnis*, *Seitennummerierung* und *formalen SOPHIST-konformen Anforderungen*.

== Abgrenzung und Scope

*Im Scope:*

- Berechnung geografischer Zielrichtung und Entfernung auf WGS84-Basis; diskrete Ordinalrichtung; optional Kursabweichung, sofern der Host einen Kurs liefert.
- Session-Lebenszyklus inklusive Abbruch mit GPX-Datenbereitstellung ohne erzwungenes Dateisystem.
- Konfigurierbare zeitliche Abtastung, Punktbudgets, Qualitätsfilter (HDOP, Geschwindigkeitssprünge), Segmentierung bei Zeitlücken.
- GPX 1.1 Export, Optimierungen (n-ter Punkt, Mindestabstand, Geraden-Heuristik, optional Douglas–Peucker).
- Optional What3Words inklusive Cache; strukturiertes Logging über SLF4J.

*Außerhalb des Scopes:*

- Magnetische Peilung inklusive automatischer Deklinationskorrektur (siehe Glossar; Host-Verantwortung).
- Kartendarstellung, Kartenmatching, Routing, Geocoding allgemeiner Adressstrings (außer W3W-Option).
- Hardwareanbindung (GNSS-Treiber, Sensorfusion) – der Host liefert Messwerte.
- Cloud-Persistenz, Benutzerverwaltung, Rechteverwaltung.

#pagebreak()
]
