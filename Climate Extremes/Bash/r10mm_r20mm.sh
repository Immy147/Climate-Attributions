#!/usr/bin/env bash
set -euo pipefail

# R10mm and R20mm (ETCCDI): annual count of heavy and very heavy precipitation days.
#   R10mm_j = number of days in year j with RR >= 10 mm
#   R20mm_j = number of days in year j with RR >= 20 mm
# Usage: ./r10mm_r20mm.sh INFILE OUT_R10MM OUT_R20MM [mm|flux]
#   INFILE   : daily precipitation (mm/day, or kg m-2 s-1)
#   OUT_R10MM: one value per year, in days
#   OUT_R20MM: one value per year, in days
#   4th arg (optional): force the input units. Default is to auto-detect from the file.

INFILE=$1
OUT_R10=$2
OUT_R20=$3
UNITS_OVERRIDE=${4:-auto}

# --- 1. Make sure the input is in mm/day (the 10 and 20 mm thresholds only make sense in mm/day) ---
VAR=$(cdo -s showname "$INFILE" | awk '{print $1}')
UNITS=$(cdo -s showunit "$INFILE" | tr -d '[:space:]')

if [[ "$UNITS_OVERRIDE" == "auto" ]]; then
    case "$UNITS" in
        kgm-2s-1|kg/m2/s|kgm^-2s^-1) UNITS_OVERRIDE=flux ;;
        mm|mm/day|mmd-1|mmday-1|mm/d) UNITS_OVERRIDE=mm ;;
        *) echo "ERROR: cannot tell the units of '$VAR' (found: '${UNITS:-none}')." >&2
           echo "       Re-run with a fourth argument: mm  or  flux" >&2
           exit 1 ;;
    esac
fi

SRC="$INFILE"
if [[ "$UNITS_OVERRIDE" == "flux" ]]; then
    TMP=$(mktemp --suffix=.nc)
    trap 'rm -f "$TMP"' EXIT
    echo "Converting $VAR from kg m-2 s-1 to mm/day..."
    cdo -s -L mulc,86400 "$INFILE" "$TMP"
    SRC="$TMP"
fi

# --- 2. Yearly count of days at or above each threshold ---
for T in 10 20; do
    OUT=$OUT_R10; [[ $T -eq 20 ]] && OUT=$OUT_R20
    echo "Computing R${T}mm (days with RR >= ${T} mm)..."
    cdo -L -chname,"$VAR","r${T}mm" -setunit,days -yearsum -gec,"$T" "$SRC" "$OUT"
    echo "  saved $OUT"
done

echo "Done."
