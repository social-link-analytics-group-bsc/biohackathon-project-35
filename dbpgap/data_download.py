#!/usr/bin/env python
# coding: utf-8

import os
import re
import fnmatch
from ftplib import FTP
import ftplib






def get_all_studies(source_dir, ftp_connection):
    """
    Get the study folder for all the phs
    params:
    source_dir str(): directory were the studies are stored
    ftp_connection ftplib obj(): connection to the ftp server

    return:
    list_all_dbgap_studies list(): list of all the db_gap studies folders
    """
    list_all_dbgap_studies = ftp_connection.nlst(source_dir)
    # Be sure to select the right phs
    list_all_dbgap_studies = [x for x in list_all_dbgap_studies if 'phs' in x]
    print('Len of dbgap studies: {}'.format(len(list_all_dbgap_studies)))
    return list_all_dbgap_studies

def create_study_path(source_dir, phs_name):
    """
    Use the name and create the full path from the ftp
    """
    def extract_number(d):
        """ Get last version study """
        s = re.findall("\d+$",d)
        return (int(s[0]) if s else -1,d)

    study_path = os.path.join(source_dir, phs_name)
    study_versions = ftp.nlst(study_path)
    max_version = max(study_versions, key=extract_number)
    print(max_version)
    phenotypes_path = os.path.join(max_version, 'pheno_variable_summaries/')
    return phenotypes_path

    :


if __name__ == "__main__":

    source_dir = '/dbgap/studies/' 
    mypath = './data/'
    if not os.path.exists(mypath):
        os.makedirs(mypath)


    # init ftp connection
    print('Establishing connection')
    ftp = FTP('ftp.ncbi.nlm.nih.gov', timeout=None)
    ftp.login()
    print('Connection established')

    all_studies_list = get_all_studies(source_dir, ftp)

    phenotypes_path_list = [create_study_path(source_dir, x) for x in all_studies_list]

    try:
        reports = ftp.nlst(phenotypes_path)
    
        # Save reports
        for pht in reports:
            # I have searched only 'var_report', because 'phenotype'
            # is not always in the name of the file (to improve)
            if 'var_report' in pht:
                filename = os.path.basename(pht)
                print('{}'.format(filename))
                with open(mypath+ "/" +filename, 'wb') as fh:
                    print("dl the file into: {}".format(filename))
                    ftp.retrbinary('RETR '+pht, fh.write)
                break

    except ftplib.error_temp:
        print('Did not found the file')
        pass
