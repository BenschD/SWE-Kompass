#import "macros.typ": *

= Einleitung

== Zweck
Die vorliegende Systemspezifikation beschreibt die Anforderungen und architektonischen Rahmenbedingungen für die Entwicklung einer Java-basierten Peilungskomponente. Die zentrale Problemstellung besteht in der konsistenten, performanten und reproduzierbaren Berechnung geodätischer Basiswerte – konkret der Zielrichtung (Azimut), der geografischen Entfernung und der diskreten Ordinalrichtung – auf Basis des globalen Referenzsystems WGS84. 

Neben der reinen algorithmischen Berechnung (z. B. via Haversine- oder Vincenty-Formel) muss das System in der Lage sein, kontinuierliche Positionsdaten-Ströme im Rahmen eines klar definierten Session-Lebenszyklus zu verwalten. Dieser Lebenszyklus umfasst das Starten einer Tracking-Session, die laufende Aggregation von Wegpunkten unter Berücksichtigung von konfigurierbaren Qualitätskriterien (Punktbudget, Zeitlücken) sowie den sauberen Abschluss oder Abbruch der Session. Ein integrales Kernziel ist die vollständige Exportierbarkeit der aufgezeichneten Datenströme in das GPX-1.1-Format, um die Kompatibilität mit gängigen Geoinformationssystemen (GIS) sicherzustellen.

Die Spezifikation ist SOPHIST-konform formuliert, um eine lückenlose Testbarkeit im späteren TDD-Prozess (Test-Driven Development) zu gewährleisten.

== Einsatzbereich
Der funktionale Scope der Komponente ist bewusst scharf abgegrenzt, um eine hohe Kohäsion und lose Kopplung zu garantieren.

*Im Scope:*
- Geodätische Berechnung der horizontalen Zielrichtung (geografischer Azimut) und Distanz zwischen zwei WGS84-Koordinaten.
- Bestimmung diskreter Ordinalrichtungen (z.B. N, NNE, NE) basierend auf dem berechneten Azimut.
- Verwaltung eines deterministischen Session-Status (ACTIVE, COMPLETED, ABORTED).
- Konfigurierbare Validierung eingehender Wegpunkte (z.B. minimaler räumlicher oder zeitlicher Abstand).
- Standardsicherer Export der Track-Daten als GPX-1.1-konformer String oder direkte Dateisystem-Persistenz.
- Lokales Caching für optionale Reverse-Geocoding-Schnittstellen (z.B. What3Words).

*Außerhalb des Scopes:*
- *Hardware-Interaktion:* Die Komponente kommuniziert nicht mit GNSS-Empfängern, Gyroskopen oder Magnetometern. Die Host-Anwendung ist für das Polling und Parsing der NMEA-Daten zuständig.
- *Routenführung:* Algorithmen für Map-Matching, Routing, Turn-by-Turn-Navigation oder Kartendarstellung sind nicht Bestandteil der Bibliothek.
- *Benutzeroberfläche (UI):* Die Bibliothek ist streng "headless". Es werden keine UI-Komponenten (JavaFX, Swing etc.) bereitgestellt.
- *Datenbanken:* Es ist keine Anbindung an relationale oder NoSQL-Datenbanken vorgesehen; Persistenz erfolgt ausschließlich in-memory oder via Dateiexport.

== Glossar
Um Missverständnisse zwischen Fachexperten und Entwicklern zu vermeiden, gelten folgende Definitionen verbindlich:

#begriffskarte(
  "Peilung (Bearing)",
  "Die Bestimmung der horizontalen Zielrichtung von einem aktuellen Standpunkt zu einem definierten Zielpunkt auf der Erdoberfläche.",
  "Beinhaltet keine Wegpunkt-Navigation entlang eines Pfades (Turn-by-Turn).",
  "Gültig für alle terrestrischen WGS84-Koordinaten.",
  "Winkelmaß in Grad (°)",
  "Allgemeine Navigationsliteratur, ISO 6709"
)

#begriffskarte(
  "Geografischer Azimut",
  "Der im Uhrzeigersinn gemessene horizontale Winkel zwischen der wahren geografischen Nordrichtung und der Großkreisrichtung zum Ziel.",
  "Darf nicht mit dem magnetischen Azimut (welcher Deklination unterliegt) verwechselt werden.",
  "Gültig für Entfernungen > 0 Meter.",
  "Symbol: α (Alpha), Wertebereich: [0°, 360°)",
  "WGS84 Spezifikation"
)

#begriffskarte(
  "Trackpunkt (Trackpoint)",
  "Ein einzelner Messpunkt innerhalb einer Aufzeichnung, bestehend aus geografischer Breite, Länge und einem ISO-8601 Zeitstempel.",
  "Ist strikt vom Routenpunkt (Routepoint) abzugrenzen, der eine geplante Station darstellt.",
  "Gültig innerhalb einer aktiven Session.",
  "Attribute: lat, lon, time",
  "GPX 1.1 Schema"
)

== Überblick
Dieses Dokument gliedert sich in zwei Hauptbereiche: Kapitel 2 ("Allgemeine Beschreibung") erläutert die Systemarchitektur, den Einbettungskontext in die Host-Anwendung sowie die Interaktion der primären Akteure. Kapitel 3 ("Spezifische Anforderungen") bricht diese Konzepte in testbare, funktionale und nicht-funktionale Systemanforderungen herunter, definiert externe Schnittstellen und legt Qualitätsmetriken (wie Performance und Speichermanagement) fest.