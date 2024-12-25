## This script computes the key parameters of the analysis and saves them
## in a table, one for each time threshold.

rm(list = ls())

library(tidyverse)

source("scripts/functions/Processing.R")
source("scripts/functions/Analysis.R")

# Read the data
data1 <- read_csv("data/chunks/chunks_1_5.csv")
data2 <- read_csv("data/chunks/chunks_2_0.csv")
data3 <- read_csv("data/chunks/chunks_3_0.csv")

# Compute the key parameters
pars1 <- compute_parameters(data1)
pars2 <- compute_parameters(data2)
pars3 <- compute_parameters(data3)

# Save
write_csv(pars1, "data/parameters/parameters_1_5.csv")
write_csv(pars2, "data/parameters/parameters_2_0.csv")
write_csv(pars3, "data/parameters/parameters_3_0.csv")

# Combine
pars <- tibble(
  Pars = list(pars1, pars2, pars3),
  Threshold = c(1.5, 2, 3)
)

# Unnest
pars <- pars %>% unnest(Pars)

# Rename columns
col_names <- colnames(pars)
col_names <- str_replace(col_names, "Beta", "$\\\\beta$")
col_names <- str_replace(col_names, "Alpha", "$\\\\alpha$")
col_names <- str_replace(col_names, "Threshold", "Threshold (hours)")

# Line separation
line_sep <- c("", "", "", "\\addlinespace")

# Make a LaTeX table
pars_tex <- kable(pars, format = "latex", linesep = line_sep, booktabs = TRUE, col.names = col_names, escape = FALSE, digits = c(0, 3, 3, 3, 3, 1))

# Save
cat(pars_tex, file = "tex/parameters.tex")
