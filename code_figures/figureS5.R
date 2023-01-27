library(data.table)
library(ggplot2)
library(dplyr)

# Load data
d = fread("../qualitative_analysis/ELIXIR_BioHackathon_35FAIRX_Responses-Form_responses1.tsv")

fs5_plot = d[,24]
colnames(fs5_plot) = "Country"
fs5_plot$n = 1
fs5_plot_sum = fs5_plot %>% group_by(Country)%>%
  summarise(n = sum(n))

library(countrycode)
fs5_plot_sum$country_code = countrycode(my_countries, origin="country.name", destination ="genc2c")
fs5_plot_sum$country_code[1] = ""
fs5_plot_sum$Country = paste(fs5_plot_sum$Country, " (", fs5_plot_sum$country_code,")", sep="")
df2 <- fs5_plot_sum  %>% 
  mutate(csum = rev(cumsum(rev(n))), 
         pos = n/2 + lead(csum, 1),
         pos = if_else(is.na(pos), n/2, pos))


c = ggplot(fs5_plot_sum, aes(x="", y=n, fill=fct_inorder(Country))) +
  geom_col(width = 1, color = 1) +
  #geom_bar(stat="identity", width=1, color = "white") +
  #geom_text(aes(y = c(55), label =n), color = "white", size=6) +
  #geom_text(aes(y =..count..,label = Country))+
  coord_polar(theta = "y") +# coord_polar("y", start=0)+
#  scale_fill_brewer(palette = "Pastel1") +
  geom_label_repel(data = df2,
                   aes(y = pos, label = paste0(country_code," ",n)),
                   size = 4.5, nudge_x = 1, show.legend = FALSE) +
  guides(fill = guide_legend(title = "Country",ncol=2)) +
  theme_void()
c

png("../figures/figureS5.png", width = 1700, height = 900, res = 200)
c
dev.off()
