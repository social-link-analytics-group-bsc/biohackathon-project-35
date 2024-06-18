#!/usr/bin/env python
# coding: utf-8
import os
import csv
import re
import xml.etree.ElementTree as ET
from xml.etree.ElementTree import ParseError
import pandas as pd
import xml.etree as etree
import glob
import numpy as np

# lists for values
repository = "dbGAP"
xmlpath = "./data/"
# functions

def parse(xmlpath):
    phs = ET.parse(xmlpath)
    root = phs.getroot()
    return(root)


dict_data = dict()

def inc_dict(key):
    global dict_data
    try:
        dict_data[key] = dict_data[key]+1
    except KeyError:
        dict_data[key] = 1

for file in glob.glob('./data/*.xml'):
    try:
        root = parse(file)
        # Get the date

        for child in root.iter('subject_profile'):
            for c in child.iter():

                tag = c.tag
                inc_dict(tag)
                text = c.text
                inc_dict(text)
                attrib = c.attrib
                if isinstance(attrib, dict):
                    for i in attrib: 
                        inc_dict(i)            
                else:
                    inc_dict(attrib)
    except ParseError:
        pass

for k in dict_data:
    # if dict_data[k] > 100:
    print(k, dict_data[k])
