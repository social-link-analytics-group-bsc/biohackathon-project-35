#########################################
library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(lubridate)


#######
# Phenotypes ratio
#########


### dbGaP
dbgap = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/biohackathon-project-35/dbGaP primary phenotypes/summary_fourth.csv")
dbgap$total = dbgap$male +  dbgap$female +  dbgap$unknown
dbgap$repository="dbGaP"
dbgap$total_all = length(unique(dbgap$dataset_id))
dbgap$date = parse_date_time(dbgap$date, orders = c('mdy', 'dmy','ymd', "%d %m &y %H:%M:%S %Y"))
dbgap$year =str_split_fixed(dbgap$date, '-', 2)[,1]
spl = str_split_fixed(str_remove(dbgap$filename,'\\.\\/data\\/'), '\\.',6)
dbgap$study_id = paste(spl[,1],spl[,2],spl[,5], sep=".")

dbgap_phe = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/biohackathon-project-35/dbGaP primary phenotypes/dbGaP_primary_phenotypes.tsv", header = F,
                  col.names = c("study_id","phenotype"))
dbgap_phe

library(dplyr)
dbgap = merge(dbgap, dbgap_phe)
dbgap_ratio = dbgap %>% 
              #summarise(tot_male = sum(male),
              #          tot_female = sum(female))%>%
              mutate(FMratio = female/male)%>%
              filter(!FMratio %in% c("NaN", "Inf"))%>%
              group_by(phenotype) %>%
              summarise(FMratio_mean = mean(FMratio))

dbgap_ratio =arrange(dbgap_ratio, desc(FMratio_mean))
dbgap_ratio$x = 1:nrow(dbgap_ratio)
dbgap_ratio[1:20,]

library(ggplot2)
library(ggrepel)
phe_dbgap_plot = ggplot(dbgap_ratio, aes(x=x,y =FMratio_mean))+
  geom_bar(stat = "identity")+
  geom_label_repel(data = subset(dbgap_ratio, phenotype %in% c('Menopause','Prostate Neoplasm', 'Autism Spectrum Disorder',
                                                               'Diabetes Mellitus, Type 1', 'Cardiomyopathies', 'Anxiety',
                                                               'Chronic Obstructive Pulmonary Disease','Cardiovascular Disease')),
                   aes(x = x, y = FMratio_mean, 
                                           label = phenotype),
                   max.overlaps = Inf, box.padding = 3)+
  theme_minimal()+
  xlab("Primary phenotype")+
  ylab("F/M ratio")+
  theme(axis.text.x = element_blank())
phe_dbgap_plot 

# EGA
ega_phe = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/raw_phenotype_gender_ega.txt")
ega_phe$n = 1
ega_sum = ega_phe%>%group_by(ega_study,gender, phenotype)%>%
  summarise(n = sum(n))

ega_sum = subset(ega_sum, gender !="unknown")
library(tidyverse)
ega_sum =ega_sum %>% spread(gender, n)
ega_sum$total = ega_sum$female +ega_sum$male
ega_tot = ega_sum %>% group_by (phenotype) %>%
  summarise(total_all = sum(total))%>%
  filter(!is.na(total_all))

top100 = arrange(ega_tot, desc(total_all))[1:100,]
top100$phenotype

ega_sub100 = subset(ega_sum, phenotype %in% top100$phenotype)
ega_sub100$FMratio = ega_sub100$female / ega_sub100$male
ega_sub100 = subset(ega_sub100,!FMratio %in% c("NaN", "Inf", NA)) 
ega_sub100 = ega_sub100%>%
  group_by(phenotype) %>%
  summarise(FMratio_mean = mean(FMratio))

ega_sum$FMratio = ega_sum$female / ega_sum$male
ega_sum = subset(ega_sum,!FMratio %in% c("NaN", "Inf", NA)) 
ega_sum = ega_sum%>%
  group_by(phenotype) %>%
  summarise(FMratio_mean = mean(FMratio))

ega_ratio =arrange(ega_sub100, desc(FMratio_mean))
ega_ratio$x = 1:nrow(ega_ratio)
ega_ratio[21:40,]

phe_ega_plot = ggplot(ega_ratio, aes(x=x,y =FMratio_mean))+
  geom_bar(stat = "identity")+
  geom_label_repel(data = ega_ratio[c(1,12,6,17,18,26,24,75,93,100),],
                   aes(x = x, y = FMratio_mean, 
                       label = phenotype),
                   max.overlaps = Inf, box.padding = 2, direction = "up")+
  theme_minimal()+
  xlab("Primary phenotype")+
  ylab("F/M ratio")+
  theme(axis.text.x = element_blank())

library(cowplot)
png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/biohackathon-project-35/figures/figure5.png',
    width = 3000, height = 2500, res = 300)
plot_grid(phe_dbgap_plot, phe_ega_plot, labels = c("dbGaP", "EGA"), align = 'v', ncol = 1)
dev.off()
