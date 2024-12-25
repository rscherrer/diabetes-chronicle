## This script pre-analyzes the data by comparing different levels of depth
## of the linear models applied, to see to which level of parameterization
## we can go and still estimate reliable ratios.

rm(list = ls())

library(tidyverse)
library(patchwork)

source("scripts/functions/Plotting.R")
source("scripts/functions/Processing.R")

theme_set(theme_classic())

# Read the data
data1 <- read_csv("data/chunks/chunks_1_5.csv")
data2 <- read_csv("data/chunks/chunks_2_0.csv")
data3 <- read_csv("data/chunks/chunks_3_0.csv")

# Function to perform the pre-analysis
FUN <- function(data) {
  
  # Filter out what we do not want in our analyses
  data <- filter_dataset(data)
  
  # Note: based on first principles I choose to treat activity, alcohol and sickness
  # as independent covariates. Plus, there does not seem to be enough data points
  # for each combination of those factors to warrant including their interactions.
  
  # Contingency table
  counts <- data %>% group_by(Activity, Alcohol, Sick) %>% summarize(Number = n())
  
  # Plot separate regressions
  plot1 <- plot_separate_regressions(data)
  
  # Plot global regression (all terms included)
  plot2 <- plot_global_regression(data)
  
  # Output
  out <- list(counts = counts, plot1 = plot1, plot2 = plot2)
  
  return(out)
  
}

# Perform the pre-analysis
out1 <- data1 %>% FUN()
out2 <- data2 %>% FUN()
out3 <- data3 %>% FUN()

# Eyeball the contingency tables
out1$counts
out2$counts
out3$counts

# Note: they are very uneven, which motivates avoiding interaction terms.

# Save separate regressions
ggsave("plots/separate_regressions/separate_regressions_1_5.png", out1$plot1, width = 7, height = 6, dpi = 300)
ggsave("plots/separate_regressions/separate_regressions_2_0.png", out2$plot1, width = 7, height = 6, dpi = 300)
ggsave("plots/separate_regressions/separate_regressions_3_0.png", out3$plot1, width = 7, height = 6, dpi = 300)

# Save global regressionss
ggsave("plots/global_regressions/global_regression_1_5.png", out1$plot2, width = 6, height = 7, dpi = 300)
ggsave("plots/global_regressions/global_regression_2_0.png", out2$plot2, width = 6, height = 7, dpi = 300)
ggsave("plots/global_regressions/global_regression_3_0.png", out3$plot2, width = 6, height = 7, dpi = 300)
