library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(lubridate)

# Load data
ega = fread("../ega/EGA_with_NULL.csv")
ega_m = melt(ega, id.vars = c("ega_stable_id", "repository", "to_char", "total"))
colnames(ega_m)[colnames(ega_m) == "ega_stable_id"] = "dataset_id"

dbgap = fread("../dbpgap/summary_fourth.csv")
dbgap$total = dbgap$male +  dbgap$female +  dbgap$unknown
dbgap$date = parse_date_time(dbgap$date, orders = c('mdy', 'dmy','ymd', "%d %m &y %H:%M:%S %Y"))
dbgap$year =str_split_fixed(dbgap$date, '-', 2)[,1]
dbgap$repository = "dbGaP"
dbgap$year[dbgap$year==""] = "NA"
dbgap = subset(dbgap, year > 2017)
spl = str_split_fixed(str_remove(dbgap$filename,'\\.\\/data\\/'), '\\.',6)
dbgap$study_id = paste(spl[,1],spl[,2],spl[,5], sep=".")
dbgap_m = melt(dbgap, id.vars= c("V1", "n", "study_id", "filename", "date",'year', "total", "dataset_id", "repository"))


# bind datasets
ega_dbgap = rbindlist(list(ega_m, dbgap_m), use.names = T, fill = T)

################
# sample level #
################
ega_dbgap_percent = ega_dbgap %>% group_by(variable, repository) %>%
  summarise(value_percent = sum(value) / sum(total))

ega_dbgap_percent$variable = factor(ega_dbgap_percent$variable, levels=c("female", "male", "unknown"))

sample_plot_percent = ggplot(ega_dbgap_percent, aes(x=variable, y = value_percent, fill=variable))+
  geom_bar(stat="identity", width= 0.75)+
  ylab("Percentage of samples in all studies")+
  xlab("Biological sex classification")+
  theme_minimal()+
  scale_y_continuous(labels=scales::percent) +
  facet_grid(~repository)+
  scale_fill_manual(values = c("#20639b", "#3caea3","#f6d55c"))+
  theme(legend.position = "none",
        axis.text = element_text(size = 12, color = "black"),
        axis.title = element_text(size = 13),
        strip.text = element_text(size = 16, face = "bold"))

sample_plot_percent

####
# Boxplot
#########
ega = fread("../ega/EGA_with_NULL.csv")
ega$total_all = length(unique(ega$ega_stable_id))
colnames(ega)[1] = "study_id"
#d2 = melt(d,id.vars = c("ega_stable_id", "repository", "to_char", "total"))
dbgap = fread("../dbpgap/summary_fourth.csv")
dbgap$total = dbgap$male +  dbgap$female +  dbgap$unknown
dbgap$repository="dbGaP"
spl = str_split_fixed(str_remove(dbgap$filename,'\\.\\/data\\/'), '\\.',6)
dbgap$study_id = paste(spl[,1],spl[,2],spl[,5], sep=".")
dbgap$date = parse_date_time(dbgap$date, orders = c('mdy', 'dmy','ymd', "%d %m &y %H:%M:%S %Y"))
dbgap$year =str_split_fixed(dbgap$date, '-', 2)[,1]
dbgap2 =dbgap%>%group_by(study_id,repository)%>%
  summarise(male = sum(male),
            female = sum(female),
            unknown = sum (unknown),
            total = sum (total),
            year = max(year))
dbgap2 = subset(dbgap2, year >= 2018)
dbgap2$total_all = length(unique(dbgap2$study_id))

ega_dbgap = rbind(ega,dbgap2, fill = T)
ega_dbgap

ega_dbgap_bp = ega_dbgap %>% group_by(repository, study_id)%>%
  mutate(female_prop = female/total*100,
         male_prop = male/total*100,
         unk_prop = unknown/total*100)

ega_dbgap_bp
ega_dbgap_bp_m = melt(ega_dbgap_bp,measure.vars = c("female_prop", "male_prop", "unk_prop"))

my_comparisons <- list( c("female_prop", "male_prop"), c("male_prop", "unk_prop"),
                        c("female_prop", "unk_prop") )
library(ggpubr)
bp_prop = ggboxplot(ega_dbgap_bp_m, x = "variable", y = "value",
          fill = "variable",
          palette = c("#20639b", "#3caea3","#f6d55c"),
          facet.by="repository",
          xlab = "Biological sex classification",
          ylab = "Percentage of samples in individual studies")+ 
  stat_compare_means(comparisons = my_comparisons, 
                     method="wilcox.test",
                     paired = T, label = "p.signif")+
  scale_x_discrete(labels = c("female", "male", "unknown"))+
  theme_minimal()+
  theme(legend.position = "none",
        axis.text = element_text(size = 12, color = "black"),
        axis.title = element_text(size = 13))


bp_prop
library(cowplot)
png('../figures/figure1.png',
    width = 1000, height = 1500, res = 200)
plot_grid(NULL, sample_plot_percent, NULL, bp_prop,
          ncol = 1,
          labels = c("A","", "B",""),
          rel_heights = c(0.1,1,0.1,1))
dev.off()

