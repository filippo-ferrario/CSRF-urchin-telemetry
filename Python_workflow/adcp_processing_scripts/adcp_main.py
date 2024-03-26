#! /usr/bin/env python
# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: ADCP processing main
  Author 	: Paul Covert
  Date   	: 2024-03-22
  Version	: 
  URL		: 
  Aim    	: Handle processing of ADCP data
  ===============================================================================
"""

import sys
import os
import xarray as xr
import matplotlib.pyplot as plt
import pycurrents_ADCP_processing as adcp


def _adcp_rupert():
    """Control script for processing ADCP data from the
    Prince Rupert site"""
    
    pass
    
    
def _adcp_quadra():
    """Control script for processing ADCP data from the 
    Quadra Island site"""
    
    pass
    
    
def _adcp_bic():
    """Control script for processing ADCP data from the 
    Bic site"""
    
    pass
    
    
def _adcp_cacouna():
    """Control script for processing ADCP data from the 
    Cacouna site"""
    
    pass
    
    
def main():
    """Initiate processing of ADCP data from all four sites"""
    _adcp_bic()
    _adcp_cacouna()
    _adcp_rupert()
    _adcp_quadra()
    
    return
    

if __name__ == '__main__':
    sys.exit(main())
