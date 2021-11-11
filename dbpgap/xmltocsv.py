#!/usr/bin/env python
# coding: utf-8
import os
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

date = []
filenames = []
females = []
males = []
total = []
nulls = []

good_files_count = 0
none_type_error_count = 0
empty_files_error_count = 0 
parsed_error_count = 0 
for file in glob.glob('./data/*.xml'):
    maxmale = []
    maxfemale = []
    maxn = []
    maxnull = []
    # context = etree.iterparse(file, tag='*', events = ('end', ))
    # print(context)
    try:
        root = parse(file)
        try:
            minedate(root)
        except:
            date.append(NA)
        try:
            #print(file)
            filenames.append(file)
            # sex
            try:
                for child in root.iter():
                    for c in child.findall('sex'):
                        for i in c.iter():

                            if i.tag == 'male':
                                #print(i.tag, i.text)
                                nmale = int(i.text)
                                maxmale.append(nmale)
                            else:
                                if i.tag == 'female':
                                    nfemale = int(i.text)
                                    maxfemale.append(nfemale)
                                    #print(maxfemale)

            except:
                maxfemale.append(np.nan)
                maxmale.append(np.nan)
            
            # total cases 
            try:
                for child in root.iter():
                    for c in child.findall('stat'):
                        for i in c.iter():
                            ntotal = i.attrib['n']
                            ntotal = int(ntotal)
                            maxn.append(ntotal)
            except:
              maxn.append(np.nan)  

            # null cases
            try:
                for child in root.iter():
                    for c in child.findall('stat'):
                        for i in c.iter():
                            nulltotal = i.attrib['nulls']
                            nulltotal = int(nulltotal)
                            maxnull.append(nulltotal)
            except:
                maxnull.append(np.nan)
            n+=1
            try:
        
                mm = np.nanmax(maxmale)
                males.append(mm)


                #print(max(maxmale))
                #print(max(maxfemale))
                #print(max(maxn))
                #print(max(maxnull))
                good_files_count +=1
            except:
                males.append("NA")
                empty_files_error_count +=1

            try:
                mfm = np.nanmax(maxfemale)
                females.append(mfm)
                good_files_count +=1

            except:
                females.append("NA")
                empty_files_error_count +=1

            try:
                mn = np.nanmax(maxn)
                total.append(mn)
                good_files_count +=1

            except:
                total.append("NA")
                empty_files_error_count +=1

            try:
                mnull = np.nanmax(maxnull)
                nulls.append(mnull)
                good_files_count +=1

            except:
                nulls.append("NA")
                empty_files_error_count +=1


        except TypeError:
            none_type_error_count  +=1
            pass
            # print(child.tag, child.attrib, child.text)

    except ParseError: 
        pass

        parsed_error_count +=1


        #try:
        #    root = parse(xmlpath+xml)
        #except:
        #    date.append("NA")
        #    continue
            
        #try:
        #    minedate(root)
        #except:
        #    date.append("NA")

print('Total of functional files: {}'.format(good_files_count))
print('Total of ParsingError files: {}'.format(parsed_error_count))
print('Total of empty results files: {}'.format(empty_files_error_count))
print('Total of TypeError files: {}'.format(none_type_error_count))

print(len(filenames))
print(len(males))
print(len(females))
print(len(total))
print(len(nulls))
print(len(date))

#print(date)
df = pd.DataFrame({'dbgap_stable_id': filenames, 'male': males, 'female': females, 'unkown': nulls, 'total': total, 'repository': "dbgap"})
df.to_csv("summary.csv")

