#!/bin/bash

INPUT_ROOT="/media/wcs/Disk4/etccdi_extreme_indices/data"
OUTPUT_ROOT="/media/wcs/Disk4/etccdi_extreme_indices/Data"

MODELS=("CSIRO-Mk3L-1-2" "HadGEM2-ES")
VARIABLES=("pr" "tasmax")
SCENARIOS=("g4" "rcp45")

LOG_FILE="${OUTPUT_ROOT}/regrid_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$OUTPUT_ROOT"
touch "$LOG_FILE"

FILE_COUNT=0
SUCCESS_COUNT=0
FAIL_COUNT=0

echo "🚀 Starting CDO 1° regridding..." | tee -a "$LOG_FILE"
echo "📂 Input:  $INPUT_ROOT" | tee -a "$LOG_FILE"
echo "📂 Output: $OUTPUT_ROOT" | tee -a "$LOG_FILE"
echo "📝 Log:    $LOG_FILE" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

for model in "${MODELS[@]}"; do
  for var in "${VARIABLES[@]}"; do

    echo "" | tee -a "$LOG_FILE"
    echo "📦 MODEL: $model | VARIABLE: $var" | tee -a "$LOG_FILE"

    # pr needs conservative remapping, tasmax/tasmin bilinear
    if [ "$var" == "pr" ]; then
      REMAP="remapcon"
    else
      REMAP="remapbil"
    fi

    for scenario in "${SCENARIOS[@]}"; do

      IN=$(find "${INPUT_ROOT}/${model}/${var}/${scenario}" \
     -maxdepth 1 \
     -name "${var}_day_${model}_historical_${scenario}_r*.nc" \
     -type f)

      [ -f "$IN" ] || continue

      OUT_DIR="${OUTPUT_ROOT}/${model}/${var}/${scenario}"
      OUT="${OUT_DIR}/$(basename "$IN")"                        # skip if input missing

      [ -f "$OUT" ] && { echo "   ↳ $scenario / $(basename "$IN") (skipping - exists)"; continue; }

      mkdir -p "$OUT_DIR"

      FILE_COUNT=$((FILE_COUNT + 1))
      echo "   ↳ $scenario / $(basename "$IN") [$REMAP]"

      if cdo -O --reduce_dim -${REMAP},r360x180 "$IN" "$OUT" 2>> "$LOG_FILE"; then
        if [ -s "$OUT" ]; then
          SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
          echo "      ✓ Success" | tee -a "$LOG_FILE"
        else
          FAIL_COUNT=$((FAIL_COUNT + 1))
          echo "      ❌ Failed (output empty)" | tee -a "$LOG_FILE"
          rm -f "$OUT"
        fi
      else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo "      ❌ Failed" | tee -a "$LOG_FILE"
        rm -f "$OUT"
      fi

    done
  done
done

echo "" | tee -a "$LOG_FILE"
echo "================================" | tee -a "$LOG_FILE"
echo "✅ Regridding Complete" | tee -a "$LOG_FILE"
echo "📊 Files processed: $FILE_COUNT" | tee -a "$LOG_FILE"
echo "✓  Success: $SUCCESS_COUNT" | tee -a "$LOG_FILE"
echo "❌ Failed: $FAIL_COUNT" | tee -a "$LOG_FILE"
echo "📝 Log: $LOG_FILE" | tee -a "$LOG_FILE"
echo "================================" | tee -a "$LOG_FILE"