#########################################
library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(lubridate)

ega = fread("../ega/all_EGA_samples.txt")
#ega$total_all = length(unique(ega$ega_stable_id))
ega$year = str_split_fixed(ega$date_study, '-', 2)[,1]
colnames(ega)[1] = "study_id"
ega_m = melt(ega, id.vars = c("study_id", "repository", "date_study", "year", "total"))
ega_m$year[ega_m$year=="1980"] = "NA"

#d2 = melt(d,id.vars = c("ega_stable_id", "repository", "to_char", "total"))
dbgap = fread("../dbpgap/summary_fourth.csv")
dbgap$total = dbgap$male +  dbgap$female +  dbgap$unknown
dbgap$date = parse_date_time(dbgap$date, orders = c('mdy', 'dmy','ymd', "%d %m &y %H:%M:%S %Y"))
dbgap$year =str_split_fixed(dbgap$date, '-', 2)[,1]
spl = str_split_fixed(str_remove(dbgap$filename,'\\.\\/data\\/'), '\\.',6)
dbgap$study_id = paste(spl[,1],spl[,2],spl[,5], sep=".")
dbgap2 =dbgap%>%group_by(study_id)%>%
  summarise(male = sum(male),
            female = sum(female),
            unknown = sum (unknown),
            total = sum (total),
            year = max(year))
dbgap_m = melt(dbgap2, id.vars= c("study_id", 'year', "total"))
dbgap_m$repository = "dbGaP"
dbgap_m$year[dbgap_m$year==""] = NA

ega_dbgap = rbindlist(list(ega_m,dbgap_m), fill = T)



ega_dbgap

ega_dbgap_summary = ega_dbgap%>% group_by(repository, year, variable)%>%
  summarise(mean_samples = mean(value), 
            sd = sd(value))

g = ggplot(subset(ega_dbgap_summary, !is.na(year)&year!='NA'),
       aes(y = mean_samples, x = year, fill = variable, group= variable))+
  # geom_line() +
  #geom_point()+
  geom_bar(stat = "identity")+
  #geom_errorbar(aes(ymin=mean_samples-sd, ymax=mean_samples+sd), width=.2,
  #              position=position_dodge(0.05))+
  facet_grid(repository~., scales = "free_y")+
  ylab("mean # of samples per study")+
  theme_minimal()+
  theme()

png('../figures/figureS4.png',
    width = 2000, height = 1500, res = 300)
g
dev.off()
