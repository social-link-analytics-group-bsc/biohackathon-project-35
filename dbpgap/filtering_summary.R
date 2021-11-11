library(tidyverse)
library(stringr)

summary <- read_csv("dbpgap/summary.csv", 
                    col_names = FALSE, skip = 1)


summary <- summary[2:8]
summary <- as.data.frame(summary)
summary[1] <- stringr::str_extract(summary[1], "phs.*")

summary <- na.omit(summary)

write.csv(summary, "filtered_summary.csv")
