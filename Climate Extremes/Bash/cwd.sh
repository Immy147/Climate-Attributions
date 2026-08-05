#!/usr/bin/env bash
set -euo pipefail

# CWD: Consecutive Wet Days - the longest run of consecutive days per year
# with precipitation >= 1 mm.
#
# Usage:
#   cwd.sh INPUT.nc OUTPUT.nc

if [ "$#" -ne 2 ]; then
    echo "Usage: cwd.sh INPUT.nc OUTPUT.nc"
    exit 1
fi

INFILE=$1
OUTFILE=$2

# Input precipitation is in kg m-2 s-1 (i.e. mm/s). Multiply by 86400
# (seconds per day) to get mm/day, then find the longest run of wet days
# (>= 1 mm) in each year.
echo "Computing Consecutive Wet Days (CWD)..."
cdo -L eca_cwd -mulc,86400 "$INFILE" "$OUTFILE"

echo "Done. Saved to $OUTFILE"
