from txt2hpo.extract import Extractor
import requests
import pandas as pd
import sys
extract = Extractor()

#result = extract.hpo("patient with developmental delay and hypotonia")



def get_data(study_id):
    response = requests.get(
        "https://ega-archive.org/metadata/v2/studies/{}".format(study_id)
    )
    if response.status_code != 200:
        print("Study {} got error code {}".format(study_id, response.status_code))
        return []
    return response.json()['response']["result"]


def get_study_hpo(study_id):
    data = get_data(study_id)
    text = data[0]['description']
    phenotype_hpo = extract.hpo(text)
    d = {study_id: phenotype_hpo.hpids}
    df = pd.Series(d, name = "HPO").rename_axis("study_id").explode().reset_index()
    return df
 
def get_study_list(filename):
    with open(filename) as fi:
        study_list = list(fi.readlines())
    study_list = list(map(lambda x: x.strip(), study_list))
    return study_list
    

def main(load_file=None, skip_first=0, skip_numbers = []):
    """
    Reads Studies from EGA and counts the `gender` values for the data for each
    study.
    It outputs a final CSV summarizing the counts of `gender` for each study.
    It also produces a lot of backup files in case there is a problem do not start again.

    params:
    -------
    load_file: name of the last backup file to load.
    skip_first: how many studies it will skip.
    skip_numbers: list of the number of the study that will not collect data from.
    """

    study_list = get_study_list(load_file)
    
    counter = 0

    
    for s in study_list:
        counter+=1

        # skip the first n studies
        if counter < skip_first:
            continue
        # Skip the specified numbers
        if counter in skip_numbers:
            continue

        #print("getting study {} - {}".format(counter, s))
        df = get_study_hpo(s)
        df.to_csv('EGA_phenotype_HPO_fromtext.csv', mode='a', header=False)

    

if __name__ == "__main__":
    main(load_file = sys.argv[1])
