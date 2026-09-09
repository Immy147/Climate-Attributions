# Climate Indices Calculable from pr, tas, tasmin, tasmax, sfcWind

This reference covers indices from the standard ETCCDI/ET-SCI core set, the extended
ClimPACT2 set, agro/bioclimatic indices, wind indices, and compound/derived indices —
everything computable from your five variables (no humidity, radiation, or pressure needed,
except where noted as "partial/proxy").

**Recommended tools:** `xclim` (Python), `ClimPACT2` / `climdex.pcic` (R), `icclim` (Python/CDO-friendly).
All of these are pre-built to compute the ETCCDI/ET-SCI indices below directly from CF-compliant NetCDF.

---

## 1. Precipitation indices (from `pr`)

| Index | Full name | Description |
|---|---|---|
| PRCPTOT | Total wet-day precipitation | Sum of precip on days ≥1mm, annual/monthly |
| SDII | Simple Daily Intensity Index | Mean precip on wet days |
| Rx1day | Max 1-day precipitation | Highest daily precip in period |
| Rx5day | Max consecutive 5-day precipitation | Highest 5-day running total |
| RxNday | Max N-day precipitation | Generalized version (N user-defined) |
| R10mm | Heavy precipitation days | Count of days ≥10mm |
| R20mm | Very heavy precipitation days | Count of days ≥20mm |
| Rnnmm | Custom threshold days | Count of days ≥ user threshold |
| CWD | Consecutive Wet Days | Max run of days ≥1mm |
| CDD | Consecutive Dry Days | Max run of days <1mm |
| R95p | Very wet days | Annual total precip from days > 95th percentile |
| R99p | Extremely wet days | Annual total precip from days > 99th percentile |
| R95pTOT | Contribution from very wet days | R95p as % of PRCPTOT |
| R99pTOT | Contribution from extremely wet days | R99p as % of PRCPTOT |
| PD / Wet days | Precipitation days | Count of days ≥1mm |
| DD / Dry days | Dry days | Count of days <1mm |
| SPI | Standardized Precipitation Index | Drought index, precip-only (multi-timescale) |
| Max/Min annual precip | — | Extremes across years |

## 2. Temperature indices (from `tas`, `tasmin`, `tasmax`)

| Index | Full name | Description |
|---|---|---|
| TXx | Max Tmax | Hottest day |
| TXn | Min Tmax | Coolest "hot" day |
| TNx | Max Tmin | Warmest night |
| TNn | Min Tmin | Coldest night |
| TX10p | Cool days | % days TX < 10th percentile |
| TX90p | Warm days | % days TX > 90th percentile |
| TN10p | Cool nights | % days TN < 10th percentile |
| TN90p | Warm nights | % days TN > 90th percentile |
| WSDI | Warm Spell Duration Index | Annual count of days in warm spells (≥6 days TX90p) |
| CSDI | Cold Spell Duration Index | Annual count of days in cold spells (≥6 days TN10p) |
| FD | Frost Days | Count of days TN < 0°C |
| ID | Ice Days | Count of days TX < 0°C |
| SU | Summer Days | Count of days TX > 25°C |
| TR | Tropical Nights | Count of days TN > 20°C |
| GSL | Growing Season Length | Days between 6-day spans of TG>5°C and TG<5°C |
| DTR | Diurnal Temperature Range | Mean of TX−TN |
| ETR | Extreme Temperature Range | Max TX − min TN over period |
| CDD (degree days) | Cooling Degree Days | Sum of (TG − threshold) when TG > threshold |
| HDD | Heating Degree Days | Sum of (threshold − TG) when TG < threshold |
| GDD | Growing Degree Days | Sum of (TG − base temp) for crop growth models |
| HWFI / HWN / HWD | Heat Wave Frequency/Number/Duration | ClimPACT heat wave indices (multiple definitions: EHF, Tx90, etc.) |
| Cold wave indices | — | Analogous cold-spell counterparts |
| Last spring frost / First autumn frost | — | Phenology-relevant frost timing |
| Frost-free season length | — | Days between last/first frost |
| Ice/Frost onset & cessation dates | — | Seasonal timing metrics |

## 3. Wind indices (from `sfcWind`)

| Index | Full name | Description |
|---|---|---|
| FG | Mean wind speed | Average daily wind speed |
| FGcalm | Calm days | Days with wind speed < 2 m/s |
| FG6Bft | Windy days | Days with wind speed > 10.8 m/s (Beaufort ≥6) |
| FXx (proxy) | Max wind speed | Highest daily mean wind speed (true gust needs `sfcWindmax`) |
| Wind power density (proxy) | — | Approximate using mean wind speed cubed (better with distribution/gust data) |
| Number of high-wind days | — | Days above user threshold (e.g., >15 m/s) |
| Wind run | — | Cumulative distance-equivalent (speed × time) |

## 4. Compound / derived indices (need 2+ variables)

| Index | Variables used | Description |
|---|---|---|
| PET (Hargreaves/Thornthwaite) | tas, tasmin, tasmax | Potential evapotranspiration estimate |
| SPEI | pr + PET (derived from tas) | Standardized Precip-Evapotranspiration Index (drought) |
| De Martonne Aridity Index | pr, tas | Simple aridity index |
| Bioclimatic variables (BIO1–BIO19, WorldClim-style) | tas, tasmin, tasmax, pr | Annual mean temp, seasonality, precip of warmest/coldest quarter, etc. |
| Wind chill | tas, sfcWind | Apparent temperature adjustment for wind |
| Compound hot-dry days | tasmax, pr | Days that are both hot and dry (compound extremes) |
| Compound warm-windy days | tas, sfcWind | Relevant for fire-weather proxies |
| Effective GDD / crop stress indices | tas, tasmin, tasmax, pr | Agro-climatic suitability indices |
| Fire Weather proxies (partial) | tas, pr, sfcWind | Full Canadian FWI needs RH too — partial proxy only |

---

### Notes
- Percentile-based indices (TX90p, R95p, etc.) require a **baseline/reference period** (commonly 1961–1990 or 1981–2010) to calculate percentile thresholds.
- Some names collide across conventions (e.g., "CDD" = Consecutive Dry Days *or* Cooling Degree Days) — always check which definition your tool uses.
- True wind-gust and fire-weather indices need additional variables (`sfcWindmax`, `hurs`/RH) not in your current set — the above wind/fire entries are the closest proxies achievable with `sfcWind` alone.
- `xclim` and `ClimPACT2` implement almost the entire ETCCDI/ET-SCI list out of the box; compound and bioclimatic indices usually need custom scripting (xclim also has some compound-indicator modules).
