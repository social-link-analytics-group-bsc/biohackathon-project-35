library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(lubridate)
# Load data
ega = fread("../ega/EGA_with_NULL.csv")
ega$total_all = length(unique(ega$ega_stable_id))
ega$year = str_split_fixed(ega$to_char, '-', 2)[,1]

dbgap = fread("../dbpgap/summary_fourth.csv")
dbgap$total = dbgap$male +  dbgap$female +  dbgap$unknown
dbgap$date = parse_date_time(dbgap$date, orders = c('mdy', 'dmy','ymd', "%d %m &y %H:%M:%S %Y"))
dbgap$year =str_split_fixed(dbgap$date, '-', 2)[,1]
dbgap$repository = "dbGaP"

dbgap$year[dbgap$year==""] = "NA"
dbgap = subset(dbgap, year > 2017)
dbgap$total_all = length(unique(dbgap$dataset_id))

dbgap$phe = substr(dbgap$filename, 8,19)

ega_dbgap = rbind(ega,dbgap, fill = T)
################
# study level  #
################
unknown_only = subset(ega_dbgap, male == 0 & female == 0)
unknown_only$label = "U"

female_only = subset(subset(ega_dbgap, male == 0 & unknown == 0))
female_only$label = 'F'

male_only = subset(ega_dbgap, female == 0 & unknown == 0)
male_only$label = 'M'

female_and_male = subset(ega_dbgap, female != 0 & male != 0 & unknown == 0)
female_and_male$label = 'F&M'

female_and_unknown = subset(ega_dbgap, female != 0 & male == 0 & unknown != 0)
female_and_unknown$label = 'F&U'

male_and_unknown = subset(ega_dbgap, female == 0 & male != 0 & unknown != 0)
male_and_unknown$label = 'M&U'

female_and_male_and_unknown = subset(ega_dbgap, female != 0 & male != 0 & unknown != 0)
female_and_male_and_unknown$label = 'F&M&U'


r = rbind(unknown_only, female_only, male_only, female_and_male, female_and_unknown, male_and_unknown, female_and_male_and_unknown)
r $ c = 1
write.table(r, 'ega_dbgap_studies_classification.txt', sep = "\t")
# percent
ega_dbgap_percent = unique(r %>% group_by(label, repository) %>%
  summarise(value_percent = sum(c) / total_all))
f = arrange(ega_dbgap_percent, desc(value_percent))$label
ega_dbgap_percent$label = factor(ega_dbgap_percent$label, levels = unique(f))

study_plot_percent = ggplot(ega_dbgap_percent, aes(x= label,y = value_percent, fill = label))+
  geom_bar(stat="identity", width=0.75)+
  ylab("Percentage studies")+
  xlab("Sex specification in samples found in the study")+
  theme_minimal()+
  facet_grid(~repository)+
  scale_y_continuous(labels=scales::percent) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 10, face = "bold"),
       # axis.text.x = element_text(size = 12),
        strip.text = element_text(size = 16, face = "bold"))
study_plot_percent
png('../figures/figure2.png',
    width = 1500, height = 750, res = 200)
study_plot_percent
dev.off()



#### phenotype

ega_phe =fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/raw_phenotype_gender_ega.txt")
ega_phe_u = subset(ega_phe , ega_study %in% unknown_only$ega_stable_id)
ega_phe_u $c = 1
ega_phe_u_total = ega_phe_u%>%group_by(phenotype) %>% summarise(total = sum(c))
arrange(ega_phe_u_total, desc(total))
top20 = subset(ega_phe_u_total,total> 720)
top20$phenotype = factor(top20$phenotype, levels = arrange(top20, desc(total))$phenotype)
ggplot(top20, aes(x = phenotype, y = total))+
  geom_bar(stat="identity")+
  theme_minimal()+
  theme(axis.text.x = element_text(size = 10, face = "bold", angle = 45, hjust = 1, vjust = 1),
        # axis.text.x = element_text(size = 12),
        strip.text = element_text(size = 16, face = "bold"))



dbgap_phe =fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/biohackathon-project-35/dbpgap/archived/summary_primary_phenotype.tsv")
dbgap_phe$dataset_id = substr(dbgap_phe$`study accession`, 1, 12)
dbgap_phe_fmu = subset(dbgap_phe , dataset_id %in% female_and_male_and_unknown$phe)
dbgap_phe_fmu $c = 1
dbgap_phe_fmu_total = dbgap_phe_fmu%>%group_by(`primary phenotype`) %>% summarise(total = sum(c))
arrange(dbgap_phe_fmu_total, desc(total))
top20 = subset(dbgap_phe_fmu_total,total>25)
top20$`primary phenotype` = factor(top20$`primary phenotype`, levels = arrange(top20, desc(total))$`primary phenotype`)
ggplot(top20, aes(x = `primary phenotype`, y = total))+
  geom_bar(stat="identity")+
  theme_minimal()+
  theme(axis.text.x = element_text(size = 10, face = "bold", angle = 45, hjust = 1, vjust = 1),
        # axis.text.x = element_text(size = 12),
        strip.text = element_text(size = 16, face = "bold"))
