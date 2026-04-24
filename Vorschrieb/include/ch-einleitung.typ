#let ch-einleitung-kapitel = [
#set par(justify: true)

== Problemstellung

Im Rahmen der Projektarbeit wird die iOS-Anwendung _Kompass Professional_ als fachliche Referenz analysiert. Der Fokus liegt auf der Peilungsfunktion und nicht auf einer vollständigen Navigationslösung. Unter Peilung wird in dieser Arbeit die Berechnung der Richtung und Entfernung von der aktuellen Position zu einem Zielpunkt verstanden; optional kann die Abweichung zum aktuellen Kurs berücksichtigt werden, sofern ein Kurswert vom Host-System bereitgestellt wird. 

Die zentrale Problemstellung dieser Arbeit besteht in der konsistenten und reproduzierbaren Berechnung von Zielrichtung (Azimut), Entfernung und diskreter Ordinalrichtung auf Basis von WGS84-Koordinaten unter klar definierten Eingangs- und Schnittstellenbedingungen. Zusätzlich muss die Verarbeitung als kontinuierlicher Session-Prozess mit Start, Laufzeit und Abbruch konzipiert werden, bei dem Track-Daten trotz Unterbrechungen vollständig exportierbar bleiben und gleichzeitig durch kontrollierte Datenreduktion effizient gehalten werden. Insgesamt ergibt sich daraus die Anforderung einer robusten, nachvollziehbaren und erweiterbaren Verarbeitung von Positions- und Bewegungsdaten inklusive standardisiertem GPX-Export.




== Zielsetzung

Ziel der Arbeit ist eine vollständige, prüfbare Spezifikation zusammen mit einer Implementierung als Maven-Projekt.

In der *Anforderungsanalyse und Spezifikation* sollen die Anforderungen SOPHIST-konform und eindeutig prüfbar formuliert werden, also funktional, nicht-funktional, zu Daten, Schnittstellen und Randbedingungen, ergänzt um Qualitäts- und Risikoaspekte sowie um objektorientierte Analyse- und Entwurfsartefakte.

Die *Implementierung* soll als UI-freie Java-Komponente vorliegen, mit klaren Eingabeschnittstellen für Positions- und Rechnungsdaten, konfigurierbarer Aufzeichnung, GPX-1.1-konformem Export und optionaler What3Words-Anbindung.

Die *Qualitätssicherung* soll über nachvollziehbare Testfälle pro fachlichem Modul erfolgen, mit automatisierter Ausführung über Maven und reproduzierbaren Ergebnissen als Grundlage für die Abnahme.

Die *Lieferfähigkeit* umfasst lauffähigen Quellcode ohne eine ausführbare Fat-JAR als Hauptartefakt sowie eine Test-Suite, die sich direkt ausführen lässt.


== Abgrenzung

*Im Scope:*

- Geografische Berechnung von Zielrichtung (Azimut), Entfernung und diskreter Ordinalrichtung auf WGS84-Basis mit optionale Kursabweichung bei verfügbarem Kurswert.
- Klar definierte Integrationsschnittstellen, über die der Host Positionsdaten und weitere Rechnungsdaten (z. B. Zeitstempel, Geschwindigkeit, Genauigkeit) bereitstellt.
- Session-Lebenszyklus mit Start, laufender Aufzeichnung und Abbruch. Bei Abbruch werden die bis dahin erfassten Track-Daten weiterhin exportierbar bereitgestellt.
- Konfigurierbare Aufzeichnungslogik mit zeitlicher Abtastung, maximaler Punktzahl und Strategien zur Reduktion von Datenmengen bei ausreichender Streckenrepräsentation.
- Umgang mit Messfehlern durch Qualitätsfilter (z. B. ungültige Koordinaten, HDOP-Schwellen, unplausible Geschwindigkeitssprünge) und Segmentierung bei Zeitlücken.
- GPX-1.1-konformer Export der Track-Daten als String oder Bytefolge.
- Erweiterbare Optimierungsverfahren (z. B. n-ter Punkt, Mindestabstand, Geraden-Heuristik, optional Douglas-Peucker) sowie optionaler What3Words-Bezug inklusive Caching.

*Außerhalb des Scopes:*

- Magnetische Peilung inklusive automatischer Deklinationskorrektur (siehe Glossar; Host-Verantwortung).
- Kartendarstellung, Kartenmatching, Routing, Geocoding allgemeiner Adressstrings (außer W3W-Option).
- Hardwareanbindung (GNSS-Treiber, Sensorfusion), der Host liefert Messwerte.
- Persistenzvorgaben wie ein festes Dateiziel für GPX-Export, die Entscheidung über Speicherort und Dateiverwaltung liegt beim Host.
- Cloud-Persistenz, Benutzerverwaltung, Rechteverwaltung.

#pagebreak()
]
