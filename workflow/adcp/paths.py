# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: paths.py
  Author 	: Paul Covert
  Date   	: 2025-02-17
  Version	: 1.5.0
  URL		: 
  Aim    	: Define relative path constants for all ADCP files.  Also
              provide a utility function to return full path for a list
              of ADCP files
  ===============================================================================
"""

from pathlib import Path


# Relative path constants
BIC_ANSE_DES_PILOTES = Path(
    "raw_data_downloads_bic_2022",
    "sensors_anse_des_pilotes",
    "ADCP",
    "MADCP_2022098_AnsePilotes_19235_VEL.nc",
)
BIC_LA_BALEINE = Path(
    "raw_data_downloads_bic_2022",
    "sensors_la_baleine",
    "ADCP",
    "MADCP_2022098_LaBaleine_8601_VEL.nc",
)
CACOUNA_ILE_AUX_LIEVRES_1 = Path(
    "raw_data_downloads_cacouna_2022",
    "ADCP_between_2_sites",
    "MADCP_2022098_IleauxLievres1_24788_VEL.nc",
)
CACOUNA_ILE_AUX_LIEVRES_2 = Path(
    "raw_data_downloads_cacouna_2022",
    "ADCP_between_2_sites",
    "MADCP_2022098_IleauxLievres2_19238_VEL.nc",
)
RUPERT_TUGWELL_1 = Path(
    "raw_data_downloads_prince_rupert_2023",
    "sensors_tugwell1",
    "ADCP",
    "MADCP_2023098_Tugwell1_24788_VEL.nc",
)
RUPERT_TUGWELL_2 = Path(
    "raw_data_downloads_prince_rupert_2023",
    "sensors_tugwell2",
    "ADCP",
    "MADCP_2023098_Tugwell2_19238_VEL.nc",
)
QUADRA_MARINA_1 = Path(
    "raw_data_downloads_quadra_2023",
    "sensors_marina1",
    "ADCP",
    "MADCP_2023098_Marina1_8601_VEL.nc",
)
QUADRA_MARINA_2 = Path(
    "raw_data_downloads_quadra_2023",
    "sensors_marina2",
    "ADCP",
    "MADCP_2023098_Marina2_19235_VEL.nc",
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
