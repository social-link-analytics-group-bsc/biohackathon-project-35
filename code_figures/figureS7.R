library(data.table)
library(ggplot2)
library(dplyr)

# Load data
d = fread("../qualitative_analysis/ELIXIR_BioHackathon_35FAIRX_Responses-Form_responses1.tsv")

fs7_plot = d[,19]

colnames(fs7_plot) = "Answers"
fs7_plot$n = 1

library(stringr)
fs7_plot$answers_pretty = str_split_fixed(fs7_plot$Answers, ',',2)[,1]
fs7_plot[fs7_plot$answers_pretty=="N/A", "answers_pretty"] ="Not important"

fs7_plot_sum = fs7_plot%>% group_by(answers_pretty) %>%
  summarise(count = sum(n))

fs7_plot_sum = arrange(fs7_plot_sum, count)
fs7_plot_sum$answers_pretty = factor(fs7_plot_sum$answers_pretty, levels = fs7_plot_sum$answers_pretty)
fs7_plot_sum$percent = fs7_plot_sum$count / sum(fs7_plot_sum$count) * 100

fs7 = ggplot(fs7_plot_sum, aes(y = answers_pretty, x = count))+
  geom_bar(stat = "identity",fill = "purple")+
  geom_text(aes( label = paste0(round(percent,2),"%"),
                 x= count+3 ))+
  ylab("")+
  xlab("# answers")+
  theme_minimal()+
  theme(axis.text = element_text(size = 14),
        axis.title = element_text(size = 20))

fs7
png("../figures/figureS7.png", width = 2000, height = 500, res = 150)
fs7
dev.off()
