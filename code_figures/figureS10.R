library(data.table)
library(ggplot2)
library(dplyr)

# Load data
d = fread("../qualitative_analysis/ELIXIR_BioHackathon_35FAIRX_Responses-Form_responses1.tsv")

fs10_plot = d[,14]
colnames(fs10_plot) = "Answer"
fs10_plot$n = 1
fs10_plot_sum = fs10_plot %>% group_by(Answer)%>%
  summarise(n = sum(n))

fs10_plot_sum = fs10_plot%>% group_by(Answer) %>%
  summarise(count = sum(n))

fs10_plot_sum = arrange(fs10_plot_sum, count)
fs10_plot_sum$Answer = factor(fs10_plot_sum$Answer, levels =fs10_plot_sum$Answer)
fs10_plot_sum$percent = fs10_plot_sum$count / sum(fs10_plot_sum$count) * 100

fs10 = ggplot(fs10_plot_sum, aes(y = Answer, x = count))+
  geom_bar(stat = "identity",fill = "purple")+
  geom_text(aes( label = paste0(round(percent,2),"%"),
                 x= count+3 ))+
  ylab("")+
  xlab("# Answer")+
  theme_minimal()+
  theme(#axis.text = element_text(size = 14),
        axis.title = element_text(size = 20))


png("../figures/figureS10.png", width = 1500, height = 900, res = 150)
fs10
dev.off()
