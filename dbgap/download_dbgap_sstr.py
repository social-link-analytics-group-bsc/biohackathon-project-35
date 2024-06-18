import sys
import requests
import concurrent.futures
import os
import time

data_format="row"
url_base="https://www.ncbi.nlm.nih.gov/gap/sstr/api/v1/study"
max_retries = 3
retry_delay = 5
swagger_url = "https://www.ncbi.nlm.nih.gov/gap/sstr/swagger/"

def wait_for_swagger():
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

def download_study(study_id):
    print("HOLA")

    # Check if the JSON file already exists
    if os.path.exists(f"downloads/{study_id}.json"):
        print(f"Skipping {study_id}: JSON file already exists.")
        return

    # Check if the study ID is listed in empty_responses.txt or errors.txt
    if study_id_in_log(study_id):
        print(f"Skipping {study_id}: Found in empty_responses.txt or errors.txt.")
        return
    
    wait_for_swagger()
    retries = 0
    while retries < max_retries:
        try:
            response = requests.get(f"{url_base}/{study_id}/subjects?page=1&page_size=1&data_format={data_format}", headers={'accept': 'application/json'})
            if response.status_code == 200:
                response = requests.get(f"{url_base}/{study_id}/subjects?page=0&data_format={data_format}", headers={'accept': 'application/json'})
                data = response.json()
                if data:
                    with open(f"downloads/{study_id}.json", 'w') as f:
                        f.write(response.text)
                else:
                    log_empty_response(study_id)
                return
            else:
                if response.status_code == 502:
                    log_error(study_id, response.status_code)
                else:
                    log_error(study_id, response.status_code)
                    retries += 1
                    if retries < max_retries:
                        print(f"Retrying {study_id}... (Attempt {retries + 1}/{max_retries})")
                        wait_for_swagger()
                return
        except Exception as e:
            log_error(study_id, str(e))
            retries += 1
            if retries < max_retries:
                print(f"Retrying {study_id}... (Attempt {retries + 1}/{max_retries})")
                wait_for_swagger()

    print(f"Failed to download {study_id} after {max_retries} attempts.")

def log_empty_response(study_id):
    with open("empty_responses.txt", 'a') as f:
        f.write(study_id + '\n')

def log_error(study_id, error):
    with open("errors.txt", 'a') as f:
        f.write(f"{study_id}: {error}\n")

def study_id_in_log(study_id):
    log_files = ["empty_responses.txt", "errors.txt"]
    for log_file in log_files:
        if os.path.exists(log_file):
            with open(log_file, 'r') as f:
                if study_id in f.read():
                    return True
    return False

def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py study_ids.txt")
        sys.exit(1)

    study_ids_file = sys.argv[1]
    if not os.path.exists(study_ids_file):
        print(f"Error: {study_ids_file} not found.")
        sys.exit(1)

    with open(study_ids_file, 'r') as f:
        study_ids = f.read().splitlines()

    with concurrent.futures.ThreadPoolExecutor(max_workers=1) as executor:
        executor.map(download_study, study_ids)

if __name__ == "__main__":
    main()
