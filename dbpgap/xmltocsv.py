#!/usr/bin/env python
# coding: utf-8

import os
import re
import xml.etree.ElementTree as ET
import pandas as pd

# lists for values
ids = []
date = []
totalcases = []
nulls = []
nmale = []
nfemale = []
repository = "dbGAP"

xmlpath = "data/"

# functions
def parse(xmlpath):
    phs = ET.parse(xmlpath)
    root = phs.getroot()
    return(root)

def mine(root):
    for child in root.findall('variable'):     
        #extract subid (version + p + consent group)
        if (child.attrib['var_name'] == "ID2"):
            idhere = child.attrib['id']
            ids.append(idhere)
            
            #extracting date from prolog here to avoid different nr of dates/ids
            datehere = root.attrib["date_created"]
            date.append(datehere)

            for stats in child.findall('total'): 
                #extract total
                for n in stats.iter('stat'):
                    totalhere = n.attrib["n"]
                    totalcases.append(totalhere)

                #extract nulls
                for n in stats.iter('stat'):
                    nullshere = n.attrib["nulls"]
                    nulls.append(nullshere)

                #extract n per sex
                for male in stats.iter('male'):
                    nmaleshere = male.text
                    nmale.append(nmaleshere)
                for female in stats.iter('female'):
                    nfemalehere = female.text
                    nfemale.append(nfemalehere)

#apply to xmls
for xml in os.listdir(xmlpath):
    if xml.endswith(xml):
        root = parse(xmlpath+xml)
        mine(root)

print(ids, totalcases, nulls,nmale,nfemale, date)


df = pd.DataFrame({'ID': ids, 'Female': nfemale, 'Male': nmale, 'Total': totalcases, 'Nulls': nulls, 'Date': date, 'Repository': "dbgap"})
df.to_csv("summary.csv")
