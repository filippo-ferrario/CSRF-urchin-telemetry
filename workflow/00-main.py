#! /usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name      : 00-main.py (Main Python processing script)
  Author    : Paul Covert
  Date      : 2024-03-22
  Version   : 1.1.0
  URL       : https://github.com/filippo-ferrario/CSRF-urchin-telemetry
  Aim       : (1) Describe the structure of the Python_workflow directory and how
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

print("Creating descriptive plots of ADCP data...", flush=True)
for adcp_filepath in adcp.paths.get("all", DATA_RAW):
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