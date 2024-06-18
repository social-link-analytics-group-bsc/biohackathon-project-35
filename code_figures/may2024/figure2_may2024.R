library(data.table)
library(reshape2)
library(ggplot2)
library(stringr)
library(dplyr)
library(lubridate)

# Load data
ega = fread("../../ega/EGA_with_NULL.csv")
ega$total_all = length(unique(ega$ega_stable_id))
#d2 = melt(d,id.vars = c("ega_stable_id", "repository", "to_char", "total"))
dbgap = fread("./dbgap_may2024.csv")
dbgap$repository = "dbGaP"
dbgap = subset(dbgap, year > 2017)
dbgap$total_all = length(unique(dbgap$study_id))

ega_dbgap = rbind(ega,dbgap, fill = T)
ega_dbgap
################
# study level  #
################
unknown_only = subset(ega_dbgap, male == 0 & female == 0)
unknown_only$label = "U"

female_only = subset(subset(ega_dbgap, male == 0 & unknown == 0))
female_only$label = 'F'

male_only = subset(ega_dbgap, female == 0 & unknown == 0)
male_only$label = 'M'

female_and_male = subset(ega_dbgap, female != 0 & male != 0 & unknown == 0)
female_and_male$label = 'F&M'

female_and_unknown = subset(ega_dbgap, female != 0 & male == 0 & unknown != 0)
female_and_unknown$label = 'F&U'

male_and_unknown = subset(ega_dbgap, female == 0 & male != 0 & unknown != 0)
male_and_unknown$label = 'M&U'

female_and_male_and_unknown = subset(ega_dbgap, female != 0 & male != 0 & unknown != 0)
female_and_male_and_unknown$label = 'F&M&U'


r = rbind(unknown_only, female_only, male_only, female_and_male, female_and_unknown, male_and_unknown, female_and_male_and_unknown)
#r2 = unique(r[,c("ega_stable_id","repository","label","study_id","total_all")])

r $ c = 1


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



############
# BOXPLOTS
############
r2 = r  %>% group_by(repository, study_id)%>%
  mutate(female_prop = female/total*100,
         male_prop = male/total*100,
         unk_prop = unknown/total*100)
r2_m = melt(r2, measure.vars = c("female_prop", "male_prop", "unk_prop"))




library(ggpubr)
r2_m$variable = as.character(r2_m$variable)
r2_m$variable2 = ifelse(r2_m$variable=="female_prop", "female", ifelse(r2_m$variable=="male_prop", 'male', 'unknown'))


bp_prop1_dbgap = ggboxplot(subset(r2_m, !label %in% c("M", "U", "F") &
                              !(label == "F&M" & variable == "unk_prop" )&
                              !(label == "F&U" & variable == "male_prop" )&
                              !(label == "M&U" & variable == "female_prop" ) & 
                              label == "F&M" & repository =="dbGaP"),
                     x = "variable2",
                     y = "value",
                     fill = "variable",scales="free_x",drop = T,
                     palette = c("#20639b", "#3caea3","#f6d55c"),
                     facet.by=c("label"),
                     xlab = "Biological sex classification",
                     ylab = "Percentage of samples in individual studies") +
  stat_compare_means(comparison = list( c("female", "male")),
                     method="wilcox.test",
                     paired = T,
                     label = "p.signif") + 
  theme_minimal()+
  theme(
    strip.background.y  = element_blank(),
    strip.text.y = element_blank(),
    strip.text.x = element_text(size = 15, face = "bold"),
    legend.position = "none",
    axis.text.x = element_text(size = 10, face = "bold")
  )+ylim(0,140)
bp_prop1_dbgap


bp_prop2_dbgap = ggboxplot(subset(r2_m, !label %in% c("M", "U", "F") &
                              !(label == "F&M" & variable == "unk_prop" )&
                              !(label == "F&U" & variable == "male_prop" )&
                              !(label == "M&U" & variable == "female_prop" ) & 
                              label == "F&U" & repository =="dbGaP"),
                     x = "variable2",
                     y = "value",
                     fill = "variable",scales="free_x",drop = T,
                     palette = c("#20639b", "#f6d55c"),
                     facet.by=c("repository","label"),
                     xlab = "Biological sex classification",
                     ylab = "Percentage of samples") +
  stat_compare_means(comparison = list( c("female", "unknown")),
                     method="wilcox.test",
                     paired = T,
                     label = "p.signif") + 
  theme_minimal()+
  theme(
    strip.background.y  = element_blank(),
    strip.text.y = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    strip.text.x = element_text(size = 15, face = "bold"),
    legend.position = "none"
  )+ylim(0,140)
bp_prop2_dbgap


