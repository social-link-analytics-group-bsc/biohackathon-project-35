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
ega = fread("../../ega/all_EGA_samples.txt")

ega$date = as.Date(parse_date_time(ega$date_study, orders = c('ymd')))
ega$ym = as.yearmon(ega$date)
ega$month = month(ega$date_study)
ega$year = str_split_fixed(ega$date_study, '-', 2)[,1]
colnames(ega)[1] = "study_id"
ega_m = melt(ega, id.vars = c("study_id", "repository", "ym", "year", "total", "date", "month", "date_study"))
ega_m$year[ega_m$year=="1980"] = NA

dbgap = fread("./dbgap_may2024.csv")
dbgap$repository = "dbGaP"
dbgap= dbgap[,-c("ym")]
dbgap_m = melt(dbgap, id.vars= c("study_id", 'year', "total", "repository"))

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
            sd= sd(value),
            n_studies = n_distinct(study_id))


ega_dbgap_percent$year = factor(ega_dbgap_percent$year ,
                                 levels = c(NA,'2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021'))



coeff = 1000
ega1 = ggplot(subset(ega_dbgap_percent,
                     repository == "EGA" & !is.na(year)),
              aes(x=year,  group=repository))+
  geom_point(aes(y = total_year/coeff), size = 3,  color = "#ed553b")+
  geom_line(aes(y = total_year/coeff), color = "#ed553b")+
  geom_point(aes(y = n_studies), size = 3,  color = "#800080")+
  geom_line(aes(y = n_studies), color = "#800080")+
 # ylab("# samples")+
  xlab("Year")+
  theme_minimal()+
  ggtitle("EGA")+
  theme(axis.text.x = element_text(size = 10),
        strip.text = element_text(size = 16, face = "bold"),
        plot.title = element_text(hjust = 0.5, face= "bold", size = 20 ),
        axis.title.y = element_text(color ="#800080" , size=13),
        axis.title.y.right = element_text(color = "#ed553b", size=13)) +
  scale_y_continuous(
          # Features of the first axis
          name = "# studies",
          # Add a second axis and specify its features
          sec.axis = sec_axis(~.*coeff, name="# samples")
        )

ega1


ega2 = ggplot(subset(ega_dbgap_percent, repository =="EGA"& !is.na(year)),
                             aes(x=year,  color=variable, group=variable))+
  geom_point(aes(y =value_percent ), size = 3)+
  geom_line(aes(y = value_percent))+
  ylab("Percentage of samples")+
  xlab("Year")+
  theme_minimal()+
  scale_color_manual(values = c("#20639b", "#3caea3","#f6d55c"),
                     labels = c("Male", "Female", "Unknown"),
                     name ="")+
  theme(legend.position = "top",
        axis.text.x = element_text(size = 10),
        strip.text = element_text(size = 16, face = "bold"))

ega2


coeff = 1000
dbgap1 = ggplot(subset(ega_dbgap_percent, repository == "dbGaP"& !is.na(year)),
              aes(x=year,  group=repository))+
  # geom_line(aes(y = total_year),fill = "grey30", stat="identity", width= 0.8)+
  geom_point(aes(y = total_year/coeff), size = 3,  color = "#ed553b")+
  geom_line(aes(y = total_year/coeff), color = "#ed553b")+
  geom_point(aes(y = n_studies), size = 3,  color = "#800080")+
  geom_line(aes(y = n_studies), color = "#800080")+
  ylab("# samples")+
  xlab("Year")+
  theme_minimal()+
  ggtitle("dbGaP")+
 # facet_grid(repository~.)+
  theme(axis.text.x = element_text(size = 10),
        strip.text = element_text(size = 16, face = "bold"),
        plot.title = element_text(hjust = 0.5, face= "bold", size = 20 ),
        axis.title.y = element_text(color ="#800080" , size=13),
        axis.title.y.right = element_text(color = "#ed553b", size=13)) +
  scale_y_continuous(
    # Features of the first axis
    name = "# studies",
    # Add a second axis and specify its features
    sec.axis = sec_axis(~.*coeff, name="# samples")
  )

dbgap1

