library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(lubridate)
# Load data
ega = fread("../ega/all_EGA_samples.txt")

ega$year = str_split_fixed(ega$date_study, '-', 2)[,1]
colnames(ega)[1] = "dataset_id"
ega = ega %>% group_by(year) %>%
mutate(total_all = length(unique(dataset_id)))

dbgap = fread("../dbpgap/summary_fourth.csv")
dbgap$total = dbgap$male +  dbgap$female +  dbgap$unknown
dbgap$date = parse_date_time(dbgap$date, orders = c('mdy', 'dmy','ymd', "%d %m &y %H:%M:%S %Y"))
dbgap$year =str_split_fixed(dbgap$date, '-', 2)[,1]
dbgap$repository = "dbGaP"

dbgap$year[dbgap$year==""] = "NA"
#dbgap = subset(dbgap, year > 2017)
dbgap = dbgap %>% group_by(year) %>%
  mutate(total_all = length(unique(dataset_id)))


dbgap$phe = substr(dbgap$filename, 8,19)

ega_dbgap = rbind(ega,dbgap[colnames(ega[,-6])])
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
#write.table(r, 'ega_dbgap_studies_classification.txt', sep = "\t")
# percent
ega_dbgap_percent = unique(r %>% group_by(label, repository,year) %>%
  summarise(value_percent = sum(c) / total_all))
f = arrange(ega_dbgap_percent, desc(value_percent))$label
ega_dbgap_percent$label = factor(ega_dbgap_percent$label, levels = c("F&M", "F&M&U", "U", "F" , "M", "F&U" ,"M&U"))

ega_dbgap_percent$year[ega_dbgap_percent$year == 1980] = "NA"
ega_dbgap_percent$year = factor(ega_dbgap_percent$year,
                                    levels = c('NA','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021'))

cbp1 <- c( "#E69F00", "#56B4E9", "#009E73",
          "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

dbgap3 = ggplot(subset(ega_dbgap_percent, repository == "dbGaP"),
                aes(x= year, color = label, group =label ))+
  geom_point(aes(y = value_percent), size = 3)+
  geom_line(aes(y = value_percent))+
  ylab("Percentage studies")+
  xlab("Sex specification in samples found in the study")+
  theme_minimal()+
  facet_grid(repository~., scales= "free_y")+
  #scale_color_manual(values = cbp1)+
  scale_color_brewer(palette = "Set2")+
  theme(axis.text.x = element_text(size = 10),
        legend.position="top",
        legend.box = "horizontal",
        strip.text = element_text(size = 16, face = "bold"))+
  guides(color=guide_legend(nrow=1,byrow=TRUE, title = "Study classification"))


ega3 = ggplot(subset(ega_dbgap_percent, repository == "EGA"),
              aes(x= year, color = label, group =label ))+
  geom_point(aes(y = value_percent), size = 3)+
  geom_line(aes(y = value_percent))+
  ylab("Percentage studies")+
  xlab("Sex specification in samples found in the study")+
  theme_minimal()+
  facet_grid(repository~., scales= "free_y")+
  #scale_color_manual(values = cbp1)+
  scale_color_brewer(palette = "Set2")+
  theme(axis.text.x = element_text(size = 10),
        legend.position="top",
        legend.box = "horizontal",
        strip.text = element_text(size = 16, face = "bold"))+
  guides(color=guide_legend(nrow=1,byrow=TRUE, title = "Study classification"))


pp2 = plot_grid(dbgap3, ega3,
               labels = c('A', 'B'),
               ncol = 1, rel_heights = c(0.5,0.5))  



png('../figures/figure4.png',
    width = 1500, height = 1100, res = 200)
pp2
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
