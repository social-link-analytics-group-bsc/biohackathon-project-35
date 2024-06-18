library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(lubridate)
# Load data
ega = fread("../../ega/all_EGA_samples.txt")

ega$year = str_split_fixed(ega$date_study, '-', 2)[,1]
colnames(ega)[1] = "study_id"
ega = ega %>% group_by(year) %>%
  mutate(total_all = length(unique(study_id)))
ega$year = as.numeric(ega$year)


dbgap = fread("./dbgap_may2024.csv")
dbgap$repository = "dbGaP"
dbgap = dbgap[,-3]
#dbgap = subset(dbgap, year > 2017)
dbgap = dbgap %>% group_by(year) %>%
  mutate(total_all = length(unique(study_id)))


#dbgap$phe = substr(dbgap$filename, 8,19)

ega_dbgap = rbind(ega,dbgap)
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

r_m = melt(r, id.vars = c("study_id",
                          "total", "date_study",
                          "repository", "year", "total_all","label"))
#r_m = r_m %>% group_by(year, repository,label) %>% mutate(total_year = sum(value))
r_m_percent = r_m %>% 
  group_by(year, repository, label,variable) %>% 
  mutate(percent = value/ total) 
r_m_percent = subset(r_m_percent, !is.na(year) & year!= '1980' & year != "NA")
#r_m_percent$year[r_m_percent$year=='1980'] ='NA'

r_m_percent$year = factor (r_m_percent$year, 
                           levels = c( '1980','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021' ))


all = ggplot(subset(r_m_percent),
             aes(x = variable, y =percent, color = variable) )+
  geom_boxplot()+
  facet_grid(repository~year )+
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


all
png('../figures/figureS5.png',
    width = 3000, height = 1500, res = 300)
all
dev.off()


fmu = ggplot(subset(r_m_percent, label == "F&M&U" & year !="NA"),
             aes(x = variable, y =percent, fill = variable) )+
  geom_boxplot()+
  facet_grid(repository~year )+
  ylab("Percentage of samples in individual studies")+
  scale_fill_manual(values = c("#20639b", "#3caea3","#f6d55c"),
                     labels = c("Male (M)", "Female (F)", "Unknown (U)"),
                     name ="")+
  xlab("Sex classification")+
  scale_x_discrete(labels= c("M", "F", "U"))+
  theme_minimal()+
  theme(legend.position="top",
        strip.text = element_text(size = 12, face = "bold"),
        axis.text.x = element_text(size = 9))


fmu
png('../../figures/figureS2_may2024.png',
    width = 3000, height = 1500, res = 300)
fmu
dev.off()
