# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: consts.py
  Author 	: Paul Covert
  Date   	: 2025-02-17
  Version	: 1.5.0
  URL		: 
  Aim    	: Define constants for use in TCM analysis
  ===============================================================================
"""

import pandas as pd


# Define time intervals over which to extract TCM data
ANSE_DES_PILOTES_SLICE = slice(
    pd.to_datetime("2022-07-29T00:00:00"), 
    pd.to_datetime("2022-11-06T14:41:00")
)
LA_BALEINE_SLICE = slice(
    pd.to_datetime("2022-07-29T00:00:00"),
    pd.to_datetime("2022-11-06T17:01:00")
)
"""
CACOUNA_ILE_AUX_LIEVRES_1_TIMEBOUNDS = slice(
)
CACOUNA_ILE_AUX_LIEVRES_2_TIMEBOUNDS = slice(
)
RUPERT_TUGWELL_1_TIMEBOUNDS = slice(
)
RUPERT_TUGWELL_2_TIMEBOUNDS = slice(
)
QUADRA_MARINA_1_TIMEBOUNDS = slice(
)
QUADRA_MARINA_2_TIMEBOUNDS = slice(
)
"""
