## This script plots the data separated into strict categories of the
## confounding variables.

rm(list = ls())

library(tidyverse)
library(patchwork)
library(grid)

source("scripts/functions/Plotting.R")
source("scripts/functions/rm_axis.R")
source("scripts/functions/rm_strips.R")

# Read the data
data1 <- read_csv("data/chunks_1_5.csv")
data2 <- read_csv("data/chunks_2_0.csv")
data3 <- read_csv("data/chunks_3_0.csv")

# Make plots
plots <- map(list(data1, data2, data3), plot_all_binary, common_y = TRUE)

# Add titles
plots[[1]][[2]][[1]] <- plots[[1]][[2]][[1]] + ggtitle("Threshold = 1.5hr")
plots[[2]][[2]][[1]] <- plots[[2]][[2]][[1]] + ggtitle("Threshold = 2hr")
plots[[3]][[2]][[1]] <- plots[[3]][[2]][[1]] + ggtitle("Threshold = 3hr")

# Note: the second element of each patchwork is the actual plot, the first
# being the common y-axis. The first subplot is then the top one where we want
# the title to be.

# Remove clutter in legends
for (i in seq(plots[[1]][[2]])) plots[[1]][[2]][[i]] <- plots[[1]][[2]][[i]] + theme(legend.position = "none")
for (i in seq(plots[[2]][[2]])) plots[[2]][[2]][[i]] <- plots[[2]][[2]][[i]] + theme(legend.position = "none")

# Combine plots
P <- wrap_plots(plots, nrow = 1)

# Save
ggsave("plots/overview_binary.png", P, width = 15, height = 10, dpi = 300)
