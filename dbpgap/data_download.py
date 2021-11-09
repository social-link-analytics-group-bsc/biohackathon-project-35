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
mypath = 'home/bscuser/Biohack/BIOHACK/'

# List of all IDs (studies: phs#######)
all_dbgap_studies = ftp.nlst(source_dir)


# Subsample to test
subsample = all_dbgap_studies[1:5]


print(subsample)
len(all_dbgap_studies)

for f in subsample:
    
    # Phenotype list
    study_path = os.path.join(source_dir, f)
    study_versions = ftp.nlst(study_path)
    max_version = max(study_versions, key=extract_number)
    phenotypes_path = os.path.join(max_version, 'pheno_variable_summaries/')
    reports = ftp.nlst(phenotypes_path)
    
    # Save reports
    for pht in reports:
        # I have searched only 'var_report', becasue 'phenotype'
        # is not always in the name of the file (to improve)
        if pht.endswith('var_report.xml'):
            pht_id = os.path.basename(pht)
            with open(''+ ids+ "/" + pht_id, 'wb') as fh:
                ftp.retrbinary('RETR '+var_report, fh.write)