dbgap2 = ggplot(subset(ega_dbgap_percent, repository =="dbGaP"& !is.na(year)),
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
 # facet_grid(repository~.)+
  scale_color_manual(values = c("#20639b", "#3caea3","#f6d55c"),
                     labels = c("Male", "Female", "Unknown"),
                     name ="")+
  #scale_x_discrete(labels= c("M", "F", "U"))+
  theme(legend.position = "top",
        axis.text.x = element_text(size = 10),
        strip.text = element_text(size = 16, face = "bold"))

dbgap2

#pp = plot_grid(dbgap1, dbgap2,ega1, ega2, labels = c('A', 'B', "C", "D"), ncol = 1, rel_heights = c(0.25,0.5, 0.25, 0.5))

#png('../figures/figure3.png',
#    width = 1500, height = 1500, res = 150)
#pp
#dev.off()


### add studies classification
library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(lubridate)
# Load data
ega = fread("../../ega/all_EGA_samples.txt")
ega$total_all = length(unique(ega$ega_stable_id))
ega$year = str_split_fixed(ega$date_study, '-', 2)[,1]
#d2 = melt(d,id.vars = c("ega_stable_id", "repository", "to_char", "total"))
dbgap = fread("./dbgap_may2024.csv")
dbgap$repository = "dbGaP"
dbgap= dbgap[,-c("ym")]
dbgap$total_all = length(unique(dbgap$study_id))


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
#write.table(r, 'ega_dbgap_studies_classification.txt', sep = "\t")
# percent
r = unique(r %>% group_by(repository,year) %>%
                             mutate(total_year = sum(c)))

#fwrite(subset(r, year <= 2015 & label == "U" & repository == "EGA"),
#       'unknown_EGAstudies_before2016.txt')


ega_dbgap_percent = unique(r %>% group_by(label, repository,year) %>%
                             summarise(value_percent = sum(c) / total_year))
f = arrange(ega_dbgap_percent, desc(value_percent))$label
ega_dbgap_percent$label = factor(ega_dbgap_percent$label, levels = c("F&M", "F&M&U", "U", "F" , "M", "F&U" ,"M&U"))

ega_dbgap_percent$year[ega_dbgap_percent$year == 1980] = NA
ega_dbgap_percent$year = factor(ega_dbgap_percent$year,
                                levels = c(NA,'2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021'))


library(RColorBrewer)

dbgap3 = ggplot(subset(ega_dbgap_percent, repository == "dbGaP"& !is.na(year)),
                aes(x= year, color = label, group =label ))+
  geom_point(aes(y = value_percent), size = 3)+
  geom_line(aes(y = value_percent))+
  ylab("Percentage studies")+
  xlab("Sex classification in samples found in the study")+
  theme_minimal()+
  scale_color_manual(values = brewer.pal(7,"Set2"),
                     breaks = c("U","F&M","F&M&U","F","M","M&U","F&U"),
                     labels = c("U","F&M","F&M&U","F","M","M&U","F&U"))+
  theme(axis.text.x = element_text(size = 10),
        legend.position="top",
        legend.box = "horizontal",
        strip.text = element_text(size = 16, face = "bold"))+
  guides(color=guide_legend(nrow=1,byrow=TRUE, title = "Study classification"))+
  ylim(0,1)

dbgap3

ega3 = ggplot(subset(ega_dbgap_percent, repository == "EGA"& !is.na(year)),
                aes(x= year, color = label, group =label ))+
  geom_point(aes(y = value_percent), size = 3)+
  geom_line(aes(y = value_percent))+
  ylab("Percentage studies")+
  xlab("Sex classification in samples found in the study")+
  theme_minimal()+
  #facet_grid(repository~., scales= "free_y")+
  #scale_color_manual(values = cbp1)+
  #scale_color_brewer(palette = "Set2")+
  scale_color_manual(values = brewer.pal(7,"Set2"),
                    breaks = c("U","F&M","F&M&U","F","M","M&U","F&U"),
                    labels = c("U","F&M","F&M&U","F","M","M&U","F&U"))+
  theme(axis.text.x = element_text(size = 10),
        legend.position="top",
        legend.box = "horizontal",
        strip.text = element_text(size = 16, face = "bold"))+
  guides(color=guide_legend(nrow=1,byrow=TRUE, title = "Study classification"))

ega3


png('../../figures/figure3_may2024.png',
    width = 2700, height = 2800, res = 300)
plot_grid(dbgap1, dbgap2,dbgap3,
          labels = c('A', 'B', "C"),
          ncol = 1, rel_heights = c(0.35,0.5,0.5))
dev.off()


png('../../figures/figure4_may2024.png',
    width = 2700, height = 2800, res = 300)
plot_grid(ega1, ega2,ega3,
          labels = c('A', 'B', "C"),
          ncol = 1, rel_heights = c(0.35,0.5,0.5))
dev.off()
