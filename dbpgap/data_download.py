#!/usr/bin/env python
# coding: utf-8

import os
import re
import fnmatch
from ftplib import FTP


# init ftp connection
ftp = FTP('ftp.ncbi.nlm.nih.gov', timeout=None)
ftp.login()


# Get last version study 
def extract_number(d):
    s = re.findall("\d+$",d)
    return (int(s[0]) if s else -1,d)

source_dir = '/dbgap/studies/' 
mypath = './data/'
if not os.path.exists(mypath):
    os.makedirs(mypath)


# List of all IDs (studies: phs#######)
all_dbgap_studies = ftp.nlst(source_dir)

print('Len of dbgap studies: {}'.format(len(all_dbgap_studies)))

# Subsample to test
# subsample = all_dbgap_studies[1:20]



for f in all_dbgap_studies:
    if f.startwith('phs'):
        study_id = os.path.basename(f) 
        # if not os.path.exists(study_id):
        #     os.makedirs(study_id)

        # Phenotype list
        study_path = os.path.join(source_dir, f)
        study_versions = ftp.nlst(study_path)
        max_version = max(study_versions, key=extract_number)
        print(max_version)
        phenotypes_path = os.path.join(max_version, 'pheno_variable_summaries/')
        reports = ftp.nlst(phenotypes_path)
        
        # Save reports
        for pht in reports:
            # I have searched only 'var_report', because 'phenotype'
            # is not always in the name of the file (to improve)
            if pht.endswith('var_report.xml'):
                print('Found a var_report.xml')
                with open(mypath + "/" + study_id, 'wb') as fh:
                    print("dl the file into: {}".format(mypath))
                    ftp.retrbinary('RETR '+pht, fh.write)
                break

