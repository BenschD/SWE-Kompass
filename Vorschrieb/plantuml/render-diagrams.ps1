# PlantUML -> SVG in ./out/
# Voraussetzung: Java (java.exe im PATH) und plantuml.jar im Ordner plantuml/
# Download z. B.: https://plantuml.com/de/download
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$jar = Join-Path $here "plantuml.jar"
if (-not (Test-Path $jar)) {
  Write-Host "plantuml.jar fehlt in $here - bitte herunterladen (siehe README-plantuml.txt)." -ForegroundColor Yellow
  exit 1
}
$out = Join-Path $here "out"
New-Item -ItemType Directory -Force -Path $out | Out-Null
Get-ChildItem -Path $here -Filter "*.puml" | ForEach-Object {
  & java -jar $jar -tsvg -o $out $_.FullName
}
Write-Host "Fertig. SVGs in $out" -ForegroundColor Green
