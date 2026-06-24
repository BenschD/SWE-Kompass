# SWE-Kompass

UI-freie Java-Bibliothek für Peilung, GPS-Rohtrack und GPX-1.1-Export.

DHBW Stuttgart, Softwareentwicklung, Dipl. Ing. Peter Bohl

## Inhalt

| Datei / Ordner | Beschreibung |
| --- | --- |
| [`Spezifikation.pdf`](Spezifikation.pdf) | Pflichtenheft (Anforderungen, Schnittstellen, Modelle) |
| [`implementation/`](implementation/) | Maven-Quellcode, Tests, Konsolen-Demo |
| [`implementation/TRACEABILITY.md`](implementation/TRACEABILITY.md) | Zuordnung von /LF/, /LL/ und /TC/ zu Code und JUnit |

Anforderungs-IDs: `/LF010/` bis `/LF250/` (funktional), `/LL010/` bis `/LL080/` (nicht-funktional), `/TC010/` bis `/TC150/` (15 verbindliche Tests).

## Voraussetzungen

Java 11 oder höher, Maven 3.6 oder höher (`mvn` im PATH).

## Maven installieren

Java wird hier vorausgesetzt und nicht erneut beschrieben. Die folgenden Schritte richten nur Maven ein.

### Windows 11

1. Laden Sie auf https://maven.apache.org/download.cgi das Binary zip archive herunter, zum Beispiel `apache-maven-3.9.16-bin.zip`. Achten Sie auf das bin-Archiv und nicht auf das src-Archiv.
2. Entpacken Sie das Archiv an einen festen Ort ohne Leerzeichen im Pfad, zum Beispiel `C:\Program Files\Apache\maven\apache-maven-3.9.16`.
3. Öffnen Sie die Systemumgebungsvariablen. Drücken Sie die Windows-Taste, geben Sie Umgebungsvariablen ein und wählen Sie Systemumgebungsvariablen bearbeiten.
4. Legen Sie unter Systemvariablen eine neue Variable MAVEN_HOME an. Als Wert tragen Sie den Maven-Pfad ein, zum Beispiel `C:\Program Files\Apache\maven\apache-maven-3.9.16`.
5. Bearbeiten Sie die Variable Path und fügen Sie einen neuen Eintrag `%MAVEN_HOME%\bin` hinzu.
6. Bestätigen Sie alles mit OK und öffnen Sie ein neues PowerShell-Fenster, damit die Änderungen geladen werden.
7. Prüfen Sie die Installation mit `mvn -version`.

### macOS


1. Laden Sie auf https://maven.apache.org/download.cgi das Binary tar.gz Archiv herunter, zum Beispiel `apache-maven-3.9.16-bin.tar.gz`.
2. Entpacken Sie es, zum Beispiel nach `/opt`, mit `tar xzvf apache-maven-3.9.16-bin.tar.gz -C /opt`.
3. Tragen Sie Maven in den PATH ein. Öffnen Sie dazu die Datei `~/.zshrc` und fügen Sie folgende Zeile hinzu:

```bash
export PATH="/opt/apache-maven-3.9.16/bin:$PATH"
```

4. Laden Sie die Konfiguration neu mit `source ~/.zshrc` oder öffnen Sie ein neues Terminal.
5. Prüfen Sie die Installation mit `mvn -version`.

## Tests

### Windows

```powershell
cd implementation
mvn test
```

### macOS

```bash
cd implementation
mvn test
```

Erwartung: **BUILD SUCCESS**, 15 verbindliche Testfälle (`tc010_*` bis `tc150_*`). Details: [`TRACEABILITY.md`](implementation/TRACEABILITY.md).

Optionale Testabdeckung:

Windows:

```powershell
cd implementation
mvn verify
```

macOS:

```bash
cd implementation
mvn verify
```

Report: `implementation/bearing-api/target/site/jacoco/index.html`

## Demo (optional)

Konsolen-Demo aller Funktionen (Session, Optimierer, GPX, Path-Traversal).

### Windows

```powershell
cd implementation
.\run-all-capabilities.ps1
```

Falls PowerShell die Ausführung mit der Meldung blockiert, dass das Ausführen von Skripten deaktiviert ist, können Sie es nur für die aktuelle Sitzung erlauben. Führen Sie dazu im selben Fenster vor dem Skript folgenden Befehl aus:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

Diese Einstellung gilt nur für das aktuelle PowerShell-Fenster und wird beim Schliessen automatisch wieder zurückgesetzt.

### macOS und Linux

```bash
cd implementation
./run-all-capabilities.sh
```
