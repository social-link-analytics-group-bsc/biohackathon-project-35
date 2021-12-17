import pandas as pd
import numpy as np

df = pd.read_csv('summary_third.csv')

# data containing at least one count on male-female only for GENDER/SEX
d1 = df.loc[~df.male.isna() | ~df.female.isna()]
print("rows with male or female")
print(len(d1))

# data containing at least one count on male-female with SAMPLE and SUbBJECT
d1 = df.loc[~df.male.isna() | ~df.female.isna() 
    | ~df.subject_male.isna() | ~df.subject_female.isna()
    | ~df.sample_male.isna() | ~df.sample_female.isna()]
print("adding the SAMPLE and SUBJECT")
print(len(d1))

# Data where n<female + male
print("Where n< f+m")
print(len(d1.loc[d1.n < d1.male + d1.female]))

# Filter out rows that do not make sense
good_rows = ((d1.n >= d1.male + d1.female) | 
                  (d1.sample_n >= d1.sample_male + d1.sample_female) |
                  (d1.subject_n >= d1.subject_male + d1.subject_female))
d2=d1.loc[good_rows]
print("Where n>= f+m")
print(len(d2))

# Fill NA values for n male and female
d1['n'] = d1['n'].fillna(d1.sample_n).fillna(d1.subject_n)
d1['male'] = d1['male'].fillna(d1.sample_male).fillna(d1.subject_male).fillna(0)
d1['female'] = d1['female'].fillna(d1.sample_female).fillna(d1.subject_female).fillna(0)
d1['unknown'] = d1.n - d1.male + d1.female
d1 = d1.loc[d1.unknown >=0]
print(d1.loc[d1.unknown ==0].shape)

d1.loc[:,['n','male', 'female','unknown', 'date']].to_csv('summary_fourth.csv')