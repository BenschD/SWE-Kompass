# PlantUML-Quellen (*.puml) nach SVG rendern (einmalig oder nach Aenderung).
# Voraussetzung: Java (>= 11). Graphviz wird NICHT benoetigt, es wird die in
# PlantUML eingebaute Smetana-Layout-Engine genutzt (!pragma layout smetana).
# Ausfuehren aus Documentation/:  pwsh -File diagrams/render-plantuml.ps1
#
# Die plantuml.jar wird ausserhalb des Repos zwischengespeichert (~/.plantuml)
# und bei Bedarf einmalig heruntergeladen.

$ErrorActionPreference = "Stop"
$root     = Split-Path -Parent $MyInvocation.MyCommand.Path
$puml     = Join-Path $root "plantuml"
$svg      = Join-Path $root "svg"
New-Item -ItemType Directory -Force -Path $svg | Out-Null

$version  = "1.2024.7"
$cacheDir = Join-Path $HOME ".plantuml"
$jar      = Join-Path $cacheDir "plantuml.jar"

if (-not (Test-Path $jar)) {
  New-Item -ItemType Directory -Force -Path $cacheDir | Out-Null
  $url = "https://github.com/plantuml/plantuml/releases/download/v$version/plantuml-$version.jar"
  Write-Host "Downloading plantuml.jar ($version) ..."
  Invoke-WebRequest -Uri $url -OutFile $jar
}

Get-ChildItem -Path $puml -Filter "*.puml" | ForEach-Object {
  Write-Host "Rendering $($_.Name) -> $($_.BaseName).svg"
  java -jar $jar -charset UTF-8 -tsvg -o $svg $_.FullName
}

Write-Host "Done. SVG files in diagrams/svg/"
