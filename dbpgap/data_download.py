#!/usr/bin/env python
# coding: utf-8

import os
import re
import fnmatch
from ftplib import FTP
import ftplib
import pickle
import time
import glob

def load_temp_list(infile, type_save=None):
    if type_save == 'pickle':
        with open(infile, 'rb') as fp:
            return pickle.load(fp) 

    else:
        list_to_return = list()
        try:
            with open(infile, 'r') as fp:
                for line in fp:

                  stripped_line = line.strip()
                  list_to_return.append(stripped_line)
        except FileNotFoundError:
            pass
        return list_to_return

def save_temp_list(info, outfile, type_save=None):
    if type_save == 'pickle':
        with open(outfile, 'wb') as fp:
            pickle.dump(info, fp)
    else:
        file_object = open(outfile, 'a')
         
        file_object.write(info + '\n')
         
        # Close the file
        file_object.close()


def flatten(s):
    '''Recursively flatten any sequence of objects
    '''
    results = list()
    if non_str_seq(s):
        for each in s:
            results.extend(flatten(each))
    else:
        results.append(s)
    return results

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
    dict_to_return = dict()
    for x in list_all_dbgap_studies:
        if 'phs' in x:
            id_x = x.split('/')[-1]
            dict_to_return[id_x] = x
    # list_all_dbgap_studies = [x for x in list_all_dbgap_studies if 'phs' in x]
    print('Len of dbgap studies: {}'.format(len(dict_to_return)))
    return dict_to_return
    # return list(list_all_dbgap_studies)

def create_study_path(source_dir, phs_name, ftp):
    """
    Use the name and create the full path from the ftp
    """
    def extract_number(d):
        """ Get last version study """
        s = re.findall("\d+$",d)
        return (int(s[0]) if s else -1,d)

    study_path = os.path.join(source_dir, phs_name)

    finished = False
    time_sec = 1
    while (finished is False):
        if ftp is None:
            print("Connecting...")
            ftp = FTP('ftp.ncbi.nlm.nih.gov', timeout=None)
            ftp.login()

        try:
            study_versions = ftp.nlst(study_path)
            print("Done")
            finished = True
        except Exception as e:
            ftp.close()
            ftp = None
            time_sec +=1
            print(f"Transfer failed: {e}, will retry in {time_sec} seconds...")
            time.sleep(time_sec)
    max_version = max(study_versions, key=extract_number)
    phenotypes_path = os.path.join(max_version, 'pheno_variable_summaries/')
    return phenotypes_path


def get_files_to_dl(phenotypes_path, ftp):
    files_to_dl_list = list()
    finished = False
    time_sec = 1
    while (finished is False):

        if ftp is None:
            print("Connecting...")
            ftp = FTP('ftp.ncbi.nlm.nih.gov', timeout=None)
            ftp.login()

        try:
            reports = ftp.nlst(phenotypes_path)
            finished = True
        except ftplib.error_temp:  #TODO create a list that get which file are not found
            print('Did not found the file for: {}'.format(phenotypes_path))
            reports = None
            break
        except Exception as e:
            print(e)  
            ftp.close()
            ftp = None
            time_sec +=1
            print(f"Transfer failed: {e}, will retry in {time_sec} seconds...")
            time.sleep(time_sec)

    # Save reports
    if reports:
        for pht in reports:
            # I have searched only 'var_report', because 'phenotype'
            # is not always in the name of the file (to improve)
            if 'var_report' in pht:
                files_to_dl_list.append(pht)

                save_temp_list(pht, './var_report_list_temp')
    return files_to_dl_list


def write_file_data(infile, outfile, ftp):
    finished = False
    time_sec = 1
    while (finished is False):

        if ftp is None:
            print("Connecting...")
            ftp = FTP('ftp.ncbi.nlm.nih.gov', timeout=None)
            ftp.login()

        try:
            ftp.retrbinary('RETR '+infile, outfile.write)
            print("Done")
            finished = True
        except Exception as e:
            ftp.close()
            ftp = None
            time_sec +=1
            print(f"Transfer failed: {e}, will retry in {time_sec} seconds...")
            time.sleep(time_sec)



if __name__ == "__main__":

    source_dir = '/dbgap/studies/' 
    mypath = './data/'
    if not os.path.exists(mypath):
        os.makedirs(mypath)

    dl_phenotypes = True
    dl_var_report_list = True


    # init ftp connection
    print('Establishing connection')
    ftp = FTP('ftp.ncbi.nlm.nih.gov', timeout=None)
    ftp.login()
    print('Connection established')

    print('Get the full list of studies')
    all_studies_dict = get_all_studies(source_dir, ftp)

    print('Get the phenotype already downloaded')

    txtfiles = []
    for file_ in glob.glob("./data/*.xml"):
        print(file_)
        txtfiles.append(file_.split('/')[2].split('.')[0])
    existing_phenotype = set(txtfiles)

    print('Remove the already downloaded ones')
    for i in existing_phenotype:
        del all_studies_dict[i]


    print("Get the already made variable_file_list")
    var_report_list = load_temp_list('./var_report_list_temp')
    for x in var_report_list:
        id_x = x.split('/')[3]
        print(id_x)
        try:
            del all_studies_dict[id_x]
        except KeyError:
            pass

    print('Getting the already created path list')

    phenotypes_path_list = load_temp_list('./phenotypes_path_list_temp')

    print('Removing the already created phenotypes_path from the full list')
    print(phenotypes_path_list)
    for i in phenotypes_path_list:
        id_x = i.split('/')[3]
        try:
            del all_studies_dict[id_x]
        except KeyError:
            pass

        

    for x in all_studies_dict:
        pheno_path = create_study_path(source_dir, all_studies_dict[x], ftp) 
        phenotypes_path_list.append(pheno_path)
        save_temp_list(pheno_path, './phenotypes_path_list_temp')

    print('Get the var_report file list')
    var_report_list = flatten([get_files_to_dl(x, ftp) for x in phenotypes_path_list])


    print('Downloading the data')
    for infile in var_report_list: 
        outfile = os.path.basename(infile)
        print('{}'.format(outfile))
        with open(mypath+ "/" +outfile, 'wb') as fh:
            print("dl the file into: {}".format(outfile))
            write_file_data(infile, fh, ftp)     
