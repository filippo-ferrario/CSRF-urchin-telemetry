# CSRF urchin telemetry analysis project
 Collaborative Reproducible data analysis
 
Project folder hierarchy:

```bash
├── README.md
├── .gitignore
│
├── CSRF-urchin-telemetry.Rproj
├── initialize_renv.R
├── renv/
│   ├── activate.R/
│   ├── library
│   └── settings.json
├── conda-environment.yaml
│
├── workflow/
│   ├── 00-main.R
│   ├── 00-main.py
│   ├── 00-main.ipynb
│   ├── adcp/
│   ├── preprocessing-environmental_data/
│   ├── preprocessing-telemetry_filtering/
│   └── tcm/
│
├── data/
│   ├── raw_data_downloads_bic_2022/
│   ├── raw_data_downloads_cacouna_2022/
│   ├── raw_data_downloads_prince_rupert_2023/
│   └── raw_data_downloads_quadra_2023/
│
└── output/
```
+ `CSRF_urchin_telemetry` is the main project folder that contains subfolders for specific data processing tasks
+ The __R version to be used in this project is the 4.3.2__
+ A `renv` folder with defining the shared/common library for both sub-projects




<!-- + the file `0-packrat-initialize.R` that has been created by Filippo Ferrario at the beginning to initialize the library -->







