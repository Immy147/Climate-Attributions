#!/usr/bin/env bash
set -euo pipefail

# RX1day: the highest single-day precipitation total in each year.
#
# Usage:
#   rx1day.sh INPUT.nc OUTPUT.nc

if [ "$#" -ne 2 ]; then
    echo "Usage: rx1day.sh INPUT.nc OUTPUT.nc"
    exit 1
fi

INFILE=$1
OUTFILE=$2

# Input precipitation is in kg m-2 s-1 (i.e. mm/s). Multiply by 86400
# (seconds per day) to get mm/day, then take the max value in each year.
echo "Computing RX1day..."
cdo -L yearmax -mulc,86400 "$INFILE" "$OUTFILE"

echo "Done. Saved to $OUTFILE"
