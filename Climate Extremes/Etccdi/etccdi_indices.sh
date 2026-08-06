#!/bin/bash
# ETCCDI indices: TXx, RX1Day, RX5Day, CDD, WSDI

cdo=cdo
input_path=/media/wcs/Disk4/etccdi_extreme_indices/Data
output_path=/media/wcs/Disk4/etccdi_extreme_indices/output
mkdir -p ${output_path}

# scenarios="g6solar g6sulfur ssp126 ssp245 ssp585"
scenarios="g4 rcp45"
models=$(ls ${input_path})

baseStart=1975
baseEnd=2004
experiment="historical"
export CDO_PCTL_NBINS=$((5*(baseEnd-baseStart+1)*2+2))

for model in ${models}; do
  echo "=== ${model} ==="

  for scenario in ${scenarios}; do

    tasmaxFile=$(ls ${input_path}/${model}/tasmax/${scenario}/*.nc)
    prFile=$(ls ${input_path}/${model}/pr/${scenario}/*.nc)

    tasSuffix=$(basename "${tasmaxFile}" .nc)
    tasSuffix=${tasSuffix#tasmax_day_}

    prSuffix=$(basename "${prFile}" .nc)
    prSuffix=${prSuffix#pr_day_}

    # --- TXx ---
    out=${output_path}/${model}/indices/TXx/${scenario}
    mkdir -p ${out}
    outfile=${out}/txx_${tasSuffix}.nc
    if [[ ! -f ${outfile} ]]; then
      echo "[TXx] ${model} ${scenario}..."
      $cdo subc,273.15 -yearmax ${tasmaxFile} ${outfile}
    fi

    # --- RX1Day ---
    out=${output_path}/${model}/indices/RX1Day/${scenario}
    mkdir -p ${out}
    outfile=${out}/rx1day_${prSuffix}.nc
    if [[ ! -f ${outfile} ]]; then
      echo "[RX1Day] ${model} ${scenario}..."
      $cdo etccdi_rx1day -mulc,86400 ${prFile} ${outfile}
    fi

    # --- RX5Day ---
    out=${output_path}/${model}/indices/RX5Day/${scenario}
    mkdir -p ${out}
    outfile=${out}/rx5day_${prSuffix}.nc
    if [[ ! -f ${outfile} ]]; then
      echo "[RX5Day] ${model} ${scenario}..."
      CDO_TIMESTAT_DATE="last" $cdo etccdi_rx5day -runsum,5 -mulc,86400 ${prFile} ${outfile}
    fi

    # --- CDD ---
    out=${output_path}/${model}/indices/CDD/${scenario}
    mkdir -p ${out}
    outfile=${out}/cdd_${prSuffix}.nc
    if [[ ! -f ${outfile} ]]; then
      echo "[CDD] ${model} ${scenario}..."
      $cdo etccdi_cdd -mulc,86400 ${prFile} ${outfile}
    fi

    # --- WSDI ---
    wsdiDir=${output_path}/${model}/wsdi_baseline/${scenario}
    mkdir -p ${wsdiDir}

    baseline=${wsdiDir}/tasmax_${baseStart}-${baseEnd}.nc
    runmin=${wsdiDir}/tasmax_runmin.nc
    runmax=${wsdiDir}/tasmax_runmax.nc
    tx90thresh=${wsdiDir}/tx90thresh.nc

    if [[ ! -f ${tx90thresh} ]]; then
      echo "[wsdi baseline] ${model} ${scenario}..."
      $cdo selyear,${baseStart}/${baseEnd} ${tasmaxFile} ${baseline}
      $cdo ydrunmin,5,rm=c ${baseline} ${runmin}
      $cdo ydrunmax,5,rm=c ${baseline} ${runmax}
      $cdo ydrunpctl,90,5,pm=r8,rm=c ${baseline} ${runmin} ${runmax} ${tx90thresh}
    fi

    out=${output_path}/${model}/indices/WSDI/${scenario}
    mkdir -p ${out}
    outfile=${out}/wsdi_${tasSuffix}.nc
    if [[ ! -f ${outfile} ]]; then
      echo "[WSDI] ${model} ${scenario}..."
      $cdo etccdi_wsdi ${tasmaxFile} ${tx90thresh} ${outfile}
    fi

  done
done
echo "Done. Outputs in ${output_path}/"