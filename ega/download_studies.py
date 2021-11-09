import requests
from collections import Counter
import pandas as pd

def get_data(study_id):
    response = requests.get(
        " https://ega-archive.org/metadata/v2/samples?queryBy=study&queryId={}&limit=0".format(study_id)
    )
    if response.status_code != 200:
        print("Study {} got error code {}".format(study_id, response.status_code))
        return []
    return response.json()['response']["result"]


def get_study_info(study_id):
    data = get_data(study_id)
    counts = Counter(list(map(lambda x: x['gender'], data)))
    year = data[0]['creationTime'][:4]
    
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
    

def main():
    study_list = get_study_list("EGA_studies_list.txt")
    
    rows = []
    for s in study_list:
        rows.append(get_study_info(s))

    pd.DataFrame(rows).to_csv('EGA_data.csv',sep=';')

    

if __name__ == "__main__":
    main()
