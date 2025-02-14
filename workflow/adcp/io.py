# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: io.py
  Author 	: Paul Covert
  Date   	: 2025-02-14
  Version	: 1.0.0
  URL		: 
  Aim    	: Input / Output routines for ADCP files
  ===============================================================================
"""

import pandas as pd
import xarray as xr
from .calc import horizontal_velocity


def open_dataset(filename_or_obj):
    """Read ADCP netcdf files. For ease of readability, the column names 
    are renamed.  Horizontal speed and direction are calculated upon
    loading.
    
    Parameters
    ----------
    filename_or_obj : str, Path, file-like or DataStore
    
    Returns
    -------
    ds : time-indexed and depth-indexed xarray Dataset
            
    """
    ds = xr.open_dataset(filename_or_obj)
    ds = ds.drop(labels=["DTUT8601"])
    ds = ds.rename(
        {
            "ADEPZZ01": "xducer_depth", 
            "HEADCM01": "xducer_heading",
            "LCEWAP01": "velocity_east",
            "LCEWAP01_QC": "velocity_east_qc",
            "LCNSAP01": "velocity_north",
            "LCNSAP01_QC": "velocity_north_qc",
            "LERRAP01": "velocity_error",
            "LRZAAP01": "velocity_up",
            "LRZAAP01_QC": "velocity_up_qc",
            "PRESPR01": "xducer_pres",
            "PRESPR01_QC": "xducer_pres_qc",
            "PTCHGP01": "xducer_pitch",
            "ROLLGP01": "xducer_roll",
            "TEMPPR01": "xducer_temp",
            "TEMPPR01_QC": "xducer_temp_qc", 
        }
    )
    ds["speed"], ds["dir"] = horizontal_velocity(ds["velocity_north"], ds["velocity_east"])
    return ds
