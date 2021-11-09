import pandas as pd

df = pd.read_csv('raw_data.txt', sep=',')

grp = df.loc[df.key == 'gender'].groupby(['study','value'])
new_df = grp.size().unstack(fill_value=0)

new_df.to_csv('raw_data_dataframe.csv')