#!/usr/bin/env python
# coding: utf-8

#work in progress
# still need to loop through the files, build csv

import os
import re
import xml.etree.ElementTree as ET
import pandas as pd


#parsing -starting by a single file
phs = ET.parse('data/phs000001.v3.pht000370.v2.p1.adverse.var_report.xml')
root = phs.getroot()

#print(root.tag, root.attrib)
parentid = root.attrib['study_id']
repository = "dbGAP"
date = root.attrib["date_created"]
print(parentid, repository, date)

#dataframe to store values
df = pd.DataFrame() 

for child in root.findall('variable'):
    if (child.attrib['var_name'] == "ID2"):
        id2 = child.attrib['id']
        tocsv["id"].append(id2)
        print(id2)
        for stats in child.findall('total'):
            
            #extract total
            for n in stats.iter('stat'):
                totalcases = n.attrib["n"]
                print(totalcases)
                
            #extract nulls
            for n in stats.iter('stat'):
                nulls = n.attrib["nulls"]
                print(nulls)
                
            #extract n per sex
            for male in stats.iter('male'):
                nmale = male.text
                print(nmale)
            for female in stats.iter('female'):
                nfemale = female.text
                print(nfemale)
        