library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)

# Load data
d = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/EGA_with_NULL.csv")
d2 = melt(d,id.vars = c("ega_stable_id", "repository", "to_char", "total"))

################
# sample level #
################
d2_percent = d2 %>% group_by(variable) %>%
  summarise(value_percent = sum(value) / sum(d$total))

sample_plot = ggplot(d2, aes(x=variable, y = value, fill=variable))+
  geom_bar(stat="identity")+
  ylab("Samples number")+
  xlab("Biological sex specification")+
  theme_bw()+
  scale_y_continuous(labels=scales::percent) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 15, face = "bold"))
  
png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_samples_ega.png',
    width = 1000, height = 1000, res = 200)
sample_plot
dev.off()

sample_plot_percent = ggplot(d2_percent, aes(x=variable, y = value_percent, fill=variable))+
  geom_bar(stat="identity")+
  ylab("Percentage of samples")+
  xlab("Biological sex specification")+
  theme_bw()+
  scale_y_continuous(labels=scales::percent) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 15, face = "bold"))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_samples_ega_percent.png',
    width = 1000, height = 1000, res = 200)
sample_plot_percent
dev.off()

# by date
d2$date = str_split_fixed(d2$to_char, '-', 2)[,1]

sample_plot_year = ggplot(d2, aes(x=date, y = value, fill=variable))+
  geom_bar(stat="identity")+
  ylab("Samples number")+
  xlab("Year of the study")+
  theme_bw()+
  facet_grid(~variable)+
  theme(legend.position = "none",
        axis.text.x = element_text(size = 15, face = "bold"))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_samples_ega_year.png',
    width = 2000, height = 1000, res = 200)
sample_plot_year
dev.off()


d3 = d2 %>% group_by(variable) %>% 
  mutate(total_variable = sum(d$total)) %>%
  group_by(variable, date) %>%
  summarise(value_percent = sum(value)/unique(total_variable) )
  

sample_plot_year_percent = ggplot(d3, aes(x=date, y = value_percent, fill=variable))+
  geom_bar(stat="identity")+
  ylab("Percentage of samples")+
  xlab("Year of the study")+
  theme_bw()+
  facet_grid(~variable)+
  scale_y_continuous(labels=scales::percent) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 15, face = "bold"))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_samples_ega_year_percent.png',
    width = 2000, height = 1000, res = 200)
sample_plot_year_percent
dev.off()

################
# study level  #
################
unknown_only = subset(d, male == 0 & female == 0)
unknown_only$label = "uknown_only"

female_only = subset(subset(d, male == 0 & unknown == 0))
female_only$label = 'female_only'

male_only = subset(d, female == 0 & unknown == 0)
male_only$label = 'male_only'

female_and_male = subset(d, female != 0 & male != 0 & unknown == 0)
female_and_male$label = 'female_and_male'

female_and_unknown = subset(d, female != 0 & male == 0 & unknown != 0)
female_and_unknown$label = 'female_and_unknown'

male_and_unknown = subset(d, female == 0 & male != 0 & unknown != 0)
male_and_unknown$label = 'male_and_unknown'

female_and_male_and_unknown = subset(d, female != 0 & male != 0 & unknown != 0)
female_and_male_and_unknown$label = 'female_and_male_and_unknown'


r = rbind(unknown_only, female_only, male_only, female_and_male, female_and_unknown, male_and_unknown, female_and_male_and_unknown)
study_plot = ggplot(r, aes(x= label, fill = label))+
  geom_bar(stat='count')+
  ylab("Number of EGA studies")+
  xlab("Sex specification in samples found in the study")+
  theme_bw()+
  theme(legend.position = "none",
        axis.text.x = element_text(size = 10, face = "bold", angle = 45, vjust = 1, hjust = 1))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_study_ega.png',
    width = 1000, height = 1000, res = 200)
study_plot
dev.off()

# percent
study_plot_percent = ggplot(r, aes(x= label, fill = label))+
  geom_bar(aes(y= ..count.. /sum(..count..)))+
  ylab("Percentage of EGA studies")+
  xlab("Sex specification in samples found in the study")+
  theme_bw()+
  scale_y_continuous(labels=scales::percent) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 10, face = "bold", angle = 45, vjust = 1, hjust = 1))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_study_ega_percent.png',
    width = 1000, height = 1000, res = 200)
study_plot_percent
dev.off()



