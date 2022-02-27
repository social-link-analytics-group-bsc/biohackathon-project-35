library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)

# Load data
ega = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/EGA_with_NULL.csv")
ega$year = str_split_fixed(ega$to_char, '-', 2)[,1]
ega_m = melt(ega, id.vars = c("ega_stable_id", "repository", "to_char", "year", "total"))

colnames(ega_m)[colnames(ega_m) == "ega_stable_id"] = "dataset_id"

dbgap = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/biohackathon-project-35/dbpgap/summary_fourth.csv")
dbgap$total = dbgap$male +  dbgap$female +  dbgap$unknown
dbgap$date = parse_date_time(dbgap$date, orders = c('mdy', 'dmy','ymd', "%d %m &y %H:%M:%S %Y"))
dbgap$year =str_split_fixed(dbgap$date, '-', 2)[,1]
dbgap_m = melt(dbgap, id.vars= c("V1", "n", "dataset_id", "filename", "date",'year', "total"))
dbgap_m$repository = "dbGaP"

# bind datasets
ega_dbgap = rbindlist(list(ega_m, dbgap_m), use.names = T, fill = T)


################
# sample level #
################
ega_dbgap_percent = subset(ega_dbgap, year > 2017) %>% group_by(variable, repository, year) %>%
  summarise(value_percent = sum(value) / sum(total))


sample_plot_percent = ggplot(subset(ega_dbgap_percent), aes(x=variable, y = value_percent, fill=variable))+
  geom_bar(stat="identity", width= 0.8)+
  ylab("Percentage of samples")+
  xlab("Biological sex specification")+
  theme_minimal()+
  scale_y_continuous(labels=scales::percent) +
  facet_grid(repository~year)+
  scale_fill_manual(values = c("#ffa600", "#bc5090","#003f5c"))+
  theme(legend.position = "none",
        axis.text.x = element_text(size = 10),
        strip.text = element_text(size = 16, face = "bold"))

sample_plot_percent

png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/figures/figure3.png',
    width = 1200, height = 600, res = 150)
sample_plot_percent
dev.off()

