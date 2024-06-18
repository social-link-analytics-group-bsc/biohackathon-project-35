#!/usr/bin/env python
# coding: utf-8
import csv
import re
import xml.etree.ElementTree as ET
from xml.etree.ElementTree import ParseError
import glob
import pandas as pd
import numpy as np


# lists for values
repository = "dbGAP"
xmlpath = "./data/"

# -----functions-----
def parse(xmlpath):
    phs = ET.parse(xmlpath)
    root = phs.getroot()
    return(root)

def parse_data(tree,dict_to_save,pre_tag=None):
    for c in tree.iter('sex'):
        for a in c:
            if pre_tag:
                dict_to_save.setdefault(pre_tag+a.tag, []).append(a.text)
            else:
                dict_to_save.setdefault(a.tag, []).append(a.text)


    for i in tree.iter('stat'):
        info = i.attrib
        for key in info:
            if pre_tag:
                dict_to_save.setdefault(pre_tag+key, []).append(info[key])
            else:
                dict_to_save.setdefault(key, []).append(info[key])


n = 0
good_files_count = 0
none_type_error_count = 0
empty_files_error_count = 0 
parsed_error_count = 0 

pattern = '(SEX|sex|gender|Gender)'

# ----- parse files -----
list_dict = list()
for file in glob.glob('./data/*.xml'):
    dict_data = dict()
    try:
        print(file)
        root = parse(file)

        # Get the date
        dict_data['date'] = root.attrib["date_created"]
        dict_data['dataset_id'] = root.attrib['dataset_id']

        dict_data['filename'] = file
        for child in root.iter('variable'):
            if re.search(pattern, child.attrib['var_name']):
                parse_data(child,dict_data)

            if child.attrib['var_name'] == 'SUBJECT_ID':
                parse_data(child,dict_data,pre_tag="subject_")

            if child.attrib['var_name'] == 'SAMPLE_ID':
                parse_data(child,dict_data,pre_tag="sample_")

        # Getting the max_value for each key if contains a list
        for k in dict_data:
            if isinstance(dict_data[k], list):
                dict_data[k] = max(dict_data[k])
        list_dict.append(dict_data)
    except ParseError: 
        pass

# ----- Write CSV -----
# list_keys = list()
# for dict_ in list_dict:
#     for k in dict_:
#         list_keys.append(k)
# keys = set(list_keys)
# print(keys)
# with open('summary_third.csv', 'w') as output_file:
#     dict_writer = csv.DictWriter(output_file, fieldnames=keys, delimiter=',')
#     dict_writer.writeheader()
#     dict_writer.writerows(list_dict)

# ----- As Dataframe -----
df = pd.DataFrame(list_dict)

# # data containing at least one count on male-female only for GENDER/SEX
# d1 = df.loc[~df.male.isna() | ~df.female.isna()]
# print("rows with male or female")
# print(len(d1))

# # data containing at least one count on male-female with SAMPLE and SUBJECT
# d1 = df.loc[~df.male.isna() | ~df.female.isna() 
#     | ~df.subject_male.isna() | ~df.subject_female.isna()
#     | ~df.sample_male.isna() | ~df.sample_female.isna()]
# print("adding the SAMPLE and SUBJECT")
# print(len(d1))

# # Filter out rows that do not make sense
# # Data where n<female + male
# good_rows = ((d1.n >= d1.male + d1.female) | 
#                   (d1.sample_n >= d1.sample_male + d1.sample_female) |
#                   (d1.subject_n >= d1.subject_male + d1.subject_female))
# d2=d1.loc[good_rows]
# print("Where n>= f+m")
# print(len(d2))

# Fill NA values for n male and female
df['n'] = pd.to_numeric(df['n'].fillna(df.sample_n).fillna(df.subject_n))
df['male'] = pd.to_numeric(df['male'].fillna(df.sample_male).fillna(df.subject_male).fillna(0))
df['female'] = pd.to_numeric(df['female'].fillna(df.sample_female).fillna(df.subject_female).fillna(0))
df['unknown'] = df.n - (df.male + df.female)
df = df.loc[df.unknown >=0] 

print(df.loc[df.unknown ==0].shape)

df.loc[:,['n','male', 'female','unknown', 'date', 'filename', 'dataset_id']].to_csv('summary_fourth.csv')
