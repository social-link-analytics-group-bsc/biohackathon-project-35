# Summary of results from file "EGA_with_NULL.csv"

The total number of studies from 2018 to date (9 Nov 2021) is 1,490 with a total number of 1,249,255 samples. Some studies include samples from before 2018, i.e.: the gender was not mandatory to be specified. As a result we find samples corresponding to the 'unknown' class. 

## Quantification biases at the sample level

### Globally

<p align="center">
<img src="images/gender_bias_samples_ega.png" width="400" heigh="400"/>
</p>

### Anually
<p align="center">
<img src="images/gender_bias_samples_ega_year.png" width="800" heigh="400"/>
</p>

## Quantification biases at the study level

### Globally
  - 20% (301) of the quantified studies do not report biological sex at all in their samples. 
  - 13 % (198) allow some uncertainty in their samples regarding biological sex (i.e.: unknown samples are included together with female and/or male samples.)
  - 67% (991) of the studies report the biological sex of all the considered samples .

<p align="center">
<img src="images/gender_bias_study_ega.png" width="400" heigh="400"/>
</p>

### Anually
<p align="center">
<img src="images/gender_bias_study_ega_year.png" width="800" heigh="400"/>
</p>

# Summary of results from file "raw_data_sample_tag.txt"
- 704,732 unique samples
- 1487 studies
- 4289 phenotypes

# Results from file "raw\_data"

## Processing of the data

From the key value data file we extracted all the studies with gender and counted the gender in order to have a table like the following

| study | males | females | unknown |
|---    |---    |---      |---      |
|_id_   |3      | 4       | 5       |


Then we filtered out the studies having more than 100 samples of data.
This was done to get the _pertinent_ studies.
This produced a dataset of 556 studies.


## Results

### Summary of known and unknown gender

Even if the studies are after 2018, when EGA made mandatory the sex in the data, there are some studies using old data.
So this implies that some studies have an unknown gender and a non specified gender.
We didn't take into account the studies that have an non specified gender, but we were curious about the number of studies that used data with unknown sex.  

Studies that only used data with sex marked: **276**.
Studies that used all the data with unknown sex: **93**.

### Summary of gap in sex

To measure the relative gap we took only into account studies that have at least 1 male and one female.
This list of those defined studies is of length 386.

From there we measure the relative gap as #females/(#males+#females) - #males/(#males+#females).  
On average the gap in the studies is -12%.
Which means tha on average each study has a data set with 12% more men than women.
