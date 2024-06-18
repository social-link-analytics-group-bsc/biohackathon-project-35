#########################################
library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(lubridate)
library(dplyr)

ega = fread("../../ega/all_EGA_samples.txt")
ega$year = str_split_fixed(ega$date_study, '-', 2)[,1]
colnames(ega)[1] = "study_id"
ega_m = melt(ega, id.vars = c("study_id", "repository", "date_study", "year", "total"))
ega_m$year[ega_m$year=="1980"] = "NA"

dbgap = fread("./dbgap_may2024.csv")
dbgap$repository = "dbGaP"
dbgap = dbgap[,-3]


dbgap_m = melt(dbgap, id.vars= c("study_id", 'year', "total", "repository"))
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


png('../../figures/figureS1_may2024.png',
    width = 2500, height = 1000, res = 300)
samples_year
dev.off()
