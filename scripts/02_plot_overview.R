## This script plots the data according to various confounding variables.

rm(list = ls())

library(tidyverse)
library(patchwork)
library(grid)

source("scripts/functions/Plotting.R")
source("scripts/functions/rm_axis.R")
source("scripts/functions/rm_strips.R")

theme_set(theme_classic())

# Read data
data1 <- read_csv("data/chunks/chunks_1_5.csv")
data2 <- read_csv("data/chunks/chunks_2_0.csv")
data3 <- read_csv("data/chunks/chunks_3_0.csv")

# Combine
data <- tibble(Data = list(data1, data2, data3), Threshold = c(1.5, 2, 3))

# Unnest
data <- data %>% unnest(Data)

# Plot
P <- plot_all(data, common_y = TRUE)

# Function to add facets by time threshold to a plot
FACET <- function(plot) {
  
  # Create strip labels
  plot$data <- plot$data %>%
    mutate(ThresholdLab = str_c("Threshold = ", Threshold, "hr"))
  
  # Add facets to thes plot
  plot + facet_grid(. ~ ThresholdLab)
  
}

# Facet by time threshold
for (i in seq(P[[2]])) P[[2]][[i]] <- P[[2]][[i]] %>% FACET()
for (i in seq(P[[2]])[-1L]) P[[2]][[i]] <- P[[2]][[i]] + rm_strips("x")

# Note: the second element of the patchwork is the actual plot, the first is
# the common y-axis.

# Save
ggsave("plots/overview.png", P, width = 10, height = 10, dpi = 300)
