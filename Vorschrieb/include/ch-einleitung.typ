#let ch-einleitung-kapitel = [
#set par(justify: true)

== Problemstellung

Im Rahmen der Projektarbeit wird die iOS-Anwendung _Kompass Professional_ als fachliche Referenz analysiert. Der Fokus liegt auf der Peilungsfunktion und nicht auf einer vollständigen Navigationslösung. Unter *Peilung* wird in dieser Arbeit die Berechnung der Richtung und Entfernung von der aktuellen Position zu einem Zielpunkt verstanden; optional kann die Abweichung zum aktuellen Kurs berücksichtigt werden, sofern ein Kurswert vom Host-System bereitgestellt wird.

Aus der Aufgabenstellung ergeben sich vier eng miteinander verknüpfte Kernprobleme:

+ *Fachliche Eindeutigkeit:* Die Begriffe, Eingangsgrößen und Berechnungsregeln der Peilung müssen präzise definiert, nachvollziehbar und reproduzierbar sein.
+ *Systemneutrale Integration:* Die Lösung ist als UI-freie Java-Komponente zu entwerfen, die in beliebige Java-Oberflächen integrierbar ist und ihre Daten ausschließlich über klar spezifizierte Schnittstellen erhält.
+ *Datenqualität und Nachvollziehbarkeit:* Während einer Peilung ist ein GPS-Track robust aufzuzeichnen, bei ungültigen Messwerten kontrolliert zu reagieren und ein konsistenter Datenstand auch bei Abbruch bereitzustellen.
+ *SWE-konforme Umsetzung:* Die Benotung verlangt eine durchgängige Kette aus Anforderungsanalyse, Spezifikation, objektorientiertem Entwurf, Implementierung und Test mit den in beiden Semestern vermittelten Methoden.

== Zielsetzung

Das übergeordnete Ziel ist eine *vollständige, prüfbare Spezifikation* zusammen mit einer *Referenzimplementierung* als Maven-Projekt. Konkret:

- *Anforderungsanalyse und Spezifikation:* SOPHIST-konforme, eindeutig prüfbare Anforderungen (funktional, nicht-funktional, Daten, Schnittstellen, Randbedingungen) inklusive Qualitäts- und Risikoaspekten sowie objektorientierter Analyse- und Entwurfsartefakte.
- *Implementierung:* UI-freie Java-Komponente mit klaren Eingabeschnittstellen für Positions- und Rechnungsdaten, konfigurierbarer Aufzeichnung, GPX-1.1-konformem Export und optionaler What3Words-Integration.
- *Qualitätssicherung:* Nachvollziehbare Testfälle pro fachlichem Modul, automatisierte Ausführung über Maven und reproduzierbare Ergebnisse als Grundlage der Abnahme.
- *Lieferfähigkeit:* Abgabe des lauffähigen Quellcodes (keine ausführbare Fat-JAR als Hauptartefakt) mit sofort ausführbarer Test-Suite.

Die Arbeit adressiert explizit das in der Aufgabenstellung genannte Mindestformat von *mindestens 50 Druckseiten* (A4, Fließtext und tabellarische Anforderungsdokumente) und berücksichtigt das Semester-3-Feedback zu *Inhaltsverzeichnis*, *Seitennummerierung* und *formalen SOPHIST-konformen Anforderungen*.

== Abgrenzung und Scope

*Im Scope:*

- Geografische Berechnung von Zielrichtung (Azimut), Entfernung und diskreter Ordinalrichtung auf WGS84-Basis; optionale Kursabweichung bei verfügbarem Kurswert.
- Klar definierte Integrationsschnittstellen, über die der Host Positionsdaten und weitere Rechnungsdaten (z. B. Zeitstempel, Geschwindigkeit, Genauigkeit) bereitstellt.
- Session-Lebenszyklus mit Start, laufender Aufzeichnung und Abbruch; bei Abbruch werden die bis dahin erfassten Track-Daten weiterhin exportierbar bereitgestellt.
- Konfigurierbare Aufzeichnungslogik mit zeitlicher Abtastung, maximaler Punktzahl und Strategien zur Reduktion von Datenmengen bei ausreichender Streckenrepräsentation.
- Umgang mit Messfehlern durch Qualitätsfilter (z. B. ungültige Koordinaten, HDOP-Schwellen, unplausible Geschwindigkeitssprünge) und Segmentierung bei Zeitlücken.
- GPX-1.1-konformer Export der Track-Daten als String oder Bytefolge; Persistierung als Datei erfolgt optional durch das aufrufende Host-System.
- Erweiterbare Optimierungsverfahren (z. B. n-ter Punkt, Mindestabstand, Geraden-Heuristik, optional Douglas-Peucker) sowie optionaler What3Words-Bezug inklusive Caching.

*Außerhalb des Scopes:*

- Magnetische Peilung inklusive automatischer Deklinationskorrektur (siehe Glossar; Host-Verantwortung).
- Kartendarstellung, Kartenmatching, Routing, Geocoding allgemeiner Adressstrings (außer W3W-Option).
- Hardwareanbindung (GNSS-Treiber, Sensorfusion) – der Host liefert Messwerte.
- Persistenzvorgaben wie ein festes Dateiziel fuer GPX-Export; Entscheidung ueber Speicherort und Dateiverwaltung liegt beim Host.
- Cloud-Persistenz, Benutzerverwaltung, Rechteverwaltung.

#pagebreak()
]
