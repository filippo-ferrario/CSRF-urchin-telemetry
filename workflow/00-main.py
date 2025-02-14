#! /usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: 00-main.py (Main Python processing script)
  Author 	: Paul Covert
  Date   	: 2024-03-22
  Version	: 1.1.0
  URL		: 
  Aim    	: (1) Describe the structure of the Python_workflow directory and how
                  it fits in with the larger R-based workflow.
              (2) Control data processing, analysis, and plotting.
  ===============================================================================

  Envision that this directory will contain the main scripts that control the
  ADCP processing sequence.  This includes:
    * creation of necessary directory structure;
    * processing of ADCP data;
    * creation of descriptive plots.
    
  The processing scripts will be designed to be callable from R.  But, should
  they be called from R, specifically, from 00-main.R?  Pros are that the 
  functions contained here could be integrated into the overall data processing 
  hierarchy.  Cons are that an environment containing Python and the necessary 
  libraries will need to be created for anyone executing 00-main.R.  Much of 
  this can be automated, but some user-guided installing will be necessary.
  
  One possible solution is to add an adcp_check function within 00-main.R.  This 
  function would raise an error if the processed ADCP output files did not exist, 
  and prompt the user to either manually or automatically run the Python scripts 
  to create those files, if they are needed.
"""

from pathlib import Path
import numpy as np
import pandas as pd
import xarray as xr
import matplotlib.pyplot as plt
import adcp
import tcm

# Define root data path
DATA_RAW = Path("../data")

# Define site data paths
BIC = Path(DATA_RAW, "raw_data_downloads_bic_2022")
CACOUNA = Path(DATA_RAW, "raw_data_downloads_cacouna_2022")
RUPERT = Path(DATA_RAW, "raw_data_downloads_prince_rupert_2023")
QUADRA = Path(DATA_RAW, "raw_data_downloads_quadra_2023")

# Define ADCP data paths
BIC_ANSE_DES_PILOTES_ADCP = Path(
    BIC, "sensors_anse_des_pilotes", "ADCP", "MADCP_2022098_AnsePilotes_19235_VEL.nc"
)
BIC_LA_BALEINE_ADCP = Path(
    BIC, "sensors_la_baleine", "ADCP", "MADCP_2022098_LaBaleine_8601_VEL.nc"
)
CACOUNA_ILE_AUX_LIEVRES_1_ADCP = Path(
    CACOUNA, "ADCP_between_2_sites", "MADCP_2022098_IleauxLievres1_24788_VEL.nc"
)
CACOUNA_ILE_AUX_LIEVRES_2_ADCP = Path(
    CACOUNA, "ADCP_between_2_sites", "MADCP_2022098_IleauxLievres2_19238_VEL.nc"
)
RUPERT_TUGWELL_1_ADCP = Path(
    RUPERT, "sensors_tugwell1", "ADCP", "MADCP_2023098_Tugwell1_24788_VEL.nc"
)
RUPERT_TUGWELL_2_ADCP = Path(
    RUPERT, "sensors_tugwell2", "ADCP", "MADCP_2023098_Tugwell2_19238_VEL.nc"
)
QUADRA_MARINA_1_ADCP = Path(
    QUADRA, "sensors_marina1", "ADCP", "MADCP_2023098_Marina1_8601_VEL.nc"
)
QUADRA_MARINA_2_ADCP = Path(
    QUADRA, "sensors_marina2", "ADCP", "MADCP_2023098_Marina2_19235_VEL.nc"
)
ALL_ADCP = [
    BIC_ANSE_DES_PILOTES_ADCP,
    BIC_LA_BALEINE_ADCP,
    CACOUNA_ILE_AUX_LIEVRES_1_ADCP,
    CACOUNA_ILE_AUX_LIEVRES_2_ADCP,
    RUPERT_TUGWELL_1_ADCP,
    RUPERT_TUGWELL_2_ADCP,
    QUADRA_MARINA_1_ADCP,
    QUADRA_MARINA_2_ADCP,
]

# Define TCM data paths
BIC_ANSE_DES_PILOTES_TCM = Path(
    BIC, "sensors_anse_des_pilotes", "TCM", "2206004_Bic1_(0)_Current.csv"
)
BIC_LA_BALEINE_TCM = Path(
    BIC, "sensors_la_baleine", "TCM", "2206005_Bic2_(0)_Current.csv"
)
CACOUNA_ILE_AUX_LIEVRES_1_TCM = Path(
    CACOUNA, "sensors_southwest", "TCM", "2206002_IleauxLievres1_(0)_Current.csv"
)
CACOUNA_ILE_AUX_LIEVRES_2_TCM = Path(
    CACOUNA, "sensors_northeast", "TCM", "2206003_IleauxLievres2_(0)_Current.csv"
)
RUPERT_TUGWELL_1_TCM = Path(RUPERT, "sensors_tugwell1", "TCM", "")
RUPERT_TUGWELL_2_TCM = Path(RUPERT, "sensors_tugwell2", "TCM", "")
QUADRA_MARINA_1_TCM = Path(QUADRA, "sensors_marina1", "TCM", "")
QUADRA_MARINA_2_TCM = Path(QUADRA, "sensors_marina2", "TCM", "")
ALL_TCM = [
    BIC_ANSE_DES_PILOTES_TCM,
    BIC_LA_BALEINE_TCM,
    CACOUNA_ILE_AUX_LIEVRES_1_TCM,
    CACOUNA_ILE_AUX_LIEVRES_2_TCM,
    RUPERT_TUGWELL_1_TCM,
    RUPERT_TUGWELL_2_TCM,
    QUADRA_MARINA_1_TCM,
    QUADRA_MARINA_2_TCM,
]


print("Creating descriptive plots of ADCP data...", flush=True)
for adcp_filepath in ALL_ADCP:
    ds_adcp = adcp.open_dataset(adcp_filepath)
    print("  {}".format(ds_adcp.attrs["platform"]))

    # generate plots of adcp position and measured current for each sensor
    fig_current, fig_position = adcp.plot.raw(ds_adcp)
    fig_current.savefig(adcp_filepath.parent / (adcp_filepath.stem + "_position.png"))
    fig_position.savefig(adcp_filepath.parent / (adcp_filepath.stem + "_current.png"))

    # generate windrose plots of adcp horizontal bottom currents and directions
    fig_windrose = adcp.plot.windrose(ds_adcp)
    fig_windrose.savefig(adcp_filepath.parent / (adcp_filepath.stem + "_windrose.png"))

    # close everything to save memory
    plt.close("all")

print("done.")


print("Comparing ADCP and TCM current measurements...", flush=True)
for adcp_filepath, tcm_filepath in zip(ALL_ADCP[0:4], ALL_TCM[0:4]):
    ds_adcp = adcp.open_dataset(adcp_filepath)
    df_tcm = tcm.read_csv(tcm_filepath)
    print("  {}".format(ds_adcp.attrs["platform"]))
    
    ds_adcp = ds_adcp.sel(depth=np.max(ds_adcp["depth"]))
    ds_adcp = ds_adcp.dropna("time")
    df_adcp = ds_adcp.to_pandas()

print("done.")
