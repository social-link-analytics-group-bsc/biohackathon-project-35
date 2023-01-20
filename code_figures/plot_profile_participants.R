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
png('../figures/sankeyplot_participants.png',
    width = 3000, height = 2000, res = 300)
sp
dev.off()


##########
# by gender
#########

df_she <- subset(d, pronouns=="She/her") %>%
  make_long(bh21_participant, continent,  age,work_experience, profession_summary, user_type)

# plot data
sp_she = ggplot(df_she, aes(x = x, 
                    next_x = next_x, 
                    node = node, 
                    next_node = next_node,
                    fill = factor(node),
                    label = node)) +
  geom_sankey(flow.alpha = 0.5, node.color = 1) +
  geom_sankey_label(size = 3.5, color = 1, fill = "white") +
  scale_fill_viridis_d() +
  theme_sankey(base_size = 16) +
  theme(legend.position = "none")

sp_she

df_him <- subset(d, pronouns=="He/him") %>%
  make_long(bh21_participant, continent,  age,work_experience, profession_summary, user_type)

# plot data
sp_him = ggplot(df_him, aes(x = x, 
                            next_x = next_x, 
                            node = node, 
                            next_node = next_node,
                            fill = factor(node),
                            label = node)) +
  geom_sankey(flow.alpha = 0.5, node.color = 1) +
  geom_sankey_label(size = 3.5, color = 1, fill = "white") +
  scale_fill_viridis_d() +
  theme_sankey(base_size = 16) +
  theme(legend.position = "none")

sp_him

library(cowplot)
png('/media/victoria/VICTORIA_EXTERNAL_DISK/BioHackathon2021/biohackathon-project-35_2/qualitative_analysis/sankeyplot_participants_bygender.png',
    width = 4000, height = 4000, res = 300)
plot_grid(sp_she, sp_him, ncol = 1, align = "v",labels = c("She/her", "He/him"))
dev.off()
# save plot



# put data in sankey format
d$work_experience = factor(d$work_experience , levels = c("< 1",   "1-5",     "6-10",  "11-15",">15" ))

ggplot(d, aes(x = work_experience, fill = question3))+
  geom_bar(stat="count", position ="dodge")

ggplot(d, aes(x = work_experience, fill = question5))+
  geom_bar(stat="count", position ="dodge")


table(d[, c("work_experience", "question3")])

df <- d %>%
  make_long(work_experience, question3)

# plot data
sp_q3 = ggplot(df, aes(x = x, 
                    next_x = next_x, 
                    node = node, 
                    next_node = next_node,
                    fill = factor(node),
                    label = node)) +
  geom_sankey(flow.alpha = 0.5, node.color = 1) +
  geom_sankey_label(size = 3.5, color = 1, fill = "white") +
  scale_fill_viridis_d() +
  theme_sankey(base_size = 16) +
  theme(legend.position = "none")

sp_q3

d$work_experience = factor(d$work_experience , levels = c("< 1",   "1-5",     "6-10",  "11-15",">15" ))
df <- d %>%
  make_long(question5,work_experience, question3)

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
  theme(legend.position = "none")

sp




# library(ggalluvial)
# is_alluvia_form(as.data.frame(d[,c(2,3,4,7,9)]), axes = 1:5, silent = TRUE)
# 
# library(reshape2)
# melt(d[,c(2,3,4,7,8,9)],id.vars = c("user_type"))
# d$Freq = 1
# ggplot(as.data.frame(d),
#        aes(y = Freq, axis1 = bh21_participant, axis2 = age, axis3 =work_experience ,axis4=profession_summary)) +
#   geom_alluvium(aes(fill = pronouns), width = 1/12) +
#   geom_stratum(width = 1/12, fill = "black", color = "grey") +
#   geom_label(stat = "stratum", aes(label = after_stat(stratum))) +
#  # scale_x_discrete(limits = c("Gender", "Dept"), expand = c(.05, .05)) +
#   #scale_fill_brewer(type = "qual", palette = "Set1") +
#   ggtitle("UC Berkeley admissions and rejections, by sex and department")
# 



