library(data.table)
library(ggplot2)
library(dplyr)

# Load data
d = fread("../qualitative_analysis/ELIXIR_BioHackathon_35FAIRX_Responses-Form_responses1.tsv")

fs6_plot = as.data.frame(d[,2:11])
fs6_plot[fs6_plot==""] = NA
fs6_plot[fs6_plot=="N/A"] = NA
fs6_plot[fs6_plot=="Never (1)"] = 1
fs6_plot[fs6_plot=="Very Rarely (2)"] = 2
fs6_plot[fs6_plot=="Always (5)"] = 5
fs6_plot[fs6_plot=="Very Frequently (4)"] = 4
fs6_plot[fs6_plot=="Occasionally (3)"] = 3
fs6_plot =data.frame(lapply(fs6_plot ,as.numeric))
cm = colMeans(fs6_plot, na.rm=T)


data = data.frame(sex = c(5,1),
                  gender = c(5,1),
                  age = c(5,1),
                  ethnicity = c(5,1),
                  race = c(5,1))
data2 = rbind(cm[1:5], cm[6:10])
colnames(data2)= colnames(data)
rownames(data2) = c("developers", "researchers")

data = rbind(data, data2)

# Library
library(fmsb)


# Color vector
colors_border=c( rgb(0.2,0.5,0.5,0.9), rgb(0.8,0.2,0.5,0.9) , rgb(0.7,0.5,0.1,0.9) )
colors_in=c( rgb(0.2,0.5,0.5,0.4), rgb(0.8,0.2,0.5,0.4) , rgb(0.7,0.5,0.1,0.4) )


png("../figures/figureS6.png", width = 1200, height = 1000, res = 200)
# plot with default options:
radarchart( data  , axistype=1 , 
            #custom polygon
            pcol=colors_border , pfcol=colors_in , plwd=2 , plty=6,
            #custom the grid
            cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,5,1), cglwd=0.8,
            #custom labels
            vlcex=0.8 
)

# Add a legend
legend(x=0.7, y=1, legend = rownames(data[-c(1,2),]),
       bty = "n", pch=20 , col=colors_in , text.col = "grey20", cex=1.2, pt.cex=2)
dev.off()