r2 = melt(r, id.vars = c("ega_stable_id", "total", "to_char", "repository", "label"))
study_plot2 = ggplot(subset(r2, label %in% c('female_and_unknown', 'male_and_unknown', 'female_and_male_and_unknown')),
       aes(x= variable, y = value, fill = variable))+
  geom_bar(stat='identity')+
  ylab("Number of samples")+
  xlab("Sex specification in samples")+
  theme_bw()+
  facet_wrap(~label, scales = "free_y", nrow = 1)+
  theme(legend.position = "none",
        axis.text.x = element_text(size = 10, face = "bold", angle = 45, vjust = 1, hjust = 1))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_study_ega_samplelevel.png',
    width = 1600, height = 800, res = 200)
study_plot2
dev.off()

r2b = r2 %>% group_by(label) %>%
  mutate (total = sum(value)) %>%
  group_by(label,variable) %>%
  summarise(value_percent = sum(value)/unique(total))
study_plot2_percent = ggplot(subset(r2b, label %in% c('female_and_unknown', 'male_and_unknown', 'female_and_male_and_unknown')),
                     aes(x= variable, y = value_percent, fill = variable))+
  geom_bar(stat='identity')+
  ylab("Percentage of samples")+
  xlab("Sex specification in samples")+
  theme_bw()+
  facet_wrap(~label, nrow = 1)+
  scale_y_continuous(labels=scales::percent) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 10, face = "bold", angle = 45, vjust = 1, hjust = 1))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_study_ega_samplelevel_percent.png',
    width = 1600, height = 800, res = 200)
study_plot2_percent
dev.off()


# Merge with Mauricio's data
colnames(r2)[1] = "ega_study"
r3 = left_join(r2, raw_pg_spread)


t0 = as.data.frame(table(as.character(unique(subset(r3, label == "female_and_male_and_unknown"& gender == "unknown")[, c("ega_sample", "phenotype")])$phenotype)))
t1 = as.data.frame(table(as.character(unique(subset(r3, label == "female_and_unknown" & gender == "unknown")
                                             [, c("ega_sample", "phenotype")])$phenotype)))
t2 = as.data.frame(table(as.character(unique(subset(r3, label == "male_and_unknown"& gender == "unknown")[, c("ega_sample", "phenotype")])$phenotype)))

colnames(t0) = c("phenotype", "number of samples")
colnames(t1) = c("phenotype", "number of samples")
colnames(t2) = c("phenotype", "number of samples")
knitr::kable(t0, "pipe")
knitr::kable(t1, "pipe")
knitr::kable(t2, "pipe")


# by date
r$date = str_split_fixed(r$to_char, '-', 2)[,1]


study_plot_year=  ggplot(r, aes(x= date, fill = label))+
  geom_bar(stat='count')+
  ylab("Number of EGA studies")+
  xlab("Year")+
  theme_bw()+
  facet_grid(~label)+
  theme(legend.position = "none",
        axis.text.x = element_text(size = 10, face = "bold", angle = 45, vjust = 1, hjust = 1))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_study_ega_year.png',
    width = 2000, height = 1000, res = 200)
study_plot_year
dev.off()

r$n = 1
rb = r%>% mutate (total_studies = nrow(r)) %>%
  group_by(date, label) %>%
  summarise(value_percent = sum(n)/ unique(total_studies))  

study_plot_year_percent=  ggplot(rb, aes(x= date,y = value_percent,  fill = label))+
  geom_bar(stat = "identity")+
  ylab("Percentage of EGA studies")+
  xlab("Year")+
  theme_bw()+
  facet_grid(~label)+
  scale_y_continuous(labels=scales::percent) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 10, face = "bold", angle = 45, vjust = 1, hjust = 1))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_study_ega_year_percent.png',
    width = 2000, height = 1000, res = 200)
study_plot_year_percent
dev.off()

################################################
# Mauricio's data
library(data.table)
library(stringr)
raw = readLines("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/raw_data_sample_tag.txt")
raw = as.data.frame(str_split_fixed(raw, ',', 8))
raw = data.table(raw)
colnames(raw) = c('ega_study','study_date', 'ega_dataset','dataset_date', 'ega_sample','sample_date', 'variable', 'value')
library(reshape2)
library(dplyr)
library(tidyr)

raw_pg = subset(raw, variable %in% c("phenotype", "gender"))
raw_pg_spread = raw_pg %>% spread(variable, value)
raw_pg_spread$dataset_year = str_split_fixed(raw_pg_spread$dataset_date, '-', 2)[,1]
unique(raw_pg_spread$dataset_year)

raw_pg_spread

raw_pg_spread$sample_year = str_split_fixed(raw_pg_spread$sample_creationTime, '-', 2)[,1]
unique(raw_pg_spread$sample_year)

