#import "macros.typ": *

= Allgemeine Beschreibung

== Einbettung
Die „Java-Peilungskomponente“ ist als zustandsbehaftete Software-Bibliothek (Library) konzipiert. Sie wird als Abhängigkeit (z.B. via Maven oder Gradle) direkt in den Prozessraum einer übergeordneten Host-Anwendung integriert und läuft innerhalb derselben Java Virtual Machine (JVM). 

Die Bibliothek agiert als klassische API-Fassade (Facade-Pattern). Datenflüsse sind streng unidirektional: Die Host-Anwendung schiebt (Push-Prinzip) asynchron Messwerte in die Bibliothek. Die Bibliothek selbst öffnet keine Netzwerk-Sockets für eingehende Daten und liest keine Hardware-Busse aus. Ausgehende Kommunikation findet ausschließlich auf Anforderung statt (z. B. beim Abruf eines HTTP-basierten What3Words-Auflösungsdienstes), wobei auch dies über Dependency Injection vollständig durch Mocks ersetzt werden kann.

== Funktionen und Use Cases
Die Funktionalität der Bibliothek wird durch folgende essenzielle Use Cases (UC) abgebildet:

- *UC-01 Session starten:* 
  - *Vorbedingung:* System befindet sich im IDLE-Zustand.
  - *Aktion:* Die Host-Applikation übergibt Zielkoordinaten und Konfigurationsparameter (z.B. Point-Limit). Das System validiert diese.
  - *Nachbedingung:* Zustand wechselt zu ACTIVE. Interne Speicherstrukturen werden allokiert.
- *UC-02 Positionsupdate verarbeiten:* 
  - *Vorbedingung:* Zustand ist ACTIVE.
  - *Aktion:* Ein neuer WGS84-Fix (Breite, Länge, Höhe, Zeit, optional Kurs) wird übergeben. Das System führt Entprellungsprüfungen (z. B. Entfernung zum letzten Punkt) durch und berechnet aktuelle Distanz sowie Azimut zum Ziel neu.
- *UC-03 Peilungswerte abrufen:* 
  - *Vorbedingung:* Zustand ist ACTIVE, mindestens ein Fix ist verarbeitet.
  - *Aktion:* Das System liefert ein zustandsloses Data-Transfer-Object (DTO), das die aktuellen Werte für Azimut, Distanz, Ordinalrichtung und potenzielle Varianzen enthält.
- *UC-04 Session regulär beenden (Complete):* 
  - *Vorbedingung:* Zustand ist ACTIVE.
  - *Aktion:* Aufnahme neuer Fixes wird blockiert. Das System finalisiert den Track und stößt optional den GPX-Export an.
  - *Nachbedingung:* Zustand ist COMPLETED.
- *UC-05 Session abbrechen (Abort):* 
  - *Aktion:* Die Aufzeichnung wird gestoppt. Die bisher aufgezeichneten Daten werden unoptimiert und ohne zwingende Persistierung als String zurückgegeben.
  - *Nachbedingung:* Zustand ist ABORTED.

== Benutzerprofile und Stakeholder
Die Anforderungen an das System variieren je nach Betrachtungswinkel der beteiligten Stakeholder:
/*
#figure(
  caption: [Stakeholder und Einflussmatrix],
  kind: table,
  align(left, table(
    columns: (3cm, 1fr, 2.5cm),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Stakeholder*], [*Wesentliche Erwartungen*], [*Einfluss*],
    [Prüfer / Auditoren], [Hohe Code-Qualität, nachweisbare Testabdeckung, saubere Dokumentation.], [Sehr hoch],
    [Host-Entwickler], [Abwärtskompatible API, klare Exception-Semantik (Fail-Fast), deterministisches Verhalten für eigene Unit-Tests.], [Hoch],
    [Architektur-Team], [Wartbarkeit, strikte Einhaltung von Clean Code Prinzipien, keine Abhängigkeitshölle.], [Mittel],
    [Endanwender], [Präzise Peilungsdaten ohne Lags oder Abstürze (indirekter Einfluss über Host-App).], [Niedrig]
  ))
)
*/
== Einschränkungen und Annahmen
Folgende systemische Restriktionen sind für die Implementierung bindend:
- *Hardware-Neutralität:* Da die Abtastrate des GPS-Sensors unbekannt ist, gibt es in der Bibliothek keine Timer oder Threads, die auf Sensordaten warten. Alles ist Event-getrieben.
- *Datenbereinigung:* Die Bibliothek nimmt keine automatische Korrektur von Ausreißern (wie extremen Geschwindigkeitssprüngen durch Multipath-Effekte) vor. Fehlerhafte GPS-Punkte des Hosts werden als gegebene Wahrheit verarbeitet.
- *Ausführungsumgebung:* Es wird zwingend eine Java SE Umgebung der Version 11 oder höher vorausgesetzt (bevorzugt LTS-Versionen wie Java 17).