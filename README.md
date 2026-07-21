# Climate Attribution and Climate Extremes Analysis

## Overview

This repository provides a reproducible workflow for analyzing climate variability, climate extremes, and long-term climate change using gridded climate model outputs. The workflow includes data preprocessing, quality control, spatial processing, computation of climate extreme indices, statistical analysis, and visualization.

The pipeline is designed to support climate attribution studies, climate impact assessments, and regional climate analyses using NetCDF datasets from global and regional climate models.

---

## Features

- Read and process large NetCDF climate datasets
- Quality control and data validation
- Detection and correction of unrealistic climate values
- Missing data interpolation
- Spatial clipping using administrative or custom boundaries
- Province/region-wise climate analysis
- Computation of ETCCDI climate extreme indices
- Generation of publication-quality figures
- Export processed datasets in NetCDF and CSV formats

---

## Supported Climate Variables

Examples include

- Daily Maximum Temperature (`tasmax`)
- Daily Minimum Temperature (`tasmin`)
- Daily Mean Temperature (`tas`)
- Daily Precipitation (`pr`)

The workflow can easily be extended to additional climate variables.

---

## Climate Extreme Indices

The repository supports the computation of several ETCCDI indices, including:

### Temperature

- TXx – Annual maximum of daily maximum temperature
- TXn – Annual minimum of daily maximum temperature
- TNx – Annual maximum of daily minimum temperature
- TNn – Annual minimum of daily minimum temperature

### Precipitation

- RX1day – Annual maximum 1-day precipitation
- RX5day – Annual maximum consecutive 5-day precipitation
- PRCPTOT – Annual total wet-day precipitation
- R10mm – Number of heavy precipitation days
- R20mm – Number of very heavy precipitation days
- CDD – Consecutive Dry Days
- CWD – Consecutive Wet Days

Additional ETCCDI indices can be incorporated with minimal modifications.

---

## Workflow

```text
Raw Climate Data
        │
        ▼
Quality Control
        │
        ▼
Data Cleaning
        │
        ▼
Interpolation of Missing Values
        │
        ▼
Spatial Clipping
        │
        ▼
Climate Extreme Indices
        │
        ▼
Regional Statistics
        │
        ▼
Visualization
        │
        ▼
NetCDF & CSV Outputs
```

---


## Main Processing Steps

### Data Preparation

- Load NetCDF climate datasets
- Inspect metadata
- Verify coordinate systems
- Validate temporal coverage

### Quality Control

- Detect unrealistic values
- Replace invalid observations with missing values
- Preserve original metadata

### Interpolation

- Fill missing values using spatial interpolation
- Maintain spatial consistency
- Generate cleaned climate datasets

### Spatial Analysis

- Clip datasets using administrative boundaries or shapefiles
- Regional aggregation
- Province/state/district level analysis

### Climate Indices

Compute annual and seasonal climate extreme indices following ETCCDI definitions.

### Statistical Analysis

Generate regional statistics including:

- Mean
- Median
- Minimum
- Maximum
- Standard Deviation
- Temporal trends

### Visualization

Generate publication-quality figures including:

- Spatial distribution maps
- Time series
- Trend analysis
- Moving averages
- Regional comparisons
- Heatmaps
- Anomaly maps

---

## Applications

This workflow can be applied to

- Climate attribution studies
- Climate change detection
- Climate variability analysis
- Extreme event analysis
- Disaster risk assessment
- Environmental impact studies
- Hydrological studies
- Agricultural climate assessments
- Climate adaptation planning
- Regional climate assessments

---

## Input Data

The workflow accepts standard CF-compliant NetCDF files from sources such as

- CORDEX
- CMIP5
- CMIP6
- ERA5
- ISIMIP
- Observational gridded datasets

Boundary datasets may include

- Administrative boundaries
- Watersheds
- River basins
- Custom polygons

---

## Software Requirements

Python 3.9 or later

Main libraries

- xarray
- numpy
- pandas
- scipy
- matplotlib
- geopandas
- rioxarray
- rasterio
- netCDF4
- dask
- pathlib

Optional

- CDO (Climate Data Operators)
- NCO (NetCDF Operators)

---

## Typical Outputs

### NetCDF

- Cleaned datasets
- Interpolated datasets
- Climate indices
- Regional subsets

### CSV

- Regional statistics
- Annual summaries
- Time series

### Figures

- Spatial maps
- Climate index maps
- Trend analysis
- Province/state comparisons
- Annual variability
- Long-term climate trends

---

## Reproducibility

The workflow is fully reproducible and built using open-source Python libraries. File management is handled using `pathlib`, making the project portable across Windows, Linux, and macOS.

---

## Future Development

Planned enhancements include:

- Bias correction workflows
- Ensemble analysis
- Climate attribution diagnostics
- Multi-model comparisons
- Extreme value analysis
- Return period estimation
- Interactive dashboards
- Parallel processing with Dask
- Automated report generation

---

## Citation

If you use this repository in your research, please cite the relevant climate datasets, ETCCDI methodology, and software packages used in your analysis.

---

## Contributing

Contributions are welcome. Feel free to submit issues, feature requests, or pull requests to improve the workflow.

---

## License

This project is distributed under the MIT License.

---

## Author

**Imran Ul Haq**

Research Engineer
Weather and Climate Services, Islamabad, Pakistan.


Research interests include:

- Climate Attribution
- Climate Change
- Climate Extremes
- Geospatial Data Science
- Earth System Modelling
- Environmental Analytics
