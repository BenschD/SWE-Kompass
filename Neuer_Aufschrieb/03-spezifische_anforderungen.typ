#import "macros.typ": *

= Spezifische Anforderungen

== Funktionale Anforderungen
Die funktionalen Anforderungen werden nach den strengen syntaktischen Schablonen der SOPHIST-Gruppe formuliert, um Eindeutigkeit sicherzustellen.

- * /LF010/ Session-Initialisierung:* Das System MUSS fähig sein, eine Session mit Zielkoordinaten zu initiieren, sofern die Koordinaten im gültigen WGS84-Wertebereich liegen (Lat: -90 bis +90, Lon: -180 bis +180).
- * /LF050/ Peilungswerte berechnen:* Wenn eine aktive Session existiert und mindestens ein Positions-Fix vorliegt, MUSS das System dem Aufrufer auf Anfrage ein Objekt liefern, das den geografischen Azimut (0-360°), die Distanz in Metern sowie die berechnete Ordinalrichtung (N, NE, E etc.) enthält.
- * /LF120/ GPX-Generierung:* Wenn die Session den Status COMPLETED oder ABORTED erreicht, MUSS das System in der Lage sein, die aggregierten Trackpunkte gemäß dem XML-Schema GPX 1.1 als validen UTF-8 String zurückzugeben.
- * /LF130/ Punkt-Verwerfung:* Das System MUSS jeden neuen Trackpunkt verwerfen, dessen Zeitstempel zeitlich vor dem zuletzt akzeptierten Trackpunkt liegt (Chronologie-Schutz).

== Nicht-funktionale Anforderungen
Die nicht-funktionalen Anforderungen definieren die architektonischen Leitplanken.

- * /LL190/ Deterministische Ausführung:* Das System MUSS bei Zufuhr derselben Konfiguration und identischen Eingabedatenströmen bitgenau dieselben Ergebnisse (inkl. XML-Output) produzieren. Datum/Zeit-Abhängigkeiten MÜSSEN über Clock-Injection auflösbar sein.
- * /LF440/ API-Sicherheit:* Die Bibliothek DARF in keinem Package auf interne Java-Klassen (z.B. `sun.misc.*` oder `com.sun.*`) zurückgreifen.
- * /LL160/ Lifecycle-Reset:* Das System SOLLTE aus jedem Endzustand (COMPLETED, ABORTED) über einen expliziten Methodenaufruf wieder in den IDLE-Zustand überführt werden können, wobei alle internen Speicherstrukturen via Garbage Collector freigebbar sein müssen.

== Externe Schnittstellen
Da die Software kopflos (headless) agiert, sind die externen Softwareschnittstellen essenziell.
/*
#figure(
  caption: [Systemschnittstellen und Protokolle],
  kind: table,
  align(left, table(
    columns: (3.5cm, 2.5cm, 1fr),
    stroke: tbl-stroke, inset: tbl-inset,
    [*Schnittstelle*], [*Typ/Protokoll*], [*Zweck & Einschränkung*],
    [Core-API], [Java Interface], [Einziger Eintrittspunkt für den Host. Erfordert Parameter-Validierung (Null-Checks).],
    [Event-Callback], [Java Interface], [Asynchroner Rückkanal für den Host bei Statusänderungen (z.B. Erreichen des Punktbudgets).],
    [W3W-Dienst], [HTTP(S) / REST], [Reverse-Geocoding für Koordinaten. Anfragen müssen gecacht werden, um API-Limits nicht zu überschreiten.],
    [Lokales Dateisystem], [File I/O], [Optionaler GPX-Export. Streng geschützt gegen Directory Traversal (Path-Injection).],
  ))
)
*/
== Anforderungen an die Performance
- * /LP010/ Latenz der Verarbeitung:* Das System MUSS einen einzelnen eingereichten Trackpunkt (ohne I/O-Operationen) in weniger als 5 Millisekunden (99. Perzentil) verarbeiten, um den Host-Thread nicht zu blockieren.
- * /LP020/ Speicherbudget:* Das System MUSS ein striktes, konfigurierbares Limit an Trackpunkten im Speicher erzwingen (Default: 10.000 Punkte). Bei Überschreitung muss eine FIFO-Rotation oder ein Exception-Verhalten greifen.
- * /LP030/ Export-Geschwindigkeit:* Die Serialisierung von 10.000 Punkten in einen GPX-String DARF auf einer Standard-x86-Umgebung nicht länger als 1.500 Millisekunden dauern.

== Qualitäts-Anforderungen
Basierend auf der ISO/IEC 25010 Norm liegt der Fokus auf Sicherheit, Wartbarkeit und Zuverlässigkeit.

- *Applikationssicherheit:* Alle String-Eingaben des Hosts (wie Wegpunkt-Namen oder Beschreibungen), die in den GPX-Export fließen, MÜSSEN zwingend XML-escaped werden, um Injection-Attacken auf nachgelagerte Parser zu verhindern.
- *Dateisystem-Integrität:* Wenn ein Pfad für den GPX-Export übergeben wird, MUSS das System validieren, dass der Pfad innerhalb eines vorkonfigurierten Basis-Verzeichnisses liegt. Relative Pfade wie `../../etc/passwd` MÜSSEN zu einer SecurityException führen.
- *Wartbarkeit (Clean Code):* Alle öffentlichen (public und protected) Klassen und Methoden MÜSSEN mit aussagekräftigen Javadoc-Kommentaren versehen sein. Die zyklomatische Komplexität einer einzelnen Methode DARF den Wert 10 nicht überschreiten.