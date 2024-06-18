library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(lubridate)
library(stringr)

#### comparison of dbgap study ids
#original IDs
orig_ids= fread("/media/victoria/TOSHIBA EXT/BioHackathon2021/biohackathon-project-35/dbpgap/dbGaP primary phenotypes/study_list.txt")

# orig IDs mine
orig_vic_ids= fread("/media/victoria/TOSHIBA EXT/BioHackathon2021/biohackathon-project-35/dbpgap/may2024/list_dbgap_studies.txt", header = F)

orig_vic_ids[which(!orig_vic_ids$V1 %in% orig_ids$filename..),] # all input ids (1340) for downloading data from SSTR service is OK

# downloaded ids
down_ids = fread("/media/victoria/TOSHIBA EXT/BioHackathon2021/biohackathon-project-35/dbpgap/may2024/list_dbgap_studies_downloaded.txt", header = F)

down_ids[which(!down_ids$V1 %in% orig_ids$filename..),]

# extracted counts ids
counts = fread("/media/victoria/TOSHIBA EXT/BioHackathon2021/biohackathon-project-35/dbpgap/may2024/study_sex_counts_summary_samples.csv")
counts$dbgap_id[which(!counts$dbgap_id %in% orig_ids$filename..)] 



# missing ids
orig_ids$filename..[which(!orig_ids$filename.. %in%counts$dbgap_id )] 

# "phs000286.v6.p2" the version is suspended, get summary or eliminate? - ONLY SUBJECTS INFO, AUTHORIZED ACCESS REQUIRED
# "phs001446.v2.p1  now it is another version, get summary or phs001446.v2.p1?
# "phs001588.v1.p1"  0 records, get summary or eliminate.  



# put in proper format new data
colnames(counts)[1:2] = c("dbgap_id", "study_id")
counts$total = counts$male + counts$female + counts$unknown
counts
# put in proper format old format
library(zoo)
dbgap = fread("../../dbpgap/summary_fourth.csv")
dbgap$total = dbgap$male +  dbgap$female +  dbgap$unknown
dbgap$date = as.Date(parse_date_time(dbgap$date, orders = c('mdy', 'dmy','ymd', "%d %m &y %H:%M:%S %Y")))
dbgap$ym = as.yearmon(dbgap$date)
dbgap$month = month(dbgap$date)
dbgap$year =str_split_fixed(dbgap$date, '-', 2)[,1]
spl = str_split_fixed(str_remove(dbgap$filename,'\\.\\/data\\/'), '\\.',6)
dbgap$study_id = paste(spl[,1],spl[,2],spl[,5], sep=".")
dbgap =dbgap%>%group_by(study_id)%>%
  summarise(male = sum(male),
            female = sum(female),
            unknown = sum (unknown),
            total = sum (total),
            year = max(year),
            ym = max(ym))

colnames(dbgap) = c("study_id", "male_old", "female_old", "unknown_old", "total_old", "year", "ym")
# merge dbgap with old data
dbgap_merged = merge(dbgap, counts)
dbgap_merged

fwrite(dbgap_merged[,c("study_id", "year", "ym","male", "female", "unknown", "total")], "dbgap_may2024.csv")

dbgap_merged$total_sub = dbgap_merged$total - dbgap_merged$total_old
dbgap_merged$female_sub = dbgap_merged$female - dbgap_merged$female_old
dbgap_merged$male_sub = dbgap_merged$male - dbgap_merged$male_old
dbgap_merged$unknown_sub = dbgap_merged$unknown - dbgap_merged$unknown_old





mm = melt(dbgap_merged[,c("study_id","total_sub","female_sub","male_sub","unknown_sub")],
     id.vars= c("study_id"))

library(ggplot2)
#ggplot(mm, aes(x=value, y = study_id))+
#  geom_bar(stat = "identity")+
#  facet_grid(~variable, scales ="free_x")+
#  theme(axis.text.y = element_blank())


hp = ggplot(mm, aes(x=value))+
  geom_histogram()+
  facet_grid(~variable, scales ="free_x")+
  ggtitle("Histogram dbgap new numbers (NCBI API) - old numbers (xml)")+
  xlab("Substraction value (new - old)")
  
jpeg('histogram_dbgap_new_vs_old.jpg', width = 3000, height = 1000, res = 200)
hp
dev.off()

library(ggrepel)

vp = ggplot(mm, aes(x=variable, y = value, label = study_id))+
  geom_violin()+
  geom_point()+
  geom_text_repel(data = subset(mm, value < (-250000)),
                  nudge_x       = 0.1,
                  #size          = 4,
                  box.padding   = 0.5,
                  #point.padding = 0.5,
                 # force         = 100,
                  #segment.size  = 0.3,
                  #segment.color = "grey50",
                  max.overlaps = Inf,
                  direction = "y",
                 hjust = "left"
                 )+
  facet_grid(~variable, scales ="free_x")+
  ggtitle("Violing plot - dbgap new numbers (NCBI API) - old numbers (xml)")+
  ylab("Substraction value (new - old)")+
  xlab("Sample category")

vp
jpeg('violinplot_dbgap_new_vs_old.jpg', width = 3000, height = 2000, res = 250)
vp
dev.off()
