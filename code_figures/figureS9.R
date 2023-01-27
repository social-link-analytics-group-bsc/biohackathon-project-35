library(data.table)
library(ggplot2)
library(ggsankey)
library(dplyr)

# Load data
d = fread("/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/biohackathon-project-35_2/qualitative_analysis/responses_survey_profile_participants.tsv")

# put data in sankey format
d$work_experience = factor(d$work_experience , levels = c("< 1",   "1-5",     "6-10",  "11-15",">15" ))
dsum1 = d %>% group_by(question3, work_experience)%>% summarise(n = n())
pp = ggplot(dsum1, aes(x = work_experience, color = question3, y = n, group=question3))+
  geom_point(size = 4)+
  geom_line(linewidth=1)+
  theme_minimal()+
  xlab("Work experience (years)")+
  ylab("# answers")

dsum = d %>% group_by(question3)%>% summarise(n = n())
pc = ggplot(dsum, aes(x="", y=n, fill=question3)) +
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0)+
  theme_void()+
  geom_text(aes(y = c(55, 35, 15), label =n), color = "white", size=6) +
  ggtitle("Total number of answers")

pc = pc+theme(legend.position = "top")
legend = get_legend(pc)

library(cowplot)
png('../figures/figureS9_B.png',
    width = 1500, height = 500, res = 150)
plot_grid(legend, 
          plot_grid(pc+theme(legend.position = "none"),
                    pp+theme(legend.position = "none"), labels = c('', ''),nrow = 1,
                    ncol = 2, rel_widths =  c(0.45,1)),
          ncol = 1, rel_heights = c(0.1,1))
dev.off()