# CSRF Urchin Telemetry Analysis

<!-- TOC -->

- [Introduction](#introduction)
- [Installation](#installation)
  - [R](#r)
  - [Python](#python)
- [Project Structure](#project-structure)
- [Data & Output](#data--output)
- [Contributing](#contributing)
  - [File I/O](#file-io)
  - [Git branches](#git-branches)
  
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
The project is primarily an `R` project defined by `CSRF_urchin_telemetry.Rproj` at the top level.  The work environment is defined by the `renv` directory for `R` and the `environment.yaml` file for `Python`.  The `workflow` directory contains scripts and subdirectories for specific data processing tasks.  The scripts `00-main.R` and `00-main.py` are the primary control scripts.  Specific processing scripts are contained within the subdirectories of `workflow`.  While not part of the Github repository, the `data` and `output` directories should be located at the same level as `workflow`.  It is critical that this file structure is adhered to, for ease of project maintenance.  The directory tree below illustrates the project structure.

```sh
├── README.md
├── .gitignore
│
├── CSRF-urchin-telemetry.Rproj
├── initialize_renv.R
├── renv/
│   ├── activate.R
│   ├── library
│   └── settings.json
├── environment.yaml
│
├── workflow/
│   ├── 00-main.R
│   ├── 00-main.py
│   ├── 00-explore.ipynb
│   │
│   ├── adcp/
│   ├── preprocessing-environmental_data/
│   ├── preprocessing-telemetry_filtering/
│   └── tcm/
│
├── data/
└── output/
```

## Data & Output
All of the raw, processed data and visualization output are to be placed in the `data` and `output` directories.  You should keep working copies of these directories locally and update the Azure storage containers when the processing/analysis task is completed.  Connect to the Azure container (https://ppocec.blob.core.windows.net/csrf-urchin-telemetry) using the [Microsoft Azure Storage Explorer](https://azure.microsoft.com/en-ca/products/storage/storage-explorer).  Contact the project maintainer to obtain the shared access code for the storage container.

## Contributing


### File I/O
Design your code to read and write from the `data` and `output` directories.  Use of relative paths will increase the likelihood that the code will run from another person's userspace on their local machine.  Since the `data` and `output` directories are not updated through `git`, any files created in those directories will need to be manually copied to the Azure storage container.

### Git branches
When adding new contributions to the repository, please create a branch to work from instead of working in `main`. Branches should, more or less, contain work associated with a specific task, rather than being open-ended.  So, if you had a couple of tasks, it is better to create two branches `task_1` and `task_2` rather than a generic branch `stuff_to_work_on`.  In this way, work associated with specific task will have less likelihood of impacting or breaking code in other tasks.

Please adhere to the steps below to contribute new work to this repository.
* Define the task to be done
* [Create a new branch](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-and-deleting-branches-within-your-repository#creating-a-branch) for this task
* Develop new code on your local machine and periodically push changes to Github
* When the task is completed, [submit a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request#creating-the-pull-request) to merge the branch back into `main`.
* [Delete the branch](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-and-deleting-branches-within-your-repository#deleting-a-branch) once the pull request has been approved and the merge complete.

#
 <div align="right"> Last updated: 2025-02-19 </div>
 
<!-- + the file `0-packrat-initialize.R` that has been created by Filippo Ferrario at the beginning to initialize the library -->







