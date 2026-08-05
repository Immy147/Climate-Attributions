#!/usr/bin/env bash
set -euo pipefail

# CDD: the longest run of consecutive dry days (precip < 1mm) in each year.
#
# Usage:
#   cdd.sh INPUT.nc OUTPUT.nc

if [ "$#" -ne 2 ]; then
    echo "Usage: cdd.sh INPUT.nc OUTPUT.nc"
    exit 1
fi

INFILE=$1
OUTFILE=$2

# Input precipitation is in kg m-2 s-1 (i.e. mm/s). Multiply by 86400
# (seconds per day) to get mm/day, then find the longest dry spell per year.
echo "Computing Consecutive Dry Days..."
cdo -L eca_cdd -mulc,86400 "$INFILE" "$OUTFILE"

echo "Done. Saved to $OUTFILE"
