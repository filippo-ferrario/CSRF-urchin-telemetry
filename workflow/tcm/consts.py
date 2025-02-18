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

from pandas import to_datetime


# Define time intervals over which to extract TCM data
BIC_ANSE_DES_PILOTES_TIMEBOUNDS = [to_datetime("2022-01-01"), to_datetime("2022-01-01")]
BIC_LA_BALEINE_TIMEBOUNDS = [to_datetime("2022-01-01"), to_datetime("2022-01-01")]
CACOUNA_ILE_AUX_LIEVRES_1_TIMEBOUNDS = [
    to_datetime("2022-01-01"),
    to_datetime("2022-01-01"),
]
CACOUNA_ILE_AUX_LIEVRES_2_TIMEBOUNDS = [
    to_datetime("2022-01-01"),
    to_datetime("2022-01-01"),
]
"""
RUPERT_TUGWELL_1_TIMEBOUNDS = [
    to_datetime(), to_datetime
]
RUPERT_TUGWELL_2_TIMEBOUNDS = [
    to_datetime(), to_datetime
]
QUADRA_MARINA_1_TIMEBOUNDS = [
    to_datetime(), to_datetime
]
QUADRA_MARINA_2_TIMEBOUNDS = [
    to_datetime(), to_datetime
]
"""