bp_prop3_dbgap = ggboxplot(subset(r2_m, !label %in% c("M", "U", "F") &
                              !(label == "F&M" & variable == "unk_prop" )&
                              !(label == "F&U" & variable == "male_prop" )&
                              !(label == "M&U" & variable == "female_prop" ) & 
                              label == "M&U"& repository=="dbGaP"),
                     x = "variable2",
                     y = "value",
                     fill = "variable",scales="free_x",drop = T,
                     palette = c("#3caea3", "#f6d55c"),
                     facet.by=c("repository","label"),
                     xlab = "Biological sex classification",
                     ylab = "Percentage of samples") +
  stat_compare_means(comparison = list( c("male", "unknown")),
                     method="wilcox.test",
                     paired = T,
                     exact=FALSE,
                     label = "p.signif") + 
  theme_minimal()+
  theme(
    strip.background.y  = element_blank(),
    strip.text.y = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    strip.text.x = element_text(size = 15, face = "bold"),
    legend.position = "none"
  )+ylim(0,140)

bp_prop3_dbgap

bp_prop4_dbgap = ggboxplot(subset(r2_m, !label %in% c("M", "U", "F") &
                              !(label == "F&M" & variable == "unk_prop" )&
                              !(label == "F&U" & variable == "male_prop" )&
                              !(label == "M&U" & variable == "female_prop" ) & 
                              label == "F&M&U"&repository == "dbGaP"),
                     x = "variable2",
                     y = "value",
                     fill = "variable",scales="free_x",drop = T,
                     palette = c("#20639b","#3caea3", "#f6d55c"),
                     facet.by=c("repository","label"),
                     xlab = "Biological sex classification",
                     ylab = "Percentage of samples") +
  stat_compare_means(comparison = list( c("male", "unknown"),
                                        c("male", "female"),
                                        c("female", "unknown")),
                     method="wilcox.test",
                     paired = T,
                     label = "p.signif") +
  theme_minimal()+
  theme(
       axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    strip.text.x = element_text(size = 15, face = "bold"),
    legend.position = "none"
  )+ylim(0,140)

bp_prop4_dbgap



# ega


bp_prop1_ega = ggboxplot(subset(r2_m, !label %in% c("M", "U", "F") &
                                    !(label == "F&M" & variable == "unk_prop" )&
                                    !(label == "F&U" & variable == "male_prop" )&
                                    !(label == "M&U" & variable == "female_prop" ) & 
                                    label == "F&M" & repository =="EGA"),
                           x = "variable2",
                           y = "value",
                           fill = "variable",scales="free_x",drop = T,
                           palette = c("#20639b", "#3caea3","#f6d55c"),
                           facet.by=c("label"),
                           xlab = "Biological sex classification",
                           ylab = "Percentage of samples in individual studies") +
  stat_compare_means(comparison = list( c("female", "male")),
                     method="wilcox.test",
                     paired = T,
                     label = "p.signif") + 
  theme_minimal()+
  theme(
    strip.background.y  = element_blank(),
    strip.text.y = element_blank(),
    strip.text.x = element_text(size = 15, face = "bold"),
    legend.position = "none",
    axis.text.x = element_text(size = 10, face = "bold")
  )+ylim(0,140)
bp_prop1_ega


bp_prop2_ega = ggboxplot(subset(r2_m, !label %in% c("M", "U", "F") &
                                    !(label == "F&M" & variable == "unk_prop" )&
                                    !(label == "F&U" & variable == "male_prop" )&
                                    !(label == "M&U" & variable == "female_prop" ) & 
                                    label == "F&U" & repository =="EGA"),
                           x = "variable2",
                           y = "value",
                           fill = "variable",scales="free_x",drop = T,
                           palette = c("#20639b", "#f6d55c"),
                           facet.by=c("repository","label"),
                           xlab = "Biological sex classification",
                           ylab = "Percentage of samples") +
  stat_compare_means(comparison = list( c("female", "unknown")),
                     method="wilcox.test",
                     paired = T,
                     label = "p.signif") + 
  theme_minimal()+
  theme(
    strip.background.y  = element_blank(),
    strip.text.y = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    strip.text.x = element_text(size = 15, face = "bold"),
    legend.position = "none"
  )+ylim(0,140)
bp_prop2_ega


bp_prop3_ega = ggboxplot(subset(r2_m, !label %in% c("M", "U", "F") &
                                    !(label == "F&M" & variable == "unk_prop" )&
                                    !(label == "F&U" & variable == "male_prop" )&
                                    !(label == "M&U" & variable == "female_prop" ) & 
                                    label == "M&U"& repository=="EGA"),
                           x = "variable2",
                           y = "value",
                           fill = "variable",scales="free_x",drop = T,
                           palette = c("#3caea3", "#f6d55c"),
                           facet.by=c("repository","label"),
                           xlab = "Biological sex classification",
                           ylab = "Percentage of samples") +
  stat_compare_means(comparison = list( c("male", "unknown")),
                     method="wilcox.test",
                     paired = T,
                     label = "p.signif") + 
  theme_minimal()+
  theme(
    strip.background.y  = element_blank(),
    strip.text.y = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    strip.text.x = element_text(size = 15, face = "bold"),
    legend.position = "none"
  )+ylim(0,140)

