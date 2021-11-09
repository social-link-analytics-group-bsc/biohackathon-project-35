import os
import numpy as np
import xml.etree.ElementTree as ET

VALID_YEARS = ["2018", "2019", "2020", "2021"]
ALL_STUDIES = os.listdir("data/")

valid_studies = []
for study in ALL_STUDIES:
    try:
        tree = ET.parse('data/{}'.format(study))
        root = tree.getroot()
        for year in VALID_YEARS:
            if year in root.attrib["date_created"]:
                valid_studies.append(root.attrib["study_id"])
    except:
        continue
valid_studies = np.unique(valid_studies)
np.savetxt("valid_studies.txt", valid_studies, fmt="%s", delimiter="\n")
