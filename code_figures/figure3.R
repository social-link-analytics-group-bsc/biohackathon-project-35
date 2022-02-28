library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(lubridate)

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


################
# sample level #
################
ega_dbgap_percent = subset(ega_dbgap) %>% group_by(variable, repository, year) %>%
  summarise(value_percent = sum(value) / sum(total))
ega_dbgap_percent$year = factor(ega_dbgap_percent$year ,
                                 levels = c('NA','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021'))

sample_plot_percent = ggplot(subset(ega_dbgap_percent), aes(x=year, y = value_percent, color=variable, group=variable))+
  #geom_bar(stat="identity", width= 0.8)+
  geom_point(size = 3)+
  geom_line()+
  ylab("Percentage of samples")+
  xlab("Year")+
  theme_minimal()+
  scale_y_continuous(labels=scales::percent) +
  facet_grid(repository~.)+
  scale_color_manual(values = c("#ffa600", "#bc5090","#003f5c"),
                     labels = c("Male", "Female", "Unknown"),
                     name ="")+
  #scale_x_discrete(labels= c("M", "F", "U"))+
  theme(legend.position = "top",
        axis.text.x = element_text(size = 10),
        strip.text = element_text(size = 16, face = "bold"))


sample_plot_percent

png('../figures/figure3.png',
    width = 1500, height = 700, res = 150)
sample_plot_percent
dev.off()