bp_prop3_ega

bp_prop4_ega = ggboxplot(subset(r2_m, !label %in% c("M", "U", "F") &
                                    !(label == "F&M" & variable == "unk_prop" )&
                                    !(label == "F&U" & variable == "male_prop" )&
                                    !(label == "M&U" & variable == "female_prop" ) & 
                                    label == "F&M&U"&repository == "EGA"),
                           x = "variable2",
                           y = "value",
                           fill = "variable",scales="free_x",drop = T,
                           palette = c("#20639b","#3caea3", "#f6d55c"),
                           facet.by=c("repository","label"),
                           xlab = "Biological sex classification",
                           ylab = "Percentage of samples") +
  stat_compare_means(comparison = list( c("male", "unknown"),
                                        c("male", "female"),
                                        c("female", "unknown")),
                     method="wilcox.test",
                     paired = T,
                     label = "p.signif") +
  theme_minimal()+
  theme(
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    strip.text.x = element_text(size = 15, face = "bold"),
    legend.position = "none"
  )+ylim(0,140)

bp_prop4_ega


##########################
# PLOTTTTTTTTTTTTTT
#########################

library(cowplot)
P1 = plot_grid(list_plot[[1]]+theme(axis.title.x = element_text(size = 12))+xlab("Studies classification"),
               list_plot[[2]]+theme(axis.title.x = element_text(size = 12))+xlab("Studies classification"),
               align = "h", labels=c("A","B"))

library(grid)
library(gridExtra)
#x.grob <- textGrob("Studies classification", 
#                   gp=gpar(  fontsize=10))

#add to plot

#P1 = grid.arrange(arrangeGrob(pp,  bottom = x.grob))



cp_dbgap = cowplot::plot_grid(bp_prop1_dbgap+theme(
  axis.title.x = element_blank(),
 # axis.text.x = element_blank(),
  axis.title.y = element_blank()),
  bp_prop2_dbgap+theme(
 #   axis.text.x = element_blank(),
    axis.title.x = element_blank()),
  bp_prop3_dbgap+theme(
    axis.title.x = element_blank(),
  #  axis.text.x = element_text(size=13, color = "black"),
    axis.text.y = element_text()),
  bp_prop4_dbgap+theme(
    axis.title.x = element_blank(),
   # axis.text.x = element_text(size=13, color = "black"),
    strip.text.y=element_blank()), 
  ncol = 2,
  align = "hv",label_x = "bb")

cp_dbgap

x.grob2 <- textGrob("Biological sex classification", 
                    gp=gpar( fontsize=12))
y.grob2 <- textGrob("Percentage of samples in individual studies", 
                    gp=gpar( fontsize=12), rot = 90)

#add to plot

P2 = grid.arrange(arrangeGrob(cp_dbgap,
                              bottom = x.grob2,
                              left = y.grob2,
                              top=textGrob("dbGaP",
                                           gp=gpar( fontsize=16, fontface="bold"))))



cp_ega = cowplot::plot_grid(bp_prop1_ega+theme(
  axis.title.x = element_blank(),
 # axis.text.x = element_blank(),
  axis.title.y = element_blank()),
  bp_prop2_ega+theme(
  #  axis.text.x = element_blank(),
    axis.title.x = element_blank()),
  bp_prop3_ega+theme(
    axis.title.x = element_blank(),
 #   axis.text.x = element_text(size=13, color = "black"),
    axis.text.y = element_text()),
  bp_prop4_ega+theme(
    axis.title.x = element_blank(),
  #  axis.text.x = element_text(size=13, color = "black"),
    strip.text.y=element_blank()), 
  ncol = 2,
  align = "hv",label_x = "bb")

cp_ega

x.grob2 <- textGrob("Biological sex classification", 
                    gp=gpar( fontsize=12))


#add to plot

P3 = grid.arrange(arrangeGrob(cp_ega,  bottom = x.grob2,
                              left = y.grob2,
                              top=textGrob("EGA",
                                           gp=gpar( fontsize=16, fontface="bold"))))
#add to plot



png('../../figures/figure2_may2024.png',
    width = 2500, height = 2300, res = 250)
plot_grid(list_plot[[1]]+theme(axis.title.x = element_text(size = 12))+xlab("Studies classification"),
          list_plot[[2]]+theme(axis.title.x = element_text(size = 12))+xlab("Studies classification"),
          NULL,
          NULL,
          P2,
          P3, #plot_grid(P2,P3,ncol= 2,labels = c("B", "C") ),
          ncol = 2,
          labels = c("A", "B", "C","D", "",""),label_size = 18,
          rel_heights = c(1,0.1,1.5,1,0.1,1.5), align = "hv")
dev.off()
