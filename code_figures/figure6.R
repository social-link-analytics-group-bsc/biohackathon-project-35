library(data.table)
library(ggplot2)
library(ggsankey)
library(dplyr)

# Load data
d = fread("responses_survey_profile_participants.tsv")

# put data in sankey format
d$work_experience = factor(d$work_experience , levels = c("< 1",   "1-5",     "6-10",  "11-15",">15" ))
d$pronouns[d$pronouns == "Do not subscribe to the belief system underlying this question"] = "*"
df <- d %>%
  make_long(bh21_participant, continent, pronouns, age,work_experience, profession_summary)

# plot data
sp = ggplot(df, aes(x = x, 
                    next_x = next_x, 
                    node = node, 
                    next_node = next_node,
                    fill = factor(node),
                    label = node)) +
  geom_sankey(flow.alpha = 0.5, node.color = 1) +
  geom_sankey_label(size = 3.5, color = 1, fill = "white") +
  scale_fill_viridis_d() +
  theme_sankey(base_size = 16) +
  theme(legend.position = "none")+
  xlab("")+
  scale_x_discrete(labels=c("bh21_participant"="BH21 participant",
                            "continent"="Continent",
                            "pronouns"="Pronouns",
                            "age"="Age",
                            "work_experience"="Work exp.",
                            "profession_summary"="Profession"))

sp

# save plot
png('../figures/figure6.png',
    width = 3000, height = 2000, res = 300)
sp
dev.off()


##########
# by gender
#########

# df_she <- subset(d, pronouns=="She/her") %>%
#   make_long(bh21_participant, continent,  age,work_experience, profession_summary, user_type)
# 
# # plot data
# sp_she = ggplot(df_she, aes(x = x, 
#                     next_x = next_x, 
#                     node = node, 
#                     next_node = next_node,
#                     fill = factor(node),
#                     label = node)) +
#   geom_sankey(flow.alpha = 0.5, node.color = 1) +
#   geom_sankey_label(size = 3.5, color = 1, fill = "white") +
#   scale_fill_viridis_d() +
#   theme_sankey(base_size = 16) +
#   theme(legend.position = "none")
# 
# sp_she
# 
# df_him <- subset(d, pronouns=="He/him") %>%
#   make_long(bh21_participant, continent,  age,work_experience, profession_summary, user_type)
# 
# # plot data
# sp_him = ggplot(df_him, aes(x = x, 
#                             next_x = next_x, 
#                             node = node, 
#                             next_node = next_node,
#                             fill = factor(node),
#                             label = node)) +
#   geom_sankey(flow.alpha = 0.5, node.color = 1) +
#   geom_sankey_label(size = 3.5, color = 1, fill = "white") +
#   scale_fill_viridis_d() +
#   theme_sankey(base_size = 16) +
#   theme(legend.position = "none")
# 
# sp_him
# 
# library(cowplot)
# png('../figures/figure6.png',
#     width = 4000, height = 4000, res = 300)
# plot_grid(sp_she, sp_him, ncol = 1, align = "v",labels = c("She/her", "He/him"))
# dev.off()
# # save plot
# 
# 
# 
# # put data in sankey format
# d$work_experience = factor(d$work_experience , levels = c("< 1",   "1-5",     "6-10",  "11-15",">15" ))
# 
# ggplot(d, aes(x = work_experience, fill = question3))+
#   geom_bar(stat="count", position ="dodge")
# 
# ggplot(d, aes(x = work_experience, fill = question5))+
#   geom_bar(stat="count", position ="dodge")
# 
# 
# table(d[, c("work_experience", "question3")])
# 
# df <- d %>%
#   make_long(work_experience, question3)
# 
# # plot data
# sp_q3 = ggplot(df, aes(x = x, 
#                     next_x = next_x, 
#                     node = node, 
#                     next_node = next_node,
#                     fill = factor(node),
#                     label = node)) +
#   geom_sankey(flow.alpha = 0.5, node.color = 1) +
#   geom_sankey_label(size = 3.5, color = 1, fill = "white") +
#   scale_fill_viridis_d() +
#   theme_sankey(base_size = 16) +
#   theme(legend.position = "none")
# 
# sp_q3
# 
# d$work_experience = factor(d$work_experience , levels = c("< 1",   "1-5",     "6-10",  "11-15",">15" ))
# df <- d %>%
#   make_long(question5,work_experience, question3)
# 
# # plot data
# sp = ggplot(df, aes(x = x, 
#                     next_x = next_x, 
#                     node = node, 
#                     next_node = next_node,
#                     fill = factor(node),
#                     label = node)) +
#   geom_sankey(flow.alpha = 0.5, node.color = 1) +
#   geom_sankey_label(size = 3.5, color = 1, fill = "white") +
#   scale_fill_viridis_d() +
#   theme_sankey(base_size = 16) +
#   theme(legend.position = "none")
# 
# sp
# 
