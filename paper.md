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

# Introduction

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

# Results
* Percentage of studies containing patient sex information
* Percentage of male/female patients in the studies
* Differential phenotype enrichment by sex?
* Differential sex enrichment by phenotype?

# Discussion

# References
