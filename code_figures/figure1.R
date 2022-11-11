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



sample_plot_percent = ggplot(ega_dbgap_percent, aes(x=variable, y = value_percent, fill=variable))+
  geom_bar(stat="identity", width= 0.75)+
  ylab("Percentage of samples")+
  xlab("Biological sex specification")+
  theme_minimal()+
  scale_y_continuous(labels=scales::percent) +
  facet_grid(~repository)+
  scale_fill_manual(values = c("#20639b", "#3caea3","#f6d55c"))+
  theme(legend.position = "none",
        axis.text.x = element_text(size = 12),
        strip.text = element_text(size = 16, face = "bold"))

sample_plot_percent

png('../figures/figure1.png',
    width = 1000, height = 500, res = 200)
sample_plot_percent
dev.off()

