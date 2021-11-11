#!/usr/bin/env python
# coding: utf-8
import os
import re
import xml.etree.ElementTree as ET
from xml.etree.ElementTree import ParseError
import pandas as pd
import xml.etree as etree
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
            print(file)
            # sex
            for child in root.iter():
                for c in child.findall('sex'):
                    for i in c.iter():

                        if i.tag == 'male':
                            #print(i.tag, i.text)
                            nmale = int(i.text)
                            maxmale.append(nmale)

                        if i.tag == 'female':
                            nfemale = int(i.text)
                            maxfemale.append(nfemale)
            # total cases 
            for child in root.iter():
                for c in child.findall('stat'):
                    for i in c.iter():
                        ntotal = i.attrib['n']
                        ntotal = int(ntotal)
                        maxn.append(ntotal)

            # null cases
            for child in root.iter():
                for c in child.findall('stat'):
                    for i in c.iter():
                        nulltotal = i.attrib['nulls']
                        nulltotal = int(nulltotal)
                        maxnull.append(nulltotal)
            n+=1
            try:
                print(max(maxmale))
                print(max(maxfemale))
                print(max(maxn))
                #print(max(maxnull))
                good_files_count +=1
            except:
                empty_files_error_count +=1
                print("NA")
        except TypeError:
            none_type_error_count  +=1
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
        parsed_error_count +=1

print('Total of functional files: {}'.format(good_files_count))
print('Total of ParsingError files: {}'.format(parsed_error_count))
print('Total of empty results files: {}'.format(empty_files_error_count))
print('Total of TypeError files: {}'.format(none_type_error_count))
