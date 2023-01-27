library(data.table)
library(ggplot2)
library(dplyr)

# Load data
d = fread("../qualitative_analysis/ELIXIR_BioHackathon_35FAIRX_Responses-Form_responses1.tsv")

## plot figure 6
f7_plot = d[,15]
colnames(f7_plot) = "Answers"
f7 = ggplot(f7_plot, aes(x = Answers))+
  geom_histogram(fill = "purple",binwidth = 0.5)+
  geom_text(aes( label = scales::percent(..prop..),
                 y= ..count.. ), stat= "count", vjust = -.5)+
  xlab("Relevancy score")+
  ylab("# answers")+
  theme_minimal()+
  theme(axis.text = element_text(size = 16),
        axis.title = element_text(size = 20))

png("../figures/figure7.png", width = 1500, height = 1000, res = 200)
f7
dev.off()

