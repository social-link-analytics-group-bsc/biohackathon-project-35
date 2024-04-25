import pandas as pd
import requests
import os
from tqdm import tqdm
import concurrent.futures

def download_file(file_info):
    file_url, file_path = file_info
    try:
        response = requests.get(file_url)
        if response.status_code == 200:
            with open(file_path, 'wb') as f:
                f.write(response.content)
            return f"Downloaded and saved: {file_path}"
        else:
            return f"Failed to download {file_url}, status code: {response.status_code}"
    except Exception as e:
        return f"Error downloading {file_url}: {str(e)}"

def filename_to_url(filename):
    if filename.startswith("./data/"):
        filename = filename[7:]
    parts = filename.split('.')
    study, version, part = parts[0], parts[1], parts[4]
    file_url = f"https://ftp.ncbi.nlm.nih.gov/dbgap/studies/{study}/{study}.{version}.{part}/pheno_variable_summaries/{filename}"
    return file_url

def main():
    df = pd.read_csv('summary_fourth.csv')
    os.makedirs('data0', exist_ok=True)
    df['file_url'] = df['filename'].apply(filename_to_url)
    df['file_path'] = df['file_url'].apply(lambda x: os.path.join('data0', os.path.basename(x)))
    
    file_infos = list(zip(df['file_url'], df['file_path']))
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=7) as executor:
        results = list(tqdm(executor.map(download_file, file_infos), total=len(file_infos), desc="Downloading files"))

    for result in results:
        print(result)

    print("Process completed.")

if __name__ == "__main__":
    main()
