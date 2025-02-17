# CSRF Urchin Telemetry Analysis

<!-- TOC -->

- [Introduction](#introduction)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Data & Output](#data-output)
- [Contributing](#contributing)
  
<!-- /TOC -->

## Introduction
This repository contains data processing and visualization code for analysis of telemetry, photomosaic, and environmental data from the CSRF-funded Urchin Telemetry Project.  Given the size of the raw and processed data, these are not contained in the repository.  Instead, they are hosted on an Azure repository.

## Installation
Depending on the analysis being performed, either `R`, `Python`, or both will need to be installed on your local machine.

The `R` version to be used in this project is __4.3.2__.  

The `Python` version used in this project is __3.11__.  The easiest way to create the environment containing this version of Python alongside the necessary numeric and plotting packages is with a `conda` installation.  From the commandline in the root project directory, enter the following to create the environment:
```sh
conda env create -f environment.yml
```
To activate the environment, enter:
```sh
conda activate urchins
```

## Project Structure
The project is primarily an `R` project defined by `CSRF_urchin_telemetry.Rproj` at the top level.  The work environment is defined by the `renv` directory for `R` and the `environment.yaml` file for `Python`.  The `workflow` directory contains scripts and subdirectories for specific data processing tasks.  The scripts `00-main.R` and `00-main.py` are the primary control scripts.  Specific processing scripts are contained with the subdirectories of `workflow`.  While not part of the Github repository, the `data` and `output` directories should be located at the same level as `workflow`.  It is critical that this file structure is adhered to, for ease of project maintenance.  The directory tree below illustrates the project structure.

```sh
├── README.md
├── .gitignore
│
├── CSRF-urchin-telemetry.Rproj
├── initialize_renv.R
├── renv/
│   ├── activate.R/
│   ├── library
│   └── settings.json
├── environment.yaml
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
Last updated: 2025-02-17

## Data & Output
Instructions on accessing data and output directories on Azure.

## Contributing


<!-- + the file `0-packrat-initialize.R` that has been created by Filippo Ferrario at the beginning to initialize the library -->







