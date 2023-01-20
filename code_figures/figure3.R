library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(lubridate)
library(patchwork) 
library(cowplot)
library(zoo)

# Load data
ega = fread("../ega/all_EGA_samples.txt")

ega$date = as.Date(parse_date_time(ega$date_study, orders = c('ymd')))
ega$ym = as.yearmon(ega$date)
ega$month = month(ega$date_study)
ega$year = str_split_fixed(ega$date_study, '-', 2)[,1]
<<<<<<< HEAD:code_figures/figure3_4.R
colnames(ega)[1] = "study_id"
ega_m = melt(ega, id.vars = c("study_id", "repository", "ym", "year", "total", "date", "month", "date_study"))
ega_m$year[ega_m$year=="1980"] = NA
=======
colnames(ega)[1] = "dataset_id"
ega_m = melt(ega, id.vars = c("dataset_id", "repository", "date_study", "year", "total"))
ega_m$year[ega_m$year=="1980"] = "NA"
>>>>>>> parent of 547c59c... updated code and figures:code_figures/figure3.R

dbgap = fread("../dbpgap/summary_fourth.csv")
dbgap$total = dbgap$male +  dbgap$female +  dbgap$unknown
dbgap$date = as.Date(parse_date_time(dbgap$date, orders = c('mdy', 'dmy','ymd', "%d %m &y %H:%M:%S %Y")))
dbgap$ym = as.yearmon(dbgap$date)
dbgap$month = month(dbgap$date)
dbgap$year =str_split_fixed(dbgap$date, '-', 2)[,1]
<<<<<<< HEAD:code_figures/figure3_4.R
spl = str_split_fixed(str_remove(dbgap$filename,'\\.\\/data\\/'), '\\.',6)
dbgap$study_id = paste(spl[,1],spl[,2],spl[,5], sep=".")
dbgap2 =dbgap%>%group_by(study_id)%>%
  summarise(male = sum(male),
            female = sum(female),
            unknown = sum (unknown),
            total = sum (total),
            year = max(year),
            ym = max(ym))
dbgap_m = melt(dbgap2, id.vars= c("study_id", 'year', "ym","total"))
=======
dbgap_m = melt(dbgap, id.vars= c("V1", "n", "dataset_id", "filename", "date",'year', "total"))
>>>>>>> parent of 547c59c... updated code and figures:code_figures/figure3.R
dbgap_m$repository = "dbGaP"
dbgap_m$year[dbgap_m$year==""] = "NA"

# bind datasets
ega_dbgap = rbindlist(list(ega_m, dbgap_m), use.names = T, fill = T)

#total samples per year
ega_dbgap = ega_dbgap %>% group_by(repository,year) %>% mutate(total_year = sum(value))

################
# sample level #
################
ega_dbgap_percent = subset(ega_dbgap) %>% group_by(variable, repository, year) %>%
  summarise(value_percent = sum(value) / unique(total_year),
            total_year = unique(total_year),
            sd= sd(value))


ega_dbgap_percent$year = factor(ega_dbgap_percent$year ,
                                 levels = c('NA','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021'))


ega1 = ggplot(subset(ega_dbgap_percent, repository == "EGA"),
              aes(x=year,  group=repository))+
  geom_point(aes(y = total_year), size = 3,  color = "#ed553b")+
  geom_line(aes(y = total_year), color = "#ed553b")+
  ylab("# samples")+
  xlab("Year")+
  theme_minimal()+
<<<<<<< HEAD:code_figures/figure3_4.R
  ggtitle("EGA")+
=======
  facet_grid(repository~.)+
>>>>>>> parent of 547c59c... updated code and figures:code_figures/figure3.R
  theme(axis.text.x = element_text(size = 10),
        strip.text = element_text(size = 16, face = "bold"))

ega2 = ggplot(subset(ega_dbgap_percent, repository =="EGA"),
                             aes(x=year,  color=variable, group=variable))+
  geom_point(aes(y =value_percent ), size = 3)+
  geom_line(aes(y = value_percent))+
  ylab("Percentage of samples")+
  xlab("Year")+
  theme_minimal()+
<<<<<<< HEAD:code_figures/figure3_4.R
=======
  scale_y_continuous(labels=scales::percent)+#,
  #sec.axis = sec_axis(~.*0.01, name="Second Axis")) +
  facet_grid(repository~.)+
>>>>>>> parent of 547c59c... updated code and figures:code_figures/figure3.R
  scale_color_manual(values = c("#20639b", "#3caea3","#f6d55c"),
                     labels = c("Male", "Female", "Unknown"),
                     name ="")+
  theme(legend.position = "top",
        axis.text.x = element_text(size = 10),
        strip.text = element_text(size = 16, face = "bold"))

ega2

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

dbgap2

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


<<<<<<< HEAD:code_figures/figure3_4.R
ega_dbgap = rbind(ega,dbgapb, fill = T)
=======
dbgap$phe = substr(dbgap$filename, 8,19)

ega_dbgap = rbind(ega,dbgap[colnames(ega[,-6])])
>>>>>>> parent of 547c59c... updated code and figures:code_figures/figure3.R
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

<<<<<<< HEAD:code_figures/figure3_4.R

library(RColorBrewer)
=======
cbp1 <- c( "#E69F00", "#56B4E9", "#009E73",
           "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
>>>>>>> parent of 547c59c... updated code and figures:code_figures/figure3.R

dbgap3 = ggplot(subset(ega_dbgap_percent, repository == "dbGaP"),
                aes(x= year, color = label, group =label ))+
  geom_point(aes(y = value_percent), size = 3)+
  geom_line(aes(y = value_percent))+
  ylab("Percentage studies")+
  xlab("Sex specification in samples found in the study")+
  theme_minimal()+
<<<<<<< HEAD:code_figures/figure3_4.R
  scale_color_manual(values = brewer.pal(7,"Set2"),
                    breaks = c("F&M","F&M&U","U","F","M","F&U","M&U"),
                    labels = c("F&M","F&M&U","U","F","M","F&U","M&U"))+
=======
  facet_grid(repository~., scales= "free_y")+
  #scale_color_manual(values = cbp1)+
  scale_color_brewer(palette = "Set2")+
>>>>>>> parent of 547c59c... updated code and figures:code_figures/figure3.R
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


<<<<<<< HEAD:code_figures/figure3_4.R


png('../figures/figure3.png',
    width = 2700, height = 2500, res = 300)
plot_grid(dbgap1, dbgap2,dbgap3,
          labels = c('A', 'B', "C"),
          ncol = 1, rel_heights = c(0.25,0.5,0.5))
dev.off()

=======
pp = plot_grid(dbgap1, dbgap2,dbgap3, ega1, ega2,ega3,
               labels = c('A', 'B', "C", "D","E", "F"),
               ncol = 1, rel_heights = c(0.25,0.5,0.5, 0.25, 0.5,0.5))
pp
>>>>>>> parent of 547c59c... updated code and figures:code_figures/figure3.R

png('../figures/figure3_alternative.png',
    width = 1500, height = 2000, res = 150)
pp
dev.off()
