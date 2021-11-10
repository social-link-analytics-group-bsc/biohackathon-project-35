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
sample_plot = ggplot(d2, aes(x=variable, y = value, fill=variable))+
  geom_bar(stat="identity")+
  ylab("Samples number")+
  xlab("Biological sex specification")+
  theme_bw()+
  theme(legend.position = "none",
        axis.text.x = element_text(size = 15, face = "bold"))
  
png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/gender_bias_samples_ega.png',
    width = 1000, height = 1000, res = 200)
sample_plot
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

table(r$label)

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
