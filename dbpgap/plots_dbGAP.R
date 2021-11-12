library(data.table)
library(stringr)
library(dplyr)
summary = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/dbGAP/summary.csv")
filtered_summary = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/dbGAP/filtered_summary.csv")

filtered_summary

# filtering by date (2018 onwards)
filtered_summary$date_nchar = nchar(filtered_summary$date_study)
subset(filtered_summary, date_nchar < 10 ) ## all dates have same length but different formats. Extract year

filtered_summary_otherdateformat = filtered_summary[!str_detect(filtered_summary$date_study, '/'), ]
filtered_summary_otherdateformat$year = str_sub(filtered_summary_otherdateformat$date_study ,-4,-1)

filtered_summary_dateformat = filtered_summary[str_detect(filtered_summary$date_study, '/'), ]
year = c()
for(i in 1:nrow(filtered_summary_dateformat)){
  d = str_split_fixed(filtered_summary_dateformat[i, 'date_study'], '/', 3)
  year = c(year, d[nchar(d) == 4])
}
filtered_summary_dateformat$ year = year


filtered_summary = rbind(filtered_summary_otherdateformat, filtered_summary_dateformat)

filtered_summary2018 = subset(filtered_summary, year >= 2018 & !is.na(male) & !is.na(female) & !is.na(unknown) & !is.na(total))

length(unique(filtered_summary $dbgap_study_id))
# 7864 studies
length(unique(filtered_summary2018 $dbgap_study_id))
# 4315 studies
sum(filtered_summary2018 $total)
# 10547994 samples
################
# sample level #
################
library(reshape2)
d2 = melt(filtered_summary2018, id.vars = c("dbgap_study_id", "repository", "date_study","date_nchar", "year", "total", "V1"))
d2

d2_percent = d2 %>% group_by(variable) %>%
  summarise(value_percent = sum(value, na.rm = T) / sum(filtered_summary2018$total))


#subset(filtered_summary2018, dbgap_stable_id == "./data/phs002007.v1.pht010434.v1.p1.Innate_Tcells_GEO.var_report.xml")
library(ggplot2)
sample_plot_percent = ggplot(d2_percent, aes(x=variable, y = value_percent, fill=variable))+
  geom_bar(stat="identity")+
  ylab("Percentage of samples")+
  xlab("Biological sex specification")+
  theme_bw()+
  scale_y_continuous(labels=scales::percent) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 15, face = "bold"))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/dbGAP/samples_dbgap_percent.png',
    width = 1000, height = 1000, res = 200)
sample_plot_percent
dev.off()

### by study
d3 = d2 %>% group_by(variable) %>% 
  mutate(total_variable = sum(filtered_summary2018$total)) %>%
  group_by(variable, year) %>%
  summarise(value_percent = sum(value)/unique(total_variable) )


sample_plot_year_percent = ggplot(d3, aes(x=year, y = value_percent, fill=variable))+
  geom_bar(stat="identity")+
  ylab("Percentage of samples")+
  xlab("Year of the study")+
  theme_bw()+
  facet_grid(~variable)+
  scale_y_continuous(labels=scales::percent) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 15, face = "bold"))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/dbGAP/samples_dbgap_year_percent.png',
    width = 2000, height = 1000, res = 200)
sample_plot_year_percent
dev.off()

################
# study level  #
################

female_only =subset(filtered_summary2018, male == 0 )
female_only$label = 'female_only'

male_only = subset(filtered_summary2018, female == 0 )
male_only$label = 'male_only'

female_and_male = subset(filtered_summary2018, female != 0 & male != 0 )
female_and_male$label = 'female_and_male'

r = rbind(female_only, male_only, female_and_male)
study_plot_percent = ggplot(r, aes(x= label, fill = label))+
  geom_bar(aes(y= ..count.. /sum(..count..)))+
  ylab("Percentage of EGA studies")+
  xlab("Sex specification in samples found in the study")+
  theme_bw()+
  scale_y_continuous(labels=scales::percent) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 10, face = "bold", angle = 45, vjust = 1, hjust = 1))

study_plot_percent 
# 100% of studies in filtered dataset contain male and female samples. No need of plot ?



r $n= 1
rb = r%>% mutate (total_studies = nrow(r)) %>%
  group_by(year,label) %>%
  summarise(value_percent = sum(n)/ unique(total_studies))  

study_plot_year_percent=  ggplot(rb, aes(x= year,y = value_percent,  fill = label))+
  geom_bar(stat = "identity")+
  ylab("Percentage of dbGAP studies")+
  xlab("Year")+
  theme_bw()+
  facet_grid(~label)+
  scale_y_continuous(labels=scales::percent) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 10, face = "bold", angle = 45, vjust = 1, hjust = 1))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/dbGAP/dbgap_female_male_year_percent.png',
    width = 1000, height = 1000, res = 200)
study_plot_year_percent
dev.off()


### boxplot
d3 = melt(filtered_summary, id.vars = c("dbgap_study_id", "repository", "date_study","date_nchar", "year", "total", "V1"))
d2
d3 = d3 %>% 
  mutate(value_percent = (value / total) * 100)

library(ggplot2)
bp = ggplot(d3, aes(x = variable, y = value_percent , fill = variable))+
  # geom_dotplot()+
  #geom_violin()+
  geom_boxplot(width=0.5)+
  facet_grid(~year)+
  xlab("Percentage of samples")+
  xlab("Sex classification")+
  theme_bw()+
  theme(
    axis.text.x = element_text(size = 10, face = "bold", angle = 45, vjust = 1, hjust = 1))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/dbGAP/boxplot_dbgap_percentage_samples_gender_years.png',
    width = 3000, height = 1000, res = 200)
bp
dev.off()

bp2 = ggplot(d3, aes(x = year, y = value_percent , color = variable))+
  # geom_dotplot()+
  #geom_violin()+
  geom_boxplot(position = "dodge", width=0.5)+
  ylab("Percentage of samples")+
  xlab("Year")+
  theme_bw()+
  theme(
    axis.text.x = element_text(size = 10, face = "bold", angle = 45, vjust = 1, hjust = 1))+
stat_summary(
  fun = median,
  geom = 'line', size = 2,
  aes(group = variable, colour = variable),
  position = position_dodge(width = 0.9) #this has to be added
)

bp2
png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/dbGAP/boxplot_dbgap_percentage_samples_gender_years2.png',
    width = 3000, height = 1000, res = 200)
bp2
dev.off()
