library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(lubridate)
library(patchwork) # To display 2 charts together
#library(hrbrthemes)
library(cowplot)

# Load data
ega = fread("../ega/all_EGA_samples.txt")
#ega$total_all = length(unique(ega$ega_stable_id))
ega$year = str_split_fixed(ega$date_study, '-', 2)[,1]
colnames(ega)[1] = "dataset_id"
ega_m = melt(ega, id.vars = c("dataset_id", "repository", "date_study", "year", "total"))
ega_m$year[ega_m$year=="1980"] = "NA"

dbgap = fread("../dbpgap/summary_fourth.csv")
dbgap$total = dbgap$male +  dbgap$female +  dbgap$unknown
dbgap$date = parse_date_time(dbgap$date, orders = c('mdy', 'dmy','ymd', "%d %m &y %H:%M:%S %Y"))
dbgap$year =str_split_fixed(dbgap$date, '-', 2)[,1]
dbgap_m = melt(dbgap, id.vars= c("V1", "n", "dataset_id", "filename", "date",'year', "total"))
dbgap_m$repository = "dbGaP"
dbgap_m$year[dbgap_m$year==""] = "NA"

# bind datasets
ega_dbgap = rbindlist(list(ega_m, dbgap_m), use.names = T, fill = T)

#total samples per year
ega_dbgap = ega_dbgap %>% group_by(repository, year) %>% mutate(total_year = sum(value))

################
# sample level #
################

ega_dbgap_percent = subset(ega_dbgap) %>% group_by(variable, repository, year) %>%
  summarise(value_percent = sum(value) / sum(total),
            total_year = unique(total_year))
ega_dbgap_percent$year = factor(ega_dbgap_percent$year ,
                                 levels = c('NA','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021'))


ega1 = ggplot(subset(ega_dbgap_percent, repository == "EGA"),
              aes(x=year,  group=repository))+
  # geom_line(aes(y = total_year),fill = "grey30", stat="identity", width= 0.8)+
  geom_point(aes(y = total_year), size = 3,  color = "#ed553b")+
  geom_line(aes(y = total_year), color = "#ed553b")+
  ylab("# samples")+
  xlab("Year")+
  theme_minimal()+
  facet_grid(repository~.)+
  theme(axis.text.x = element_text(size = 10),
        strip.text = element_text(size = 16, face = "bold"))

ega2 = ggplot(subset(ega_dbgap_percent, repository =="EGA"),
                             aes(x=year,  color=variable, group=variable))+
  # geom_line(aes(y = total_year),fill = "grey30", stat="identity", width= 0.8)+
  geom_point(aes(y = value_percent), size = 3)+
  geom_line(aes(y = value_percent))+
  ylab("Percentage of samples")+
  xlab("Year")+
  theme_minimal()+
  scale_y_continuous(labels=scales::percent)+#,
  #sec.axis = sec_axis(~.*0.01, name="Second Axis")) +
  facet_grid(repository~.)+
  scale_color_manual(values = c("#20639b", "#3caea3","#f6d55c"),
                     labels = c("Male", "Female", "Unknown"),
                     name ="")+
  #scale_x_discrete(labels= c("M", "F", "U"))+
  theme(legend.position = "top",
        axis.text.x = element_text(size = 10),
        strip.text = element_text(size = 16, face = "bold"))



dbgap1 = ggplot(subset(ega_dbgap_percent, repository == "dbGaP"),
              aes(x=year,  group=repository))+
  # geom_line(aes(y = total_year),fill = "grey30", stat="identity", width= 0.8)+
  geom_point(aes(y = total_year), size = 3,  color = "#ed553b")+
  geom_line(aes(y = total_year), color = "#ed553b")+
  ylab("# samples")+
  xlab("Year")+
  theme_minimal()+
  facet_grid(repository~.)+
  theme(axis.text.x = element_text(size = 10),
        strip.text = element_text(size = 16, face = "bold"))

dbgap2 = ggplot(subset(ega_dbgap_percent, repository =="dbGaP"),
              aes(x=year,  color=variable, group=variable))+
  # geom_line(aes(y = total_year),fill = "grey30", stat="identity", width= 0.8)+
  geom_point(aes(y = value_percent), size = 3)+
  geom_line(aes(y = value_percent))+
  ylab("Percentage of samples")+
  xlab("Year")+
  theme_minimal()+
  scale_y_continuous(labels=scales::percent)+#,
  ylim(0,1)+
  #sec.axis = sec_axis(~.*0.01, name="Second Axis")) +
  facet_grid(repository~.)+
  scale_color_manual(values = c("#20639b", "#3caea3","#f6d55c"),
                     labels = c("Male", "Female", "Unknown"),
                     name ="")+
  #scale_x_discrete(labels= c("M", "F", "U"))+
  theme(legend.position = "top",
        axis.text.x = element_text(size = 10),
        strip.text = element_text(size = 16, face = "bold"))



pp = plot_grid(dbgap1, dbgap2,ega1, ega2, labels = c('A', 'B', "C", "D"), ncol = 1, rel_heights = c(0.25,0.5, 0.25, 0.5))

png('../figures/figure3.png',
    width = 1500, height = 1500, res = 150)
pp
dev.off()

### add studies classification
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


pp = plot_grid(dbgap1, dbgap2,dbgap3, ega1, ega2,ega3,
               labels = c('A', 'B', "C", "D","E", "F"),
               ncol = 1, rel_heights = c(0.25,0.5,0.5, 0.25, 0.5,0.5))
pp

png('../figures/figure3_alternative.png',
    width = 1500, height = 2000, res = 150)
pp
dev.off()
