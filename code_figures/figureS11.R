library(data.table)
library(ggplot2)
library(dplyr)

# Load data
d = fread("../qualitative_analysis/ELIXIR_BioHackathon_35FAIRX_Responses-Form_responses1.tsv")

fs11_plot = d[,16]
colnames(fs11_plot) = "Answer"
fs11_plot$n = 1
fs11_plot_sum = fs11_plot %>% group_by(Answer)%>%
  summarise(n = sum(n))

fs11_plot_sum = fs11_plot%>% group_by(Answer) %>%
  summarise(count = sum(n))

fs11_plot_sum = arrange(fs11_plot_sum, count)
fs11_plot_sum$Answer = factor(fs11_plot_sum$Answer, levels =fs11_plot_sum$Answer)
fs11_plot_sum$percent = fs11_plot_sum$count / sum(fs11_plot_sum$count) * 100

fs11 = ggplot(fs11_plot_sum, aes(y = Answer, x = count))+
  geom_bar(stat = "identity",fill = "purple")+
  geom_text(aes( label = paste0(round(percent,2),"%"),
                 x= count+3 ))+
  ylab("")+
  xlab("# Answer")+
  theme_minimal()+
  theme(#axis.text = element_text(size = 14),
    axis.title = element_text(size = 20))


png("../figures/figureS11.png", width = 1500, height = 900, res = 200)
fs11
dev.off()
