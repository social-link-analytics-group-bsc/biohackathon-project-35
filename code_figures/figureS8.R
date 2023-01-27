library(data.table)
library(ggplot2)
library(dplyr)

# Load data
d = fread("../qualitative_analysis/ELIXIR_BioHackathon_35FAIRX_Responses-Form_responses1.tsv")

fs8_plot = d[,13]

colnames(fs8_plot) = "Answers"
fs8_plot$n = 1

library(stringr)

fs8_plot_sum = fs8_plot%>% group_by(Answers) %>%
  summarise(count = sum(n))

fs8_plot_sum = arrange(fs8_plot_sum, count)
fs8_plot_sum$Answers = factor(fs8_plot_sum$Answers, levels =fs8_plot_sum$Answers)
fs8_plot_sum$percent = fs8_plot_sum$count / sum(fs8_plot_sum$count) * 100

fs8 = ggplot(fs8_plot_sum, aes(y = Answers, x = count))+
  geom_bar(stat = "identity",fill = "purple")+
  geom_text(aes( label = paste0(round(percent,2),"%"),
                 x= count+3 ))+
  ylab("")+
  xlab("# answers")+
  theme_minimal()+
  theme(axis.text = element_text(size = 14),
        axis.title = element_text(size = 20))

fs8
png("../figures/figureS8.png", width = 2500, height = 500, res = 150)
fs8
dev.off()
