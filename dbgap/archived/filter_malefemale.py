import pandas as pd

# df.loc[:,['n','male', 'female','unknown', 'date', 'filename', 'dataset_id']].to_csv('summary_fourth.csv')

df = pd.read_csv('summary_fourth.csv')

all_male = df.loc[(df.female == 0) & (df.unknown == 0) & (df.male > 100)]
all_female = df.loc[(df.female > 100) & (df.unknown == 0) & (df.male == 0)]

all_male['sex'] = 'M'
all_female['sex'] = 'F'

new_df = pd.concat([all_female,all_male])

new_df[['n','filename', 'dataset_id', 'sex']].to_csv('all_one_sex.csv',index=False)