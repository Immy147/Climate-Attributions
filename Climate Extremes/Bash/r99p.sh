#!/usr/bin/env bash
set -euo pipefail

# R99p: total precipitation on days above the 99th percentile,
# using REF_START-REF_END as the reference period for the percentile.
#
# Usage:
#   r99p.sh INPUT.nc OUTPUT.nc REF_START REF_END

if [ "$#" -ne 4 ]; then
    echo "Usage: r99p.sh INPUT.nc OUTPUT.nc REF_START REF_END"
    exit 1
fi

INFILE=$1
OUTFILE=$2
REF_START=$3
REF_END=$4

# Input precipitation is in kg m-2 s-1 (i.e. mm/s). Multiply by 86400
# (seconds per day) to get mm/day before computing the index.
echo "Computing R99p using reference period ${REF_START}-${REF_END}..."
cdo -L etccdi_r99p,"${REF_START}","${REF_END}" -mulc,86400 "$INFILE" "$OUTFILE"

echo "Done. Saved to $OUTFILE"
