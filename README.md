# CSRF Urchin Telemetry Analysis

<!-- TOC -->

- [Introduction](#introduction)
- [Installation](#installation)
  - [R](#r)
  - [Python](#python)
- [Project Structure](#project-structure)
- [Data & Output](#data--output)
- [Contributing](#contributing)
  
<!-- /TOC -->

## Introduction
This repository contains data processing and visualization code for analysis of telemetry, photomosaic, and environmental data from the CSRF-funded Urchin Telemetry Project.  Given the size of the raw and processed data files, these are not contained in the repository.  Instead, they are hosted on Azure.

## Installation
Depending on the analysis being performed, either `R`, `Python`, or both will need to be installed on your local machine.

### R
The `R` version to be used in this project is __4.3.2__.  You will also need `Rtools` __4.3__ installed.  To set up your environment, open `R` or `RStudio` from the project directory.  If the project is properly installed, you will see a message similar to
```r
Project '~/CSRF-urchin-telemetry' loaded. [renv 1.0.3]
```
Use renv to list and install the necessary packages.
```r
renv::status()
renv::restore()
```

### Python
The `Python` version used in this project is __3.11__.  The easiest way to create the environment containing this version of Python alongside the necessary numeric and plotting packages is with a `conda` installation.  From the commandline in the root project directory, enter the following to create the environment:
```bash
conda env create -f environment.yml
```
To activate the environment, enter:
```bash
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
 <div align="right"> Last updated: 2025-02-17 </div>

## Data & Output
All of the raw, processed data and visualization output are to be placed in the `data` and `output` directories.  You should keep working copies of these directories locally and update the Azure storage containers when the processing/analysis task is completed.  Connect to the Azure container using the [Microsoft Azure Storage Explorer](https://azure.microsoft.com/en-ca/products/storage/storage-explorer).  Contact project maintainer for specifics on connecting to the storage container.

## Contributing


<!-- + the file `0-packrat-initialize.R` that has been created by Filippo Ferrario at the beginning to initialize the library -->







