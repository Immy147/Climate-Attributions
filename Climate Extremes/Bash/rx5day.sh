#!/usr/bin/env bash
set -euo pipefail

# RX5day: the highest 5-day-consecutive precipitation total in each year.
#
# Usage:
#   rx5day.sh INPUT.nc OUTPUT.nc

if [ "$#" -ne 2 ]; then
    echo "Usage: rx5day.sh INPUT.nc OUTPUT.nc"
    exit 1
fi

INFILE=$1
OUTFILE=$2

# Input precipitation is in kg m-2 s-1 (i.e. mm/s). Multiply by 86400
# (seconds per day) to get mm/day, sum every rolling 5-day window,
# then take the max 5-day sum in each year.
echo "Computing RX5day..."
cdo -L yearmax -runsum,5 -mulc,86400 "$INFILE" "$OUTFILE"

echo "Done. Saved to $OUTFILE"
