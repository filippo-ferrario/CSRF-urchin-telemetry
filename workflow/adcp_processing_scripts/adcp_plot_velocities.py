#! /usr/bin/env python3
# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: ADCP plot velocities
  Author 	: Paul Covert
  Date   	: 2025-02-11
  Version	: 25.02.1a
  URL		: 
  Aim    	: Plot processed velocity data for all ADCPs deployed.  To be used
              as a preliminary check of data quality, continuity, etc.
              Plots are saved in the original data directories.
  ===============================================================================
"""

import sys
import os
import numpy as np
import xarray as xr
import matplotlib.pyplot as plt


def _load_adcp_data(filepath):
    return xr.open_dataset(filepath)


def _plot_adcp_position(ds):
    fig, (ax_depth, ax_heading, ax_pitch, ax_roll) = plt.subplots(
        ncols=1, nrows=4, sharex=True, figsize=(6, 9), constrained_layout=True
    )
    ds["ADEPZZ01"].plot(ax=ax_depth)
    ds["HEADCM01"].plot(ax=ax_heading)
    ds["PTCHGP01"].plot(ax=ax_pitch)
    ds["ROLLGP01"].plot(ax=ax_roll)

    ax_depth.set_xlabel("")
    ax_heading.set_xlabel("")
    ax_pitch.set_xlabel("")
    fig.suptitle(ds.attrs["platform"])
    return fig


def _plot_adcp_current(ds):
    ds["horiz_speed"] = (ds["LCNSAP01"] ** 2.0 + ds["LCEWAP01"] ** 2.0) ** 0.5
    ds["horiz_speed"].attrs = {
        "long_name": "horizontal sea water speed",
        "units": "m/s",
    }
    ds["horiz_heading"] = np.arctan2(ds["LCNSAP01"], ds["LCEWAP01"]) * 180.0 / np.pi
    ds["horiz_heading"].attrs = {
        "long_name": "horizontal sea water heading",
        "units": "degree",
    }
    fig, (ax_horiz_speed, ax_horiz_heading, ax_vert_velocity) = plt.subplots(
        ncols=1, nrows=3, sharex=True, figsize=(6, 9), constrained_layout=True
    )
    ds["horiz_speed"].where(ds["LCNSAP01"]<=2).plot(ax=ax_horiz_speed)
    ds["horiz_heading"].where(ds["LCNSAP01"]<=2).plot(ax=ax_horiz_heading)
    ds["LRZAAP01"].where(ds["LRZAAP01"]<=2).plot(ax=ax_vert_velocity)

    ax_horiz_speed.yaxis.set_inverted(True)
    ax_horiz_heading.yaxis.set_inverted(True)
    ax_vert_velocity.yaxis.set_inverted(True)
    fig.suptitle(ds.attrs["platform"])

    return fig


def main():
    """Initiate plotting of ADCP data from all four sites"""
    
    filepath_list = [
        "../../data/raw_data_downloads_bic_2022/sensors_anse_des_pilotes/ADCP/MADCP_2022098_AnsePilotes_19235_VEL.nc",
        "../../data/raw_data_downloads_bic_2022/sensors_la_baleine/ADCP/MADCP_2022098_LaBaleine_8601_VEL.nc",
        "../../data/raw_data_downloads_cacouna_2022/ADCP_between_2_sites/MADCP_2022098_IleauxLievres1_24788_VEL.nc",
        "../../data/raw_data_downloads_cacouna_2022/ADCP_between_2_sites/MADCP_2022098_IleauxLievres2_19238_VEL.nc",
        "../../data/raw_data_downloads_prince_rupert_2023/sensors_tugwell1/ADCP/MADCP_2023098_Tugwell1_24788_VEL.nc",
        "../../data/raw_data_downloads_prince_rupert_2023/sensors_tugwell2/ADCP/MADCP_2023098_Tugwell2_19238_VEL.nc",
        "../../data/raw_data_downloads_quadra_2023/sensors_marina1/ADCP/MADCP_2023098_Marina1_8601_VEL.nc",
        "../../data/raw_data_downloads_quadra_2023/sensors_marina2/ADCP/MADCP_2023098_Marina2_19235_VEL.nc",
    ]
    
    for filepath in filepath_list:
        ds = _load_adcp_data(filepath)
        
        fig1 = _plot_adcp_position(ds)
        fig2 = _plot_adcp_current(ds)
    
        filepath_root, _ = os.path.splitext(filepath)
        fig1.savefig(filepath_root + "_position.png")
        fig2.savefig(filepath_root + "_current.png")
        
    return


if __name__ == "__main__":
    sys.exit(main())
