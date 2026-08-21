# SPEI — A Complete Learning Guide
### From Concept to Research-Grade Implementation on Climate-Model Data

---

## 1. The Big Picture

**SPEI (Standardized Precipitation Evapotranspiration Index)** measures how wet or dry a location is *relative to its own normal climate*, using the balance between water supply (precipitation) and atmospheric water demand (potential evapotranspiration, PET).

Think of a location's water budget like a bank account:
- **Deposits** = precipitation (P)
- **Withdrawals** = potential evapotranspiration (PET) — how much water the atmosphere "wants" to pull out of the soil/vegetation, driven mainly by temperature, radiation, humidity, and wind
- **Balance** = D = P − PET

SPEI standardizes this balance so that a value of, say, −1.5 means "about as dry as the driest ~7% of years/months in the local historical record," regardless of whether that place is a rainforest or a desert.

**Why it was developed:** SPI (Standardized Precipitation Index) only uses precipitation. It works well for meteorological drought but misses the fact that a warming atmosphere increases evaporative demand even if rainfall doesn't change. PDSI accounts for evapotranspiration and soil moisture but is not naturally multi-timescale and has known algorithmic issues (fixed soil-moisture parameterization, poor comparability across regions). SPEI was designed by **Vicente-Serrano, Beguería, and López-Moreno (2010)** to combine SPI's multiscalar, distribution-based simplicity with PDSI's sensitivity to temperature/evapotranspiration — making it explicitly suited to **climate-change studies**, where warming itself can intensify drought even without a precipitation decline.

**Climatic water balance** = the net water available at the surface over a period: D = P − PET. It's not the same as *actual* evapotranspiration or soil moisture — it's a simplified atmospheric-demand-vs-supply accounting, not a full land-surface water balance.

**Simple example:** Two towns each receive 600 mm of rain this year.
- Town A (cool climate): PET = 500 mm → D = +100 mm (surplus)
- Town B (same rainfall, but 2°C warmer): PET = 750 mm → D = −150 mm (deficit)

Same rainfall, opposite outcomes. This is exactly the effect SPI cannot see and SPEI is built to capture.

---

## 2. Drought Fundamentals

| Drought type | Definition | Key variables | Typical lag after rain deficit |
|---|---|---|---|
| **Meteorological** | Below-normal precipitation over a period | P | Immediate (0–1 month) |
| **Agricultural** | Insufficient soil moisture for crop/vegetation needs | P, PET, soil moisture | Weeks to ~1–3 months |
| **Hydrological** | Below-normal streamflow, reservoir, groundwater levels | Runoff, storage | Months (3–12+) |
| **Ecological** | Water stress propagating through ecosystems, affecting species/habitats | Multiple, ecosystem-specific | Variable |
| **Socioeconomic** | Water demand exceeds supply, causing economic/social impact | Supply, demand, infrastructure | Variable, policy-dependent |

**Where SPEI fits:** SPEI is a *climatic* index (like SPI), not a direct hydrological or soil-moisture model. But because it's computed at multiple accumulation timescales (1 to 48 months), short SPEI timescales (1–3 months) approximate meteorological/early agricultural drought, while long timescales (12–24+ months) approximate hydrological drought propagation. It is a proxy, not a measurement, of agricultural or hydrological conditions.

