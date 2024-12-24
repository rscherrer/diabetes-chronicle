## This script takes the master database and summarizes all food, glycemia and
## insulin etc. events down to a per time-chunk basis.

rm(list = ls())

library(tidyverse)
library(lubridate)

source("scripts/functions/Processing.R")

# Read the master database
data <- read_csv("data/diabetes_2024.csv")

# Create data sets with various chunk stability thresholds
d1 <- create_dataset(data, threshold = 1.5)
d2 <- create_dataset(data, threshold = 2)
d3 <- create_dataset(data, threshold = 3)

# Save
write_csv(d1, "data/chunks/chunks_1_5.csv")
write_csv(d2, "data/chunks/chunks_2_0.csv")
write_csv(d3, "data/chunks/chunks_3_0.csv")