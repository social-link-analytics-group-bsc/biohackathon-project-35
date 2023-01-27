library(data.table)
library(ggplot2)
library(dplyr)

# Load data
d = fread("../qualitative_analysis/ELIXIR_BioHackathon_35FAIRX_Responses-Form_responses1.tsv")

## plot figure 6
fs12_plot = d[,18]
colnames(fs12_plot) = "Answers"
fs12 = ggplot(fs12_plot, aes(x = Answers))+
  geom_histogram(fill = "purple",binwidth = 0.5)+
  geom_text(aes( label = scales::percent(..prop..),
                 y= ..count.. ), stat= "count", vjust = -.5)+
  xlab("Relevancy score")+
  ylab("# answers")+
  theme_minimal()+
  theme(#axis.text = element_text(size = 16),
        axis.title = element_text(size = 16))

png("../figures/figureS12.png", width = 1200, height = 800, res = 150)
fs12
dev.off()
