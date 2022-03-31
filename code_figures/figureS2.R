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

library(reshape2)

r_m = melt(r, id.vars = c("dataset_id","total", "date_study", "repository", "year", "total_all","label"))
#r_m = r_m %>% group_by(year, repository,label) %>% mutate(total_year = sum(value))
r_m_percent = r_m %>% 
  group_by(year, repository, label,variable) %>% 
  mutate(percent = value/ total) 
r_m_percent$year = factor (r_m_percent$year, 
                           levels = c('NA', '1980','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021','2009' ))
fmu = ggplot(subset(r_m_percent, repository =="dbGaP" & label == "F&M&U"),
             aes(x = variable, y =percent, color = variable) )+
  geom_boxplot()+
  facet_grid(label~year )+
  ylab("Percentage of samples")+
  scale_color_manual(values = c("#20639b", "#3caea3","#f6d55c"),
                     labels = c("Male (M)", "Female (F)", "Unknown (U)"),
                     name ="")+
  xlab("Sex classification")+
  scale_x_discrete(labels= c("M", "F", "U"))+
  theme_minimal()+
  theme(legend.position="top",
        strip.text = element_text(size = 12, face = "bold"),
        axis.text.x = element_text(size = 9))


fmu
png('../figures/figureS2.png',
    width = 3000, height = 1000, res = 250)
fmu
dev.off()
