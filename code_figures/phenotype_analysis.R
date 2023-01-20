library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(lubridate)

# Load data
ega = fread("../ega/EGA_with_NULL.csv")
ega$total_all = length(unique(ega$ega_stable_id))
#d2 = melt(d,id.vars = c("ega_stable_id", "repository", "to_char", "total"))
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
dbgap2 = subset(dbgap2, year >= 2018)
dbgap2$total_all = length(unique(dbgap2$study_id))

ega_dbgap = rbind(ega,dbgap2, fill = T)
ega_dbgap
################
# study level  #
################
female_only = subset(subset(ega_dbgap, male == 0 & unknown == 0))
female_only$label = 'F'

male_only = subset(ega_dbgap, female == 0 & unknown == 0)
male_only$label = 'M'


subset(female_only, total >= 100)
subset(male_only, total >= 100)

ega_phe = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/EGA_examples/raw_phenotype_gender_ega.txt")
dbgap_phe = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/biohackathon-project-35/dbGaP primary phenotypes/dbGaP_primary_phenotypes.tsv", header = F,
                  col.names = c("study_id","phenotype"))

colnames(ega_phe)[2] = "ega_stable_id"

dbg = left_join(subset(rbindlist(list(male_only,female_only)),total>=100), dbgap_phe)
dbg = subset(unique(dbg[,c("study_id","phenotype","label", "total")]), !is.na(study_id))

list_results = list()
for (s in dbg$study_id){
  title = system(paste("curl -s 'https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/study.cgi?study_id=",s,"' | grep 'study-name'", sep =""),intern=TRUE)
  if(length(attr(title,"status"))!= 0){
    next
  }
  clean_title = str_split(title, '>|<')[[1]][3]
  list_results[[s]] = data.frame(study_id =s, title = clean_title)
}

df = rbindlist(list_results)
df

dff = left_join(dbg, df)
fwrite(dff, 'study_dbgap_manual_curation.txt')

egg = left_join(subset(rbindlist(list(male_only,female_only)), total >=100), ega_phe)
egg = subset(unique(egg[,c("ega_stable_id", "label", "total")]), !is.na(ega_stable_id))

#egg2 = egg[,
#           .(ega_stable_id = unique(ega_stable_id), phenotype = toString(phenotype))]

#egg2 = left_join(egg2, unique(egg[,c("ega_stable_id", "label", "total")]))

list_results2 = list()
for (s2 in egg$ega_stable_id){
  title = system(paste("curl -s 'https://ega-archive.org/studies/",s2,"' | grep '<title>'", sep =""),intern=TRUE)
  if(length(attr(title,"status"))!= 0){
    next
  }
  clean_title = str_split(title, '>|<')[[1]][3]
  list_results2[[s2]] = data.frame(ega_stable_id =s2, title = clean_title)
}

df2 = rbindlist(list_results2)
df2$title = str_remove(df2$title, ' - EGA European Genome-Phenome Archive')

dff2 = left_join(subset(egg, !is.na(ega_stable_id)), subset(df2, !is.na(ega_stable_id)))
fwrite(dff2, 'study_ega_manual_curation.txt')

# percent
ega_dbgap_percent = unique(r %>% group_by(label, repository) %>%
                             summarise(value_percent = sum(c) / total_all))

library(RColorBrewer)
list_plot = list()
for(i in c("dbGaP", "EGA")){
  f = arrange(subset(ega_dbgap_percent, repository==i), desc(value_percent))$label
  ega_dbgap_percent$label = factor(ega_dbgap_percent$label, levels = unique(f))
  
  study_plot_percent = ggplot(subset(ega_dbgap_percent, repository ==i),
                              aes(x= label,y = value_percent, fill = label))+
    geom_bar(stat="identity", width=0.75)+
    ylab("Percentage of studies")+
    #  xlab("Sex specification in samples found in the study")+
    theme_minimal()+
    facet_grid(~repository)+
    scale_y_continuous(labels=scales::percent) +
    scale_fill_manual(values = brewer.pal(7,"Set2"),
                      breaks = c("U","F&M","F&M&U","F","M","M&U","F&U"),
                      labels = c("U","F&M","F&M&U","F","M","M&U","F&U"))+
    theme(legend.position = "none",
          axis.text.x = element_text(size = 10, face = "bold"),
          axis.title.x = element_blank(),#text(size = 12),
          strip.text = element_text(size = 16, face = "bold"))
  
  list_plot[[i]] = study_plot_percent
}
study_plot_percent

library(cowplot)
pp = plot_grid(list_plot[[1]],list_plot[[2]],
               align = "h")

library(grid)
library(gridExtra)
x.grob <- textGrob("Sex specification in samples found in the study", 
                   gp=gpar(  fontsize=10))

#add to plot

grid.arrange(arrangeGrob(pp,  bottom = x.grob))

png('../figures/figure2.png',
    width = 1500, height = 750, res = 200)
grid.arrange(arrangeGrob(pp,  bottom = x.grob))
dev.off()

