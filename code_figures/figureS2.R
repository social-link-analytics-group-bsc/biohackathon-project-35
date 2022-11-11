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
colnames(ega)[1] = "study_id"
ega= ega%>%group_by(study_id,repository)%>%
  summarise(male = sum(male),
            female = sum(female),
            unknown = sum (unknown),
            total = sum (total),
            year = max(year))

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

# bind datasets
ega_dbgap = rbindlist(list(unique(ega[,c("study_id","repository","year")]),
                           dbgap2), use.names = T, fill = T)
ega_dbgap$s = 1

ll = ega_dbgap%>% group_by(year, repository) %>% summarise(stu = sum(s))
ndatasets= ggplot(subset(ll, !is.na(year) & year != 1980),
                  aes(x = as.numeric(year), y = stu, group = repository, color = repository))+
  geom_point(stat = "identity")+
  geom_line()+
  theme_minimal()+
  ylab("# studies")+
  xlab("Year")

ndatasets
png('../figures/figureS2.png',
    width = 1000, height = 500, res = 200)
ndatasets
dev.off()
