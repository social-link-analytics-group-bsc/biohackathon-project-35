#install.packages("hpoPlot")
library(hpoPlot)
data(hpo.terms)
hpo.plot(hpo.terms, terms=unique(hpo_ega$V3[2:20]))
str(hpo.terms)
library(ontologyIndex)
ont = get_ontology("hp.obo")
tt = data.frame(id = ont$id, name = ont$name)

library(data.table)
hpo_ega = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/phenotype_from_text/EGA_phenotype_HPO_fromtext.csv")
hpo_ega$V3[1:20]

u_ega = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/phenotype_from_text/unknown_EGAstudies_before2016.txt")

library(dplyr)
u_ega_hpo = left_join(u_ega,hpo_ega, by = c("ega_stable_id" = "V2"))

hpo = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/phenotype_from_text/phenotype.hpoa",
            skip = 4)
u_ega_hpo_disease = left_join ( u_ega_hpo, tt ,
                                by =c("V3"= "id"))


u_ega_hpo_disease_sum = u_ega_hpo_disease %>% group_by(ega_stable_id, year)%>%
  filter(V3 == min(V3))
library(ggplot2)

library(tidyr)
u_ega_hpo_disease_sum_heatmap = u_ega_hpo_disease_sum %>% group_by(year)%>%
  count (name,name = "count")
u_ega_hpo_disease_sum_heatmap= subset(u_ega_hpo_disease_sum_heatmap, year > 1990 & year < 2014)

u_ega_hpo_disease_sum_heatmap$name = factor(u_ega_hpo_disease_sum_heatmap$name,
                                            levels= rev(sort(unique(u_ega_hpo_disease_sum_heatmap$name))))
u_ega_hpo_disease_sum_heatmap= u_ega_hpo_disease_sum_heatmap %>%
  complete(
           name, fill = list(count = NA))

u_ega_hpo_disease_sum_heatmap$name = ifelse(is.na(u_ega_hpo_disease_sum_heatmap$name), 'Unknown', as.character(u_ega_hpo_disease_sum_heatmap$name) )
u_ega_hpo_disease_sum_heatmap$name =factor(u_ega_hpo_disease_sum_heatmap$name,
                                           levels= rev(sort(unique(u_ega_hpo_disease_sum_heatmap$name))))



count_phe = ggplot(u_ega_hpo_disease_sum_heatmap,
                   aes(x = year, y = name, fill = count))+
  geom_tile(color = "grey80")+
  scale_fill_continuous(na.value = "white")+
  facet_grid(~year, scales="free_x")+
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank())+
  ylab("Phenotype (based on extracted HPO term)")
count_phe

png("phenotype_unknown_ega_before2016.png", width = 1800, height = 3000, res = 300)
count_phe
dev.off()

