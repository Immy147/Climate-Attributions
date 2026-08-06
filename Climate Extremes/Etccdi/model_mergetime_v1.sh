#!/bin/bash

ROOT="/media/wcs/Disk4/GeoMIP_Data"
OUT_ROOT="/media/wcs/Disk4/etccdi_extreme_indices/data"
mkdir -p "$OUT_ROOT"
SCENARIOS=(g4 rcp45)
VARS=(pr tasmax)

for model_path in "$ROOT"/*/; do
    model=$(basename "$model_path")

    for var in "${VARS[@]}"; do

        HIST_DIR="${ROOT}/${model}/${var}/historical"
        HIST_FILES=$(ls "$HIST_DIR"/*.nc 2>/dev/null | sort)
        [ -z "$HIST_FILES" ] && continue

        # ----- Extract historical metadata -----
        HIST_FIRST=$(echo "$HIST_FILES" | head -n1)
        HIST_BASE=$(basename "$HIST_FIRST")

        ENSEMBLE=$(echo "$HIST_BASE" | sed -E 's/.*_(r[0-9]+i[0-9]+p[0-9]+)_.*/\1/')
        START=$(echo "$HIST_BASE" | sed -E 's/.*_([0-9]{8})-[0-9]{8}\.nc/\1/')

        # check if all outputs already exist
        ALL_DONE=true
        for scenario in "${SCENARIOS[@]}"; do

            SCEN_DIR="${ROOT}/${model}/${var}/${scenario}"
            SCEN_FILES=$(ls "$SCEN_DIR"/*.nc 2>/dev/null | sort)
            [ -z "$SCEN_FILES" ] && continue

            LAST=$(echo "$SCEN_FILES" | tail -n1)
            LAST_BASE=$(basename "$LAST")
            END=$(echo "$LAST_BASE" | sed -E 's/.*_[0-9]{8}-([0-9]{8})\.nc/\1/')

            OUT="${OUT_ROOT}/${model}/${var}/${scenario}/${var}_day_${model}_historical_${scenario}_${ENSEMBLE}_${START}-${END}.nc"

            [ ! -f "$OUT" ] && ALL_DONE=false
        done

        if [ "$ALL_DONE" = true ]; then
            echo "Skipping: $model | $var (all scenario outputs already exist)"
            continue
        fi

        HIST_TMP="${TMPDIR:-/tmp}/hist_${model}_${var}.nc"
        cdo -O mergetime $HIST_FILES "$HIST_TMP"

        for scenario in "${SCENARIOS[@]}"; do

            SCEN_DIR="${ROOT}/${model}/${var}/${scenario}"
            SCEN_FILES=$(ls "$SCEN_DIR"/*.nc 2>/dev/null | sort)
            [ -z "$SCEN_FILES" ] && continue

            LAST=$(echo "$SCEN_FILES" | tail -n1)
            LAST_BASE=$(basename "$LAST")
            END=$(echo "$LAST_BASE" | sed -E 's/.*_[0-9]{8}-([0-9]{8})\.nc/\1/')

            OUT_DIR="${OUT_ROOT}/${model}/${var}/${scenario}"
            OUT="${OUT_DIR}/${var}_day_${model}_historical_${scenario}_${ENSEMBLE}_${START}-${END}.nc"

            [ -f "$OUT" ] && continue

            mkdir -p "$OUT_DIR"

            echo "Processing: $model | $var | historical + $scenario"

            SCEN_TMP="${TMPDIR:-/tmp}/scen_${model}_${var}_${scenario}.nc"
            cdo -O mergetime $SCEN_FILES "$SCEN_TMP"

            cdo -O mergetime "$HIST_TMP" "$SCEN_TMP" "$OUT"

            rm -f "$SCEN_TMP"

            echo "  Saved → $OUT"

        done

        rm -f "$HIST_TMP"

    done
done

echo "All done."