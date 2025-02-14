# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: calc.py
  Author 	: Paul Covert
  Date   	: 2025-02-11
  Version	: 1.1.0
  URL		: 
  Aim    	: Calculation routines for processing ADCP data
  ===============================================================================
"""

import numpy as np
import xarray as xr


def horizontal_velocity(ds):
    """Calculate horizontal current speed and direction based on
    northward and eastward current velocities."""
    ds["horiz_speed"] = (ds["LCNSAP01"] ** 2.0 + ds["LCEWAP01"] ** 2.0) ** 0.5
    ds["horiz_speed"].attrs = {
        "standard_name": "horizontal_sea_water_speed",
        "long_name": "horizontal sea water speed",
        "units": "m/s",
        "data_max": np.max(ds["horiz_speed"].values),
        "data_min": np.min(ds["horiz_speed"].values),
    }
    ds["horiz_heading"] = np.arctan2(ds["LCEWAP01"], ds["LCNSAP01"]) * 180.0 / np.pi
    ds["horiz_heading"] = (ds["horiz_heading"] + 360.0) % 360.0
    ds["horiz_heading"].attrs = {
        "standard_name": "horizontal_sea_water_heading",
        "long_name": "horizontal sea water heading",
        "units": "degree",
        "data_max": np.max(ds["horiz_heading"].values),
        "data_min": np.min(ds["horiz_heading"].values),
    }
    return ds
