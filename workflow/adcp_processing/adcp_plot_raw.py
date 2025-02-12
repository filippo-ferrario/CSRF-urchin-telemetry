# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: ADCP plot raw
  Author 	: Paul Covert
  Date   	: 2025-02-11
  Version	: 1.1.0
  URL		: 
  Aim    	: Plot processed position and velocity data from ADCP.  To be used
              as a preliminary check of data quality, continuity, etc.
  ===============================================================================
"""

import numpy as np
import xarray as xr
import matplotlib.pyplot as plt


def _plot_position(ds):
    """Plot position and orientation of the ADCP over the course
    of the entire deployment."""
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


def _plot_current(ds):
    """Plot horizontal and vertical speed and horizontal direction
    of the current during the entire deployment."""
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
    ds["horiz_speed"].where(ds["LCNSAP01"] <= 2).plot(ax=ax_horiz_speed)
    ds["horiz_heading"].where(ds["LCNSAP01"] <= 2).plot(ax=ax_horiz_heading)
    ds["LRZAAP01"].where(ds["LRZAAP01"] <= 2).plot(ax=ax_vert_velocity)

    ax_horiz_speed.yaxis.set_inverted(True)
    ax_horiz_heading.yaxis.set_inverted(True)
    ax_vert_velocity.yaxis.set_inverted(True)
    fig.suptitle(ds.attrs["platform"])

    return fig


def plot_raw(ds):
    return _plot_position(ds), _plot_current(ds)
