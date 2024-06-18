#########################################
library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(lubridate)
library(dplyr)

ega = fread("../ega/all_EGA_samples.txt")
#ega$total_all = length(unique(ega$ega_stable_id))
ega$year = str_split_fixed(ega$date_study, '-', 2)[,1]
colnames(ega)[1] = "study_id"
ega_m = melt(ega, id.vars = c("study_id", "repository", "date_study", "year", "total"))
ega_m$year[ega_m$year=="1980"] = "NA"

#d2 = melt(d,id.vars = c("ega_stable_id", "repository", "to_char", "total"))
dbgap = fread("../dbpgap/summary_fourth.csv")
#dbgap$total = dbgap$male +  dbgap$female +  dbgap$unknown
dbgap$date = parse_date_time(dbgap$date, orders = c('mdy', 'dmy','ymd', "%d %m &y %H:%M:%S %Y"))
dbgap$year =str_split_fixed(dbgap$date, '-', 2)[,1]
spl = str_split_fixed(str_remove(dbgap$filename,'\\.\\/data\\/'), '\\.',6)
dbgap$study_id = paste(spl[,1],spl[,2],spl[,5], sep=".")
dbgap2 =dbgap%>%group_by(study_id)%>%
  summarise(male = sum(male),
            female = sum(female),
            unknown = sum (unknown),
           # total = sum (total),
            year = max(year))
dbgap_m = melt(dbgap2, id.vars= c("study_id", 'year', "total"))
dbgap_m$repository = "dbGaP"
dbgap_m$year[dbgap_m$year==""] = NA

ega_dbgap = rbindlist(list(ega_m,dbgap_m), fill = T)

ll2 = ega_dbgap%>% group_by(year, repository, variable) %>% summarise(samples = sum(value))
samples_year=ggplot(subset(ll2),
                    aes(x = as.numeric(year), y = samples, group = variable, color = variable))+
  geom_point()+
  geom_line()+
  facet_grid(repository~., scales="free_y")+
  theme_minimal()+
  ylab("# samples")+
  xlab("Year")

samples_year


png('../figures/figureS3.png',
    width = 2500, height = 1000, res = 300)
samples_year
dev.off()
