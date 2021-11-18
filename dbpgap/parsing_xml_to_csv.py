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

def minedate(root):
    datehere = root.attrib["date_created"]
    date.append(datehere)

n = 0

good_files_count = 0
none_type_error_count = 0
empty_files_error_count = 0 
parsed_error_count = 0 


pattern = '(SEX|sex|gender|Gender)'

n = 0
list_dict = list()
for file in glob.glob('./data/*.xml'):
    dict_data = dict()
    try:
        print(file)
        root = parse(file)
        # Get the date

        dict_data['date'] = root.attrib["date_created"]
        # date.append(NA)
        dict_data['filename'] = file
        for child in root.iter('variable'):
            if re.search(pattern, child.attrib['var_name']):
                for c in child.iter('sex'):
                    for a in c:
                        dict_data.setdefault(a.tag, []).append(a.text)



        
                for i in child.iter('stat'):
                    info = i.attrib
                    for key in info:
                        dict_data.setdefault(key, []).append(info[key])
        # Getting the max_value for each key if contains a list
        for k in dict_data:
            if isinstance(dict_data[k], list):
                dict_data[k] = max(dict_data[k])
        list_dict.append(dict_data)
    except ParseError: 
        pass

list_keys = list()
for dict_ in list_dict:
    for k in dict_:
        list_keys.append(k)
keys = set(list_keys)
print(keys)
with open('summary_second.csv', 'w') as output_file:
    dict_writer = csv.DictWriter(output_file, fieldnames=keys, delimiter=',')
    dict_writer.writeheader()
    dict_writer.writerows(list_dict)
