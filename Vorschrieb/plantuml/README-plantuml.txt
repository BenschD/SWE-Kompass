PlantUML-Diagramme (UML) fuer die Typst-Dokumentation
=====================================================

1) plantuml.jar von https://plantuml.com/de/download in diesen Ordner legen.

2) PowerShell:
   cd Vorschrieb/plantuml
   .\render-diagrams.ps1

3) Ausgabe: Unterordner out/ mit SVG-Dateien (gleicher Basisname wie .puml).

4) Typst bindet die Grafiken aus out/ in include/ch-spezifikation.typ ein.

Ausgabe-Dateinamen (aktuell): SWE_Kompass_UseCases.svg, SWE_Kompass_Context.svg,
SWE_Kompass_Activity_PositionUpdate.svg, SWE_Kompass_Activity_GpxExport.svg,
SWE_Kompass_Sequence_Complete.svg, SWE_Kompass_Sequence_ValidationError.svg,
SWE_Kompass_State_Session.svg, SWE_Kompass_OOA_Domain.svg, SWE_Kompass_OOD_Design.svg,
SWE_Kompass_Component_Layers.svg

Diese Namen ergeben sich aus dem Diagrammtitel in @startuml <Name>.
