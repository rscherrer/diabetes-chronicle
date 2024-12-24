## This script computes the key parameters of the analysis and saves them
## in a table, one for each time threshold.

rm(list = ls())

library(tidyverse)

source("scripts/functions/Processing.R")
source("scripts/functions/Analysis.R")

# Read the data
data1 <- read_csv("data/chunks_1_5.csv")
data2 <- read_csv("data/chunks_2_0.csv")
data3 <- read_csv("data/chunks_3_0.csv")

# Compute the key parameters
pars1 <- compute_parameters(data1)
pars2 <- compute_parameters(data2)
pars3 <- compute_parameters(data3)

# Save
write_csv(pars1, "data/parameters_1_5.csv")
write_csv(pars2, "data/parameters_2_0.csv")
write_csv(pars3, "data/parameters_3_0.csv")
