import sys
import requests
import concurrent.futures
import os
import time
import re
import csv
import json


max_retries = 3
retry_delay = 5


def wait_for_swagger():
    swagger_url = "https://www.ncbi.nlm.nih.gov/gap/sstr/swagger/"
    while True:
        try:
            response = requests.get(swagger_url)
            if response.status_code == 200:
                print("Swagger documentation is available. Resuming downloads.")
                return
        except Exception as e:
            print(f"Error checking Swagger documentation: {e}")
        print("Swagger documentation is not available. Waiting...")
        time.sleep(retry_delay)
        
def parse_error_file (error_file):
    # Open the error file
    with open(error_file, "r") as f:
        lines = f.readlines()

    # Initialize an empty list to store the study IDs
    non_homogeneous_ids = []

    # Iterate through the lines in the error file
    for line in lines:
        # Use regular expressions to extract the study ID and error message
        id_match = re.search(r"phs\d{6}\.\w{1,3}\.p\d", line)
       # error_match = re.search(r"Expecting value", line)

        # If the ID is found and there's an error message, add the ID to the list
        if id_match:
            non_homogeneous_ids.append(id_match.group(0))

    # Print the extracted study IDs
    return set(non_homogeneous_ids)


def pagination(url_base, study_id, page, page_size, data_format, headers):
    url = f"{url_base}/{study_id}/subjects?page={page}&page_size={page_size}&data_format={data_format}"
    wait_for_swagger()
    # Loop to retry the request if it fails
    response = requests.get(url, headers=headers)

    # Check if the request was successful (status code 200)
    if response.status_code == 200:
        data = response.json()
        # If there is data, write it to a JSON file
        if data:
            with open(f"downloads/{study_id}_page{page}.json", 'w') as f:
                json.dump(data, f)
                return data
    else:
        raise Exception(f"Request failed with status code {response.status_code}")


def download_missing_study(study_id):
    # Set headers for the requests
    data_format="row"
    url_base="https://www.ncbi.nlm.nih.gov/gap/sstr/api/v1/study"
    headers = {'accept': 'application/json'}

    
    page = 1
    page_size = 50
    summary="no"
    while True:
        # Check if the JSON file already exists
        if os.path.exists(f"downloads/{study_id}_page{page}.json"):
            print(f"Skipping {study_id} page {page}: JSON file already exists.")
            page = page + 1
            continue
        # Check if the study ID is listed in empty_responses.txt or errors.txt
        if study_id_in_log(study_id):
            print(f"Skipping {study_id} page {page}: Found in empty_responses.txt or errors_missing.txt.")
            page = page + 1
            continue
           # break
        # Now, check other conditions and process the data
        try:
            data = pagination(url_base, study_id, page, page_size, data_format, headers)
            if len(data["data"]) < page_size:
                return
            else:
                page = page + 1
        except Exception as e:
            print("An error occurred in the try block:", str(e))
            # Handle the exception and continue with the next iteration
            log_error(study_id, str(e))
            summary="yes"
            break

    if summary=="yes":
        # Download the study summary if there is no data
        url = f"{url_base}/{study_id}/summary"
        response = requests.get(url, headers=headers)

        # Check if the request was successful (status code 200)
        if response.status_code == 200:
            # Parse the JSON response
            data = response.json()
            if data:
                with open(f"downloads/{study_id}_summary.json", 'w') as f:
                    json.dump(data, f)

            # Extract the "subject_count" field
            subject_count = data["study_stats"]["cnt_subjects"]["loaded"]

            # Write the subject counts to a CSV file
            id_counts[study_id] = {"total": subject_count,"unknown":subject_count, "female": 0, "male":0}
            with open("subject_counts.csv", "w", newline="") as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow(["study_id", "subject", "female", "male", "unknown"])
                for id, counts in id_counts.items():
                    row = [id, counts["total"],counts["unknown"], counts["female"], counts["male"]]
                    writer.writerow(row)
                    return
        else:
            print("An error occurred in the study summary download:", str(e))
            log_error(study_id, str(e))


def log_error(study_id, error):
    with open("errors_missing.txt", 'a') as f:
        f.write(f"{study_id}: {error}\n")
        
# Add the study ID to the log files if necessary
def study_id_in_log(study_id):
    # Read the content of the log files
    with open("empty_responses.txt", "r") as file:
        content = file.read()
    with open("errors_missing.txt", "r") as file:
        content += file.read()

    # Check if the study ID is in the content
    if study_id in content:
        return True
    else:
        return False



def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py errors.txt")
        sys.exit(1)

    error_file = sys.argv[1]
    if not os.path.exists(error_file):
        print(f"Error: {error_file} not found.")
        sys.exit(1)
    
    study_ids= list(parse_error_file(error_file))
    print(study_ids)
    with concurrent.futures.ThreadPoolExecutor(max_workers=1) as executor:
        executor.map(download_missing_study, study_ids)

if __name__ == "__main__":
    main()