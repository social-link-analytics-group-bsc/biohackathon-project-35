#########################################
library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(lubridate)

ega = fread("../ega/all_EGA_samples.txt")
ega$total_all = length(unique(ega$ega_stable_id))
ega$year = str_split_fixed(ega$date_study, '-', 2)[,1]
colnames(ega)[1] = "dataset_id"
#d2 = melt(d,id.vars = c("ega_stable_id", "repository", "to_char", "total"))
dbgap = fread("../dbpgap/summary_fourth.csv")
dbgap$total = dbgap$male +  dbgap$female +  dbgap$unknown
dbgap$repository="dbGaP"
dbgap$total_all = length(unique(dbgap$dataset_id))
dbgap$date = parse_date_time(dbgap$date, orders = c('mdy', 'dmy','ymd', "%d %m &y %H:%M:%S %Y"))
dbgap$year =str_split_fixed(dbgap$date, '-', 2)[,1]

ega_dbgap = rbind(ega,dbgap, fill = T)

ega_dbgap


library(reshape2)
ega_dbgap_m = melt(ega_dbgap[,c(1:5,7:9)],
                   id.vars = c("dataset_id", "repository", "year", "total", "total_all"))

library(dplyr)
ega_dbgap_m_percent = ega_dbgap_m %>% 
  mutate(value_percent = (value / total) * 100)

library(ggplot2)
bp = ggplot(subset(ega_dbgap_m_percent, !year %in% c("",1980)),
            aes(x = variable, y = value_percent , color = variable))+
 # geom_dotplot()+
  #geom_violin()+
  geom_boxplot(width=0.5)+
  facet_grid(repository~year)+
  ylab("Percentage of samples")+
  scale_color_manual(values = c("#20639b", "#3caea3","#f6d55c"),
                     labels = c("Male (M)", "Female (F)", "Unknown (U)"),
                     name ="")+
  xlab("Sex classification")+
  scale_x_discrete(labels= c("M", "F", "U"))+
  theme_minimal()+
  theme(legend.position="top",
        strip.text = element_text(size = 12, face = "bold"),
        axis.text.x = element_text(size = 9))

bp


png('../figures/figure4.png',
    width = 3000, height = 1000, res = 250)
bp
dev.off()
