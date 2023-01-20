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

<<<<<<< HEAD


library(dplyr)
dbgap = merge(dbgap, dbgap_phe)
dbgap_ratio = dbgap %>% 
              #summarise(tot_male = sum(male),
              #          tot_female = sum(female))%>%
              mutate(FMratio = female/male)%>%
              filter(!FMratio %in% c("NaN", "Inf"))%>%
              group_by(phenotype) %>%
              summarise(FMratio_mean = mean(FMratio))

dbgap_ratio 
dbgap_ratio =arrange(dbgap_ratio, desc(FMratio_mean))
dbgap_ratio $repository = "dbGaP"

dbgap_ratio$x = 1:nrow(dbgap_ratio)
dbgap_ratio[1:20,]
=======
df = as.data.frame(ega_dbgap)
rownames(df) = df$dataset_id
df$male1 = ifelse(df$male !=0, 'male', NA)
df$female1 = ifelse(df$female !=0, 'female', NA)
df$unknown1 = ifelse(df$unknown !=0, 'unknown', NA)
library(ggsankey)

df2 <- df %>%
  make_long(male1, female1,unknown1)
>>>>>>> parent of 547c59c... updated code and figures

library(dplyr) # Necesario

ggplot(df2[1:100,], aes(x = x, 
               next_x = next_x, 
               node = node, 
               next_node = next_node,
               fill = factor(node),
               label = node)) +
  geom_sankey(flow.alpha = 0.5, node.color = 1) +
  geom_sankey_label(size = 3.5, color = 1, fill = "white") +
  scale_fill_viridis_d(option = "A", alpha = 0.95) +
  theme_sankey(base_size = 16)

library(reshape2)
ega_dbgap_m = melt(ega_dbgap[,c(1:5,7:9)],
                   id.vars = c("dataset_id", "repository", "year", "total", "total_all"))

df$n = 1
library(ggalluvial)
ggplot(df[1:10,],
       aes(y = n, axis1 = male1, axis2 = female1,axis3=unknown1)) +
  geom_alluvium()+
  geom_stratum(width = 1/12, fill = "black", color = "grey") +
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) 
+
  scale_x_discrete(limits = c("Gender", "Dept"), expand = c(.05, .05)) +
  scale_fill_brewer(type = "qual", palette = "Set1") +
  ggtitle("UC Berkeley admissions and rejections, by sex and department")



<<<<<<< HEAD
ega_ratio =arrange(ega_sub100, desc(FMratio_mean))
ega_ratio$repository = "EGA"

s= rbindlist(list(dbgap_ratio,ega_ratio))
s$FMratio_mean = round(s$FMratio_mean,2)
fwrite(s, "FMratio.csv")

ega_ratio$x = 1:nrow(ega_ratio)
ega_ratio[21:40,]
=======
library(dplyr)
ega_dbgap_m_percent = ega_dbgap_m %>% 
  mutate(value_percent = (value / total) * 100)
>>>>>>> parent of 547c59c... updated code and figures

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
