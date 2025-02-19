# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: plot.py
  Author 	: Paul Covert
  Date   	: 2025-02-12
  Version	: 1.5.0
  URL		: 
  Aim    	: Create plots of bottom current at each site
  ===============================================================================
"""

import numpy as np
import matplotlib.pyplot as plt


def _position(ds):
    """Plot position and orientation of the ADCP over the course
    of the entire deployment."""
    fig, (ax_depth, ax_heading, ax_pitch, ax_roll) = plt.subplots(
        ncols=1, nrows=4, sharex=True, figsize=(6, 9), constrained_layout=True
    )
    ds["xducer_depth"].plot(ax=ax_depth)
    ds["xducer_heading"].plot(ax=ax_heading)
    ds["xducer_pitch"].plot(ax=ax_pitch)
    ds["xducer_roll"].plot(ax=ax_roll)

    ax_depth.set_xlabel("")
    ax_heading.set_xlabel("")
    ax_pitch.set_xlabel("")
    fig.suptitle(ds.attrs["platform"])
    return fig


def _current(ds):
    """Plot northward, eastward and upward velocities of the current during
    the entire deployment."""
    fig, (ax_north, ax_east, ax_up) = plt.subplots(
        ncols=1, nrows=3, sharex=True, figsize=(6, 9), constrained_layout=True
    )
    ds["velocity_north"].where(ds["velocity_north_qc"] <= 2).plot(ax=ax_north)
    ds["velocity_east"].where(ds["velocity_east_qc"] <= 2).plot(ax=ax_east)
    ds["velocity_up"].where(ds["velocity_up_qc"] <= 2).plot(ax=ax_up)

    ax_north.set_xlabel("")
    ax_north.yaxis.set_inverted(True)
    ax_east.set_xlabel("")
    ax_east.yaxis.set_inverted(True)
    ax_up.yaxis.set_inverted(True)
    fig.suptitle(ds.attrs["platform"])
    return fig


def raw(ds):
    """Wrapper to return figures of both raw position and raw
    current measurements."""
    return _position(ds), _current(ds)


def timeseries(ds, depth=None):
    """Plot current speed timeseries."""

    # default action is to plot bottom current
    if depth == None:
        depth = np.max(ds["depth"])

    # create 1d dataset and drop all times with NaN values
    ds_1d = ds.sel(depth=depth)
    ds_1d = ds_1d.dropna("time")

    fig, (ax_speed, ax_heading) = plt.subplots(
        ncols=1, nrows=2, sharex=True, constrained_layout=True
    )
    ds_1d["speed"].plot(ax=ax_speed)
    ds_1d["dir"].plot(ax=ax_heading)
    fig.suptitle("{}: {:.2f}m".format(ds_1d.attrs["platform"], depth))
    return fig


def histogram(ds, depth=None):
    """Plot current speed histogram."""

    # default action is to plot bottom current
    if depth == None:
        depth = np.max(ds["depth"])

    # create 1d dataset and drop all times with NaN values
    ds_1d = ds.sel(depth=depth)
    ds_1d = ds_1d.dropna("time")

    fig, (ax_speed, ax_heading) = plt.subplots(
        ncols=2, nrows=1, sharey=True, constrained_layout=True
    )
    ds_1d["speed"].plot.hist(ax=ax_speed, bins=25)
    ds_1d["dir"].plot.hist(ax=ax_heading, bins=25)
    fig.suptitle("{}: {:.2f}m".format(ds_1d.attrs["platform"], depth))
    return fig


def windrose(ds, depth=None):
    """Plot a windrose of the horizontal current speeds at the chosen depth."""
    from windrose import WindroseAxes

    # default action is to plot bottom current
    if depth == None:
        depth = np.max(ds["depth"])

    # create 1d dataset and drop all times with NaN values
    ds_1d = ds.sel(depth=depth)
    ds_1d = ds_1d.dropna("time")

    fig = plt.figure(figsize=(6, 6))
    ax_rose = WindroseAxes.from_ax(fig=fig)
    ax_rose.bar(
        ds_1d["dir"].values,
        ds_1d["speed"].values,
        nsector=36,
        bins=(0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0),
        normed=True,
        opening=1,
        edgecolor="white",
    )
    y_ticks = [0, 5, 10, 15, 20, 22.5]
    y_ticklabels = ["0", "5", "10", "15", "20", ""]
    ax_rose.set_rgrids(y_ticks, y_ticklabels)
    ax_rose.set_legend(title=r"m s$^{-1}$")
    fig.suptitle("{}: {:.2f}m".format(ds_1d.attrs["platform"], depth))
    return fig
