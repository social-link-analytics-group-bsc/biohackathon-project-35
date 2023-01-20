library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(lubridate)
library(patchwork) # To display 2 charts together
#library(hrbrthemes)
library(cowplot)

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

#total samples per year
ega_dbgap = ega_dbgap %>% group_by(repository, year) %>% mutate(total_year = sum(value))

################
# sample level #
################
ega_dbgap$s = 1

ggplot(subset(ega_dbgap, total < 10000 & repository == "EGA"),
       aes(x = variable, y = value, color = variable))+
  geom_boxplot()+
  facet_grid(~year)


ll = ega_dbgap%>% group_by(year, repository) %>% summarise(stu = sum(s))
ggplot(subset(ll, repository == "EGA"),
       aes(x = as.numeric(year), y = stu, group = repository))+
  geom_point()+
  geom_line()

ll2 = ega_dbgap%>% group_by(year, repository, variable) %>% summarise(samples = sum(value))
ggplot(subset(ll2, repository == "EGA"),
       aes(x = as.numeric(year), y = samples, group = variable, color = variable))+
  geom_point()+
  geom_line()


