# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: io.py
  Author 	: Paul Covert
  Date   	: 2025-02-14
  Version	: 1.0.0
  URL		: 
  Aim    	: Input / Output routines for TCM files
  ===============================================================================
"""

import pandas as pd


def read_csv(filepath_or_buffer):
    """Read tilt current meter (TCM) csv files.

    Both current and temperature files are supported.  For ease of
    readability, the column names are renamed.  Speed and velocity,
    which are in units of cm/s in the TCM current files, are converted
    to m/s.

    Parameters
    ----------
    filepath_or_buffer : str, path object or file-like object

    Returns
    -------
    df : time-indexed pandas DataFrame
        Water current DataFrame contains ``time``, ``speed``, ``dir``,
        vel_N``, and ``vel_E`` columns.  Water temperature DataFrame
        contains ``time`` and ``temp`` columns.

    """
    df = pd.read_csv(filepath_or_buffer)
    if df.columns.values[1] == "Speed (cm/s)":
        df.rename(
            columns={
                "ISO 8601 Time": "time",
                "Speed (cm/s)": "speed",
                "Heading (degrees)": "dir",
                "Velocity-N (cm/s)": "velocity_north",
                "Velocity-E (cm/s)": "velocity_east",
            },
            inplace=True,
        )
        df["speed"] = df["speed"] / 100.0
        df["velocity_north"] = df["velocity_north"] / 100.0
        df["velocity_east"] = df["velocity_east"] / 100.0
    elif df.columns.values[1] == "Temperature (C)":
        df.rename(
            columns={
                "ISO 8601 Time": "time",
                "Temperature (C)": "xducer_temp",
            },
            inplace=True,
        )
    else:
        pass
    df["time"] = pd.to_datetime(df["time"])
    df.set_index("time", inplace=True)
    return df
