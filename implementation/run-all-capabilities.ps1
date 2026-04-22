# Fuehrt die Konsolen-Demo aus (alle Hauptfunktionen auf stdout).
# Voraussetzung: Maven im PATH (oder Umgebungsvariable MVN_CMD auf mvn.cmd setzen).
$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
Push-Location $here
try {
    $mvn = if ($env:MVN_CMD) { $env:MVN_CMD } else { "mvn" }
    & $mvn -pl bearing-demo -am install "-DskipTests"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $mvn -f (Join-Path $here "bearing-demo\pom.xml") exec:java
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
