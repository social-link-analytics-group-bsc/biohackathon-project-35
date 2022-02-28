library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
# Load data
ega = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/EGA_with_NULL.csv")
ega$total_all = length(unique(ega$ega_stable_id))
#d2 = melt(d,id.vars = c("ega_stable_id", "repository", "to_char", "total"))
dbgap = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/biohackathon-project-35/dbpgap/summary_fourth.csv")
dbgap$total = dbgap$male +  dbgap$female +  dbgap$unknown
dbgap$repository="dbGaP"
dbgap$total_all = length(unique(dbgap$dataset_id))
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
# percent
ega_dbgap_percent = unique(r %>% group_by(label, repository) %>%
  summarise(value_percent = sum(c) / total_all))
f = arrange(ega_dbgap_percent, desc(value_percent))$label
ega_dbgap_percent$label = factor(ega_dbgap_percent$label, levels = unique(f))

study_plot_percent = ggplot(ega_dbgap_percent, aes(x= label,y = value_percent, fill = label))+
  geom_bar(stat="identity", width=0.75)+
  ylab("Percentage of EGA studies")+
  xlab("Sex specification in samples found in the study")+
  theme_minimal()+
  facet_grid(~repository)+
  scale_y_continuous(labels=scales::percent) +
  theme(legend.position = "none",
        axis.text.x = element_text(size = 10, face = "bold"),
       # axis.text.x = element_text(size = 12),
        strip.text = element_text(size = 16, face = "bold"))
study_plot_percent
png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/figures/figure2.png',
    width = 1500, height = 750, res = 200)
study_plot_percent
dev.off()