**Distinguishing related terms:**
- **Dry conditions** = a snapshot state (e.g., "this month was dry")
- **Drought** = a *sustained, anomalous* deficit relative to local normal — not just "dry" but "drier than expected here"
- **Aridity** = a *permanent climatological* characteristic of a place (deserts are arid but not necessarily "in drought")
- **Heat** = a temperature anomaly; it can *cause or worsen* drought via PET but is not drought itself
- **Water deficit** = the general shortfall of water relative to demand (SPEI's D = P − PET is one operational form of this)
- **Soil-moisture deficit** = a specific, physically measured/modeled quantity — related to but distinct from the climatic water balance SPEI uses

*Example:* The Atacama Desert is arid year-round (climatology), but it can still have a "drought" if it gets even less precipitation than its already-low normal for that time of year.

---

## 3. SPEI vs Other Drought Indices

| Index | Inputs | What it measures | Timescale | Advantages | Limitations | Typical use |
|---|---|---|---|---|---|---|
| **SPI** | Precipitation only | Meteorological wet/dry anomaly | Multiscalar (1–48 mo) | Simple, only needs P, WMO-recommended, comparable across climates | Ignores temperature/PET — insensitive to warming-driven drought | Meteorological drought monitoring, seasonal outlooks |
| **SPEI** | P and PET (needs T, sometimes radiation/humidity/wind) | Climatic water balance anomaly | Multiscalar (1–48 mo) | Captures warming effect on drought; multiscalar; comparable across climates | More data-demanding; PET method choice matters a lot | Climate-change drought studies, cross-climate comparison |
| **PDSI** | P, T, soil-water-holding capacity | Soil moisture supply/demand anomaly via a fixed 2-layer bucket model | Fixed (~9–12 month "memory"), not user-selectable | Physically motivated soil-moisture proxy; long historical use in the US | Not standardized across climates (values not comparable); fixed timescale; sensitive to arbitrary constants; slow to respond | Long-running US/national drought monitoring, historical continuity |
| **scPDSI** | Same as PDSI | Self-calibrating version of PDSI | Same as PDSI | Locally calibrated constants → more comparable across regions than PDSI | Still not multiscalar; more complex to compute | Regional/global comparative PDSI-style studies |
| **Palmer Moisture Anomaly Index (Z-index)** | Same as PDSI (an intermediate PDSI product) | Short-term moisture anomaly (no memory term) | ~1 month | Captures short-term anomalies within the Palmer framework | Same data/model demands as PDSI; less multiscalar flexibility than SPEI | Sub-component of Palmer-family monitoring |
| **SRI (Standardized Runoff Index)** | Streamflow/runoff | Hydrological drought | Multiscalar | Directly hydrological | Requires hydrological model or gauge data | Hydrological drought, reservoir management |
| **Soil-moisture indices (e.g., SSI)** | Modeled/observed soil moisture | Agricultural drought directly | Multiscalar | Direct agricultural relevance | Requires land-surface model or in-situ network; large uncertainty in models | Crop-impact studies |
| **CDD (Consecutive Dry Days)** | Daily precipitation | Dry-spell length | Event-based, not standardized | Simple, intuitive | Not standardized/comparable across climates; ignores PET entirely | Extreme dry-spell characterization (ETCCDI index) |
| **Precipitation anomaly** | Precipitation | Raw deviation from mean | Any | Very simple | Not standardized (units-dependent, not comparable across climates); ignores distribution skewness | Quick-look assessments only |

### SPI vs SPEI — Numerical Example

Suppose two grid cells both receive **P = 60 mm** in a given month, and both have identical *historical* P distributions (so an SPI calculated from P alone would be **identical** at both).

- Cell 1: PET = 55 mm → D = +5 mm (near-normal balance)
- Cell 2 (2°C warmer, e.g., under future warming): PET = 90 mm → D = −30 mm (deficit)

If the historical D-distribution at that location has mean ≈ 0 mm and SD ≈ 25 mm:
- Cell 1: SPEI ≈ (5 − 0)/25 ≈ **+0.2** (near normal)
- Cell 2: SPEI ≈ (−30 − 0)/25 ≈ **−1.2** (moderate drought)

Same precipitation, same SPI — but SPEI diverges sharply because it "sees" the extra evaporative demand. This is precisely why SPEI is preferred for detecting **warming-amplified drought**, even where rainfall trends are flat or increasing.

---

## 4. Mathematical Foundation

**Step 1 — Water balance:**
```
D_i = P_i − PET_i
```
- `D_i` = climatic water balance in month *i* (mm)
- `P_i` = precipitation in month *i* (mm)
- `PET_i` = potential evapotranspiration in month *i* (mm)

Both **must be in the same units** (mm, i.e., mm water depth per month) before subtracting — this is a very common source of error (see Section 16).

**Why monthly?** Monthly balances smooth out day-to-day noise while retaining enough temporal resolution to build multi-month accumulations relevant to agricultural and hydrological drought. Daily SPEI variants exist but are far less common and much more sensitive to distribution-fitting instability.

**Step 2 — Accumulation (the "multiscalar" part):**

For an *n*-month SPEI, you compute a **rolling sum** (not a mean) of D over the previous *n* months:
```
D_i^(n) = D_i + D_(i-1) + ... + D_(i-n+1)
```

### Worked example (24 months of toy data, mm)

| Month | P | PET | D=P−PET |
|---|---|---|---|
| Jan yr1 | 40 | 60 | −20 |
| Feb | 35 | 55 | −20 |
| Mar | 50 | 70 | −20 |
| Apr | 60 | 80 | −20 |
| May | 70 | 100 | −30 |
| Jun | 90 | 120 | −30 |
| Jul | 100 | 140 | −40 |
| Aug | 95 | 130 | −35 |
| Sep | 80 | 100 | −20 |
| Oct | 65 | 80 | −15 |
| Nov | 50 | 60 | −10 |
| Dec | 45 | 55 | −10 |
| Jan yr2 | 55 | 65 | −10 |
| Feb | 45 | 60 | −15 |
| Mar | 60 | 75 | −15 |
| Apr | 70 | 85 | −15 |
| May | 85 | 110 | −25 |
| Jun | 100 | 130 | −30 |
| Jul | 110 | 150 | −40 |
| Aug | 100 | 135 | −35 |
| Sep | 85 | 105 | −20 |
| Oct | 70 | 85 | −15 |
| Nov | 55 | 65 | −10 |
| Dec | 50 | 58 | −8 |

- **SPEI-1** for July (yr1) uses only D_Jul = −40, fit against the distribution of *all July D-values* across the record.
- **SPEI-3** for July (yr1) uses D_May+D_Jun+D_Jul = −30−30−40 = **−100 mm**, fit against the distribution of all *May–Jun–Jul 3-month sums* in the record.
- **SPEI-6** for July uses Feb–Jul sum = −20−20−20−30−30−40 = **−160 mm**.
- **SPEI-12** for December (yr1) uses the full trailing 12 months (Jan–Dec yr1) = **−260 mm**.

Each of these summed series (D^(1), D^(3), D^(6), D^(12) …) is then **separately fitted to its own probability distribution and separately standardized** — this is critical: SPEI-3 is not "SPEI-1 divided by 3," it is its own full distribution-fitting exercise on the 3-month-summed series.

---

## 5. Potential Evapotranspiration (PET)

**Evapotranspiration (ET)** = actual water lost to the atmosphere from soil evaporation + plant transpiration, constrained by *available* water.

**Potential evapotranspiration (PET)** = the evapotranspiration that *would* occur if water availability were unlimited — i.e., pure atmospheric demand. It depends on temperature, humidity, wind, and radiation, **not** on how much water is actually present.

- ET ≤ PET always (ET can only equal PET when water is not limiting)
- PET rises with temperature (more energy → more evaporative capacity), independent of rainfall
- This is exactly why PET can increase in a warming world even if precipitation is unchanged, which is the physical basis of SPEI's climate-change relevance

### PET Methods Compared

| Method | Inputs required | Principle | Advantages | Limitations | Climate-model suitability |
|---|---|---|---|---|---|
| **Thornthwaite (1948)** | Monthly mean temperature only (+ latitude for daylight hours) | Empirical relationship between T and PET | Minimal data; works with T-only datasets | Crude physically; systematically biased in arid/high-latitude/extreme regions; poor at capturing radiation/humidity/wind effects | Good fallback when only `tas` is available; widely used in original SPEI paper for exactly this reason |
| **Hargreaves (1985)** | Tmax, Tmin, Tmean (+ extraterrestrial radiation from latitude/date) | Uses diurnal temperature range as a proxy for solar radiation/cloudiness | Better than Thornthwaite; still only needs temperature variables | Still a temperature-based proxy; less accurate than energy-balance methods in humid/windy regions | Good middle ground for CMIP/CORDEX output when only tas/tasmin/tasmax exist |
| **Penman-Monteith (FAO-56)** | Tmean (or Tmax/Tmin), relative humidity, wind speed, solar radiation, (surface pressure) | Full physically based energy-balance + aerodynamic approach; the FAO reference-ET standard | Most physically realistic; recommended by FAO as the reference method | Data-hungry; radiation and wind fields in climate models can carry larger biases | Best choice when the model provides hurs/huss, sfcWind, rsds (and ideally rlds/ps) |
| **Penman (1948, original)** | Similar to Penman-Monteith, without the resistance terms tuned to a reference crop | Combines energy balance and mass-transfer (aerodynamic) terms | Physically grounded, historical basis for later methods | Superseded in practice by Penman-Monteith's standardized parameterization | Rarely used directly now; mostly conceptual/historical |
| **Priestley-Taylor (1972)** | Tmean, net radiation (a simplified energy-balance approach, drops the aerodynamic term) | Assumes aerodynamic term is a near-constant fraction of the radiation term | Needs radiation but not wind/humidity; simpler than full Penman-Monteith | Less accurate in windy/dry/advective climates where the aerodynamic term matters | Useful when radiation is available but wind/humidity are not |

**Guidance by data availability:**
- **Only tas/tasmin/tasmax + pr** → Thornthwaite (simplest) or Hargreaves (usually better; needs only Tmax/Tmin, no extra data)
- **+ hurs (or huss), sfcWind, rsds** → Priestley-Taylor is possible (radiation-only) or a reduced-form Penman-Monteith
- **+ radiation (rsds, rlds), pressure (ps), humidity, wind, all consistently available** → full FAO-56 Penman-Monteith is preferable — it's the most physically defensible, provided the model's radiation/wind fields are not badly biased

**Do not simply "use Penman-Monteith" by default on climate-model data.** GCM/RCM radiation and wind fields often carry substantial systematic biases, and missing/inconsistent variables across a multi-model ensemble force you toward the *lowest common denominator* method (often Hargreaves) so that all models are treated identically — using different PET methods for different models in the same ensemble is a serious inconsistency (see Section 23).

### Dataset scenarios from your prompt

- **Dataset A** (tas, tasmin, tasmax, pr only) → **Hargreaves** is realistic and recommended over Thornthwaite for better accuracy while staying temperature-only.
- **Dataset B** (+ hurs, sfcWind, rsds) → **Priestley-Taylor** or a reduced Penman-Monteith become possible; Hargreaves is still a valid, more conservative fallback.
- **Dataset C** (+ radiation, full humidity/wind/pressure) → **full FAO-56 Penman-Monteith** is preferable, assuming the model's energy-balance variables are reasonably trustworthy for your region.

---

## 6. Climate-Model NetCDF Variables for PET

| Variable | Meaning | Used by |
|---|---|---|
| `tas` | Near-surface (2m) mean air temperature | Thornthwaite, Hargreaves, PM, PT |
| `tasmin`, `tasmax` | Daily minimum/maximum near-surface temperature | Hargreaves, PM |
| `pr` | Precipitation flux | Water balance (not PET itself) |
| `hurs` | Near-surface relative humidity (%) | Penman-Monteith (vapor pressure deficit) |
| `huss` | Near-surface specific humidity | Alternative humidity input for PM |
| `sfcWind` | Near-surface wind speed | Penman-Monteith aerodynamic term |
| `rsds` | Surface downwelling shortwave radiation | PM, Priestley-Taylor |
| `rlds` | Surface downwelling longwave radiation | Full net-radiation PM |
| `rsus`, `rlus` | Upwelling short/longwave radiation | Net radiation = (rsds−rsus)+(rlds−rlus), for more rigorous PM |
| `ps` | Surface pressure | PM (psychrometric constant) |

Building net radiation from all four radiation components (rsds, rsus, rlds, rlus) is more rigorous than assuming a fixed albedo, if all four are available.

---

## 7. Temporal Aggregation Workflow

```
Daily P, T, (humidity, wind, radiation)
        │
        ▼
Monthly P (sum), Monthly PET (computed from monthly or daily-then-monthly T/other vars)
        │
        ▼
Monthly D = P − PET
        │
        ▼
Rolling SUM over n months  →  D^(n) series
        │
        ▼
Fit probability distribution (per calendar month, per timescale, per grid cell)
        │
        ▼
Convert D^(n) values to cumulative probabilities
        │
        ▼
Standardize (inverse-normal transform)
        │
        ▼
SPEI-n
```

**Rolling sum, not rolling mean.** SPEI accumulates the *total* water balance over the window (mm), preserving the physical water-depth interpretation. A rolling mean would just rescale everything by 1/n and wouldn't change the standardized outcome much, but the convention — and what the reference software (SPEI R package, `climate_indices`, `xclim`) implements — is a **sum**.

Critically, each month's accumulated value is compared **only against other values from the same calendar month** (e.g., all July SPEI-3 values across your record) to control for seasonality — this is why you need a distribution fit *per calendar month, per timescale*, not one global fit.

---

## 8. Probability Distributions & Standardization

**Why not a normal distribution directly on D?** The water balance D = P − PET is rarely normally distributed — it is often **left-skewed** (bounded below in effect, because PET can rarely be enormously exceeded by P in most climates, while extreme negative D values, i.e., very dry periods, can be quite pronounced or even reach a lower bound). Standardizing raw skewed data with a normal-distribution assumption gives biased/inaccurate percentiles, especially in the tails — exactly where drought classification matters most.

**Concepts, gently:**
- **Probability distribution**: a mathematical model of how likely different values of D are, given the historical record
- **CDF (cumulative distribution function)**: for a given D value, "what fraction of the historical record was ≤ this value?"
- **Standardization**: converting that fraction (a probability) into a number of standard deviations from the mean *of a standard normal distribution* — this is what makes different climates/timescales comparable
- **Percentile**: the CDF expressed as %, e.g., CDF = 0.05 means "5th percentile," i.e., drier than 95% of history

**The log-logistic distribution (original SPEI methodology):**

The original Vicente-Serrano et al. (2010) method fits the D^(n) series to a **three-parameter log-logistic distribution**:
```
F(x) = [1 + (α / (x − γ))^β]^(-1)
```
- `α` (scale), `β` (shape), `γ` (origin/location) — fitted from the D^(n) series, typically via **L-moments** (probability-weighted moments), which are more robust than ordinary moments for skewed hydroclimatic data
- The log-logistic distribution was chosen because it handles the **left-skewed, occasionally negative-value** nature of D better than a Gamma distribution (which requires strictly positive values and is used for SPI's precipitation-only case), and it fits well empirically across many climates in the original validation

**From CDF to SPEI:**

1. Fit F(x) to the D^(n) series (per calendar month)
2. For each D^(n) value, compute its cumulative probability `P = F(x)`
3. Convert P to a standard normal quantile — practically, using an approximation like Abramowitz & Stegun's rational approximation to the inverse normal CDF (this is the same approach used for SPI):
```
SPEI = sign * [ t − (c0 + c1·t + c2·t²) / (1 + d1·t + d2·t² + d3·t³) ]
```
where `t = sqrt(-2 ln(P))` for P ≤ 0.5 (and mirrored for P > 0.5). In practice, you simply call `scipy.stats.norm.ppf(P)` in Python — the manual formula above is what the original methodology paper documents, but any accurate inverse-normal-CDF function gives the same numerical result.

**Conceptually:** D = −100 mm might be the 10th percentile in a wet climate (SPEI ≈ −1.28) but only the 35th percentile in a dry climate (SPEI ≈ −0.39) — because "how unusual −100 mm is" depends entirely on that location's own historical distribution. This is the heart of *why* standardization makes the index comparable across climates.

---

## 9. From Water Balance to Standardized Value

| D^(n) value | What determines its SPEI | Key point |
|---|---|---|
| +200 mm | Its percentile rank within *this location's own* historical D^(n) distribution for that month/season | A "wet" D value in a dry climate might be far more anomalous (higher SPEI) than the same absolute value in a wet climate |
| +50 mm | Same | |
| 0 mm | Same | Does **not** guarantee SPEI ≈ 0 — only true if 0 mm happens to be near the historical median |
| −50 mm | Same | −50 mm might be mild drought in one place, severe in another |
| −200 mm | Same | |

The **reference/historical climate** is what the log-logistic distribution is fitted to — it defines what "normal" means at that location for that calendar month and that accumulation timescale. Change the reference period, and you change what counts as normal, and therefore every SPEI value downstream (see Section 12).

---

## 10. Interpreting SPEI Values

| SPEI range | Category |
|---|---|
| ≥ 2.00 | Extremely wet |
| 1.50 to 1.99 | Severely wet |
| 1.00 to 1.49 | Moderately wet |
| −0.99 to 0.99 | Near normal |
| −1.00 to −1.49 | Moderate drought |
| −1.50 to −1.99 | Severe drought |
| ≤ −2.00 | Extreme drought |

This scheme (from McKee et al. 1993 for SPI, adopted for SPEI) is the most widely used, but **not universal** — some studies use slightly different breakpoints (e.g., merging "severe" and "extreme" at different cutoffs, or adding a "very extreme" ≤ −2.5 class). Always state explicitly which classification scheme you used, and check what the specific study/software you're comparing against used, since inter-study comparisons of "percent area in severe drought" are only valid if the classification thresholds match.

---

## 11. SPEI Timescales in Depth

| Timescale | Typical relevance |
|---|---|
| SPEI-1 | Immediate meteorological conditions; very noisy |
| SPEI-2/3 | Short-term agricultural drought; crop stress in shallow-rooted vegetation; soil-moisture in upper layers |
| SPEI-6 | Seasonal drought; deeper soil moisture; irrigation planning |
| SPEI-9 | Transition between agricultural and hydrological signals |
| SPEI-12 | Annual water-resources balance; reservoir levels; groundwater recharge in many systems |
| SPEI-24/36 | Long-term hydrological drought; multi-year groundwater/reservoir depletion; climate-change trend detection |

**Why SPEI-1 and SPEI-12 can diverge at the same time and place:** SPEI-1 reflects *this month's* anomaly only — a single wet month can push SPEI-1 to −0.5 (near-normal) even in the middle of a multi-year drought, because that one month happened to be less bad than average. Meanwhile SPEI-12 integrates the past 12 months, so if 11 of those months were severely dry, the trailing-12-month sum stays deeply negative (SPEI-12 = −2.0) even though the most recent month brought some relief. This is a common and important real pattern: **short-timescale recovery does not mean long-timescale (hydrological) drought is over.**

---

## 12. Reference/Baseline Period

The reference period is the historical window used to fit the log-logistic (or chosen) distribution — it defines "normal."

Common choices: 1981–2010, 1991–2020 (current WMO-recommended 30-year climate normal), or a full available historical record.

**Why it matters:**
- A longer period generally gives more robust distribution parameter estimates (fewer sampling artifacts in the tails)
- A recent period (e.g., 1991–2020) reflects a *warmer* recent-normal, which will tend to compress SPEI's sensitivity to recent warming (because the recent warm/dry conditions become part of "normal")
- An older period (e.g., 1961–1990) preserves a cooler baseline, making recent and future warming-driven drying show up as more strongly negative SPEI — this is often the *intent* in climate-change detection studies

### Historical vs future scenarios — the critical methodological decision

You should almost always:
1. **Fit the distribution parameters using only the historical/baseline period** (e.g., a defined historical simulation window, such as 1981–2010, from the *historical* experiment)
2. **Apply that same fitted distribution** to standardize *all* periods — historical, RCP2.6, RCP4.5, RCP8.5/SSP scenarios alike

**Why not fit each scenario's distribution independently?** If you fit RCP8.5's own future distribution to itself, you are asking "how anomalous is 2080 relative to 2080's own new normal?" — this will make severe future drying *disappear* from the SPEI signal, because the SPEI will simply re-center on the new, drier climate. This defeats the purpose of using SPEI for climate-change detection. Fitting once on a common historical baseline and applying it forward is what allows you to say "future conditions are X standard deviations drier *relative to the historical climate*," which is the scientifically meaningful statement for climate-change work.

The trade-off: applying a fixed historical-fit distribution far outside its calibration range (e.g., a very different future climate) means the distribution tails are being **extrapolated**, and SPEI values in extreme future decades may compress or saturate somewhat unrealistically if the log-logistic fit doesn't hold well far from the calibration data. This is a known limitation, not a fatal one, but should be reported.

---

## 13. Historical vs Future Simulations — Terminology

- **Baseline/reference period**: the historical window used to fit the distribution (Section 12)
- **Calibration period**: often synonymous with baseline period — the data the statistical model is trained on
- **Evaluation period**: sometimes a held-out period used to check the calibration generalizes (less commonly separated in SPEI practice, more common in bias-correction validation)
- **Scenario period**: any future period under a given RCP/SSP (e.g., 2071–2100 under SSP5-8.5)
- **Model period**: the full span a given climate model simulation covers, spanning historical + scenario runs

**Avoiding artificial inter-scenario differences:** Use the *same* baseline period, the *same* PET method, and the *same* fitted distribution parameters across all scenarios from a given model. Never let the choice of baseline period or PET method vary by scenario — any such difference will show up in your results as a spurious "difference" between scenarios that has nothing to do with actual climate change.

---

## 14. Bias Correction and SPEI

Should you bias-correct the raw variables (P, T, radiation, etc.) *before* computing PET and SPEI, or compute SPEI directly from raw model output?

| Approach | Advantages | Disadvantages |
|---|---|---|
| **Bias-correct P and T (and other vars) first, then compute PET → SPEI** | Removes systematic model bias from each input; results more comparable to observations; recommended when comparing model SPEI to observation-based SPEI or when absolute drought severity matters | Bias correction of temperature/radiation can distort their joint statistical relationship with precipitation (breaks physical consistency between variables) unless a multivariate bias-correction method is used |
| **Compute SPEI directly on raw model data (self-consistent)** | Preserves the model's own internal physical consistency between P and T/PET; valid for studying *relative* changes in drought (future vs. historical, within the same model) | Absolute SPEI values may not be directly comparable to observation-based SPEI; model P/T biases can compound in PET calculation |

**Key scientific point — compound bias:** because PET depends on temperature (often exponentially, in Thornthwaite/Hargreaves-type formulas), a warm bias in `tas` doesn't just shift PET, it can *amplify* into a compounded bias in D = P − PET, which then propagates non-linearly through the log-logistic fit. A modest T bias can therefore produce a disproportionately large SPEI bias.

**Practical guidance:** 
- For **climate-change signal detection within a single model** (future vs. its own historical baseline) — raw, uncorrected model data computed self-consistently is defensible and commonly done, since you're differencing the same model against itself.
- For **absolute drought characterization or multi-model comparison against observations** — bias-correct precipitation and temperature (ideally jointly/multivariately, e.g., via quantile mapping methods that preserve inter-variable dependence) before computing PET and SPEI.
- Whichever you choose, **do it consistently across the whole model ensemble and across all scenarios**, and **report it explicitly** in your methods section.

---

## 15–18. Preprocessing Climate-Model NetCDF Data

**Inspection & QC checklist before any SPEI calculation:**

1. **Units** — check every variable's `units` attribute (`ncdump -h file.nc` or `xr.open_dataset(...).<var>.attrs['units']`); never assume
2. **Calendar** — check `time.calendar` attribute (Section 17)
3. **Missing values** — check `_FillValue`/`missing_value` attributes; count NaNs per variable
4. **Unrealistic values** — sanity-range checks (e.g., precipitation < 0, temperature outside ~200–330 K, humidity outside 0–100%)
5. **Time coordinate alignment** — all input variables (pr, tas, tasmin, tasmax, …) must share an identical time axis before combining
6. **Grid alignment** — all variables must share identical lat/lon grids (same resolution, same grid registration); regrid if a variable comes from a different source/resolution
7. **Unit conversion** — see Section 16
8. **Daily → monthly aggregation** — sum for precipitation, mean for temperature/humidity/radiation/wind (see below)

**Daily-to-monthly aggregation rule of thumb:**
- Precipitation: **sum** over the month (flux → depth, see Section 16)
- Temperature, humidity, wind, radiation: **mean** over the month
- Tasmin/Tasmax (if needed for Hargreaves): **mean of daily minima** and **mean of daily maxima** respectively — not the min/max of the monthly mean

### Missing data and bad values (Section 18)

- **NaNs/masked values**: propagate as NaN through D, accumulation, and distribution fitting rather than silently zero-filling — zero-filling precipitation, for instance, would fabricate a "dry" signal
- **Negative precipitation, impossible temperatures**: flag and mask; these usually indicate file corruption or unit-conversion errors upstream, not legitimate data
- **Missing months**: a single missing month breaks *every* rolling window that includes it, for however many months the window spans (e.g., one missing month poisons up to 12 different SPEI-12 windows) — decide explicitly whether to gap-fill, exclude the affected windows, or exclude the whole year
- **Incomplete years**: exclude from distribution fitting if the year lacks full monthly coverage, since partial-year data can bias monthly climatology estimates
- **Why blind interpolation is dangerous**: interpolating across a multi-month gap invents a smooth trajectory that never happened, which then feeds directly into "real" drought/wet anomalies and event detection (Section 28) — any interpolation should be limited (e.g., ≤1–2 consecutive missing days for reanalysis-quality gaps), clearly flagged, and ideally excluded from anything more than a few days

---

## 16. Units and Conversions

**Precipitation**
- Model native flux: `kg m⁻² s⁻¹` (equivalent to mm/s of water depth, since 1 kg/m² of water = 1 mm depth)
- To mm/day: `mm/day = flux (kg m⁻² s⁻¹) × 86400`
- To mm/month: `mm/month = mm/day × (number of days in that month)` — **the days-in-month must respect the file's actual calendar** (see Section 17); using 30 for every month on a 360_day calendar is correct, but wrong on a standard/noleap calendar

**Temperature**
- Kelvin → Celsius: `°C = K − 273.15`
- Most PET formulas (Thornthwaite, Hargreaves, Penman-Monteith) are defined in °C — verify which your chosen implementation/library expects

**Radiation** — usually W m⁻² in model output; some PET formulas need MJ m⁻² day⁻¹: `MJ m⁻² day⁻¹ = W m⁻² × 0.0864`

**Wind speed** — `sfcWind` is usually already m/s at 10 m; FAO-56 Penman-Monteith requires wind speed *at 2 m*, so a logarithmic wind-profile correction is typically applied: `u2 = u10 × 4.87 / ln(67.8×10 − 5.42)`

**Humidity** — `hurs` (%) is used directly by some PM formulations; `huss` (specific humidity, kg/kg) requires conversion to vapor pressure using pressure and temperature

**Pressure** — usually Pa in model output; many PET formulas expect kPa: `kPa = Pa / 1000`

**Common mistakes that silently invalidate SPEI:**
- Subtracting PET (mm/month) from raw precipitation flux (kg m⁻² s⁻¹) without converting first
- Using calendar-month-length assumptions inconsistent with the file's actual calendar
- Feeding Kelvin into a PET formula that expects Celsius (Thornthwaite/Hargreaves go badly wrong, sometimes producing negative or absurd PET)
- Using 10 m wind speed directly in a formula that requires 2 m wind speed

---

## 17. Calendar Issues

| Calendar | Days/year | Notes |
|---|---|---|
| Gregorian / standard | 365 or 366 (leap years) | Matches real-world calendar |
| Proleptic Gregorian | 365/366 | Gregorian rules extended backward before 1582 |
| No-leap (365_day) | Always 365 | Common in some GCMs; no Feb 29 |
| 360_day | Always 360 (12×30) | Common in some GCM output for computational simplicity |

**Why it matters in xarray/pandas:** pandas' native `Timestamp`/`DatetimeIndex` only supports the standard Gregorian calendar. Non-standard calendars (`noleap`, `360_day`) must be handled via **xarray's `cftime`-backed time coordinates** (`use_cftime=True` when opening the dataset) rather than being silently (and incorrectly) converted to standard pandas datetimes, which can shift or duplicate dates.

**Monthly aggregation recommendation:** use `xarray`'s `.resample(time="1MS")` or `.groupby("time.month")` operating on the native `cftime` index, and compute days-in-month using the correct calendar-aware day count (e.g., via `xarray.coding.cftime_offsets` or a small calendar-aware lookup) rather than a hardcoded 30/31/28-day table, especially for `360_day` or `noleap` model output.

---

## 19. Python Implementation

**Libraries and their roles:**
- **xarray**: core data structure for NetCDF (labeled N-D arrays), handles time/grid alignment, `apply_ufunc` for vectorized per-grid-cell fitting
- **numpy**: numerical arrays underlying xarray
- **pandas**: convenient for single time-series work and calendar-aware resampling
- **scipy.stats**: distribution fitting (`scipy.stats.fisk` for log-logistic, or `genlogistic`/`gamma` if comparing methods) and `norm.ppf` for the final standardization step
- **climate-indices** (`climate_indices` package, maintained by NIDIS/NOAA-affiliated authors): a research-grade, well-tested implementation of SPI/SPEI/PDSI with multiple PET options
- **xclim**: xarray-native climate-indices library with built-in `xclim.indices.standardized_precipitation_evapotranspiration_index` and multiple PET functions (`xclim.indices.potential_evapotranspiration` supporting Thornthwaite, Hargreaves, and several Penman-family methods) — generally the most convenient for gridded CMIP/CORDEX workflows because it's built directly on xarray/dask

### Minimal readable workflow (conceptual skeleton)

```python
import xarray as xr
import numpy as np
from scipy import stats

# 1. Load and align
pr = xr.open_dataset("pr.nc", use_cftime=True)["pr"]          # kg m-2 s-1
tas = xr.open_dataset("tas.nc", use_cftime=True)["tas"]        # K

# 2. Unit conversions
pr_mm_day = pr * 86400
tas_C = tas - 273.15

# 3. Monthly aggregation
pr_monthly = pr_mm_day.resample(time="1MS").sum()
tas_monthly = tas_C.resample(time="1MS").mean()

# 4. PET (Thornthwaite shown conceptually; use xclim in practice)
import xclim.indices as xci
pet_monthly = xci.potential_evapotranspiration(tas=tas_monthly, method="thornthwaite63")

# 5. Water balance
D = pr_monthly - pet_monthly

# 6. Accumulate (e.g., SPEI-3)
D3 = D.rolling(time=3, min_periods=3).sum()

# 7. Fit log-logistic distribution per calendar month, per grid cell, then standardize
spei3 = xci.standardized_precipitation_evapotranspiration_index(
    wb=D, freq="MS", window=3, dist="fisk",
    method="APP",  # or "ML" for maximum likelihood
    cal_start="1981-01-01", cal_end="2010-12-31"
)
```

`xclim` handles the per-grid-cell, per-calendar-month distribution fitting and standardization internally (vectorized via `xr.apply_ufunc`/dask), which is far more robust than hand-rolling the fit yourself — hand-rolling is useful for *understanding* the steps (Sections 4, 8) but not recommended for production gridded workflows.

---

## 20. CDO Implementation

**What CDO can reasonably do:**
- Unit checks/conversions: `cdo -b F64 mulc,86400 pr.nc pr_mmday.nc`, `cdo subc,273.15 tas.nc tas_C.nc`
- Daily → monthly aggregation: `cdo monsum pr_mmday.nc pr_monthly.nc` (sum), `cdo monmean tas_C.nc tas_monthly.nc` (mean)
- Simple arithmetic: `cdo sub pr_monthly.nc pet_monthly.nc D.nc` (once PET exists)
- Rolling/moving sums: `cdo runsum,3 D.nc D3.nc` (a genuine rolling sum operator, useful for SPEI-n accumulation)
- Basic regridding/remapping if grids mismatch: `cdo remapbil,target_grid.txt in.nc out.nc`
- Simple validation: `cdo infon`, `cdo timmin/timmax`, `cdo showdate`

**What CDO cannot reasonably do:**
- **CDO has no native SPEI (or SPI) operator.** It has no built-in log-logistic (or gamma) distribution fitting, no per-calendar-month distribution calibration, and no inverse-normal standardization step. There is no CDO command that computes distribution-based standardization — anyone showing you a one-line CDO "SPEI command" is not implementing the actual statistical methodology.
- Computing PET itself (Penman-Monteith, Hargreaves, etc.) is not implemented as a built-in CDO operator either; it must be done in Python (or a dedicated tool) and fed back in as a NetCDF variable.

**Recommended split:** use CDO for the mechanical preprocessing (unit conversion, monthly aggregation, rolling sums, regridding, basic QC) and Python (xclim/climate_indices/scipy) for PET calculation and the distribution-fitting/standardization step, since that step requires real statistical machinery CDO doesn't provide.

**Validating CDO output:** `cdo infon file.nc` to scan for absurd min/max values; `cdo fldmean file.nc` to check basin/region-averaged time series look physically sensible before proceeding to the Python stage.

---

## 21. xclim, climate-indices, and the SPEI R Package

| Package | Input requirements | PET methods | Distribution | Reference period handling | Notes |
|---|---|---|---|---|---|
| **xclim** (Python) | xarray Datasets, CF-compliant units | Thornthwaite, Hargreaves, several Penman-family variants | log-logistic (`fisk`), Gamma option | Explicit `cal_start`/`cal_end` args | Best native fit for gridded CMIP/CORDEX/dask workflows |
| **climate_indices** (Python, NOAA/NIDIS-affiliated) | 1-D time series (per-station or looped over grid cells) primarily; some gridded support | Thornthwaite built-in | log-logistic (SPEI), Gamma (SPI) | Explicit calibration-period arguments | Well-validated against the original Spanish SPEI group's reference outputs; good for point/station-style validation |
| **SPEI R package** (Beguería & Vicente-Serrano, the original authors' reference implementation) | Vectors/matrices of P and PET | User supplies PET (via companion functions or external calculation) | log-logistic (default), with Gamma/PearsonIII options | `ref.start`/`ref.end` arguments | **The authoritative reference implementation** — useful for validating any other tool's output against the "ground truth" methodology |

**Reproducibility emphasis:** whichever tool you use, explicitly report: the exact PET method and its parameterization, the distribution family and fitting method (L-moments vs. maximum likelihood), the reference period, and the software package/version. Two "SPEI-3" values computed with different tools/settings are not guaranteed to match closely, and small methodological differences (e.g., L-moments vs. ML fitting) can shift values meaningfully in short or unusual records.

---

## 22. Validation Checklist

**Data validation**
- [ ] Precipitation is in mm (not still kg m⁻² s⁻¹) before use
- [ ] PET is in mm and using a consistent time-integration (monthly, not daily) matching P
- [ ] Temperature converted to the units your PET formula expects (usually °C)
- [ ] Time axis is calendar-consistent across all input files, no duplicated/misaligned timestamps
- [ ] Missing-data fraction is documented and acceptable (or explicitly masked/excluded)

**Mathematical validation**
- [ ] D = P − PET behaves sensibly (positive in wet season/climate, negative in dry season/arid climate)
- [ ] Rolling accumulation window length matches the intended SPEI-n (off-by-one errors are common)
- [ ] Distribution fit converges (no NaN/absurd parameter values) for the vast majority of grid cells/months
- [ ] Standardization step produces values centered near 0 with SD ≈ 1 over the reference period specifically (by construction)

**Output validation**
- [ ] SPEI values mostly fall within roughly ±3 to ±4 (values routinely beyond ±5 suggest a distribution-fitting or unit problem)
- [ ] Spatial pattern is physically plausible (e.g., no isolated single-cell extreme values inconsistent with neighbors, unless a genuine local event)
- [ ] Known historical droughts (e.g., a documented regional drought year) show up as negative SPEI in your output
- [ ] SPEI averaged over the reference period itself is close to 0 with SD close to 1 (a strong internal-consistency check)

**What suspicious results look like:** SPEI values pegged at extreme constants (e.g., many cells exactly at the same large negative number) usually indicates a distribution-fitting failure being silently clipped; SPEI with no seasonal variability at SPEI-1 suggests input months got mixed up; a spatial map with sharp, grid-artifact-like boundaries usually indicates a grid-alignment or masking bug rather than real climate signal.

---

## 23. Top 20 SPEI Implementation Mistakes

1. **Wrong precipitation units** — using raw flux (kg m⁻² s⁻¹) without converting to mm → fix by explicit `×86400` (and month-length) conversion, verified against `units` attribute
2. **Wrong PET units** — mismatched integration period (daily formula output used as if monthly) → fix by checking the formula's native output period and converting explicitly
3. **Wrong temperature units** — Kelvin fed into a Celsius-based formula → fix with explicit `−273.15` and a sanity check (should be roughly −50 to +50°C)
4. **Wrong/inconsistent reference period** — different baseline windows used for different scenarios or models → fix by fixing one documented baseline for the whole study
5. **Incorrect temporal aggregation** — summing temperature or averaging precipitation (should be opposite) → fix by explicit sum-for-P, mean-for-T rule
6. **Incorrect rolling accumulation window (off-by-one)** — SPEI-3 accidentally using 2 or 4 months → fix by explicitly checking window length against a known toy example
7. **Wrong distribution family** — applying a Gamma fit (SPI's distribution, requires only positive values) to SPEI's D series, which can be negative → fix by using log-logistic (or another distribution genuinely valid for signed values)
8. **Fitting each scenario independently** — future SPEI computed against its own future baseline, hiding climate-change drying → fix per Section 12: always standardize against a single historical baseline
9. **Ignoring missing months in accumulation windows** — a single NaN silently propagating or being zero-filled → fix by explicit NaN propagation and window-exclusion rules
10. **Mixing grids** — combining variables regridded inconsistently (different resolutions/registrations) → fix by regridding everything to one common target grid before computing D
11. **Incorrect calendar handling** — treating a 360-day or no-leap model as standard Gregorian in pandas → fix with `cftime`-aware xarray processing throughout
12. **Using an inappropriate PET method for available data** — forcing Penman-Monteith with missing/interpolated radiation or wind → fix by matching method to genuinely available, trustworthy variables (Section 5)
13. **Inappropriate interpolation of missing data** — smoothing over multi-month gaps → fix by limiting interpolation to very short gaps and excluding longer ones
14. **Comparing SPEI values computed against different baselines** — e.g., comparing your SPEI-12 (1981–2010 baseline) to a paper's SPEI-12 (1991–2020 baseline) as if directly equivalent → fix by matching baselines or explicitly noting the difference
15. **Misinterpreting negative values as always "drought"** — small negative SPEI (e.g., −0.3) is *near normal*, not drought → fix by using the standard classification table (Section 10) rather than treating "negative = bad"
16. **Using different PET methods across models in a multi-model ensemble** — introduces artificial inter-model spread unrelated to real climate differences → fix by using one consistent PET method (usually the lowest-common-denominator one all models support) across the whole ensemble
17. **Applying bias correction inconsistently** (e.g., correcting P but not T, or correcting some scenarios but not others) → fix by applying the same bias-correction protocol to every variable/scenario or none at all
18. **Fitting the distribution on too short a record** — unstable tail estimates from, e.g., only 10–15 years → fix by using at least ~30 years where possible, and reporting record length explicitly
19. **Ignoring spatial/land masking** — computing "SPEI" over ocean grid cells or fitting distributions across mixed land/ocean cells → fix with an explicit land-sea mask applied before fitting
20. **Not reporting methodological choices** — omitting PET method, distribution, baseline period, or software version from a paper's methods section, making the analysis unreproducible → fix by explicitly documenting every choice in Section 30's checklist

---

## 24. SPEI in Climate-Change Research

SPEI supports analysis of:
- **Drought frequency** — count of drought onsets (SPEI crossing below −1) per period
- **Drought duration** — consecutive months below threshold
- **Drought severity** — cumulative SPEI deficit during an event (sum of |SPEI| below threshold across the event)
- **Drought intensity** — severity normalized by duration (average SPEI during the event)
- **Drought onset/recovery** — first month crossing below/above threshold
- **Seasonality shifts** — changes in which season drought events cluster in, under future scenarios
- **Spatial pattern changes** — maps of trend/frequency change across regions

**Combining with ETCCDI/extreme indices** for compound-extreme studies:
- `TXx` (annual max Tmax), `TX90p` (warm-day frequency), `WSDI` (warm-spell duration) — link SPEI drought severity to concurrent heat stress ("hot droughts," which are especially damaging)
- `RX1day`, `RX5day` — characterize whether drought recovery comes via intense short bursts of rain (relevant to runoff efficiency, not just totals)
- `CDD` (consecutive dry days) — a complementary daily-scale dryness metric alongside SPEI's monthly-scale index
- `PRCPTOT` — total precipitation, useful to check whether SPEI trends are P-driven, PET-driven, or both

---

## 25. Multi-Model Ensemble Analysis

**The key methodological question: compute SPEI per model then ensemble, or ensemble the raw variables then compute one SPEI?**

**Recommended: compute SPEI separately for each model, then ensemble the resulting SPEI values.**

Why: 
- Averaging raw P and T *across models first* would blend together each model's own internal bias structure and internal variability in a way that doesn't correspond to any single physically consistent simulation — the "ensemble-mean climate" is a statistical construct, not a real atmospheric state, and PET computed from ensemble-mean T does not equal the ensemble mean of each model's own PET (because PET is a non-linear function of T)
- Computing SPEI independently per model preserves each model's own internal P–T physical consistency, then lets you characterize **inter-model spread as genuine structural uncertainty** in the ensemble mean/median SPEI and its spread

**Ensemble statistics to compute (across the per-model SPEI fields):**
- Ensemble mean and median SPEI (median is more robust to any single outlier model)
- Inter-model standard deviation / spread (a direct uncertainty measure)
- Model agreement metrics — e.g., fraction of models agreeing on the sign of a trend, or fraction exceeding a drought threshold simultaneously

---

## 26. Spatial SPEI

For gridded data (time × lat × lon), SPEI is computed **independently at every grid cell** — there is no spatial pooling of data when fitting the distribution (each cell has its own climate and thus its own log-logistic parameters). This is computationally expressed as a **vectorized loop over grid cells** (in practice via `xr.apply_ufunc` with `vectorize=True` or dask parallelization, not a literal Python `for` loop, for performance).

- **Land masking**: apply a land-sea mask before fitting; fitting a distribution on ocean cells (where "precipitation" and "PET" are often meaningless/undefined for drought purposes) wastes compute and can introduce garbage values into any later spatial statistics
- **Missing grid cells**: cells with excessive missing data (e.g., coastal/ice-edge artifacts in some model grids) should be masked out rather than force-fit
- **Spatial interpolation**: only regrid input *fields* consistently before D is computed (Section 15) — do not spatially interpolate the *final SPEI field* itself, since SPEI is a statistically derived quantity per cell, and interpolating it blends together the different climatological baselines of neighboring cells in a way that has no direct physical meaning
- **Computational considerations**: distribution-fitting across large 3-D arrays benefits substantially from vectorization (scipy `fisk.fit` per-cell is expensive in a Python loop; xclim/`climate_indices` vectorize this) and from dask-based chunked/parallel processing for large multi-model CMIP archives

**Producing standard outputs:**
- **SPEI maps**: SPEI value at each grid cell for a chosen month/period
- **Drought-frequency maps**: count (or %) of months below a threshold (e.g., SPEI < −1) per grid cell over a period
- **Drought-trend maps**: per-cell linear or Sen's slope trend in SPEI or in drought-event metrics over time
- **Regional averages**: spatially averaged SPEI over a defined region/basin — note that averaging *already-standardized* SPEI values across space is a common but simplified approach; some studies instead average the underlying D field regionally first, then re-standardize, when the region is climatologically homogeneous

---

## 27. Trend Analysis

- **Linear trend** (OLS regression of SPEI or drought metric vs. time): simple, but assumes normality/independence of residuals, which SPEI time series often violate due to autocorrelation
- **Mann-Kendall test**: a non-parametric test for monotonic trend, robust to non-normality and outliers — the standard choice for hydroclimatic trend detection
- **Sen's slope**: a non-parametric trend-magnitude estimator, robust to outliers, typically reported alongside Mann-Kendall significance
- **Autocorrelation**: SPEI at longer timescales (e.g., SPEI-12) is, by construction, strongly autocorrelated month-to-month (each value shares 11 of 12 months with its neighbor) — standard Mann-Kendall p-values will be **overconfident (too significant)** unless a modified test accounting for autocorrelation (e.g., Hamed & Rao's modified MK test, or pre-whitening) is used
- **Field significance**: when testing trends across many grid cells simultaneously, some will appear "significant" by chance alone (multiple-testing problem) — field-significance approaches (e.g., false discovery rate control) are recommended for spatial trend maps

**Correct interpretation examples:**
- "SPEI-12 shows a statistically significant (modified MK, p<0.05) drying trend of −0.15/decade over 1981–2020" is a defensible, properly qualified statement
- "This region is getting droughts more often" requires actually counting drought *events* (Section 28) over time, not just citing a negative SPEI trend — trend and event frequency are related but distinct claims

---

## 28. Drought Event Detection

**Common definition:** a drought event = a period where SPEI < −1 (moderate drought threshold or stricter) for **at least 2–3 consecutive months**.

### Toy SPEI-1 time series (12 months)

| Month | SPEI |
|---|---|
| 1 | −0.3 |
| 2 | −0.8 |
| 3 | −1.2 |
| 4 | −1.6 |
| 5 | −1.1 |
| 6 | −0.4 |
| 7 | 0.2 |
| 8 | −1.3 |
| 9 | −0.9 |
| 10 | 0.5 |
| 11 | −1.4 |
| 12 | −0.6 |

Applying "SPEI < −1 for ≥2 consecutive months":

- **Event 1**: months 3–5 (SPEI = −1.2, −1.6, −1.1) → **duration = 3 months**; **severity** = sum of |SPEI| below threshold = 1.2+1.6+1.1 = **3.9**; **intensity** = severity/duration ≈ **1.30**; **maximum severity month** = month 4 (−1.6)
- **Month 8** (−1.3) is isolated (month 9 = −0.9, above threshold) → does **not** qualify as an event under the ≥2-month rule; illustrates why the consecutive-month criterion matters for filtering noise
- **Month 11** (−1.4) is similarly isolated → not a qualifying event alone
- **Recovery time** after Event 1: month 6 (−0.4) is the first month SPEI rises back above the drought threshold — recovery time = 1 month after the event ends

This kind of table-driven extraction is directly implementable as a simple threshold-and-run-length algorithm on any SPEI time series (per grid cell, looped or vectorized).

---

## 29. Practical End-to-End Example (Conceptual)

**Setup:** daily P and T, 1980–2100, 6 CMIP-class models, historical + one or more SSP/RCP scenarios.

```
Daily P, Tmin, Tmax (per model, per scenario, per grid cell)
   │
   ▼  QC: units, calendar, missing-value screening, range checks
Quality-controlled daily fields
   │
   ▼  Monthly aggregation (sum P, mean/min-mean/max-mean T)
Monthly P, monthly Tmean/Tmin/Tmax
   │
   ▼  PET (e.g., Hargreaves — consistent method across all 6 models)
Monthly PET
   │
   ▼  D = P − PET
Monthly water balance
   │
   ▼  Rolling sum (n = 3, 6, 12 months)
D^(3), D^(6), D^(12)
   │
   ▼  Fit log-logistic distribution using ONLY the historical baseline (e.g., 1981–2010), per calendar month, per grid cell, per model
Distribution parameters (α, β, γ) per model/cell/month/timescale
   │
   ▼  Apply the same fitted distribution to standardize historical AND all future-scenario D^(n) values
SPEI-3, SPEI-6, SPEI-12 (1980–2100, all scenarios, all models)
   │
   ▼  Write to NetCDF (CF-compliant metadata: method, baseline period, distribution documented in global attributes)
   │
   ▼  Per-model drought-event extraction (Section 28) and trend analysis (Section 27)
   │
   ▼  Multi-model ensembling of the resulting SPEI/drought metrics (Section 25): mean, median, spread, agreement
   │
   ▼  Visualization: SPEI time series, spatial trend maps, drought-frequency change maps, ensemble agreement maps
```

Every arrow above corresponds to a specific decision documented in this guide — the point of walking through it end-to-end is to see how the individual sections (PET method, baseline handling, distribution fitting, ensembling order) chain together into one coherent, reproducible pipeline.

---

## 30. Reporting SPEI Methodology in a Paper

A defensible methods section should explicitly state:

1. **Precipitation dataset**: source, resolution, period covered
2. **Temperature dataset**: source, resolution, period, whether Tmin/Tmax used
3. **PET method**: exact formula (Thornthwaite / Hargreaves / FAO-56 Penman-Monteith / Priestley-Taylor) and its specific parameterization
4. **Temporal resolution**: monthly (state explicitly, since daily variants exist)
5. **Accumulation timescale(s)**: which SPEI-n were computed and why
6. **Reference/baseline period**: exact start–end years, and whether it's a common baseline across scenarios/models
7. **Probability distribution**: log-logistic (or alternative), and fitting method (L-moments vs. maximum likelihood)
8. **Standardization procedure**: confirm use of the inverse-normal transform (standard) vs. any variant
9. **Climate scenarios**: which RCPs/SSPs, which models, ensemble member IDs
10. **Bias correction**: whether applied, to which variables, and which method
11. **Multi-model ensemble approach**: per-model-then-ensemble vs. ensembled-inputs (state and justify, per Section 25)
12. **Trend analysis method**: e.g., modified Mann-Kendall + Sen's slope, and significance threshold used
13. **Drought-event definition**: threshold and minimum-duration criteria used (Section 28)

**Reproducibility-critical items** (omitting any of these makes independent replication effectively impossible): PET method + exact formula, distribution family + fitting method, exact baseline period, and software/package version used.

---

## 31. Foundational and Key Literature

- **Vicente-Serrano, S.M., Beguería, S., López-Moreno, J.I. (2010).** *A Multiscalar Drought Index Sensitive to Global Warming: The Standardized Precipitation Evapotranspiration Index.* Journal of Climate, 23(7), 1696–1718. DOI: 10.1175/2009JCLI2909.1. — **The original SPEI methodology paper.** Introduces the log-logistic-based standardization of the P−PET water balance and demonstrates SPEI's sensitivity to temperature-driven drought that SPI misses. Essential first read.
- **Beguería, S., Vicente-Serrano, S.M., Reig, F., Latorre, B. (2014).** *Standardized precipitation evapotranspiration index (SPEI) revisited: parameter fitting, evapotranspiration models, tools, datasets and drought monitoring.* International Journal of Climatology, 34(10), 3001–3023. DOI: 10.1002/joc.3887. — Follow-up paper refining parameter-fitting approaches (L-moments vs. other methods), comparing PET method sensitivity, and describing the SPEI R package/global SPEI database. Important for implementation-level detail.
- **McKee, T.B., Doesken, N.J., Kleist, J. (1993).** *The relationship of drought frequency and duration to time scales.* Proceedings of the 8th Conference on Applied Climatology. — The original SPI paper; foundational for the multiscalar drought-index concept and the standard classification thresholds later adopted for SPEI.
- **Thornthwaite, C.W. (1948).** *An approach toward a rational classification of climate.* Geographical Review, 38(1), 55–94. — Origin of the Thornthwaite PET method.
- **Hargreaves, G.H., Samani, Z.A. (1985).** *Reference crop evapotranspiration from temperature.* Applied Engineering in Agriculture, 1(2), 96–99. — Origin of the Hargreaves PET method.
- **Allen, R.G., Pereira, L.S., Raes, D., Smith, M. (1998).** *Crop evapotranspiration — Guidelines for computing crop water requirements.* FAO Irrigation and Drainage Paper 56. — The standard reference for FAO-56 Penman-Monteith PET, including the 2 m wind correction and other practical formulas used in Section 16.

I recommend starting with the 2010 paper (concept and math), then the 2014 paper (implementation nuance), and keeping FAO-56 as your PET reference manual.

---

## 32–33. Learning Roadmap and Final Checklist

### Level 1 — Basic Understanding
- What SPEI measures and why it exists (Sections 1–3)
- Drought types and where SPEI fits (Section 2)

### Level 2 — Mathematical Understanding
- Water balance, accumulation, probability distributions, standardization (Sections 4, 8, 9)
- Basic trend-test statistics (Mann-Kendall, Sen's slope) (Section 27)

### Level 3 — Climate-Data Understanding
- NetCDF variables, units, calendars, missing data (Sections 6, 15–18)

### Level 4 — SPEI Methodology Choices
- PET method selection, reference period, bias correction, ensembling order (Sections 5, 12–14, 25)

### Level 5 — Implementation
- Python (xarray/xclim/climate_indices) and CDO preprocessing workflows (Sections 19–21)

### Level 6 — Validation
- Data, mathematical, and output validation; recognizing the Top 20 mistakes (Sections 22–23)

### Level 7 — Research Application
- Drought-event/trend analysis, multi-model ensembles, compound extremes, methodology reporting (Sections 24, 26–30)

### Final Checklist — 25 Questions to Answer Before Running SPEI on Real Data

1. What exactly does my D = P − PET represent physically, and are both terms in the same units?
2. Which PET method am I using, and is it justified by the variables I actually have (and trust) in my dataset?
3. Am I using the same PET method across every model in my ensemble?
4. What accumulation timescale(s) (SPEI-1/3/6/12/…) am I computing, and why are they appropriate for my research question?
5. Am I performing a rolling *sum*, not a mean, over the correct window length?
6. Which probability distribution am I fitting (log-logistic or otherwise), and is it appropriate for signed values?
7. Am I fitting the distribution separately for each calendar month, each timescale, and each grid cell?
8. What is my exact reference/baseline period, and is it the same across all scenarios and models?
9. Am I fitting the distribution only on the baseline period and applying it forward to future scenarios (not re-fitting per scenario)?
10. Have I decided on, and documented, whether/how I'm bias-correcting input variables before computing PET and SPEI?
11. Have I verified every variable's units against its NetCDF attribute rather than assuming?
12. Have I confirmed the calendar type of my model output and handled it with `cftime`, not plain pandas?
13. How am I handling missing months, and could a single missing month silently poison multiple rolling windows?
14. Have I confirmed all input variables share identical time axes and identical spatial grids?
15. Am I masking ocean/invalid grid cells before fitting distributions?
16. What SPEI classification thresholds am I using, and are they consistent with what I'll compare against in the literature?
17. Am I computing SPEI separately per model and then ensembling the SPEI outputs, rather than ensembling raw inputs first?
18. What ensemble statistics (mean, median, spread, agreement) will I report, and why?
19. Which trend test am I using, and have I accounted for autocorrelation (especially at SPEI-6/12+)?
20. How am I defining a "drought event" (threshold + minimum duration), and is that definition stated explicitly in my methods?
21. Have I validated my output against at least one known historical drought event in my study region?
22. Are my output SPEI values within a physically reasonable range (roughly ±3 to ±4), with no suspicious clipping or spatial artifacts?
23. Have I documented every methodological choice (PET method, distribution, baseline, software/version) needed for someone else to reproduce my results?
24. If comparing to observation-based SPEI or another study, are our baselines, PET methods, and distributions actually comparable?
25. Have I distinguished clearly, in my own understanding and in my writing, between "what SPEI is" (concept) and "how I computed it" (implementation choices) — and can I defend each implementation choice scientifically if challenged?

---

*This guide is meant as a living reference — revisit Sections 8–14 (distribution fitting and baseline handling) and Section 23 (common mistakes) once you start implementing on your own data, since that's where most real-world SPEI errors occur.*