sample_date = unique(raw_pg_spread[,c("ega_sample","gender", "dataset_year")])
sample_date$gender[is.na(sample_date$gender )] = "unknown"
library(ggplot2)
sample_date_plot = ggplot(sample_date,aes(x = gender, fill = gender))+
  geom_bar (stat="count")+
  facet_grid(~dataset_year)+  
  ylab("Samples number")+
  xlab("Biological sex classification")+
  scale_y_continuous(labels=scales::percent) +
  theme_bw()+
  theme(legend.position = "none",
        axis.text.x = element_text(size = 7, face = "bold"))



png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_samples_ega_yearofsample2.png',
    width = 2000, height = 1000, res = 200)
sample_date_plot
dev.off()

sample_date$n = 1
sample_date2 = sample_date %>% group_by(gender, dataset_year) %>%
  summarise(value_percent = sum(n) / nrow(sample_date))

sample_date_plot_percent = ggplot(sample_date2,aes(x = gender, y = value_percent, fill = gender))+
  geom_bar (stat="identity")+
  facet_grid(~dataset_year)+  
  ylab("Percentage of samples")+
  xlab("Biological sex classification")+
  scale_y_continuous(labels=scales::percent) +
  theme_bw()+
  theme(legend.position = "none",
        axis.text.x = element_text(size = 7, face = "bold"))



png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_samples_ega_yearofsample2_percent.png',
    width = 2000, height = 1000, res = 200)
sample_date_plot_percent
dev.off()

sample_date %>% group_by(dataset_year) %>% mutate (total = sum(n)) %>% group_by(dataset_year, gender) %>% summarise(percent = sum(n)/unique(total))


study_sample_date = unique(raw_pg_spread[,c("ega_study", "dataset_year")])
sss = left_join(study_sample_date, d[,c("ega_stable_id", "to_char")], by = c("ega_study"="ega_stable_id"))

sss$date_study = str_split_fixed(sss$to_char, '-', 2)[,1]


sss_plot = ggplot(sss ,aes(x = date_study, fill= dataset_year))+
  geom_bar (stat="count")+
  ylab("Number of studies")+
  xlab("Date of study")+
  theme_bw()+
  scale_fill_discrete(name = "Date of \nconsidered \nsamples")+
  theme(
        axis.text.x = element_text(size = 10, face = "bold"))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_yearofsample_yearstudy.png',
    width = 1000, height = 1000, res = 200)
sss_plot
dev.off()


study_sample_date = raw_pg_spread[,c("ega_study", "dataset_year")]
sss = left_join(study_sample_date, d[,c("ega_stable_id", "to_char")], by = c("ega_study"="ega_stable_id"))

sss$date_study = str_split_fixed(sss$to_char, '-', 2)[,1]


sss_plot = ggplot(sss ,aes(x = date_study, fill= dataset_year))+
  geom_bar (stat="count")+
  ylab("Number of samples")+
  xlab("Date of study")+
  theme_bw()+
  scale_fill_discrete(name = "Date of \nconsidered \nsamples")+
  theme(
    axis.text.x = element_text(size = 10, face = "bold"))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_yearofsample_yearstudy2.png',
    width = 1000, height = 1000, res = 200)
sss_plot
dev.off()


study_date_plot = ggplot(study_sample_date ,aes(x = year))+
  geom_bar (stat="count")+
  ylab("Number of studies")+
  xlab("Year of the SAMPLE included in the study")+
  theme_bw()+
  theme(legend.position = "none",
        axis.text.x = element_text(size = 10, face = "bold"))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_samples_ega_yearofsample.png',
    width = 2000, height = 1000, res = 200)
study_date_plot
dev.off()



########################################3
# all_EGA_samples.txt
#########################################
library(data.table)
library(stringr)
all_ega_samples = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/all_EGA_samples.txt")
all_ega_samples$year =  str_split_fixed(all_ega_samples$date_study, '-', 2)[,1]
all_ega_samples

library(reshape2)
all_ega_samples_m = melt(all_ega_samples,id.vars = c("ega_stable_id", "repository", "date_study","year", "total"))

library(dplyr)
all_ega_samples_m = all_ega_samples_m %>% 
  mutate(value_percent = (value / total) * 100)

library(ggplot2)
bp = ggplot(all_ega_samples_m, aes(x = variable, y = value_percent , fill = variable))+
 # geom_dotplot()+
  #geom_violin()+
  geom_boxplot(width=0.5)+
  facet_grid(~year)+
  xlab("Percentage of samples")+
  xlab("Sex classification")+
  theme_bw()+
  theme(
        axis.text.x = element_text(size = 10, face = "bold", angle = 45, vjust = 1, hjust = 1))

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/boxplot_ega_percentage_samples_gender_years.png',
    width = 3000, height = 1000, res = 200)
bp
dev.off()
