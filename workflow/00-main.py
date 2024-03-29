#! /usr/bin/env python
# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: Master Main file
  Author 	: Paul Covert
  Date   	: 2024-03-22
  Version	: 
  URL		: 
  Aim    	: Describe the structure of the Python_workflow directory and how
              it fits in with the larger R-based workflow.
  ===============================================================================

  Envision that this directory will contain the main scripts that control the
  ADCP processing sequence.  This includes:
    * creation of necessary directory structure;
    * pre-processing of ADCP data;
    * processing of ADCP data;
    * creation of descriptive plots.
    
  The processing scripts will be designed to be callable from R.  But, should
  they be called from R, specifically, from 00-main.R?  Pros are that the 
  functions contained here could be integrated into the overall data processing 
  hierarchy.  Cons are that an environment containing Python and the necessary 
  libraries will need to be created for anyone executing 00-main.R.  Much of 
  this can be automated, but some user-guided installing will be necessary.
  
  One possible solution is to add an adcp_check function within 00-main.R.  This 
  function would raise an error if the processed ADCP output files did not exist, 
  and prompt the user to either manually or automatically run the Python scripts 
  to create those files, if they are needed.
"""
