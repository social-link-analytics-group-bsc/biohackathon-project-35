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

def minedate(root):
    datehere = root.attrib["date_created"]
    date.append(datehere)

#currently doesn't work 
def minetotal(root):
    for child in root.findall('variable'): 
        for total in child.findall('total'):
            #for n in stats.find('stat'):
            print(total.attrib)
            #for n in total.findall('stat'):
            #    print(n.attrib)
            #    totalhere = n.attrib["n"]
            #   totalcases.append(totalhere)
    
#parse and retrieve dates
for xml in os.listdir(xmlpath):
    ids.append(os.path.splitext(xml))
    if xml.endswith(xml):
        
        try:
            root = parse(xmlpath+xml)
        except:
            date.append("NA")
            continue
            
        try:
            minedate(root)
        except:
            date.append("NA")
            
        #works up until this function:
        minetotal(root)


#summary
print(len(ids)) #ok
print(len(date)) #ok w/ some error handling 
print(len(totalcases)) # empty at the moment
print(len(nulls)) # empty at the moment
print(len(nfemale)) # empty at the moment
print(len(nmale)) # empty at the moment


#df = pd.DataFrame({'Study_ids': ids, 'Date': date, 'Total': totalcases, 'Nulls': nulls, 'Female': nfemale, 'Male': nmale, 'Repository': "dbgap"})
#df.to_csv("summary.csv")