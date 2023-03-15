#!/bin/env bash

if [ -z "$1" ]; then
  echo "Pass file name without extension"
  exit 1
fi

IN="$1"

X=$(grep "aux_axis_origin" "$IN.kicad_pcb" | tr -s ' ' | cut -d ' ' -f 3)
Y=$(grep "aux_axis_origin" "$IN.kicad_pcb" | tr -s ' ' | cut -d ' ' -f 4 | tr -d ')')

kicad-cli sch export pdf "$IN.kicad_sch" --no-background-color -o "gerber/$IN.pdf"
kicad-cli sch export netlist "$IN.kicad_sch" --format kicadxml -o "gerber/$IN.net"
python hellen-one/kicad/hellen-one-kicad-bom-plugin.py "gerber/$IN.net" "gerber/$IN.csv"

kicad-cli pcb export gerbers --disable-aperture-macros -l "F.Cu,B.Cu,F.Paste,F.SilkS,B.SilkS,F.Mask,B.Mask,Edge.Cuts,In2.Cu,In1.Cu" --no-x2 "$IN.kicad_pcb" -o gerber/
kicad-cli pcb export drill --map-format ps --drill-origin plot --excellon-zeros-format suppressleading "$IN.kicad_pcb" -o gerber/
kicad-cli pcb export pos --format csv --units mm --use-drill-file-origin "$IN.kicad_pcb" -o "gerber/$IN-all-pos.csv"

python export-vrml.py "$IN.kicad_pcb" "$X" "$Y" "gerber/$IN.wrl"
