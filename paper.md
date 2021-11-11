---
title: 'BioHackrXiv  template'

tags:
  - replace with your own keywords
  - at least 3 is recommended
authors:
  - name: First Last
    orcid: 0000-0000-0000-0000
    affiliation: 1
  - name: Second Last
    orcid: 0000-0000-0000-0000
    affiliation: 2

affiliations:
 - name: Institution 1, address, city, country
   index: 1
 - name: Institution 1, address, city, country
   index: 2
date: 12 November 2021
bibliography: paper.bib
authors_short: Last et al. (2021) BioHackrXiv  template
group: BioHackrXiv
event: BioHackathon Europe 2021
---

# Abstract 
The design of AI systems for health is a grand achievement of science and technology of our times. Nevertheless, such systems learn to perform specific tasks by processing extensive amounts of data that is produced and stored in large biomedical repositories. The quality and content of this data have an immense impact on what and how AI learns. If the data contains biases, such as skewed representation of certain categories or missing information, the application of AI can lead to discriminatory outcomes and propagate them into society, as we recently pointed out [@cirillo2020sex]. The objective of this work is to determine the extent of biases in available demographic categories (sex, age, race) in ELIXIR biomedical data repositories, which are largely used in the community to train AI systems. Here, we quantify the bias and provide recommendations on how to properly use the data to develop fair and trustworthy AI, including solutions and best practices.

# Methods
## Databases
Two independent databases were considered in the present investigation: EGA [@riccio2012ega] and dbGaP [@mailman2007ncbi], containing population from Europe and the United States, respectively (check this info).

### EGA
### dbGAP
We downloaded the xml files of all the studies from 2018 to present (date of creation) from https://ftp.ncbi.nlm.nih.gov/dbgap/studies/. The final list contained XXX xml files that we converted to tables reporting the information about the variables of interest.

dbGaP is a database that provides access to large-scale genetic and phenotypic datasets required for GWAS designs and provides authorized access to individual-level data.

Studies in dbGaP contain four basic types of data:
* Study documentation, including study descriptions, protocol documents, and data collection instruments, such as questionnaires;
* Phenotypic data for each variable assessed, at both an individual level and in summary form; 
* Genetic data, including study subjects' individual genotypes, pedigree information, fine mapping results, and resequencing traces; and 
* Statistical results, including association and linkage analyses, when available (copied from paper).

Here, we are mainly interested in the Phenotypic data.

Individuals in datasets are separately classified by sex, case-control status, and consent category.
Hence, changes in participant sets will alter the statistical summary of values and prompt the regeneration of all versions of data files to reflect the new consent structure.

# Analysis

## Quantitative Analysis 

* Percentage of studies containing patient sex information
* Percentage of male/female patients in the studies
* Differential phenotype enrichment by sex?
* Differential sex enrichment by phenotype?



## Qualitative Analysis 

### Content Analysis 

Table of results 

### Recommendations 

1. provide clear definitions of sex and gender. avoid confusion (EGA uses "gender" biological sex)		
		
2. mandatory field is not enough, often filled as "unknown". other actions need to be included (legal aspects, global recommendations, etc.) 	

			
3. education is essential to raise awareness on the importance of including diversity in the creation of datasets and in research practice ( by training in companies, institutions but also in the curriculum in courses of medicine, engineer, bioinformatics, etc... ) 			
	
	3.1 do we propose ideas/methods?			
	3.2 who should be included?			
	3.3 trade-off between preserving the privacy of personal data and the necessity to include it to improve outcomes		

4. social impact in biomedical research/precision medicine of not capturing the diversity				
5. not only ask for gender identification / ethnic... and start putting efforts on the genomic data and study its relation to biological sex or ethnicity 				
	5.1 what is in the genetics that makes a drug work differently for specific sex?			
6. promote methods for transparency and accountability to foster open science/ open access, reusability, reduce the cost of creating/curating datasets				
	6.1 what happens with datasets that were created before gender was mandatory?			
	6.2 synthetic data?			
	6.3 user-friendly info to define the quality level of the dataset (eg., red-yellow-green)			
7. standardization of datasets to allow interoperability				
	7.1 avoid free text			
	7.2 ontologies for diseases / phenotypes ...			




# Discussion


# References
