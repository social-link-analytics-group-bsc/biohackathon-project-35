import os
import json
import pandas as pd
from glob import glob

def log_error(study_id, error):
    with open("errors_missing_final.txt", 'a') as f:
        f.write(f"{study_id}: {error}\n")

# Function to count the sexes in a list of records
def count_sexes(sex):
    male = female = unknown = 0
    if sex == 'male':
        male += 1
    elif sex == 'female':
        female += 1
    else:
        unknown += 1
    return male, female, unknown

# Function to extract dbgap_id from the file name
def extract_dbgap_id(file_name):
    # Remove extension
    file_name_without_extension = os.path.splitext(file_name)[0]
    # Split on '_page' if it exists, otherwise the name is the ID
    dbgap_id = file_name_without_extension.split('_page')[0]
    return dbgap_id

# Function to process a single JSON file
def process_json_file(file_path):
    # Extract dbgap_id from the file name
    dbgap_id = extract_dbgap_id(os.path.basename(file_path))
    male = []
    female = []
    unknown = []
    dbgap_subject_id = []
    
    with open(file_path, 'r') as file:
        try:
            if '_summary' in file_path:
                study_id = data['study']['accver']['accession'][3:]  # Extracting study_id from accession
                unknown = data['study_stats']['cnt_subjects']['loaded']
                male = female = 0
            else:
                data = json.load(file)
                records = data.get('data', [])
                study_id = records[0].get('study_key') if records else None
                for record in records:
                    sex = record.get('sex')
                    m, f, u= count_sexes(sex)
                    male.append(m)
                    female.append(f)
                    unknown.append(u)
                    dbgap_subject_id.append(record.get('dbgap_subject_id'))
                #male, female, unknown = count_sexes(records)
                #return study_id, male, female, unknown, dbgap_id
                study_id = [study_id] * len(male)
                dbgap_id = [dbgap_id] * len(male)
                return study_id, male, female, unknown, dbgap_subject_id, dbgap_id 
        except Exception as e:
            log_error(dbgap_id, str(e))
            return 

def flatten_concatenation(matrix):
    flat_list = []
    for row in matrix:
        flat_list += row
    return flat_list

# Process all JSON files and compile results into a DataFrame
def process_all_json_files(directory):
    # Find all JSON files in the specified directory
    json_files = glob(os.path.join(directory, "*.json"))
    
    s = []
    m = []
    f = []
    u = []
    ds = []
    did = []
    
    for json_file in json_files:
        #results = []
        print(json_file)
        try:
            study_id, male, female, unknown, dbgap_subject_id, dbgap_id = process_json_file(json_file)
            #s = s + study_id
            #m = m + male
            #f = f + female
            #u = u + unknown
            #df = ds + dbgap_subject_id
            #did = did + dbgap_id
            #if not study_id:
            #    continue
        except:
            continue
       
        results= {
                'study_id': study_id,
                'male':male,
                'female':female,
                'unknown':unknown,
                'dbgap_subject_id' : dbgap_subject_id,
                'dbgap_id': dbgap_id
            }
    # Sum the counts for files with the same dbgap_id
       
        #df = pd.DataFrame(results)
        df = pd.DataFrame.from_dict(results)
        #df = df.explode(list("study_idmalefemaleunknowndbgap_subject_iddbgap_id")) 
        #df_unique = df.drop_duplicates()
        #df_unique = df_unique.groupby(['study_id', 'dbgap_id'], as_index=False).sum()
        # Optionally, save the DataFrame to a CSV file
        if os.path.exists("study_sex_counts.csv"):
            df.to_csv('study_sex_counts.csv', index=False, mode='a', header=False)
        else:
            df.to_csv('study_sex_counts.csv', index=False)
    return 

# Specify the directory where your JSON files are located
directory = './downloads'
df = process_all_json_files(directory)



# Print the DataFrame to see the results
#print(df)