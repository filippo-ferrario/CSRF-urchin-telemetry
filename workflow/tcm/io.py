# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: io.py
  Author 	: Paul Covert
  Date   	: 2025-02-14
  Version	: 1.0.0a
  URL		: 
  Aim    	: Input / Output routines for TCM files
  ===============================================================================
"""

import pandas as pd


def read_csv(filepath_or_buffer):
    df = pd.read_csv(filepath_or_buffer)
    df["ISO 8601 Time"] = pd.to_datetime(df["ISO 8601 Time"])
    df.set_index("ISO 8601 Time", inplace=True)
    return df
    