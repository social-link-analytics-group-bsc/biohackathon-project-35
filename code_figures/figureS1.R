library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(lubridate)

# Mauricio's data
library(data.table)
library(stringr)
raw = readLines("..ega//raw_data_sample_tag.txt")
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
sample_date$n = 1
total = length(unique(sample_date$ega_sample))
sum_sample_date = unique(sample_date[,c(1:2,4)]) %>% group_by (gender) %>% summarise (percent = sum(n)/total * 100)
sum_sample_date $gender = factor(sum_sample_date $gender, levels = c("male", "female", "unknown"))
library(ggplot2)
sample_date_plot = ggplot(sum_sample_date,aes(x = gender,y = percent, fill = gender))+
  geom_bar (stat="identity")+
  #facet_grid(~dataset_year)+  
  ylab("Percentage of unique samples")+
  xlab("Biological sex specification")+
  theme_minimal()+
  scale_fill_manual(values = c("#20639b", "#3caea3","#f6d55c"))+
  theme_bw()+
  theme(legend.position = "none",
        axis.text.x = element_text(size = 12),
        strip.text = element_text(size = 16, face = "bold"))

sample_date_plot

png('../figures/figureS1.png',
    width = 700, height = 700, res = 200)
sample_date_plot
dev.off()

