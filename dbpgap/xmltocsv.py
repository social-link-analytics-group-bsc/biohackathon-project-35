#!/usr/bin/env python
# coding: utf-8

import os
import re
import xml.etree.ElementTree as ET
from xml.etree.ElementTree import ParseError
import pandas as pd
import lxml.etree as etree
import glob
# lists for values
ids = []
date = []
totalcases = []
nulls = []
nmale = []
nfemale = []
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

#currently doesn't work 
def minetotal(root):
    for child in root.findall('*'):
        for c in child.find("*"):
        # print(child)
            print(c.tag, c.attrib, c.text)
        #for total in child.findall('total'):
        #    #for n in stats.find('stat'):
        #    print(total.attrib)
        #    #for n in total.findall('stat'):
        #    #    print(n.attrib)
        #    #    totalhere = n.attrib["n"]
        #    #   totalcases.append(totalhere)
    
#parse and retrieve dates
n = 0
for file in glob.glob('./data/*.xml'):
    # context = etree.iterparse(file, tag='*', events = ('end', ))
    # print(context)
    try:
        root = parse(file)
        try:
            print(file)
            for child in root.iter():
                for c in child.findall('sex'):
                    for i in c.iter():
                        print(i.tag, i.attrib, i.text)
                    # print(c.tag, c.attrib, c.text)
                # for c in child.findall('male'):
                #     print(c.tag, c.attrib, c.text)
                # for c in child.findall('female'):
                #     print(c.tag, c.attrib, c.text)

            n+=1
        except TypeError:
            pass

            # print(child.tag, child.attrib, child.text)
    except ParseError: 
        pass
    
        #try:
        #    root = parse(xmlpath+xml)
        #except:
        #    date.append("NA")
        #    continue
            
        #try:
        #    minedate(root)
        #except:
        #    date.append("NA")
            
        ##works up until this function:
    # minetotal(root)
    if n == 10:
        break


#df = pd.DataFrame({'Study_ids': ids, 'Date': date, 'Total': totalcases, 'Nulls': nulls, 'Female': nfemale, 'Male': nmale, 'Repository': "dbgap"})
#df.to_csv("summary.csv")
