#! /usr/bin/env python
# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: 00-main.py (Main Python processing script)
  Author 	: Paul Covert
  Date   	: 2024-03-22
  Version	: 1.0.1
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
import xarray as xr
import matplotlib.pyplot as plt
import adcp_processing as adcp


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
BIC_ANSE_DES_PILOTES_TCM = Path(
    BIC_RAW, "sensors_anse_des_pilotes", "TCM", "2206004_Bic1_(0)_Current.csv"
)
BIC_LA_BALEINE_TCM = Path(
    BIC_RAW, "sensors_la_baleine", "TCM", "2206005_Bic2_(0)_Current.csv"
)
CACOUNA_ILE_AUX_LIEVRES_1_TCM = Path(
    CACOUNA_RAW, "sensors_southwest", "TCM", "2206002_IleauxLievres1_(0)_Current.csv"
)
CACOUNA_ILE_AUX_LIEVRES_2_TCM = Path(
    CACOUNA_RAW, "sensors_northeast", "TCM", "2206003_IleauxLievres2_(0)_Current.csv"
)


print("Creating descriptive plots of ADCP data...", flush=True)
for p in ALL_ADCP:
    ds = xr.open_dataset(p)
    print("  {}".format(ds.attrs["platform"]))

    # calculations: horizontal velocity
    ds = adcp.calc.horizontal_velocity(ds)

    # generate plots of adcp position and measured current for each sensor
    fig_current, fig_position = adcp.plot.raw(ds)
    fig_current.savefig(p.parent / (p.stem + "_position.png"))
    fig_position.savefig(p.parent / (p.stem + "_current.png"))

    # generate windrose plots of adcp horizontal bottom currents and directions
    fig_windrose = adcp.plot.windrose(ds)
    fig_windrose.savefig(p.parent / (p.stem + "_windrose.png"))

    # close everything to save memory
    plt.close("all")

print("done.")
