# Mermaid-Quellen nach SVG rendern (einmalig oder nach Aenderung an *.mmd).
# Voraussetzung: Node.js + npx
# Ausfuehren aus Documentation/:  pwsh -File diagrams/render-diagrams.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$mermaid = Join-Path $root "mermaid"
$svg = Join-Path $root "svg"
New-Item -ItemType Directory -Force -Path $svg | Out-Null

$config = Join-Path $root "mermaid/mermaid.config.json"

Get-ChildItem -Path $mermaid -Filter "*.mmd" | ForEach-Object {
  $out = Join-Path $svg ($_.BaseName + ".svg")
  Write-Host "Rendering $($_.Name) -> $($_.BaseName).svg"
  npx --yes @mermaid-js/mermaid-cli@11.4.0 -i $_.FullName -o $out -b transparent -c $config
}

Write-Host "Done. SVG files in diagrams/svg/"
