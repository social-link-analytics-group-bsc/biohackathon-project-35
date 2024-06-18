library(tidyverse)
library(stringr)

summary <- read_csv("summary.csv", 
                    col_names = FALSE, skip = 1)


summary <- summary[2:8]
summary <- as.data.frame(summary)
summary[1] <- stringr::str_extract_all(summary[1], "phs\\d*.v\\d*.pht\\d*.v\\d*.p\\d*")

summary <- na.omit(summary)

summary <- summary %>% 
  select(-X6, -X5) %>% 
  mutate(X6 = X3+X4)

cols <- c("dbgap_study_id", "male", 
          "female", 
          "date_study", "repository", 
          "total")

colnames(summary) <- cols
#reorder columns
summary <- summary %>% 
  select("dbgap_study_id", "male", 
         "female", "total",
         "date_study", "repository")



write.csv(summary, "filtered_summary.csv")
