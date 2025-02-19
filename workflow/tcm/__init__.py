# -*- coding: utf-8 -*-
"""
  ===============================================================================
  Name   	: __init__.py
  Author 	: Paul Covert
  Date   	: 2025-02-12
  Version	: 1.0.1
  URL		: 
  Aim    	: Indicates to Python parser that it is okay to import
              variable and functions from other Python files within
              the directory.
  ===============================================================================
"""
from . import io, paths, consts
from .io import read_csv
