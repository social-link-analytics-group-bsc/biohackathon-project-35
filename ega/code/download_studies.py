import requests
from collections import Counter
import pandas as pd

def get_data(study_id):
    response = requests.get(
        "https://ega-archive.org/metadata/v2/samples?queryBy=study&queryId={}&limit=0".format(study_id)
    )
    if response.status_code != 200:
        print("Study {} got error code {}".format(study_id, response.status_code))
        return []
    return response.json()['response']["result"]


def get_study_info(study_id):
    data = get_data(study_id)
    counts = Counter(list(map(lambda x: x['gender'], data)))
    if len(data) > 0:
        year = data[0]['creationTime'][:4]
    else:
        year = "-1"
    
    #Transform it to a dict
    row = dict(counts)
    row['date'] = year
    row['identifier'] = study_id
    row['total'] = len(data)
    row['database'] = 'EGA'

    return row

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

    study_list = get_study_list("../EGA_studies_list.txt")
    
    rows = []
    counter = 0

    if load_file != None:
        rows = pd.read_csv(load_file,sep=';').to_dict('records')

    
    for s in study_list:
        counter+=1

        # skip the first n studies
        if counter < skip_first:
            continue
        # Skip the specified numbers
        if counter in skip_numbers:
            continue

        print("getting study {} - {}".format(counter, s))
        rows.append(get_study_info(s))
        if counter%10 == 0:
            pd.DataFrame(rows).to_csv("../EGA_data_back{}.csv".format(int(counter/10)))

    pd.DataFrame(rows).to_csv('../EGA_data.csv',sep=';')

    

if __name__ == "__main__":
    main("../EGA_data_back108.csv", 1080, [374, 1087, 1090])
