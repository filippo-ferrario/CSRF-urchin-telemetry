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


def horizontal_velocity(u, v):
    """Calculate horizontal current speed and direction based on
    northward and eastward current velocities.
    
    Parameters
    ----------
    u : xarray DataArray
        northward current velocities (m/s)
    v : xarray DataArray
        eastward current velocities (m/s)
        
    Returns
    -------
    s : xarray DataArray
        horizontal current speed (m/s)
    theta : xarray DataArray
        horizontal current direction (deg)
    
    """
    s = (u ** 2.0 + v ** 2.0) ** 0.5
    s.attrs = {
        "standard_name": "horizontal_sea_water_speed",
        "long_name": "horizontal sea water speed",
        "units": "m/s",
        "data_max": np.max(u.values),
        "data_min": np.min(u.values),
    }
    theta = np.arctan2(v, u) * 180.0 / np.pi
    theta = (theta + 360.0) % 360.0
    theta.attrs = {
        "standard_name": "horizontal_sea_water_heading",
        "long_name": "horizontal sea water heading",
        "units": "degree",
        "data_max": np.max(theta.values),
        "data_min": np.min(theta.values),
    }
    return s, theta
