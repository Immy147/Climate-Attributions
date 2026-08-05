#!/usr/bin/env bash
set -euo pipefail

# R95p: total precipitation on days above the 95th percentile,
# where the 95th percentile is calculated from the reference period.
#
# Usage:
#   r95p.sh INPUT.nc OUTPUT.nc REF_START REF_END

if [ "$#" -ne 4 ]; then
    echo "Usage: r95p.sh INPUT.nc OUTPUT.nc REF_START REF_END"
    exit 1
fi

INFILE=$1
OUTFILE=$2
REF_START=$3
REF_END=$4

# Input precipitation is in kg m-2 s-1 (i.e. mm/s). Multiply by 86400
# (seconds per day) to get mm/day, then compute R95p on the converted data.
echo "Computing R95p using reference period ${REF_START}-${REF_END}..."
cdo -L etccdi_r95p,"${REF_START}","${REF_END}" -mulc,86400 "$INFILE" "$OUTFILE"

echo "Done. Saved to $OUTFILE"
