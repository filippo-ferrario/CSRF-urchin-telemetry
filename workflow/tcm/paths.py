# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: consts.py
  Author 	: Paul Covert
  Date   	: 2025-02-26
  Version	: 1.6.0
  URL		: 
  Aim    	: Define relative path constants for all TCM files.  Also
              provide a utility function to return full path for a list
              of TCM files.
  ===============================================================================
"""

from pathlib import Path


# Relative path constants
BIC_ANSE_DES_PILOTES = Path(
    "raw_data_downloads_bic_2022",
    "sensors_anse_des_pilotes",
    "TCM",
    "2206004_Bic1_(0)_Current.csv",
)
BIC_LA_BALEINE = Path(
    "raw_data_downloads_bic_2022",
    "sensors_la_baleine",
    "TCM",
    "2206005_Bic2_(0)_Current.csv",
)
CACOUNA_ILE_AUX_LIEVRES_1 = Path(
    "raw_data_downloads_cacouna_2022",
    "sensors_southwest",
    "TCM",
    "2206002_IleauxLievres1_(0)_Current.csv",
)
CACOUNA_ILE_AUX_LIEVRES_2 = Path(
    "raw_data_downloads_cacouna_2022",
    "sensors_northeast",
    "TCM",
    "2206003_IleauxLievres2_(0)_Current.csv",
)
RUPERT_TUGWELL_1 = Path(
    "raw_data_downloads_prince_rupert_2023",
    "sensors_tugwell1",
    "TCM",
    "2206002_PrinceRupert1_(0)_Current.csv"
)
RUPERT_TUGWELL_2 = Path(
    "raw_data_downloads_prince_rupert_2023",
    "sensors_tugwell2",
    "TCM",
    "2206003_PrinceRupert2_(0)_Current.csv"
)
QUADRA_MARINA_1 = Path(
    "raw_data_downloads_quadra_2023",
    "sensors_marina1",
    "TCM",
    "2206004_Quadra1_(0)_Current.csv"
)
QUADRA_MARINA_2 = Path(
    "raw_data_downloads_quadra_2023",
    "sensors_marina2",
    "TCM",
    "2206005_Quadra2_(0)_Current.csv"
)



# function to return full paths
def get(location: str, root="."):
    pathdict = {
        "all": [
            BIC_ANSE_DES_PILOTES,
            BIC_LA_BALEINE,
            CACOUNA_ILE_AUX_LIEVRES_1,
            CACOUNA_ILE_AUX_LIEVRES_2,
            RUPERT_TUGWELL_1,
            RUPERT_TUGWELL_2,
            QUADRA_MARINA_1,
            QUADRA_MARINA_2,
        ],
        "qc": [
            BIC_ANSE_DES_PILOTES,
            BIC_LA_BALEINE,
            CACOUNA_ILE_AUX_LIEVRES_1,
            CACOUNA_ILE_AUX_LIEVRES_2,
        ],
        "bc": [RUPERT_TUGWELL_1, RUPERT_TUGWELL_2, QUADRA_MARINA_1, QUADRA_MARINA_2],
        "bic": [BIC_ANSE_DES_PILOTES, BIC_LA_BALEINE],
        "cacouna": [CACOUNA_ILE_AUX_LIEVRES_1, CACOUNA_ILE_AUX_LIEVRES_2],
        "rupert": [RUPERT_TUGWELL_1, RUPERT_TUGWELL_2],
        "quadra": [QUADRA_MARINA_1, QUADRA_MARINA_2],
        "anse_des_pilotes": [BIC_ANSE_DES_PILOTES],
        "la_baleine": [BIC_LA_BALEINE],
        "ile_aux_lievres_1": [CACOUNA_ILE_AUX_LIEVRES_1],
        "ile_aux_lievres_2": [CACOUNA_ILE_AUX_LIEVRES_2],
        "tugwell_1": [RUPERT_TUGWELL_1],
        "tugwell_2": [RUPERT_TUGWELL_2],
        "marina_1": [QUADRA_MARINA_1],
        "marina_2": [QUADRA_MARINA_2],
    }
    pathlist = [Path(root, p) for p in pathdict[location]]
    if len(pathlist) == 1:
        pathlist = pathlist[0]
    return pathlist
